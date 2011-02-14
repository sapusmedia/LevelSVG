//
//  Box2dDebugDrawNode.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 05/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//


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
		flags += b2DebugDraw::e_shapeBit;
		flags += b2DebugDraw::e_jointBit;
//		flags += b2DebugDraw::e_aabbBit;
//		flags += b2DebugDraw::e_pairBit;
//		flags += b2DebugDraw::e_centerOfMassBit;

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
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

	world_->DrawDebugData();

	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
}
@end
