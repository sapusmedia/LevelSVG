/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Jason Booth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "Joystick.h"
#import "cocos2d.h"

@implementation Joystick

@synthesize padPosition=padPosition_;

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

		// pad
		spritePad_ = [CCSprite spriteWithSpriteFrameName:@"joystick.png"];
		CGSize s = [spritePad_ contentSize];
		spritePad_.position = ccp(s.width/2, s.height/2);
		[self addChild:spritePad_ z:10];
		padEnabled_ = YES;
		padBounds = CGRectMake(0, 0, s.width, s.height);
		padTouch = nil;

		// buttons
		for( int i=0; i<BUTTON_MAX; i++) {
			buttons_[i].sprite_ = [CCSprite spriteWithSpriteFrameName:@"jump.png"];
			s = [buttons_[i].sprite_ contentSize];
			buttons_[i].sprite_.position = ccp(winSize.width - (s.width) *(i+1) + s.width/2, s.height/2);

			[self addChild:buttons_[i].sprite_ z:10];
			
			// all buttons are enabled by default
			buttons_[i].enabled_ = YES;
			buttons_[i].isPressed_ = NO;
			buttons_[i].touch_ = nil;
			buttons_[i].bounds_ = CGRectMake( winSize.width - s.width * (i+1), 0, s.width, s.height);
		}		
	}
	return self;
}

- (void) dealloc
{
	// Anything to dealloc ? No.
	[super dealloc];
}

#pragma mark Joystick - TouchDispatcher

-(CGPoint)getCurrentVelocity
{
	CGPoint ret = CGPointZero;
	if( padTouch )
		ret = CGPointMake(padCurPosition.x - padPosition_.x, padCurPosition.y - padPosition_.y);
	
	return ret;
}

-(CGPoint)getCurrentNormalizedVelocity
{
	CGPoint ret = CGPointZero;
	if( padTouch ) {
		ret = CGPointMake(padCurPosition.x - padPosition_.x, padCurPosition.y - padPosition_.y);
		ret = ccpNormalize(ret);
	}
	
	return ret;
}

-(CGPoint)getCurrentDegreeVelocity
{
	CGPoint ret = CGPointZero;
	
	if( padTouch ) {
		float dx = padPosition_.x - padCurPosition.x;
		float dy = padPosition_.y - padCurPosition.y;
		CGPoint vel = [self getCurrentVelocity];
		vel.y = ccpLength(vel);
		vel.x = atan2f(-dy, dx) * (180/3.1415f);
		ret = vel;
	}
	return ret;
}

#pragma mark Joystick - Buttons

-(BOOL) isButtonPressed:(unsigned int)buttonNumber
{
	return buttons_[buttonNumber].isPressed_;
}

-(BOOL) isButtonEnabled:(unsigned int)buttonNumber
{
	return buttons_[buttonNumber].enabled_;
}

-(void) setButton:(unsigned int)buttonNumber enabled:(BOOL)enabled
{
	if( enabled != buttons_[buttonNumber].enabled_ ) {
		buttons_[buttonNumber].enabled_ = enabled;
		buttons_[buttonNumber].sprite_.visible = enabled;
	}
}

-(void) setPosition:(CGPoint)position forButton:(unsigned int)buttonNumber
{
	buttons_[buttonNumber].sprite_.position = position;
}

#pragma mark Joystick - Pad

-(BOOL) isPadEnabled
{
	return padEnabled_;
}

-(void) setPadEnabled:(BOOL)enabled
{
	if( enabled != padEnabled_ ) {
		padEnabled_ = enabled;
		spritePad_.visible = enabled;
	}
}


#pragma mark Joystick - touch delegate
-(void) registerWithTouchDispatcher
{
	// Priorities: lower number, higher priority
	// Joystick: 10
	// GameNode (dragging objects): 50
	// HUD (dragging screen): 100
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:10 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	
	// pad ?
    if ( padEnabled_ && CGRectContainsPoint(padBounds, location))
    {
		padCurPosition = CGPointMake(location.x, location.y);
		padTouch = touch;		
		spritePad_.color = (ccColor3B) { 255,0,255};
		return YES;
	}
	
	// button ?
	for( int i=0; i < BUTTON_MAX;i++) {
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

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( touch == padTouch )
		padCurPosition = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];	
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( touch == padTouch ) {
		padTouch = nil;
		spritePad_.color = (ccColor3B) { 255,255,255};
	}
	
	else {
		for( int i=0;i < BUTTON_MAX; i++) {
			if( touch == buttons_[i].touch_ ) {
				buttons_[i].touch_ = nil;
				buttons_[i].isPressed_ = NO;
				buttons_[i].sprite_.color = (ccColor3B) {255,255,255};
				
				return;
			}
		}
	}
}

-(void)ccTouchCancelled:(UITouch*)touch withEvent:(UIEvent*)event
{
	[self ccTouchEnded:touch withEvent:event];
}

@end
