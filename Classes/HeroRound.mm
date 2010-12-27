//
//  HeroRound.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 12/02/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "HeroRound.h"
#import "GameConfiguration.h"
#import "GameConstants.h"

// Forces & Impulses
#define	JUMP_IMPULSE (1.0f);
#define MOVE_FORCE (10.0f)

//
// Hero: The main character of the game.
//
@implementation Heroround

-(id) initWithBody:(b2Body*)body game:(GameNode*)aGame
{
	if( (self=[super initWithBody:body game:aGame] ) ) {
		
		//
		// Set up the right texture
		//		
	
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"sprite_hero_01.png"];
		[self setDisplayFrame:frame];
		
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;

		
		// The hero is not a perfect circle (it is a rat with big ears), so adjust the anchor point
		[self setAnchorPoint: ccp(0.5f, 0.45f)];

		//
		// box2d stuff: Create the "correct" fixture
		//
		// 1. destroy already created fixtures
		[self destroyAllFixturesFromBody:body];
		
		// 2. create new fixture
		b2FixtureDef	fd;
		b2CircleShape	shape;
		shape.m_radius = 0.48f;		// 1 meter of diameter (optimized size)
		fd.friction		= 0.2f;
		fd.density		= 0.3f;
		fd.restitution	= 0.0f;		// don't bounce

		fd.shape = &shape;
		body->CreateFixture(&fd);
		body->SetType(b2_dynamicBody);
		
		//
		// Setup physics forces & impulses
		//
		jumpImpulse_ = JUMP_IMPULSE;
		moveForce_ = MOVE_FORCE;
	}
	return self;
}

#pragma mark HeroRound - Movement

-(void) move:(CGPoint)direction
{
	//
	// TIP:
	// HeroRound uses ApplyForce to move the hero
	// HeroBox uses SetLinearVelocity.
	// Use the one that suits your game best. Probably SetLinearVelocity is easier to fine-tune
	//
	if( (elapsedTime_ - lastTimeForceApplied_) > kPhysicsHeroForceInterval ) {
		
		
		// default force for 4-way joystick
		b2Vec2 f = b2Vec2_zero;
		
		// using 2-way joystick ?
		if( controlDirection_ == kControlDirection2Way ) {
			if( direction.x < 0 )
				f = b2Vec2(-moveForce_,0);
			else if(direction.x > 0)
				f = b2Vec2(moveForce_,0);
		} else if( controlDirection_ == kControlDirection4Way )
			f = b2Vec2(direction.x * moveForce_, direction.y * moveForce_);
		
		
		b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
		body_->ApplyForce(f, p);				
		
		lastTimeForceApplied_ = elapsedTime_;
		
		[self updateFrames:ccp(f.x, f.y)];
	}
}

-(void) jump
{
	BOOL touchingGround = NO;
	
	if( contactPointCount_ > 0 ) {
		b2Vec2 normal = b2Vec2_zero;
		int foundContacts=0;
		
		touchingGround = YES;
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
		float currentNormalY=0.3f;
		
		for( int i=0; i<kMaxContactPoints && foundContacts < contactPointCount_;i++ ) {
			ContactPoint* point = contactPoints_ + i;
			if( point->otherFixture ) {
				foundContacts++;
				
				//
				// Use the greater Y normal
				//
				if( point->normal.y > currentNormalY) {
					normal = point->normal;
					currentNormalY = point->normal.y;
				}
			}
		}
		//
		// TIP:
		// So, instead of jumping up, it jumps according to the normal,
		// making the jump more realistic
		//
		b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
		
		// It's possible that while touching ground, the Hero already started to jump
		// so, the 2nd time, the impulse should be lower
		float impulseYFactor = 1;
		b2Vec2 vel = body_->GetLinearVelocity();
		
		// but, since the "round" hero can go up using non horizontal platforms, 
		// we compare if velocity.y > constant. 
		// WARNING: If you hero is running up, it might not jump if its velocity
		// is higher than this constant.
		if( vel.y > 0.5f )
			impulseYFactor = vel.y / 40;
		
		body_->ApplyLinearImpulse( jumpImpulse_ * impulseYFactor * normal, p );
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
			
			// 200 is just a constant to get the impulse a N times lower. You might need to customize it for your game
			float impY = jumpImpulse_ * vel.y/200;
			body_->ApplyLinearImpulse( b2Vec2(0,impY), p);
		}
	}
}
@end
