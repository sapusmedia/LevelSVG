//
//  SelectLevelScene.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 25/03/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//

#import "SelectLevelScene.h"
#import "Level0.h"
#import "Level1.h"
#import "Level2.h"
#import "Level3.h"
#import "Level4.h"
#import "Level5.h"
#import "Level6.h"
#import "Level7.h"
#import "Playground0.h"
#import "Playground1.h"
#import "MenuScene.h"
#import "SoundMenuItem.h"

@implementation SelectLevelScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	id child = [SelectLevelScene node];
	
	[scene addChild:child];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
	{
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"select-level.png"];
		background.position = ccp(s.width/2, s.height/2);
		[self addChild:background z:-10];
		
		
		CCMenuItem * item0 = [CCMenuItemFont itemFromString:@"Level 0" target:self selector:@selector(level0:)];
		CCMenuItem * item1 = [CCMenuItemFont itemFromString:@"Level 1" target:self selector:@selector(level1:)];
		CCMenuItem * item2 = [CCMenuItemFont itemFromString:@"Level 2" target:self selector:@selector(level2:)];
		CCMenuItem * item3 = [CCMenuItemFont itemFromString:@"Level 3" target:self selector:@selector(level3:)];
		CCMenuItem * item4 = [CCMenuItemFont itemFromString:@"Level 4" target:self selector:@selector(level4:)];
		CCMenuItem * item5 = [CCMenuItemFont itemFromString:@"Level 5" target:self selector:@selector(level5:)];
		CCMenuItem * item6 = [CCMenuItemFont itemFromString:@"Level 6" target:self selector:@selector(level6:)];
		CCMenuItem * item7 = [CCMenuItemFont itemFromString:@"Level 7" target:self selector:@selector(level7:)];

		CCMenuItem * item8 = [CCMenuItemFont itemFromString:@"Playground 0" target:self selector:@selector(playground0:)];
		CCMenuItem * item9 = [CCMenuItemFont itemFromString:@"Playground 1" target:self selector:@selector(playground1:)];
		
		CCMenu *menu = [CCMenu menuWithItems: item0, item1, item2, item3, item4, item5, item6, item7, item8, item9, nil];
		
		[menu alignItemsInColumns:
		 [NSNumber numberWithUnsignedInt:2],
		 [NSNumber numberWithUnsignedInt:2],
		 [NSNumber numberWithUnsignedInt:2],
		 [NSNumber numberWithUnsignedInt:2],
		 [NSNumber numberWithUnsignedInt:2],
		 nil
		 ]; // 2 + 2 + 2 + 2 + 2 = total count of 10
		
		[self addChild:menu];
		
		
		// back button
		SoundMenuItem *backButton = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-back-normal.png" selectedSpriteFrameName:@"btn-back-selected.png" target:self selector:@selector(backCallback:)];	
		backButton.position = ccp(5,s.height-5);
		backButton.anchorPoint = ccp(0,1);
		
		menu = [CCMenu menuWithItems:backButton, nil];
		menu.position = ccp(0,0);
		[self addChild: menu z:0];
		
	}
	
	return self;
}

-(void) setLevelScene:(Class)klass
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSplitRows transitionWithDuration:1 scene:[klass scene]]];
}

-(void) level0:(id)sender
{
	[self setLevelScene:[Level0 class]];
}

-(void) level1:(id)sender
{
	[self setLevelScene:[Level1 class]];
}

-(void) level2:(id)sender
{
	[self setLevelScene:[Level2 class]];
}

-(void) level3:(id)sender
{
	[self setLevelScene:[Level3 class]];
}

-(void) level4:(id)sender
{
	[self setLevelScene:[Level4 class]];
}

-(void) level5:(id)sender
{
	[self setLevelScene:[Level5 class]];
}

-(void) level6:(id)sender
{
	[self setLevelScene:[Level6 class]];
}

-(void) level7:(id)sender
{
	[self setLevelScene:[Level7 class]];
}

-(void) playground0:(id)sender
{
	[self setLevelScene:[Playground0 class]];
}

-(void) playground1:(id)sender
{
	[self setLevelScene:[Playground1 class]];
}

-(void) backCallback:(id)sender
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionRotoZoom transitionWithDuration:1 scene:[MenuScene scene] ]];
}
@end
