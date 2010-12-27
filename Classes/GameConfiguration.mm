//
//  GameConfiguration.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 13/10/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//


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

#pragma mark singleton stuff
+ (GameConfiguration *)sharedConfiguration
{
	@synchronized([GameConfiguration class])
	{
		if (!_sharedConfiguration)
			[[self alloc] init];
		return _sharedConfiguration;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([GameConfiguration class])
	{
		NSAssert(_sharedConfiguration == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedConfiguration = [super alloc];
		return _sharedConfiguration;
	}
	// to avoid compiler warning
	return nil;
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
