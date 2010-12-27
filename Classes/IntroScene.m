//
//  IntroNode.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 07/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "IntroScene.h"
#import "MenuScene.h"

//
// This is an small Scene that makes the trasition smoother from the Defaul.png image to the menu scene
//

@implementation IntroScene

+(id) scene {
	CCScene *s = [CCScene node];
	id node = [IntroScene node];
	[s addChild:node];
	return s;
}

-(id) init {
	if( (self=[super init])) {
		
		// Load all the sprites/platforms now
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];

		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"Default.png"];
		background.rotation = -90;
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];
		
		[self schedule:@selector(wait1second:) interval:1];
	}
	return self;
}


-(void) wait1second:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionRadialCW transitionWithDuration:1.0f scene:[MenuScene scene]]];
}
@end
