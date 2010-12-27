//
//  SettingsScene.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 22/10/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//


#import "SettingsScene.h"
#import "MenuScene.h"
#import "GameConfiguration.h"
#import "SoundMenuItem.h"

@implementation SettingsScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	id child = [SettingsScene node];
	
	[scene addChild:child];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
	{
		[super init];
		
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		CCMenuItemToggle *item1 = [CCMenuItemToggle itemWithTarget:self selector:@selector(controlCallback:) items:
								 [CCMenuItemFont itemFromString: @"Control: Tilt"],
								 [CCMenuItemFont itemFromString: @"Control: D-Pad"],
								 nil];

		CCMenuItemToggle *item2 = [CCMenuItemToggle itemWithTarget:self selector:@selector(controlFPS:) items:
								   [CCMenuItemFont itemFromString: @"Show FPS: OFF"],
								   [CCMenuItemFont itemFromString: @"Show FPS: ON"],
								   nil];
		
		
		GameConfiguration *config = [GameConfiguration sharedConfiguration];
		if( config.controlType == kControlTypePad )
			item1.selectedIndex = 1;
		
		CCMenu *menu = [CCMenu menuWithItems:
					  item1, item2,
						nil];
		[menu alignItemsVertically];
		
		[self addChild: menu];
		
		
		// back button
		CGSize s = [[CCDirector sharedDirector] winSize];
		SoundMenuItem *backButton = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-back-normal.png" selectedSpriteFrameName:@"btn-back-selected.png" target:self selector:@selector(backCallback:)];	
		backButton.position = ccp(5,s.height-5);
		backButton.anchorPoint = ccp(0,1);
		
		menu = [CCMenu menuWithItems:backButton, nil];
		menu.position = ccp(0,0);
		[self addChild: menu z:0];
		
		
		return self;
	}
	
	return self;
}

-(void) backCallback:(id)sender
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1 scene:[MenuScene scene] withColor:ccWHITE]];
}

-(void) controlFPS:(id)sender
{
	CCMenuItemToggle *item = (CCMenuItemToggle*) sender;	
	if( item.selectedIndex == 0 )
		[[CCDirector sharedDirector] setDisplayFPS:NO];
	else
		[[CCDirector sharedDirector] setDisplayFPS:YES];
}

-(void) controlCallback:(id)sender
{
	CCMenuItemToggle *item = (CCMenuItemToggle*) sender;	
	GameConfiguration *config = [GameConfiguration sharedConfiguration];
	if( item.selectedIndex == 0 )
		config.controlType = kControlTypeTilt;
	else
		config.controlType = kControlTypePad;
}
@end
