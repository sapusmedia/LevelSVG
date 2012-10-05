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
