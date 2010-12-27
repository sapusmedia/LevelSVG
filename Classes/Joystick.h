/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Jason Booth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


// virtual joystick class
//
// Creates a virtual touch joystick within the bounds passed in. 
// Default mode is that any press begin in the bounds area becomes
// the center of the joystick. Call setCenter if you want a static
// joystick center position instead. Query getCurrentVelocity
// for an X,Y offset value, or getCurrentDegreeVelocity for a
// degree and velocity value.
//
// You initialize the joystick with a rect defining it's area
// and you have to forward touch events to the joystick via
// it's touch event handlers. They will return YES if the touch
// is handled.

#import "cocos2d.h"
#import "JoystickProtocol.h"

enum {
	BUTTON_A,
	BUTTON_B,
	
	BUTTON_MAX
};

@interface Joystick : CCLayer <JoystickProtocol>
{
	// pad
	CGPoint	padCurPosition;
	CGPoint	padPosition_;
	CGPoint	velocity;
	CGRect	padBounds;
	UITouch	*padTouch;
	BOOL	padEnabled_;

	// buttons
	struct Button buttons_[BUTTON_MAX];

	// weak reference
	CCSprite	*spritePad_;
}

/** pad position */
@property (nonatomic, readwrite) CGPoint padPosition;

/** allocates and initializes the joystic */
+(id) joystick;

/** initializes the joystick */
-(id)init;

/** is pad enabled */
-(BOOL) isPadEnabled;
-(void) setPadEnabled:(BOOL)enabled;

/** is button enabled */
-(void) setPosition:(CGPoint)position forButton:(unsigned int)buttonNumber;
-(BOOL) isButtonPressed:(unsigned int)buttonNumber;
-(BOOL) isButtonEnabled:(unsigned int)buttonNumber;
-(void) setButton:(unsigned int)buttonNumber enabled:(BOOL)enabled;


/* returns the current velocity */
-(CGPoint)getCurrentVelocity;

/* returns the current velocity. Values are between -1 and 1 */
-(CGPoint)getCurrentNormalizedVelocity;

/* returns the currect degree velocity */
-(CGPoint)getCurrentDegreeVelocity;
@end
