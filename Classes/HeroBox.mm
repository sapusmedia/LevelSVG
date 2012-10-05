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

#import "HeroBox.h"
#import "GameConfiguration.h"
#import "GameConstants.h"
#import "GameNode.h"
#import "Bullet.h"


#define SPRITE_WIDTH 20
#define SPRITE_HEIGHT 44

// Forces & Impulses
#define	JUMP_IMPULSE (2.3f)
#define MOVE_FORCE (5.0f)

#define FIRE_FREQUENCY (0.2f)

//
// Hero: The main character of the game.
//
@implementation Herobox

-(id) initWithBody:(b2Body*)body game:(GameNode*)aGame
{
	if( (self=[super initWithBody:body game:aGame] ) ) {

		//
		// Set up the right texture
		//
		
		// Set the default frame
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"walk-right_01.png"];
		[self setDisplayFrame:frame];

		
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;

		//
		// box2d stuff: Create the "correct" fixture
		//
		// 1. destroy already created fixtures
		[self destroyAllFixturesFromBody:body];
		
		// 2. create new fixture
		b2FixtureDef	fd;
		
		b2PolygonShape shape;
		
		// Sprite size is SPRITE_WIDTH x SPRITE_HEIGHT
		float height = (SPRITE_HEIGHT / kPhysicsPTMRatio) / 2;
		float width = (SPRITE_WIDTH/ kPhysicsPTMRatio) / 2;
		
		// vertices should be in Counter Clock-Wise order, orderwise it will crash
		b2Vec2 vertices[4];
		vertices[0].Set(-width,-height);	// bottom-left
		vertices[1].Set(width,-height);		// bottom-right
		vertices[2].Set(width,height);		// top-right
		vertices[3].Set(-width,height);		// top-left
		shape.Set(vertices, 4);

		// TIP: friction should be 0 to avoid sticking into walls
		fd.friction		= 0.0f;
		fd.density		= 1.0f;
		fd.restitution	= 0.0f;
				

		// TIP: fixed rotation. The hero can't rotate. Very useful for Super Mario like games
		body->SetFixedRotation(true);

		fd.shape = &shape;
		
		// Collision filtering between Hero and Bullet
		// If the groupIndex is negative, then the fixtures NEVER collide.
		fd.filter.groupIndex = -kCollisionFilterGroupIndexHero;

		body->CreateFixture(&fd);
		body->SetType(b2_dynamicBody);
		
		//
		// Setup physics forces & impulses
		//
		jumpImpulse_ = JUMP_IMPULSE;
		moveForce_ = MOVE_FORCE;

		//
		// Setup custom HeroBox ivars
		//
		facingRight_ = YES;
		gettimeofday( &lastFire_, NULL);	
		
		antiGravityForce_ = NO;
		touchingGround_ = NO;
		
	}
	return self;
}

#pragma mark HeroBox - Movements

-(void) move:(CGPoint)direction
{
	//
	// TIP:
	// HeroRound uses ApplyForce to move the hero.
	// HeroBox uses SetLinearVelocity (simpler to code, and probably more realistic)
	//
	
	// HeroBox is optimized for platform games, so it can only move right/left. And climb up/down ladders


	b2Vec2 velocity = body_->GetLinearVelocity();

	velocity.x = moveForce_ * direction.x;

	if( direction.y > 0.4f && isTouchingLadder_ )
		antiGravityForce_ = YES;
	
	if( antiGravityForce_ ) {
		velocity.y = moveForce_ * direction.y;
		velocity.x = direction.x;
	}
	else 
		velocity.x = moveForce_ * direction.x;


	body_->SetLinearVelocity( velocity );
	
	// needed for bullets. Don't update if x==0
	if( direction.x != 0 )
		facingRight_ = (direction.x > 0);
	
	[self updateFrames:direction];
}

-(void) fire
{
	struct timeval now;
	gettimeofday( &now, NULL);	
	ccTime dt = (now.tv_sec - lastFire_.tv_sec) + (now.tv_usec - lastFire_.tv_usec) / 1000000.0f;
	
	if( dt > FIRE_FREQUENCY ) {

		lastFire_ = now;

		Bullet *bullet = [[Bullet alloc] initWithPosition:body_->GetPosition() direction:(facingRight_ ? 1 : -1) game:game_];
		[game_ addBodyNode:bullet z:0];
		[bullet release];
	}
}

-(void) jump
{
	touchingGround_ = NO;

	if( contactPointCount_ > 0 ) {
		
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

		for( int i=0; i<kMaxContactPoints && foundContacts < contactPointCount_;i++ ) {
			ContactPoint* point = contactPoints_ + i;
			if( point->otherFixture && ! point->otherFixture->IsSensor() ) {
				foundContacts++;
				
				//
				// Use the greater Y normal
				//
				if( point->normal.y > 0.5f) {
					touchingGround_ = YES;

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

	if( ! touchingGround_ ) {
		
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

-(void) onGameOver:(BOOL)winner
{
	body_->SetLinearVelocity(b2Vec2(0,0));
}

-(void) updateFrames:(CGPoint)direction
{
	const char *dir = "left";
	unsigned int index = 0;

	if( antiGravityForce_ ) {
		dir = "up";

		// There are 6 frames
		// And every 15 pixels a new frame should be displayed
		index = ((unsigned int)position_.y /15) % 6;
		
	}
	else {
		if( direction.x == 0 )
			return;

		dir = "left";
		
		if( direction.x > 0 )
			dir = "right";

		// There are 8 frames
		// And every 20 pixels a new frame should be displayed
		index = ((unsigned int)position_.x /20) % 8;
	}
	
	// increase frame index, since frame names start in "1" and not "0"
	index++;
	
	NSString *str = [NSString stringWithFormat:@"walk-%s_%02d.png", dir, index];
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:str];
	[self setDisplayFrame:frame];
}

-(void) update:(ccTime)dt
{
	[super update:dt];
	
	if( ! isTouchingLadder_ || touchingGround_ )
		antiGravityForce_ = NO;

	// If the Hero is touching a ladder, then apply an anti-gravity force
	if( antiGravityForce_ ) {
		// anti-gravity force
		b2Vec2 gravity = world_->GetGravity();
		b2Vec2 p = body_->GetLocalCenter();
		body_->ApplyForce( -body_->GetMass()*gravity, p );		
	}
	
}

@end
