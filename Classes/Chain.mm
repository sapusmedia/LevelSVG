//
//  Chain.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 8/9/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "Chain.h"
#import "GameNode.h"


@implementation Chain
-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game] ) ) {
	
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"chain_ball.png"];
		[self setDisplayFrame:frame];
		
		// destroy previously created fixtures
		[self destroyAllFixturesFromBody:body];
		
		b2World *world = [game world];
		
		b2PolygonShape polyShape;
		// pixels: 
		polyShape.SetAsBox(10 /kPhysicsPTMRatio, 3 / kPhysicsPTMRatio);
		
		b2FixtureDef fd;
		fd.shape = &polyShape;
		fd.density = 20.0f;
		fd.friction = 0.2f;
		
		b2RevoluteJointDef jd;
		jd.collideConnected = false;

		// obtain initial position
		b2Vec2 pos = body->GetPosition();

		//
		// Roof. Chain attach point
		//
		b2BodyDef bd;
		bd.position = pos;
		b2Body *roof = world->CreateBody(&bd);
		
		b2Body* prevBody = roof;
		
		//
		// Create links
		// Chain based on sample that comes with Box2d distribution
		//
		const int numberOfLinks = 8;
		for (int32 i = 0; i < numberOfLinks; ++i)
		{
			b2BodyDef bd;
			bd.type = b2_dynamicBody;
			bd.position.Set(pos.x + (i+1)*0.4f, pos.y);
			b2Body* newBody = world->CreateBody(&bd);
			newBody->CreateFixture(&fd);
			
			b2Vec2 anchor( pos.x + i*0.4f + 0.2f, pos.y);
			jd.Initialize(prevBody, newBody, anchor);
			world->CreateJoint(&jd);
			
			prevBody = newBody;
			
			BodyNode *bodyNode = [[BodyNode alloc] initWithBody:newBody game:game];
			bodyNode.preferredParent = BN_PREFERRED_PARENT_SPRITES_PNG;
			
			frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"chain.png"];
			[bodyNode setDisplayFrame:frame];

			[game addBodyNode:bodyNode z:0];
			[bodyNode release];
			newBody->SetUserData(bodyNode);	
		}
		
		//
		// Create big ball
		//
		b2CircleShape	circleShape;
		circleShape.m_radius = 10 / kPhysicsPTMRatio; // radius of 10 pixels
		fd.shape = &circleShape;
		fd.density = 20;
		fd.friction = 0.2f;
		body->CreateFixture(&fd);
		body->SetTransform( b2Vec2( pos.x + (numberOfLinks+1) * 0.4f, pos.y), 0 );
		body->SetType(b2_dynamicBody);
		
		b2Vec2 anchor( pos.x + numberOfLinks*0.4f + 0.2f, pos.y);
		jd.Initialize(prevBody, body, anchor);
		world->CreateJoint(&jd);
		
		
	}
	
	return self;
}
@end
