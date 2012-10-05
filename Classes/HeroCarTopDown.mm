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

#import "SimpleAudioEngine.h"

#import "HeroCarTopDown.h"
#import "GameConfiguration.h"
#import "GameConstants.h"
#import "GameNode.h"

#pragma mark -
#pragma mark Herocartopdown

// Forces & Impulses

// Modify this value to create a bigger/smaller car
const float CAR_SCALE = 0.2f;

const b2Vec2 leftRearWheelPosition = b2Vec2(-1.5f * CAR_SCALE, 1.9f * CAR_SCALE);
const b2Vec2 rightRearWheelPosition = b2Vec2(1.5f * CAR_SCALE, 1.9f * CAR_SCALE);
const b2Vec2 leftFrontWheelPosition = b2Vec2(-1.5f * CAR_SCALE, -1.9f * CAR_SCALE);
const b2Vec2 rightFrontWheelPosition = b2Vec2(1.5f * CAR_SCALE, -1.9f * CAR_SCALE);

const float MAX_STEER_ANGLE = (float)M_PI /3.0f ;
const float STEER_SPEED = 2.5f;
const float HORSEPOWERS = 10 * CAR_SCALE;


//
// HeroCarTopDown: The main character of the game.
//

@implementation Herocartopdown

-(id) initWithBody:(b2Body*)body game:(GameNode*)aGame
{
	if( (self=[super initWithBody:body game:aGame] ) ) {

		//
		// Set up the right texture
		//
		
		// Set the default frame
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"car_top_view.png"];
		[self setDisplayFrame:frame];
		
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;

//		self.isTouchable = YES;
		//
		// box2d stuff: Create the "correct" fixture
		//
		// 1. destroy already created fixtures
		[self destroyAllFixturesFromBody:body];
		
		//
		// Car model based on:
		// http://www.emanueleferonato.com/2009/04/06/two-ways-to-make-box2d-cars/
		//

		//
		// Bodies
		//
		body->SetLinearDamping(1);
		body->SetAngularDamping(1);
		body->SetType(b2_dynamicBody);
		
		float originalAngle = body->GetAngle();
		
		body->SetTransform( body->GetPosition(), 0 );
		
		//left wheel
		b2BodyDef leftWheelDef;
		leftWheelDef.position = body->GetPosition() + leftFrontWheelPosition;
//		leftWheelDef.angle = body->GetAngle();
		leftWheel_ = world_->CreateBody(&leftWheelDef);
		leftWheel_->SetType(b2_dynamicBody);


		//right wheel
		b2BodyDef rightWheelDef;
		rightWheelDef.position = body->GetPosition() + rightFrontWheelPosition;
//		rightWheelDef.angle = body->GetAngle();
		rightWheel_ = world_->CreateBody(&rightWheelDef);
		rightWheel_->SetType(b2_dynamicBody);
		
		//left rear wheel
		b2BodyDef leftRearWheelDef;
		leftRearWheelDef.position = body->GetPosition() + leftRearWheelPosition;
//		leftRearWheelDef.angle = body->GetAngle();
		leftRearWheel_ = world_->CreateBody(&leftRearWheelDef);
		leftRearWheel_->SetType(b2_dynamicBody);

		
		//right rear wheel
		b2BodyDef rightRearWheelDef;
		rightRearWheelDef.position = body->GetPosition() + rightRearWheelPosition;
//		rightRearWheelDef.angle = body->GetAngle();
		rightRearWheel_ = world_->CreateBody(&rightRearWheelDef);
		rightRearWheel_->SetType(b2_dynamicBody);
		
		
		//
		// Shapes
		//
		
		// car shape
		b2PolygonShape boxDef;
		boxDef.SetAsBox(1.5f * CAR_SCALE, 2.5f * CAR_SCALE);
		body->CreateFixture(&boxDef, 1);
		
		//Left Wheel shape
		b2PolygonShape leftWheelShapeDef;
		leftWheelShapeDef.SetAsBox(0.2f * CAR_SCALE, 0.5f * CAR_SCALE);
		leftWheel_->CreateFixture(&leftWheelShapeDef, 1);
		
		//Right Wheel shape
		b2PolygonShape rightWheelShapeDef;
		rightWheelShapeDef.SetAsBox(0.2f * CAR_SCALE, 0.5f * CAR_SCALE);
		rightWheel_->CreateFixture( &rightWheelShapeDef, 1);
		
		//Left Wheel shape
		b2PolygonShape leftRearWheelShapeDef;
		leftRearWheelShapeDef.SetAsBox(0.2f * CAR_SCALE, 0.5f * CAR_SCALE);
		leftRearWheel_->CreateFixture(&leftRearWheelShapeDef,1);
		
		//Right Wheel shape
		b2PolygonShape rightRearWheelShapeDef;
		rightRearWheelShapeDef.SetAsBox(0.2f * CAR_SCALE, 0.5f * CAR_SCALE);
		rightRearWheel_->CreateFixture(&rightRearWheelShapeDef,1);
	
		
		//
		// Joints
		//
		b2RevoluteJointDef leftJointDef;
		leftJointDef.Initialize(body, leftWheel_, leftWheel_->GetWorldCenter());
		leftJointDef.enableMotor = true;
		leftJointDef.maxMotorTorque = 100;
		
		b2RevoluteJointDef rightJointDef;
		rightJointDef.Initialize(body, rightWheel_, rightWheel_->GetWorldCenter());
		rightJointDef.enableMotor = true;
		rightJointDef.maxMotorTorque = 100;
		
		leftJoint_ = (b2RevoluteJoint*) world_->CreateJoint(&leftJointDef);
		rightJoint_ = (b2RevoluteJoint*) world_->CreateJoint(&rightJointDef);
		
		b2PrismaticJointDef leftRearJointDef;
		leftRearJointDef.Initialize(body, leftRearWheel_, leftRearWheel_->GetWorldCenter(), b2Vec2(1,0));
		leftRearJointDef.enableLimit = true;
		leftRearJointDef.lowerTranslation = leftRearJointDef.upperTranslation = 0;
		
		b2PrismaticJointDef rightRearJointDef;
		rightRearJointDef.Initialize(body, rightRearWheel_, rightRearWheel_->GetWorldCenter(), b2Vec2(1,0));
		rightRearJointDef.enableLimit = true;
		rightRearJointDef.lowerTranslation = rightRearJointDef.upperTranslation = 0;
		
		world_->CreateJoint(&leftRearJointDef);
		world_->CreateJoint(&rightRearJointDef);
		
		
		// steering angle, speed
		steeringAngle_ = 0;
		engineSpeed_ = 0;
		
		body->SetTransform( body->GetPosition(), originalAngle );
	}
	return self;
}

//This function applies a "friction" in a direction orthogonal to the body's axis.
-(void) killOrthogonalVelocity:(b2Body*)targetBody
{
	b2Vec2 localPoint = b2Vec2(0,0);
	b2Vec2 velocity = targetBody->GetLinearVelocityFromLocalPoint(localPoint);
	
//	b2Vec2 sidewaysAxis = targetBody->GetTransform().R.col2;

	b2Rot rot = leftWheel_->GetTransform().q;
	b2Vec2 sidewaysAxis = b2Vec2( -rot.s, rot.c );
	sidewaysAxis *= b2Dot(velocity,sidewaysAxis);
	targetBody->SetLinearVelocity(sidewaysAxis);//targetBody.GetWorldPoint(localPoint));
}

-(void) update:(ccTime)dt
{
	// Call super, because the base class needs to update it
	[super update:dt];

	[self killOrthogonalVelocity:leftWheel_];
	[self killOrthogonalVelocity:rightWheel_];
	[self killOrthogonalVelocity:leftRearWheel_];
	[self killOrthogonalVelocity:rightRearWheel_];

	//Driving
	b2Rot lrot = leftWheel_->GetTransform().q;
	b2Vec2 ldirection = b2Vec2( -lrot.s, lrot.c );
//	b2Vec2 ldirection = leftWheel_->GetTransform().R.col2;
	ldirection *= engineSpeed_;
	b2Rot rrot = rightWheel_->GetTransform().q;
	b2Vec2 rdirection = b2Vec2( -rrot.s, rrot.c );
//	b2Vec2 rdirection = rightWheel_->GetTransform().R.col2;
	rdirection *= engineSpeed_;
	
	leftWheel_->ApplyForce(ldirection, leftWheel_->GetPosition());
	rightWheel_->ApplyForce(rdirection, rightWheel_->GetPosition());
	
	//Steering
	float mspeed = steeringAngle_ - leftJoint_->GetJointAngle();
	leftJoint_->SetMotorSpeed(mspeed * STEER_SPEED);
	
	mspeed = steeringAngle_ - rightJoint_->GetJointAngle();
	rightJoint_->SetMotorSpeed(mspeed * STEER_SPEED);
}

#pragma mark HeroCar - Movements

-(void) move:(CGPoint)direction
{
	engineSpeed_ = -direction.y * HORSEPOWERS;
	steeringAngle_ = -direction.x * MAX_STEER_ANGLE;	
}

-(void) teleportTo:(CGPoint)point
{	
}

-(void) onGameOver:(BOOL)winner
{
}

@end

