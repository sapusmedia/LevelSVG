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

//#import "KinematicNode.h"
#import "BodyNode.h"


enum{
	kPlatformDirectionHorizontal,
	kPlatformDirectionVertical,
};


//
// TIP:
// If you want to move the platforms using cocos2d actions
// then you must make it a subclass of StaticNode
//
//@interface Movingplatform : StaticNode {
//

@interface Movingplatform : BodyNode {

	int		direction_;
	float	duration_;
	float	translationInPixels_;
	b2Vec2	origPosition_;
	b2Vec2	finalPosition_;
	b2Vec2	currentPosition_; // used when paused
	b2Vec2	velocity_;
	BOOL	goingForward_;
	BOOL	wasPaused_;
}

- (void)gameStateChanged:(NSNotification *)notification;
//-(CCAction*) getAction;
@end
