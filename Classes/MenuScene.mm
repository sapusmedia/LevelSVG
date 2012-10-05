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


#import "MenuScene.h"
#import "SettingsScene.h"
#import "SelectLevelScene.h"
#import "AboutScene.h"
#import "SoundMenuItem.h"


@implementation MenuScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	id child = [MenuScene node];
	
	[scene addChild:child];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
	{
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"main-menu-background.png"];
		background.position = ccp(s.width/2, s.height/2);
		[self addChild:background z:-10];
		

		CCMenuItemFont * item0 = [CCMenuItemFont itemFromString:@"Play" target:self selector:@selector(play:)];
		item0.color = ccBLACK;
		CCMenuItemFont * item1 = [CCMenuItemFont itemFromString:@"Settings" target:self selector:@selector(settings:)];
		item1.color = ccBLACK;
		CCMenuItemFont * item2 = [CCMenuItemFont itemFromString:@"About" target:self selector:@selector(about:)];
		item2.color = ccBLACK;


		CCMenu *menu = [CCMenu menuWithItems: item0, item1, item2, nil];
		
		[menu alignItemsVertically];
		[self addChild:menu];
		
		// Buy Sapus Sources
		SoundMenuItem *buyButton = [SoundMenuItem itemFromNormalSpriteFrameName:@"buy-source-code-normal.png" selectedSpriteFrameName:@"buy-source-code-selected.png" target:self selector:@selector(buyCallback:)];	
		menu = [CCMenu menuWithItems:buyButton, nil];
		
		menu.position = ccp(s.width-50,40);
		[self addChild: menu z:0];
		
	}
	
	return self;
}

-(void) play:(id)sender
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionCrossFade transitionWithDuration:1 scene:[SelectLevelScene scene]]];
}

-(void) settings:(id)sender
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1 scene:[SettingsScene scene] withColor:ccWHITE]];
}

-(void) about:(id)sender
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFlipY transitionWithDuration:1 scene:[AboutScene scene]]];	
}

-(void) buyCallback: (id) sender {
	// Launches Safari and opens the requested web page
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sapusmedia.com/levelsvg"]];
}



@end
