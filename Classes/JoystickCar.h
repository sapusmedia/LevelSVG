//
//  JoystickCar.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 12/12/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//


#import "cocos2d.h"
#import "JoystickProtocol.h"

enum {
	JOYSTICK_CAR_UP,
	JOYSTICK_CAR_DOWN,
	JOYSTICK_CAR_LEFT,
	JOYSTICK_CAR_RIGHT,
	JOYSTICK_CAR_MAX,
};

@interface JoystickCar : CCLayer <JoystickProtocol>
{
	struct Button		buttons_[JOYSTICK_CAR_MAX];
}

/** allocates and initializes the joystic */
+(id) joystick;
@end
