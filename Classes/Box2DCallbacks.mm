//
//  Box2DCallbacks.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 12/08/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//

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
