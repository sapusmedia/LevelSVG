//
//  AppDelegate.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 12/09/09.
//  Copyright Sapus Media 2009. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//


// cocos2d and cocosdenshion imports
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

// local imports
#import "RootViewController.h"
#import "AppDelegate.h"
#import "IntroScene.h"


@interface AppDelegate (Sounds)
- (void) initSounds;
- (void) removeStartupFlicker;
@end

@implementation AppDelegate

@synthesize window=window_;
@synthesize viewController=viewController_;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if your Application only supports landscape mode
	//
	
	//	CC_ENABLE_DEFAULT_GL_STATES();
	//	CCDirector *director = [CCDirector sharedDirector];
	//	CGSize size = [director winSize];
	//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
	//	sprite.position = ccp(size.width/2, size.height/2);
	//	sprite.rotation = -90;
	//	[sprite visit];
	//	[[director openGLView] swapBuffers];
	//	CC_ENABLE_DEFAULT_GL_STATES();
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		
	// before creating any layer, set the landscape mode
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the view controller
	viewController_ = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController_.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:0	// GL_DEPTH_COMPONENT24_OES
						];
	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// To use High-Res un comment the following line
	if (![director enableRetinaDisplay:YES]) {
		CCLOG(@"Retina Display Not supported");
	}
	
	[director setAnimationInterval:1.0f/60.0f];
	// Display FPS ?
	//	[director setDisplayFPS:YES];

	// make the OpenGLView a child of the view controller
	[viewController_ setView:glView];
	
	// make the View Controller a child of the main window
	[window_ addSubview:viewController_.view];
	
	// make main window visible
	[window_ makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];	


	// Init sounds
	[self initSounds];
	
	// Run
	[[CCDirector sharedDirector] runWithScene: [IntroScene scene]];
}

- (void)initSounds
{
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"pickup_coin.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"you_won.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"you_are_hit.wav"];

}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	// TIP:
	// Stop the director mainloop.
	// Callback only called in iOS >=4 and in multitasking devices
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	// TIP:
	// Resume the director mainloop.
	// Callback only called in iOS >=4 and in multitasking devices
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{	
	// TIP:
	// Save the game state here
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController_ release];
	
	[window_ release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window_ release];
	[viewController_ release];
	[super dealloc];
}

@end
