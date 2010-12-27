//
//  Star.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 24/03/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameNode.h"
#import "GameConstants.h"
#import "Star.h"
#import "SimpleAudioEngine.h"

//
// Star: a sensor with the shape of an star.
// When touched, it will increase points in 10
//

@implementation Star

-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game]) ) {
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Star.png"];
		[self setDisplayFrame:frame];
		
	}
	return self;
}

-(void) touchedByHero
{
	[super touchedByHero];
	[game_ increaseScore:10];
	[[SimpleAudioEngine sharedEngine] playEffect: @"pickup_star.wav"];
}

@end
