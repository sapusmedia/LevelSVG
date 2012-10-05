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
#import "Spinner.h"
#import "GameNode.h"


@implementation Spinner
-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game] ) ) {
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		isTouchable_ = YES;
		
		// set display frame
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spinner.png"];
		[self setDisplayFrame:frame];
		
		// 0. Calculate height, width
		
		// default radius
		float radius = 1.0f;
		
		b2Fixture *fixture = body->GetFixtureList();
		b2Shape::Type t = fixture->GetType();
		
		if( t ==  b2Shape::e_circle ) {
			b2CircleShape *circle = dynamic_cast<b2CircleShape*>(fixture->GetShape());
			radius = circle->m_radius;
		} else {
			CCLOG(@"LevelSVG: Spinner should be a circle!");
		}
		
		CGSize texSize = [self contentSize];
		float pixels = radius * kPhysicsPTMRatio * 2;
		self.scale = pixels / texSize.width;
	
		// ratio between height and width: 30/130
		float width = radius * (30.0f/130.0f);
	
		// 1. destroy already created fixtures
		[self destroyAllFixturesFromBody:body];
		
		// 2. create 2 boxes
		b2FixtureDef	fd;
		fd.density = 20;
		fd.restitution = 0.2f;
		fd.friction = 0.3f;
		b2PolygonShape	shape;
		fd.shape = &shape;
		shape.SetAsBox(radius,width);
		body->CreateFixture(&fd);
		shape.SetAsBox(width, radius);
		body->CreateFixture(&fd);
		body->SetType(b2_dynamicBody);
		
		// 3. create an static body
		b2BodyDef bodyDef;
		b2World *world = [game world];
		b2Body *static_body = world->CreateBody(&bodyDef);
		
		// 4. create the revolute joint with the 2 bodies
		b2RevoluteJointDef jointDef;
		jointDef.Initialize(static_body,body,body->GetWorldCenter());
		//	jointDef.enableMotor = true;
		//	jointDef.motorSpeed = 1.5f;
		jointDef.maxMotorTorque = 1000 * body->GetMass();												
		world->CreateJoint(&jointDef);		
	}
	
	return self;
}
@end
