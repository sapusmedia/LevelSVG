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
#import "GameConfiguration.h"


// forward declarations
@class GameScene;
@protocol JoystickProtocol;

const int32 kMaxContactPoints = 128;

struct ContactPoint
{
	b2Fixture*	otherFixture;
	b2Vec2		normal;
	b2Vec2		position;
	b2PointState state;
};

@interface Hero : BodyNode <UIAccelerometerDelegate> {
	
	// b2 world. weak ref
	b2World *world_;
	
	// sprite is blinking
	BOOL	isBlinking_;
	
	// weak ref. The joystick status is read by the hero
	id<JoystickProtocol>	joystick_;

	// elapsed time on the game
	ccTime				elapsedTime_;
	
	// last time that a forced was applied to our hero
	ccTime				lastTimeForceApplied_;
	
	// collision detection stuff
	ContactPoint		contactPoints_[kMaxContactPoints];
	int32				contactPointCount_;	
	
	// is the hero touching a ladder
	BOOL		isTouchingLadder_;

	// optimization
	ControlDirection	controlDirection_;
	
	float				jumpImpulse_;
	float				moveForce_;
}

/** HUD should set the joystick */
@property (nonatomic,readwrite,assign) id<JoystickProtocol> joystick;

/** Is the hero blinking */
@property (nonatomic, readonly) BOOL isBlinking;

// Hero movements
-(void) jump;
-(void) fire;
-(void) move:(CGPoint)direction;
-(void) blinkHero;
-(void) teleportTo:(CGPoint)point;

-(void) update:(ccTime)dt;

// update sprite frames
-(void) updateFrames:(CGPoint)p;

// called when the game is over. YES if winner, NO if loser
-(void) onGameOver:(BOOL)winner;

@end
