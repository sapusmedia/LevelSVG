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
#import "SimpleAudioEngine.h"

#import "GameNode.h"
#import "GameConstants.h"
#import "Enemy.h"

//
// Enemy: An rounded enemy that is capable of killing the hero
//
// Supported parameters:
//	patrolTime (float): the time it takes to go from left to right. Default: 0 (no movement)
//  patrolSpeed (float): the speed of the patrol (the speed is in Box2d units). Default: 2
//

@implementation Enemy
-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game]) ) {
	
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"sprite_enemy_01.png"];
		[self setDisplayFrame:frame];

		// bodyNode properties
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		isTouchable_ = YES;
		
		// 1. destroy already created fixtures
		[self destroyAllFixturesFromBody:body];
		
		// 2. create new fixture
		b2FixtureDef	fd;
		b2CircleShape	shape;
		shape.m_radius = 0.5f;		// 1 meter of diameter (optimized size)
		fd.friction		= kPhysicsDefaultEnemyFriction;
		fd.density		= kPhysicsDefaultEnemyDensity;
		fd.restitution	= kPhysicsDefaultEnemyRestitution;
		fd.shape = &shape;
		
		// filtering... in case you want to avoid collisions between enemies
//		fd.filter.groupIndex = - kCollisionFilterGroupIndexEnemy;
		
		body->CreateFixture(&fd);
		body->SetType(b2_dynamicBody);	
		
		patrolActivated_ = NO;
		
		[self schedule:@selector(update:)];
	}
	return self;
}

-(void) setParameters:(NSDictionary *)params
{
	[super setParameters:params];

	NSString *patrolTime = [params objectForKey:@"patrolTime"];
	NSString *patrolSpeed = [params objectForKey:@"patrolSpeed"];
	
	if( patrolTime ) {
		patrolTime_ = [patrolTime floatValue];
		
		patrolSpeed_ = 2; // default value
		if( patrolSpeed )
			patrolSpeed_ = [patrolSpeed floatValue];

		patrolActivated_ = YES;
	}
}

-(void) update:(ccTime)dt
{
	//
	// move the enemy if "patrol" is activated
	// In this example the enemy is moved using Box2d, and not cocos2d actions.
	//
	if( patrolActivated_ ) {
		patrolDT_ += dt;
		if( patrolDT_ >= patrolTime_ ) {
			patrolDT_ = 0;
			
			// This line eliminates the inertia
			body_->SetAngularVelocity(0);
			
			// Change the direction of the movement
			if( patrolDirectionLeft_ ) {
				body_->SetLinearVelocity( b2Vec2(-patrolSpeed_,0) );
			} else {
				body_->SetLinearVelocity( b2Vec2(patrolSpeed_,0) );
			}
			patrolDirectionLeft_ = ! patrolDirectionLeft_;
		}
	}	
}
-(void) touchedByBullet:(id)bullet
{
	[game_ removeB2Body:body_];
	[[SimpleAudioEngine sharedEngine] playEffect: @"enemy_killed.wav"];
	[game_ increaseScore:10];

}

@end