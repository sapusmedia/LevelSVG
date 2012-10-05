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


//
// Holds the game configuration, like:
//
// - control type: Pad or accelerometer
// - Joystic: 4-way or 2-way
// - Buttons: 1 or 2 buttons
// - Gravity: Default gravity for the level

// cocos2d imports
#import "cocos2d.h"

// local imports
#import "GameConfiguration.h"
#import "GameConstants.h"


static GameConfiguration *_sharedConfiguration;

@implementation GameConfiguration

@synthesize controlType=controlType_;
@synthesize controlDirection=controlDirection_;
@synthesize controlButton=controlButton_;
@synthesize gravity=gravity_;
@synthesize enableWireframe=enableWireframe_;

#pragma mark singleton stuff
+ (GameConfiguration *)sharedConfiguration
{
	if (!_sharedConfiguration)
		_sharedConfiguration = [[self alloc] init];
	
	return _sharedConfiguration;
}

+(id)alloc
{
	NSAssert(_sharedConfiguration == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

-(id) init
{
	if( (self=[super init]) ) {
		
		controlType_ = kControlTypePad;
		gravity_ = ccp( kPhysicsWorldGravityX, kPhysicsWorldGravityY);
	}
	return self;
}

@end
