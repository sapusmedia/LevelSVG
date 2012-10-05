/*
 * Copyright (c) 2009-2011 Ricardo Quesada
 * Copyright (c) 2011-2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameConstants.h"
#import "Movingplatform.h"
#import "GameNode.h"

//
// MovingPlatform: A Kinematic platfroms that uses cocos2d actions instead of box2d forces
//
// Supported parameters:
//	direction (string): "horizontal" is an horizontal movement. Else it will be a vertical movement
//  duration (float): the duration of the movement
//  translation (float): how many pixels does the platform move
//

@implementation Movingplatform


-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game]) ) {
		
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"solid_platform.png"];
		[self setDisplayFrame:frame];
		
		// bodyNode properties
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_PLATFORMS_PNG;
		
		isTouchable_ = NO;
		
		// Platforms are kinematic
		body->SetType(b2_kinematicBody);
		
		// boxes (platforms) needs a 0,1 anchor point
		[self setAnchorPoint:ccp(0,1)];
		
		origPosition_ = body->GetPosition();
				
		CGSize size = CGSizeZero;
		
		b2Fixture *fixture = body->GetFixtureList();
				
		b2Shape::Type t = fixture->GetType();
				
		if( t == b2Shape::e_polygon ) {
			b2PolygonShape *box = dynamic_cast<b2PolygonShape*>(fixture->GetShape());
			if( box->GetVertexCount() == 4 ) {
				size.width = box->GetVertex(2).x * kPhysicsPTMRatio;
				size.height = -box->GetVertex(0).y * kPhysicsPTMRatio;
				
				[self setTextureRect:CGRectMake(rect_.origin.x, rect_.origin.y, size.width, size.height)];				 
				
			} else
				CCLOG(@"LevelSVG: Movingplatform with unsupported number of vertices: %d", box->GetVertexCount() );
		} else
			CCLOG(@"LevelSVG: Movingplatform with unsupported shape type");
				
	}
	return self;
}

-(void) setParameters:(NSDictionary*)dict
{
	[super setParameters:dict];

	NSString *dir = [dict objectForKey:@"direction"];
	if( [dir isEqualToString:@"horizontal"] )
		direction_ = kPlatformDirectionHorizontal;
	else 
		direction_ = kPlatformDirectionVertical;
	
	// default duration
	duration_ = (direction_ == kPlatformDirectionHorizontal ? 4 : 1.5f);
	
	// default translation
	translationInPixels_ = (direction_ == kPlatformDirectionHorizontal ? 250 : 150);

	NSString *dur = [dict objectForKey:@"duration"];
	if( dur )
		duration_ = [dur floatValue];

	NSString *trans = [dict objectForKey:@"translation"];
	if( trans )
		translationInPixels_ = [trans floatValue];
	
	// Move the plaform using actions
//	[self runAction: [self getAction]];
}

//
// Needed when the platform is updated using SetLinearVelocity()
//
-(void) onEnterTransitionDidFinish
{	
	[super onEnterTransitionDidFinish];
	goingForward_ = YES;
	
	float vel = (translationInPixels_ / duration_) /kPhysicsPTMRatio;

	if( direction_ == kPlatformDirectionHorizontal ) {
		velocity_ = b2Vec2( vel, 0 );
		finalPosition_ = origPosition_ + b2Vec2(translationInPixels_/kPhysicsPTMRatio, 0);
	}
	else {
		velocity_ = b2Vec2( 0, vel );
		finalPosition_ = origPosition_ + b2Vec2(0, translationInPixels_/kPhysicsPTMRatio);
	}
	
	body_->SetLinearVelocity( velocity_ );
	
	[self schedule: @selector(updatePlatform:) interval:duration_];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameStateChanged:) name:kGameChangedStateNotification object:nil];
}

- (void)onExit {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gameStateChanged:(NSNotification *)notification {
	if (game_.gameState == kGameStatePaused) {
		currentPosition_ = body_->GetPosition();
		[self unschedule:@selector(updatePlatform:)];
		wasPaused_ = YES;
	} else {
		if (wasPaused_) {
			// trigger the next schedule based on the current position,
			// direction, velocity and final (or orig) position
			// v = d/t; t = d/v;
			b2Vec2 targetPoint = (goingForward_) ? finalPosition_ : origPosition_;
			float distanceToTarget = (direction_ == kPlatformDirectionHorizontal) ? fabsf(currentPosition_.x - targetPoint.x) : fabsf(currentPosition_.y - targetPoint.y);
			float t = distanceToTarget / (direction_ == kPlatformDirectionHorizontal ? velocity_.x : velocity_.y);
			[self schedule:@selector(updatePlatform:) interval:t];
		}
	}
}

//
// Platform is being moved by SetLinearVelocity()
//
-(void) updatePlatform:(ccTime)dt
{
	if( goingForward_ ) {
		body_->SetTransform( finalPosition_, 0 );
		body_->SetLinearVelocity( -velocity_ );
		goingForward_ = NO;
	} else {
		body_->SetTransform( origPosition_, 0 );
		body_->SetLinearVelocity( velocity_ );
		goingForward_ = YES;
	}
	// if we were paused, then unschedule the selector and reschedule it with
	// the right duration
	if (wasPaused_) {
		[self unschedule:@selector(updatePlatform:)];
		[self schedule:@selector(updatePlatform:) interval:duration_];
		wasPaused_ = NO;
	}
}

//-(CCAction*) getAction
//{	
//	
//	id forward;
//	if( direction == kPlatformDirectionHorizontal)
//		// Horizontal Movement
//		forward = [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(translation,0)] rate:3];
//	else 
//		// Vertical Movement
//		forward = [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(0,translation)] rate:3];
//		
//	
//	id back = [forward reverse];
//	id seq = [CCSequence actions:forward, back, nil];
//	return [CCRepeatForever actionWithAction:seq];
//}

@end
