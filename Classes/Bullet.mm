//
//  Bullet.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 05/05/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "Bullet.h"
#import "GameNode.h"
#import "GameConstants.h"
#import "SimpleAudioEngine.h"
#import "BodyNode.h"

#define BULLET_LIFE_SECONDS (2)
#define FIRE_VELOCITY (7)

//
// Bullet can't be created from SVG.
// It is an special node that is created when the "fire" button is pressed,
// and the position and direction depends on the Hero's position & direction.
//

@implementation Bullet
-(id) initWithPosition:(b2Vec2)position direction:(int)direction game:(GameNode*)game
{	
	b2CircleShape shape;
	
	shape.m_radius = 7/kPhysicsPTMRatio; // 14 pixels wide
	
	b2FixtureDef fd;
	fd.shape = &shape;
	fd.density = 20.0f;
	fd.restitution = 0.05f;
	fd.filter.groupIndex = -kCollisionFilterGroupIndexHero; // bullets should never collide with the hero
	
	b2BodyDef bd;
	bd.type = b2_dynamicBody;
	bd.bullet = true;
	bd.position = position;
	
	// weak reference
	world_ = [game world];
	
	b2Body *body = world_->CreateBody(&bd);
	body->CreateFixture(&fd);
	
	if( (self=[super initWithBody:body game:game] ) ) {
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bullet.png"];
		[self setDisplayFrame:frame];
		
		reportContacts_ = BN_CONTACT_BEGIN;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		isTouchable_ = NO;
		
		elapsedTime_ = 0;
		
		float velX = FIRE_VELOCITY;
		if( direction < 0 )
			velX = -velX;
		
		body->SetLinearVelocity(b2Vec2(velX, 0.0f));
		
		[[SimpleAudioEngine sharedEngine] playEffect: @"shoot.wav"];
		
		// TIP:
		// This update should be called before the box2d main loop,
		// otherwise the gravities won't be cancelled
		[self scheduleUpdateWithPriority:-10];
		
	}
	return self;
}

-(void) update:(ccTime)dt
{
	// anti-gravity force
	b2Vec2 gravity = world_->GetGravity();
	b2Vec2 p = body_->GetLocalCenter();
	body_->ApplyForce( -body_->GetMass()*gravity, p );
	
	elapsedTime_ += dt;
	if( elapsedTime_ > BULLET_LIFE_SECONDS )
		[game_ removeB2Body:body_];

	
}

-(void) beginContact:(b2Contact*)contact
{
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	NSAssert( fixtureA != fixtureB, @"Bullet: Box2d bug");
	
	b2Body *bodyA = fixtureA->GetBody();
	b2Body *bodyB = fixtureB->GetBody();
	
	NSAssert( bodyA != bodyB, @"Bullet: Box2d bug");
	
	// Box2d doesn't guarantees the order of the fixtures
	b2Body *otherBody = (bodyA == body_) ? bodyB : bodyA;
	b2Fixture *otherFixture = (bodyA == body_) ? fixtureB : fixtureA;
	
	// ignore sensonrs
	if( ! otherFixture->IsSensor() ) {

		BodyNode *bNode = (BodyNode*) otherBody->GetUserData();
		if( bNode && [bNode conformsToProtocol:@protocol(BodyNodeBulletProtocol) ] )
			[(id<BodyNodeBulletProtocol>)bNode touchedByBullet:self];
		
		[game_ removeB2Body:body_];
	}
}
@end

