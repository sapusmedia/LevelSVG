//
//  HUD.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 16/10/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//

#import "cocos2d.h"


@protocol JoystickProtocol;
@class JumpButton;
@class GameNode;

@interface HUD : CCLayer {
	
	// game
	GameNode	*game_;

	// joystick and joysprite. weak ref
	id<JoystickProtocol>	joystick_;
	
	CCLabelBMFont	*score_;
	CCLabelBMFont	*lives_;
}

// creates and initializes a HUD
+(id) HUDWithGameNode:(GameNode*)game;

// initializes a HUD with a delegate
-(id) initWithGameNode:(GameNode*)game;

// display a message on the screen
-(void) displayMessage:(NSString*)message;

-(void) onUpdateScore:(int)newScore;

-(void) onUpdateLives:(int)newLives;
@end
