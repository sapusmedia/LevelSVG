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



// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"

#import "GLES-Render.h"
#import "Box2DCallbacks.h"
#import "GameConstants.h"

// forward declarations
@class Hero;
@class HUD;
@class BodyNode;
@class BonusNode;

// game state
typedef enum
{
	kGameStatePaused,
	kGameStatePlaying,
	kGameStateGameOver,
} GameState;

#define kGameNodeFollowActionTag	1
#define kGameChangedStateNotification @"GameStateChangedNotification"

// HelloWorld Layer
@interface GameNode : CCLayer
{
	// box2d world
	b2World		*world_;
	
	// game state
	GameState		gameState_;
	
	// the camera will be centered on the Hero
	// If you want to move the camera, you should move this value
	CGPoint		cameraOffset_;
	
	// game scores
	unsigned int	score_;
	// game lives
	unsigned int	lives_;
	
	// Hero weak ref
	Hero	*hero_;
	
	// HUD weak ref
	HUD		*hud_;

	// Box2d: Used when dragging objects
	b2MouseJoint	* mouseJoint_;
	b2Body			* mouseStaticBody_;
	
	// box2d callbacks
	// In order to compile on SDK 2.2.x or older, they have to be pointers
	MyContactFilter			*m_contactFilter;
	MyContactListener		*m_contactListener;
	MyDestructionListener	*m_destructionListener;	
	
	// box2d iterations. Can be configured by each level
	int	worldPositionIterations_;
	int worldVelocityIterations_;
	
	// GameNode is responsible for removing "removed" nodes
	unsigned int nukeCount;
	b2Body* nuke[kMaxNodesToBeRemoved];	
}

/** Box2d World */
@property (readwrite,nonatomic) b2World *world;

/** score of the game */
@property (readonly,nonatomic) unsigned int score;

/** lives of the hero */
@property (readonly,nonatomic) unsigned int lives;

/** game state */
@property (readonly,nonatomic) GameState gameState;

/** weak ref to hero */
@property (readwrite,nonatomic,assign) Hero *hero;

/** weak ref to HUD */
@property (readwrite, nonatomic, assign) HUD *hud;

/** offset of the camera */
@property (readwrite,nonatomic) CGPoint cameraOffset;

// returns a Scene that contains the GameLevel and a HUD
+(id) scene;

// initialize game with level
-(id) init;

/** returns the SVGFileName to be loaded */
-(NSString*) SVGFileName;

// mouse (touches)
-(BOOL) mouseDown:(b2Vec2)p;
-(void) mouseMove:(b2Vec2)p;
-(void) mouseUp:(b2Vec2)p;

// game events
-(void) gameOver;
-(void) increaseScore:(int)score;
-(void) increaseLife:(int)lives;
- (void) togglePause;

// creates the foreground and background graphics
-(void) initGraphics;

// adds the BodyNode to the scene graph
-(void) addBodyNode:(BodyNode*)node z:(int)zOrder;

// schedule a b2Body to be removed
-(void) removeB2Body:(b2Body*)body;

// returns the content Rectangle of the Map
-(CGRect) contentRect;
@end
