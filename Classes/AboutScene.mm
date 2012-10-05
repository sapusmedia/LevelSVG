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
