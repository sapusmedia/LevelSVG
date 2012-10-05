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


#import <Foundation/Foundation.h>

typedef enum
{
	kControlTypePad,
	kControlTypeTilt,
	
	kControlTypeDefault = kControlTypeTilt,

} ControlType;

typedef enum
{
	kControlButton0,
	kControlButton1,
	kControlButton2,
	
	kControlButtonDefault = kControlButton1,
} ControlButton;

typedef enum {
	kControlDirection2Way,
	kControlDirection4Way,
	kControlDirection4WayCar,
	
	kControlDirectionDefault = kControlDirection4Way,
} ControlDirection;

@interface GameConfiguration : NSObject
{
	ControlType			controlType_;
	ControlDirection	controlDirection_;
	ControlButton		controlButton_;
	CGPoint				gravity_;
	BOOL				enableWireframe_;
};

@property (nonatomic,readwrite)	ControlType			controlType;
@property (nonatomic,readwrite)	ControlDirection	controlDirection;
@property (nonatomic,readwrite)	ControlButton		controlButton;
@property (nonatomic,readwrite) CGPoint				gravity;
@property (nonatomic,readwrite) BOOL				enableWireframe;

// returns the singleton
+(id) sharedConfiguration;

@end