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
								 [CCMenuItemFont itemWithString:@"Control: Tilt"],
								 [CCMenuItemFont itemWithString:@"Control: D-Pad"],
								 nil];

		CCMenuItemToggle *item2 = [CCMenuItemToggle itemWithTarget:self selector:@selector(controlFPS:) items:
								   [CCMenuItemFont itemWithString:@"Show FPS: OFF"],
								   [CCMenuItemFont itemWithString:@"Show FPS: ON"],
								   nil];

		CCMenuItemToggle *item3 = [CCMenuItemToggle itemWithTarget:self selector:@selector(controlWireframe:) items:
								   [CCMenuItemFont itemWithString:@"Wireframe: OFF"],
								   [CCMenuItemFont itemWithString:@"Wireframe: ON"],
								   nil];

		
		GameConfiguration *config = [GameConfiguration sharedConfiguration];
		if( config.controlType == kControlTypePad )
			item1.selectedIndex = 1;
		
		CCMenu *menu = [CCMenu menuWithItems:
					  item1, item2, item3,
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
		[[CCDirector sharedDirector] setDisplayStats:NO];
	else
		[[CCDirector sharedDirector] setDisplayStats:YES];
}

-(void) controlWireframe:(id)sender
{
	CCMenuItemToggle *item = (CCMenuItemToggle*) sender;	
	GameConfiguration *config = [GameConfiguration sharedConfiguration];
	if( item.selectedIndex == 0 )
		config.enableWireframe = NO;
	else
		config.enableWireframe = YES;
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
