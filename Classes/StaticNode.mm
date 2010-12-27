//
//  KinematicNode.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 05/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameNode.h"
#import "GameConstants.h"
#import "StaticNode.h"

//
// StaticNode: subclass this class if you want to move box2d objects manually (eg: using cocos2d actions)
//

@implementation StaticNode
-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game]) ) {
		//
		// TIP:
		// Tell the engine not to update the sprite. It will be updated manually
		//
		properties_ = properties_ & ~BN_PROPERTY_SPRITE_UPDATED_BY_PHYSICS;
		
		//
		// TIP: Static bodies won't collide with static and kinematic bodies
		//
		body->SetType(b2_staticBody);
		
	}
	return self;
}

-(void) setPosition:(CGPoint)position
{
	[super setPosition:position];
	body_->SetTransform( b2Vec2( position_.x / kPhysicsPTMRatio, position_.y / kPhysicsPTMRatio),  - CC_DEGREES_TO_RADIANS(rotation_) );
}

-(void) setRotation:(float)angle
{
	[super setRotation:angle];
	body_->SetTransform( b2Vec2( position_.x / kPhysicsPTMRatio, position_.y / kPhysicsPTMRatio),  - CC_DEGREES_TO_RADIANS(rotation_) );
}
@end
