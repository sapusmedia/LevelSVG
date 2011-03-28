//
//  HeroBox.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 7/7/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "SimpleAudioEngine.h"

#import "HeroCar.h"
#import "GameConfiguration.h"
#import "GameConstants.h"
#import "GameNode.h"
#import "BadGuy.h"

#pragma mark -
#pragma mark Herocar

// Forces & Impulses
#define	JUMP_IMPULSE (16)
#define MOTOR_SPEED (10)

//
// HeroCar: The main character of the game.
//
// It is a hero: it means that it is controlled by the user
// It is composed of 3 BodyNodes: a HeroCar and two WheelNode objects
// It is composed of:
//      - 1 b2Body with 2 fixtures: the upper part of the car
//      - 2 b2Body with a circular fixture: 1 for each wheel
//      - 2 b2Body used as axles
//		- 2 prismatic joints: 1 for each wheel. They are used as suspensions
//		- 2 revolute joints: 1 for each wheel. They are the motors.
//				This car is a 4WD (actually a 2 wheel drive since it only has 2 wheels)
//
//
// Each BodyNode (the Herocar and the WheelNode) detects collision
//
@implementation Herocar

-(id) initWithBody:(b2Body*)body game:(GameNode*)aGame
{
	if( (self=[super initWithBody:body game:aGame] ) ) {

		//
		// Set up the right texture
		//
		
		// Set the default frame
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"car.png"];
		[self setDisplayFrame:frame];

		
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;

//		self.isTouchable = YES;
		//
		// box2d stuff: Create the "correct" fixture
		//
		// 1. destroy already created fixtures
		[self destroyAllFixturesFromBody:body];
		
		//
		// Cart model based on:
		// http://www.emanueleferonato.com/2009/04/06/two-ways-to-make-box2d-cars/
		//

		
		//
		// Cart
		//
		// Reuses the already created body
		b2Body *cart;

		cart = body;
		b2FixtureDef fd;
		b2PolygonShape polyShape;
		b2BodyDef bodyDef;
		
		// The cart is composed of 2 fixtures:
		// A box (lower part)
		// A 5-vertices poligon (upper part)
		
		// Create lower part of the cart
		polyShape.SetAsBox(1.0f, 0.25f);
		fd.shape = &polyShape;
		fd.friction		= 0.5f;
		fd.density		= 1;
		fd.restitution	= 0.1f;
		fd.filter.groupIndex = -kCollisionFilterGroupIndexHero;
		cart->CreateFixture(&fd);
		
		// Create upper part of the cart
		b2Vec2 vertices[5];
		vertices[0].Set(-1.0f, 0.2f);	// bottom-left
		vertices[1].Set(0.6f,  0.2f);	// bottom-right
		vertices[2].Set(0.6f,  0.5f);	// top-right
		vertices[3].Set(0,    0.8f);	// top-center
		vertices[4].Set(-1.0f, 0.8f);	// top-left
		polyShape.Set(vertices, 5);
		fd.filter.groupIndex = -kCollisionFilterGroupIndexHero;
		cart->CreateFixture(&fd);
	
		cart->SetType(b2_dynamicBody);

		//
		// Axles
		//
		// Axle 1
		bodyDef.position = cart->GetWorldCenter();
		bodyDef.type = b2_dynamicBody;
		axle1_ = world_->CreateBody(&bodyDef);
		
		polyShape.SetAsBox(0.1f, 0.2f, b2Vec2(-0.65f, -0.4f), 0 );
		fd.shape = &polyShape;
		fd.density	= 1;
		fd.filter.groupIndex = -kCollisionFilterGroupIndexHero;
		axle1_->CreateFixture(&fd);
		
		// Axle 2
		axle2_ = world_->CreateBody(&bodyDef);
		polyShape.SetAsBox(0.1f, 0.2f, b2Vec2(0.80f, -0.4f), 0 );
		axle2_->CreateFixture(&fd);
		
		//
		// Suspensions
		//
		b2PrismaticJointDef prismaticDef;
		prismaticDef.Initialize(cart, axle1_, axle1_->GetWorldCenter() , b2Vec2(0, 1));
		prismaticDef.lowerTranslation = -0.1f;
		prismaticDef.upperTranslation = 0.1f;
		prismaticDef.enableLimit = true;
		spring1_ = (b2PrismaticJoint*)world_->CreateJoint(&prismaticDef);
		
		// Front Prismatic Joint
		prismaticDef.Initialize(cart, axle2_, axle2_->GetWorldCenter(), b2Vec2(0, 1));
		prismaticDef.lowerTranslation = -0.1f;
		prismaticDef.upperTranslation = 0.1f;
		prismaticDef.enableLimit = true;
		spring2_ = (b2PrismaticJoint*)world_->CreateJoint(&prismaticDef);
		
		
		//
		// Wheels
		//

		bodyDef.position = axle1_->GetWorldCenter() + b2Vec2( 0, -0.2f);
		wheel1_ = world_->CreateBody(&bodyDef);

		b2CircleShape	circleShape;
		circleShape.m_radius = 0.25f;
		fd.friction		= 0.9f;
		fd.density		= 10;
		fd.restitution	= 0.1f;
		fd.shape = &circleShape;
		fd.filter.groupIndex = -kCollisionFilterGroupIndexHero;
		wheel1_->CreateFixture(&fd);
		
		// Front Wheel (Wheel 2)
		bodyDef.position = axle2_->GetWorldCenter() + b2Vec2( 0, -0.2f);
		wheel2_ = world_->CreateBody(&bodyDef);
		wheel2_->CreateFixture(&fd);

		//
		// Motors
		//
		b2RevoluteJointDef revoluteDef;
		revoluteDef.Initialize(wheel1_, axle1_, wheel1_->GetWorldCenter() );
		motor1_ = (b2RevoluteJoint*) world_->CreateJoint(&revoluteDef);

		revoluteDef.Initialize(wheel2_, axle2_, wheel2_->GetWorldCenter() );
		motor2_ = (b2RevoluteJoint*) world_->CreateJoint(&revoluteDef);
		
		//
		// Update motor
		//
//		[self scheduleUpdate]; // already scheduled by base class, no need to re-schedule
		
		// calculate base spring force from the mass of the cart//
		baseSpringForce_ = cart->GetMass() * 5;
		
		
		//
		// Movement & Jump
		jumpImpulse_ = JUMP_IMPULSE;
		
		//
		// Sprites & BodyNodes
		//
		// Wheel 1
		wheel1Node_ = [[WheelNode alloc] initWithBody:wheel1_ game:game_];
		[game_ addBodyNode:wheel1Node_ z:1];
		[wheel1Node_ release];

		
		// Wheel 2
		wheel2Node_ = [[WheelNode alloc] initWithBody:wheel2_ game:game_];
		[game_ addBodyNode:wheel2Node_ z:1];
		[wheel2Node_ release];
		
		
	}
	return self;
}

#pragma mark HeroCar - Movements

-(void) move:(CGPoint)direction
{
//	float torque = -direction.x * 0.5f;		
//	wheel1->ApplyTorque(torque);
//	wheel2->ApplyTorque(torque);
	
	if( direction.x != 0 ) {
		motor1_->EnableMotor(true);
		motor1_->SetMotorSpeed((float32) (MOTOR_SPEED* M_PI * direction.x));
		motor1_->SetMaxMotorTorque( 10 );

		motor2_->EnableMotor(true);
		motor2_->SetMotorSpeed((float32) (MOTOR_SPEED* M_PI * direction.x));
		motor2_->SetMaxMotorTorque( 10 );
		
	} else {
		motor1_->EnableMotor(false);
		motor2_->EnableMotor(false);
	}

}

-(void) jump
{
	BOOL touchingGround = NO;
	
	if( wheel1Node_->contactPointCount_ > 0 && wheel2Node_->contactPointCount_ > 0) {
		
		int foundContacts=0;
		
		//
		// TIP:
		// only take into account the normals that have a Y component greater that 0.3
		// You might want to customize this value for your game.
		//
		// Explanation:
		// If the hero is on top of 100% horizontal platform, then Y==1
		// If it is on top of platform rotate 45 degrees, then Y==0.5
		// If it is touching a wall Y==0
		// If it is touching a ceiling then, Y== -1
		//
		
		// For simplicty it only checks the normal of the rear wheel		
		for( int i=0; i<kMaxContactPoints && foundContacts < wheel1Node_->contactPointCount_;i++ ) {
			ContactPoint* point = wheel1Node_->contactPoints_ + i;
			if( point->otherFixture ) {
				foundContacts++;
				
				//
				// Use the greater Y normal
				//
				if( point->normal.y > 0.5f) {
					touchingGround = YES;
					
					b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
					
					//
					// It's possible that while touching ground, the Hero already started to jump
					// so, the 2nd time, the impulse should be lower
					//					
					float impulseYFactor = 1;
					b2Vec2 vel = body_->GetLinearVelocity();
					if( vel.y > 0 )
						impulseYFactor = vel.y / 40;
					
					
					//
					// TIP:
					// The impulse always is "up". To simulate a more realistic
					// jump, see HeroRound.mm, since it uses the normal, but it this realism is not
					// needed in Mario-like games
					//
					body_->ApplyLinearImpulse( b2Vec2(0, jumpImpulse_ * impulseYFactor), p );
					
					//
					// TIP:
					// Another way (less realistic) to simulate a jump, is by
					// using SetLinearVelocity()
					// eg:
					//
					//		b2Vec2 vel = body_->GetLinearVelocity();
					//		body_->SetLinearVelocity( b2Vec2(vel.x, 6) );
					
					
					break;
				}
			}
		}
		
	}
	
	if( ! touchingGround ) {
		
		//
		// TIP:
		// Reduce the impulse if the jump button is still pressed, and the Hero is in the air
		//		
		b2Vec2 vel = body_->GetLinearVelocity();
		
		// going up ? so apply little impulses
		if( vel.y > 0 ) {
			b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
			
			// 160 is just a constant to get the impulse a N times lower
			float impY = jumpImpulse_ * vel.y/160;
			body_->ApplyLinearImpulse( b2Vec2(0,impY), p);
		}
	}
}

-(void) teleportTo:(CGPoint)point
{
	// overrides super teleport since it needs to move 5 bodies instead of 1
	
	body_->SetTransform( b2Vec2( point.x / kPhysicsPTMRatio, point.y/kPhysicsPTMRatio), body_->GetAngle() );

	axle1_->SetTransform( body_->GetWorldCenter(), axle1_->GetAngle() );
	axle2_->SetTransform( body_->GetWorldCenter(), axle2_->GetAngle() );

	wheel1_->SetTransform( axle1_->GetWorldCenter() + b2Vec2( 0, -0.2f) , wheel1_->GetAngle() );
	wheel2_->SetTransform( axle2_->GetWorldCenter() + b2Vec2( 0, -0.2f) , wheel2_->GetAngle() );
	
}

-(void) onGameOver:(BOOL)winner
{
	// disable motor when game is over
	motor1_->EnableMotor(false);
	motor2_->EnableMotor(false);
}

-(void) update:(ccTime)dt
{
	// Call super, because the base class needs to update it
	[super update:dt];

	spring1_->SetMaxMotorForce( baseSpringForce_ + (40 * baseSpringForce_ * powf(spring1_->GetJointTranslation(), 2) ) );
	spring1_->SetMotorSpeed( -20 * spring1_->GetJointTranslation() );
	
	spring2_->SetMaxMotorForce( baseSpringForce_ + (40 * baseSpringForce_ * powf(spring2_->GetJointTranslation(), 2) ) );
	spring2_->SetMotorSpeed( -20 * spring2_->GetJointTranslation() );
}

@end

#pragma mark -
#pragma mark WheelNode

@implementation WheelNode
-(id) initWithBody:(b2Body*)body game:(GameNode*)aGame
{
	if( (self=[super initWithBody:body game:aGame] ) ) {
		reportContacts_ = BN_CONTACT_BEGIN | BN_CONTACT_END;
		
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"wheel.png"];
		[self setDisplayFrame:frame];
		
		
		// check collisions
		[self scheduleUpdate];
	}
	
	return self;
}

//
// To know at any moment the list of contacts of the wheel, you should mantain a list based on being/endContact
//
-(void) beginContact:(b2Contact*)contact
{
	// 
	BOOL otherIsA = YES;
	
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	NSAssert( fixtureA != fixtureB, @"Hero: Box2d bug");
	
	b2WorldManifold worldManifold;
	contact->GetWorldManifold(&worldManifold);
	
	b2Body *bodyA = fixtureA->GetBody();
	b2Body *bodyB = fixtureB->GetBody();
	
	NSAssert( bodyA != bodyB, @"Hero: Box2d bug");
	
	// Box2d doesn't guarantees the order of the fixtures
	otherIsA = (bodyA == body_) ? NO : YES;
	
	
	// find empty place
	int emptyIndex;
	for(emptyIndex=0; emptyIndex<kMaxContactPoints;emptyIndex++) {
		if( contactPoints_[emptyIndex].otherFixture == NULL )
			break;
	}
	NSAssert( emptyIndex < kMaxContactPoints, @"LevelSVG: Can't find an empty place in the contacts");
	
	// XXX: should support manifolds
	ContactPoint* cp = contactPoints_ + emptyIndex;
	cp->otherFixture = ( otherIsA ? fixtureA :fixtureB );
	cp->position = b2Vec2_zero;
	cp->normal = otherIsA ? worldManifold.normal : -worldManifold.normal;
	cp->state = b2_addState;
	contactPointCount_++;
}

-(void) update:(ccTime)dt
{
	//
	// Collision with the Wheels ?
	//
	GameState state = [game_ gameState];
	// only update controls if game is "playing"
	if( state == kGameStatePlaying ) {
		
		int found = 0;
		for (int32 i = 0; i < kMaxContactPoints && found < contactPointCount_; i++)
		{
			ContactPoint* point = contactPoints_ + i;
			b2Fixture *otherFixture = point->otherFixture;
			
			if( otherFixture ) {
				
				found++;
	
				b2Body *otherBody =  otherFixture->GetBody();
				BodyNode *otherNode = (BodyNode*) otherBody->GetUserData();

				// Send the "touchByHero" message

				// special case for "BadGuy"
				if( [otherNode isKindOfClass:[BadGuy class]]) {
					Hero *hero = [game_ hero];
					if( ![hero isBlinking]  ) {
						[(BadGuy*) otherNode performSelector:@selector(touchedByHero)];
						[hero blinkHero];
					}
				}
				
				else if( [otherNode respondsToSelector:@selector(touchedByHero)] )
					[otherNode performSelector:@selector(touchedByHero)];
			}
		}
	}
}

-(void) endContact:(b2Contact*)contact
{
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	b2Body *body = fixtureA->GetBody();
	
	b2Fixture *otherFixture = (body == body_) ? fixtureB : fixtureA;
	
	int emptyIndex;
	for(emptyIndex=0; emptyIndex<kMaxContactPoints;emptyIndex++) {
		if( contactPoints_[emptyIndex].otherFixture == otherFixture ) {
			contactPoints_[emptyIndex].otherFixture = NULL;
			contactPointCount_--;
			break;
		}
	}	
}

@end

