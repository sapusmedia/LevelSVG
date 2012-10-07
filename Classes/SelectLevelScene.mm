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
		
		
		CCMenuItem * item0 = [CCMenuItemFont itemWithString:@"Level 0" target:self selector:@selector(level0:)];
		CCMenuItem * item1 = [CCMenuItemFont itemWithString:@"Level 1" target:self selector:@selector(level1:)];
		CCMenuItem * item2 = [CCMenuItemFont itemWithString:@"Level 2" target:self selector:@selector(level2:)];
		CCMenuItem * item3 = [CCMenuItemFont itemWithString:@"Level 3" target:self selector:@selector(level3:)];
		CCMenuItem * item4 = [CCMenuItemFont itemWithString:@"Level 4" target:self selector:@selector(level4:)];
		CCMenuItem * item5 = [CCMenuItemFont itemWithString:@"Level 5" target:self selector:@selector(level5:)];
		CCMenuItem * item6 = [CCMenuItemFont itemWithString:@"Level 6" target:self selector:@selector(level6:)];
		CCMenuItem * item7 = [CCMenuItemFont itemWithString:@"Level 7" target:self selector:@selector(level7:)];

		CCMenuItem * item8 = [CCMenuItemFont itemWithString:@"Playground 0" target:self selector:@selector(playground0:)];
		CCMenuItem * item9 = [CCMenuItemFont itemWithString:@"Playground 1" target:self selector:@selector(playground1:)];
		
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
