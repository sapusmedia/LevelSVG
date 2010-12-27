//
//  Hero.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 03/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


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
