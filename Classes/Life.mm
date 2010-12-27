//
//  Life.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 24/03/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//

#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameNode.h"
#import "GameConstants.h"
#import "Life.h"
#import "SimpleAudioEngine.h"

//
// Life: a sensor with the shape of a heart
// When touched, it will increase the life in 1
//

@implementation Life

-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game]) ) {
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Heart.png"];
		[self setDisplayFrame:frame];
		
	}
	return self;
}

-(void) touchedByHero
{
	[super touchedByHero];
	[game_ increaseLife:1];
	[[SimpleAudioEngine sharedEngine] playEffect: @"new_life.wav"];
}

@end
