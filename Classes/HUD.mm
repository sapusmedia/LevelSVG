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


//
// HUD: Head Up Display
//
// - Display score
// - Display lives
// - Display joystick, but it is not responsible for reading it
// - Display the menu button
// - Register a touch events: drags the screen
//

#import "HUD.h"
#import "GameConfiguration.h"
#import "Joystick.h"
#import "JoystickCar.h"
#import "GameNode.h"
#import "MenuScene.h"
#import "Hero.h"
#import "SoundMenuItem.h"

@implementation HUD

+(id) HUDWithGameNode:(GameNode*)game
{
	return [[[self alloc] initWithGameNode:game] autorelease];
}
-(id) initWithGameNode:(GameNode*)aGame
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		game_ = aGame;

		CGSize s = [[CCDirector sharedDirector] winSize];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"buttons.plist"];

		// level control configuration:
		//  - 2-way, 4-way or car ?
		//  - d-pad or accelerometer ?
		//  - 0, 1 or 2 buttons ?
	
		GameConfiguration *config = [GameConfiguration sharedConfiguration];
		ControlType control = [config controlType];
		ControlButton button = [config controlButton];
		
		if( [config controlDirection] == kControlDirection4WayCar )
			joystick_ = [JoystickCar joystick];
		else
			joystick_ = [Joystick joystick];
		[self addChild:joystick_];

		switch (button) {
			case kControlButton0:
				[joystick_ setButton:BUTTON_A enabled:NO];
			case kControlButton1:
				[joystick_ setButton:BUTTON_B enabled:NO];
				break;
			case kControlButton2:
				// both buttons are enabled by default, no need to modify it
				break;
		}
		
		// The Hero is responsible for reading the joystick
		[[game_ hero] setJoystick:joystick_];		
		
		// enable button left/right only if using "Pad" controls
		
		[joystick_ setPadEnabled: NO];
		// pad + 4 direction is not implemented yet
		if( control==kControlTypePad) {

			[joystick_ setPadEnabled: YES];
			[joystick_ setPadPosition:ccp(74,74)];
		}
		
		CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(32,32,32,128) width:s.width height:40];
		[color setPosition:ccp(0,s.height-40)];
		[self addChild:color z:0];

		// Menu Button
		CCMenuItem *itemPause = [SoundMenuItem itemFromNormalSpriteFrameName:@"btn-pause-normal.png" selectedSpriteFrameName:@"btn-pause-selected.png" target:self selector:@selector(buttonRestart:)];
		CCMenu *menu = [CCMenu menuWithItems:itemPause,nil];
		[self addChild:menu z:1];
		[menu setPosition:ccp(20,s.height-20)];
		
		// Score Label
		CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:@"SCORE:" fntFile:@"gas32.fnt"];
		[scoreLabel.texture setAliasTexParameters];
		[self addChild:scoreLabel z:1];
		[scoreLabel setPosition:ccp(s.width/2+0.5f-45, s.height-20.5f)];
		
		// Score Points
		score_ = [CCLabelBMFont labelWithString:@"000" fntFile:@"gas32.fnt"];
//		[score_.texture setAliasTexParameters];
		[self addChild:score_ z:1];
		[score_ setPosition:ccp(s.width/2+0.5f+25, s.height-20.5f)];
		
		// Lives label
		CCLabelBMFont *livesLabel = [CCLabelBMFont labelWithString:@"LIVES:" fntFile:@"gas32.fnt"];
		[livesLabel.texture setAliasTexParameters];
		[self addChild:livesLabel z:1];
		[livesLabel setAnchorPoint:ccp(1,0.5f)];
		[livesLabel setPosition:ccp(s.width-5.5f-20, s.height-20.5f)];		
		
		lives_ = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", game_.lives] fntFile:@"gas32.fnt"];
		[lives_.texture setAliasTexParameters];
		[self addChild:lives_ z:1];
		[lives_ setAnchorPoint:ccp(1,0.5f)];
		[lives_ setPosition:ccp(s.width-5.5f, s.height-20.5f)];		
		
	}
	
	return self;
}

-(void) onUpdateScore:(int)newScore
{
	[score_ setString: [NSString stringWithFormat:@"%03d", newScore]];
	[score_ stopAllActions];
	id scaleTo = [CCScaleTo actionWithDuration:0.1f scale:1.2f];
	id scaleBack = [CCScaleTo actionWithDuration:0.1f scale:1];
	id seq = [CCSequence actions:scaleTo, scaleBack, nil];
	[score_ runAction:seq];
}

-(void) onUpdateLives:(int)newLives
{
	[lives_ setString: [NSString stringWithFormat:@"%d", newLives]];
	[lives_ runAction:[CCBlink actionWithDuration:0.5f blinks:5]];
}

-(void) displayMessage:(NSString*)message
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCLabelTTF *label = [CCLabelTTF labelWithString:message fontName:@"Marker Felt" fontSize:54];
	[self addChild:label];
	[label setPosition:ccp(s.width/2, s.height/2 + 30)];

	id sleep = [CCDelayTime actionWithDuration:3];
	id rot1 = [CCRotateBy actionWithDuration:0.025f angle:5];
	id rot2 = [CCRotateBy actionWithDuration:0.05f angle:-10];
	id rot3 = [rot2 reverse];
	id rot4 = [rot1 reverse];
	id seq = [CCSequence actions:rot1, rot2, rot3, rot4, nil];
	id repeat_rot = [CCRepeat actionWithAction:seq times:3];
	
	id big_seq = [CCSequence actions:sleep, repeat_rot, nil];
	id repeat_4ever = [CCRepeatForever actionWithAction:big_seq];
	[label runAction:repeat_4ever];
	
	CCMenuItem *item1 = [CCMenuItemFont itemFromString:@"Play Again" target:self selector:@selector(playAgain:)];
	CCMenuItem *item2 = [CCMenuItemFont itemFromString:@"Main Menu" target:self selector:@selector(mainMenu:)];
	CCMenu *menu = [CCMenu menuWithItems:item1, item2, nil];
	[menu alignItemsVertically];
	[menu setPosition:ccp(s.width/2, s.height/3)];
	
	[self addChild:menu z:10];
}

-(void) playAgain:(id)sender
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[[game_ class] scene] ] ];
}

-(void) mainMenu:(id)sender
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionCrossFade transitionWithDuration:1 scene:[MenuScene scene]]];
}

-(void) buttonRestart:(id)sender
{
//    [game_ togglePause];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionCrossFade transitionWithDuration:1 scene:[MenuScene scene]]];
}

- (void) dealloc
{
	[super dealloc];
}


#pragma mark Touch Handling

-(void) registerWithTouchDispatcher
{
	// Priorities: lower number, higher priority
	// Joystick: 10
	// GameNode (dragging objects): 50
	// HUD (dragging screen): 100
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:100 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

// drag the screen
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
	
	CGPoint diff = ccpSub(touchLocation,prevLocation);
	game_.cameraOffset = ccpAdd( game_.cameraOffset, diff );
}

@end
