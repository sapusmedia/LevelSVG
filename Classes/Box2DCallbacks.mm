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

#import "Box2DCallbacks.h"
#import "BodyNode.h"

#pragma mark -
#pragma mark Contact Listener

void MyContactListener::BeginContact(b2Contact* contact)
{
	b2Fixture *fA = contact->GetFixtureA();
	b2Fixture *fB = contact->GetFixtureB();
	b2Body *bA = fA->GetBody();
	b2Body *bB = fB->GetBody();
	BodyNode *data1 = (BodyNode*) bA->GetUserData();
	BodyNode *data2 = (BodyNode*) bB->GetUserData();
	if( data1 && data1.reportContacts & BN_CONTACT_BEGIN )
		[data1 beginContact:contact];
	if( data2 && data2.reportContacts & BN_CONTACT_BEGIN )
		[data2 beginContact:contact];
}

void MyContactListener::EndContact(b2Contact* contact)
{
	b2Fixture *fA = contact->GetFixtureA();
	b2Fixture *fB = contact->GetFixtureB();
	b2Body *bA = fA->GetBody();
	b2Body *bB = fB->GetBody();
	BodyNode *data1 = (BodyNode*) bA->GetUserData();
	BodyNode *data2 = (BodyNode*) bB->GetUserData();
	if( data1 && data1.reportContacts & BN_CONTACT_END )
		[data1 endContact:contact];
	if( data2 && data2.reportContacts & BN_CONTACT_END )
		[data2 endContact:contact];	
}

void MyContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
	b2Fixture *fA = contact->GetFixtureA();
	b2Fixture *fB = contact->GetFixtureB();
	b2Body *bA = fA->GetBody();
	b2Body *bB = fB->GetBody();
	BodyNode *data1 = (BodyNode*) bA->GetUserData();
	BodyNode *data2 = (BodyNode*) bB->GetUserData();
	if( data1 && data1.reportContacts & BN_CONTACT_PRESOLVE )
		[data1 preSolveContact:contact manifold:oldManifold];
	if( data2 && data2.reportContacts & BN_CONTACT_PRESOLVE )
		[data2 preSolveContact:contact manifold:oldManifold];
}

void MyContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
	b2Fixture *fA = contact->GetFixtureA();
	b2Fixture *fB = contact->GetFixtureB();
	b2Body *bA = fA->GetBody();
	b2Body *bB = fB->GetBody();
	BodyNode *data1 = (BodyNode*) bA->GetUserData();
	BodyNode *data2 = (BodyNode*) bB->GetUserData();
	if( data1 && data1.reportContacts & BN_CONTACT_POSTSOLVE )
		[data1 postSolveContact:contact impulse:impulse];
	if( data2 && data2.reportContacts & BN_CONTACT_POSTSOLVE )
		[data2 postSolveContact:contact impulse:impulse];
}

#pragma mark -
#pragma mark Contact Filter

bool MyContactFilter::ShouldCollide(b2Fixture* fixtureA, b2Fixture* fixtureB)
{
	return true;
}
		
bool MyContactFilter::RayCollide(void* userData, b2Fixture* fixture)
{
	return true;
}

#pragma mark -
#pragma mark Destruction Listener

void MyDestructionListener::SayGoodbye(b2Joint* joint)
{
}

void MyDestructionListener::SayGoodbye(b2Fixture* fixture)
{
}
