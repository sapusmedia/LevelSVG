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


#import <Box2D/Box2D.h>

#import "BodyNode.h"
#import "GameConstants.h"
#import "GameNode.h"

@implementation BodyNode

@synthesize body = body_;
@synthesize reportContacts=reportContacts_;
@synthesize isTouchable=isTouchable_;
@synthesize preferredParent=preferredParent_;
@synthesize properties=properties_;

-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super init]) ) {

		reportContacts_ = BN_CONTACT_NONE;
		body_ = body;
		isTouchable_ = NO;
		body->SetUserData(self);
		
		game_ = game;
		
		preferredParent_ = BN_PREFERRED_PARENT_IGNORE;
		
		properties_ = BN_PROPERTY_SPRITE_UPDATED_BY_PHYSICS;
		
		// Position the sprite
		b2Vec2 bPos = body->GetPosition();
		self.position = ccp( bPos.x * kPhysicsPTMRatio, bPos.y * kPhysicsPTMRatio );
	}
	return self;
}
-(void) dealloc
{
	CCLOGINFO(@"LevelSVG: deallocing %@", self);
	
	[super dealloc];
}

#pragma mark BodyNode - Parameters
-(void) setParameters:(NSDictionary *)params
{
	// override me
}

// box2d contact protocol
#pragma mark BodyNode - Contact protocol

-(void) beginContact:(b2Contact*) contact
{
	// override me
}
-(void) endContact:(b2Contact*) contact
{
	// override me
}
-(void) preSolveContact:(b2Contact*)contact  manifold:(const b2Manifold*) oldManifold
{
	// override me
}
-(void) postSolveContact:(b2Contact*)contact impulse:(const b2ContactImpulse*) impulse
{
	// override me
}

// helper functions
-(void) destroyAllFixturesFromBody:(b2Body*)body
{
	b2Fixture *fixture = body->GetFixtureList();
	while( fixture != nil ) {
		b2Fixture *tmp = fixture;
		fixture = fixture->GetNext();
		body->DestroyFixture(tmp);
	}
}
@end
