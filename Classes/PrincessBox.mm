//
//  PrincessBox.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 24/03/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameNode.h"
#import "GameConstants.h"
#import "PrincessBox.h"

#define SPRITE_WIDTH 20
#define SPRITE_HEIGHT 44

@implementation Princessbox
-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game] ) ) {
			
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"sapus_girl_01.png"];
		[self setDisplayFrame:frame];
			
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		isTouchable_ = NO;
		
		// 1. destroy already created fixtures
		[self destroyAllFixturesFromBody:body];
		
		// 2. create new fixture
		b2FixtureDef	fd;
		
		b2PolygonShape shape;
		
		// Sprite size is SPRITE_WIDTH x SPRITE_HEIGHT
		float height = (SPRITE_HEIGHT / kPhysicsPTMRatio) / 2;
		float width = (SPRITE_WIDTH/ kPhysicsPTMRatio) / 2;
		
		// vertices should be in Counter Clock-Wise order, orderwise it will crash
		b2Vec2 vertices[4];
		vertices[0].Set(-width,-height);	// bottom-left
		vertices[1].Set(width,-height);		// bottom-right
		vertices[2].Set(width,height);		// top-right
		vertices[3].Set(-width,height);		// top-left
		shape.Set(vertices, 4);
		
		// TIP: friction should be 0 to avoid sticking into walls
		fd.friction		= 0.0f;
		fd.density		= 1.0f;
		fd.restitution	= 0.0f;
		
		
		// TIP: fixed rotation. The hero can't rotate. Very useful for Super Mario like games
		body->SetFixedRotation(true);
		
		fd.shape = &shape;
		body->CreateFixture(&fd);
		body->SetType(b2_dynamicBody);
		body->SetUserData( self );
		
		//
		// Animate the Princess
		//
		CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
		CCSpriteFrame *frame1 = [cache spriteFrameByName:@"sapus_girl_01.png"];
		CCSpriteFrame *frame2 = [cache spriteFrameByName:@"sapus_girl_02.png"];
		CCSpriteFrame *frame3 = [cache spriteFrameByName:@"sapus_girl_03.png"];
		NSArray *frames = [NSArray arrayWithObjects:frame1, frame2, frame3, nil];
		CCAnimation *animation = [CCAnimation animationWithFrames:frames];
		
		CCAnimate *animate = [CCAnimate actionWithDuration:1 animation:animation restoreOriginalFrame:NO];
		[self runAction:[CCRepeatForever actionWithAction:animate]];
	}
	return self;
}
@end