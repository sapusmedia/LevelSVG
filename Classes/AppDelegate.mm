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
#import "AppDelegate.h"
#import "IntroScene.h"


@interface AppDelegate (Sounds)
-(void) initSounds;
@end

@implementation AppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any othe call to the director
	[CCDirector setDirectorType:kCCDirectorTypeDisplayLink];
	
	// before creating any layer, set the landscape mode
	CCDirector *director = [CCDirector sharedDirector];
	
	// landscape orientation
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// set FPS at 60
	[director setAnimationInterval:1.0/60];
	
	// Display FPS ?
//	[director setDisplayFPS:YES];
	
	// Create an EAGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:0	// GL_DEPTH_COMPONENT24_OES
						];

	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// To use High-Res un comment the following line
//	[director setContentScaleFactor:2];	
	
	// make the OpenGLView a child of the main window
	[window addSubview:glView];
	
	// make main window visible
	[window makeKeyAndVisible];	
	
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
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
