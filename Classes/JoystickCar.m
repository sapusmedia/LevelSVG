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


#import "JoystickCar.h"
#import "cocos2d.h"

@implementation JoystickCar


+(id) joystick
{
	return [[[self alloc] init] autorelease];
}

-(id)init
{
	if( (self = [super init]) )
	{
		self.isTouchEnabled = YES;

		CGSize winSize = [[CCDirector sharedDirector] winSize];
		// buttons
		for( int i=0; i<JOYSTICK_CAR_MAX; i++) {
			
			NSString	*buttonName;
			CGPoint		pos;
			
			switch (i) {
				case JOYSTICK_CAR_UP:
					buttonName = @"arrow_up.png";
					pos = ccp(37,37);
					break;
				case JOYSTICK_CAR_DOWN:
					buttonName = @"arrow_down.png";
					pos = ccp(37*3,37);
					break;
				case JOYSTICK_CAR_LEFT:
					buttonName = @"arrow_left.png";
					pos = ccp(winSize.width-37*3,37);
					break;
				case JOYSTICK_CAR_RIGHT:
					buttonName = @"arrow_right.png";
					pos = ccp(winSize.width-37,37);
					break;
				default:
					NSAssert(NO, @"should not happen");
					break;
			}
			buttons_[i].sprite_ = [CCSprite spriteWithSpriteFrameName:buttonName];
			CGSize s = [buttons_[i].sprite_ contentSize];
			buttons_[i].sprite_.position = pos;

			[self addChild:buttons_[i].sprite_ z:10];
			
			// all buttons are enabled by default
			buttons_[i].enabled_ = YES;
			buttons_[i].isPressed_ = NO;
			buttons_[i].touch_ = nil;
			buttons_[i].bounds_ = CGRectMake( pos.x - s.width/2, pos.y - s.height/2, s.width, s.height);
		}		
	}
	return self;
}

- (void) dealloc
{
	// Anything to dealloc ? No.
	[super dealloc];
}

#pragma mark Joystick - Buttons

-(BOOL) isPadEnabled
{
	return YES;
}

-(void) setPadEnabled:(BOOL)enabled
{
	// ignore
}
-(void) setPadPosition:(CGPoint)pos
{
	// ignore
}

-(CGPoint) getCurrentNormalizedVelocity
{
	CGPoint	ret = CGPointZero;
	
	if( buttons_[JOYSTICK_CAR_UP].isPressed_ )
		ret.y = 1;
	else if( buttons_[JOYSTICK_CAR_DOWN].isPressed_ )
		ret.y = -1;
	   
	if( buttons_[JOYSTICK_CAR_LEFT].isPressed_ )
		ret.x = -1;
	else if( buttons_[JOYSTICK_CAR_RIGHT].isPressed_ )
		ret.x = 1;
	
	return ret;
}

-(CGPoint) getCurrentVelocity
{
	return [self getCurrentNormalizedVelocity];
}

-(CGPoint) getCurrentDegreeVelocity
{
	// ignore
	return CGPointZero;
}

-(BOOL) isButtonPressed:(unsigned int)buttonNumber
{
	return NO;
}

-(BOOL) isButtonEnabled:(unsigned int)buttonNumber
{
	return NO;
}

-(void) setButton:(unsigned int)buttonNumber enabled:(BOOL)enabled
{
}

-(void) setPosition:(CGPoint)position forButton:(unsigned int)buttonNumber
{
	// ignore
}

#pragma mark Joystick - touch delegate
-(void) registerWithTouchDispatcher
{
	// Priorities: lower number, higher priority
	// Joystick: 10
	// GameNode (dragging objects): 50
	// HUD (dragging screen): 100
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:10 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
		
	// button ?
	for( int i=0; i < JOYSTICK_CAR_MAX;i++) {
		if( buttons_[i].enabled_ && CGRectContainsPoint(buttons_[i].bounds_ , location) )
		{
			buttons_[i].isPressed_ = YES;
			buttons_[i].touch_ = touch;
			buttons_[i].sprite_.color = (ccColor3B) {255,0,255};
			return YES;
		}
	}
	
	return NO;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	for( int i=0;i < JOYSTICK_CAR_MAX; i++) {
		if( touch == buttons_[i].touch_ ) {
			buttons_[i].touch_ = nil;
			buttons_[i].isPressed_ = NO;
			buttons_[i].sprite_.color = (ccColor3B) {255,255,255};
			
			return;
		}
	}
}

-(void)ccTouchCancelled:(UITouch*)touch withEvent:(UIEvent*)event
{
	[self ccTouchEnded:touch withEvent:event];
}

@end
