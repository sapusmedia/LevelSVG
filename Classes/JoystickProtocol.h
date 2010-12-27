//
//  JoystickProtocol.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 12/12/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//

struct Button
{
	CGRect		bounds_;
	UITouch		*touch_;
	BOOL		enabled_;
	BOOL		isPressed_;	
	CCSprite	*sprite_;
};


@protocol JoystickProtocol <NSObject>

/* pad */
-(BOOL) isPadEnabled;
-(void) setPadEnabled:(BOOL)enabled;
-(void) setPadPosition:(CGPoint)pos;

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
