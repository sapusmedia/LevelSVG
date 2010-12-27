//
//  BadGuy.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 05/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BadGuy.h"
#import "SimpleAudioEngine.h"
#import "GameNode.h"

//
// BadGuy: Base class of all enemies. 
// If the hero touches a BadGuy, then the "touchedbyHero" method will be called.
//

@implementation BadGuy

-(void) touchedByHero
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"you_are_hit.wav"];
	[game_ increaseLife:-1];
}

@end
