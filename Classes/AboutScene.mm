//
//  AboutNode.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 25/03/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//

#import "AboutScene.h"
#import "MenuScene.h"
#import "SoundMenuItem.h"


@implementation AboutScene

+(id) scene {
	CCScene *s = [CCScene node];
	id node = [AboutScene node];
	[s addChild:node];
	return s;
}

-(id) init {
	if( (self=[super init])) {
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"about-background.png"];
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];
		
		// Menu: Back and Visit
		CGSize s = [[CCDirector sharedDirector] winSize];

		SoundMenuItem *visitButton = [SoundMenuItem itemFromNormalSpriteFrameName:@"visit-levelsvg-homepage-normal.png" selectedSpriteFrameName:@"visit-levelsvg-homepage-selected.png" target:self selector:@selector(visitHomepageCallback:)];	
		visitButton.position = ccp(s.width/2,30);

		SoundMenuItem *backButton = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-back-normal.png" selectedSpriteFrameName:@"btn-back-selected.png" target:self selector:@selector(backCallback:)];	
		backButton.position = ccp(5,s.height-5);
		backButton.anchorPoint = ccp(0,1);

		CCMenu *menu = [CCMenu menuWithItems:visitButton, backButton, nil];
		menu.position = ccp(0,0);
		[self addChild: menu z:0];
		
	}
	return self;
}

-(void) visitHomepageCallback: (id) sender {
	// Launches Safari and opens the requested web page
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sapusmedia.com/levelsvg"]];
}

-(void) backCallback:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionRadialCW transitionWithDuration:1.0f scene:[MenuScene scene]]];
}
@end
