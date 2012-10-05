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
