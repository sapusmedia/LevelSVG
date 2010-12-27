//
//  Portal.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 06/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

#import "GameNode.h"
#import "GameConstants.h"
#import "Portal.h"
#import "Hero.h"


//
// Portal: a sensor that teleport the hero from 1 point to another
//
//
// Supported parameters:
//	moveToX (float): The horizontal destination of the hero when touches the portal. In pixels.
//	moveToY (float): The vertical destination of the hero when touches the portal. In pixels.
//

@implementation Portal

@synthesize teleportTo=teleportTo_;

-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game]) ) {

		//
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		isTouchable_ = NO;

		// Update fixture
		[self destroyAllFixturesFromBody:body];
		
		b2CircleShape	shape;
		shape.m_radius = 0.25f;		// 0.5 meter of diameter
		b2FixtureDef	fd;
		fd.shape = &shape;
		fd.isSensor = true;			// it is a sensor
		body->CreateFixture(&fd);
		
		// Set new frame
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"portal.png"];
		[self setDisplayFrame:frame];
		
		// default teleport to
		teleportTo_ = CGPointZero;
		
		// rotate portal
		id rot = [CCRotateBy actionWithDuration:2 angle:360];
		id forEver = [CCRepeatForever actionWithAction:rot];
		[self runAction:forEver];
	}
	return self;
}

-(void) setParameters:(NSDictionary *)params
{
	[super setParameters:params];

	float x = [[params objectForKey:@"moveToX"] floatValue];
	float y = [[params objectForKey:@"moveToY"] floatValue];

	teleportTo_ = CGPointMake(x,y);
}

-(void) touchedByHero
{
	[[SimpleAudioEngine sharedEngine] playEffect: @"teleport.wav"];
	[[game_ hero] teleportTo: teleportTo_];
}

// Rotation is created with a cocos2d action
-(void) setRotation:(float)angle
{
	[super setRotation:angle];
	b2Vec2 pos = body_->GetPosition();
	body_->SetTransform( pos,  - CC_DEGREES_TO_RADIANS(rotation_) );
}

@end
