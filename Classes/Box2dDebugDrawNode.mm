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



#import <Box2d/Box2D.h>

#import "Box2dDebugDrawNode.h"
#import "GameConstants.h"

//
// This node only draws the box2d objects
// Useful for debugging purporses
//
@implementation Box2dDebugDrawNode

+(id) nodeWithWorld:(b2World*)world
{
	return [[[self alloc] initWithWorld:world] autorelease];
}

-(id) initWithWorld:(b2World*)w
{
	if ((self=[super init])) {
		world_ = w;

		uint32 flags = 0;
		flags += b2Draw::e_shapeBit;
		flags += b2Draw::e_jointBit;
//		flags += b2Draw::e_aabbBit;
//		flags += b2Draw::e_pairBit;
//		flags += b2Draw::e_centerOfMassBit;

		debugDraw_ = new GLESDebugDraw( kPhysicsPTMRatio * CC_CONTENT_SCALE_FACTOR() );
		debugDraw_->SetFlags(flags);
		
		world_->SetDebugDraw(debugDraw_);
	}
	
	return self;
}

- (void) dealloc
{
	if( debugDraw_ ) {
		delete debugDraw_;
		debugDraw_ = NULL;
	}

	[super dealloc];
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);

	world_->DrawDebugData();

	// restore default GL states
	glEnable(GL_TEXTURE_2D);	
}
@end
