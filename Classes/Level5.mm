//
//  Level5.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 07/07/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


//
// Level5:
//
// Details:
//
// It uses 2 batch nodes:
//
//  * 1 batch node for the sprites
//  * 1 batch node for the platforms
//
// Why ?
// Becuase the platforms uses a different a different texture parameter
// When you using batch nodes, all the sprites MUST share the same texture and the same texture parameters
//
// TIP:
// The platforms used in this level uses the GL_REPEAT texture parameter.
// If you open the platforms.png file, you will notice the both images are 128x128. This is on purpose. You can't add more images horizontally.
// But you can add more images vertically... (only if the platforms are not higher than 128 pixels).
//
// It also uses a Parallax with 3 children:
//  - background image
//  - platforms
//  - sprites (hero, fruits, princess, etc)
//
//
// How to create a similar level ?
//	1. Open Inkscape and create a new document of 480x320. Actually it can be of any size, but it is useful as a reference.
//		-> Inkscape -> File -> Document Properties -> Custom size: width=480, height=320
//	2. Create 1 layer:
//		-> physics:objects
//	3. Start designing the world.
//
// IMPORTANT: gravity and controls are read from the svg file
//

#import "Level5.h"
#import "BodyNode.h"
#import "Box2dDebugDrawNode.h"


@implementation Level5

-(id) init
{
	if ((self=[super init]) ) {
		
		// override box2d configuration
		
		// The car needs more iterations
		worldVelocityIterations_ = 10;
		worldPositionIterations_ = 10;
		
		
		// custom lives
		lives_ = 1;
	}
	
	return self;
}
-(void) initGraphics
{	
	// sprites
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];

	// platforms
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];

	// weak ref
	spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];

	// Invisible batch node. It contains the invisible nodes
	invisibleBatchNode_ = [CCSpriteBatchNode batchNodeWithTexture:nil capacity:10];
	invisibleBatchNode_.visible = NO;		

	// weak ref
	platformBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"platforms.png" capacity:10];
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[platformBatchNode_.texture setTexParameters:&params];
	
	//
	// TIP
	// Use 16-bit texture in background. It consumes half the memory
	//
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
	CCSprite *background = [CCSprite spriteWithFile:@"background3.png"];
	background.anchorPoint = ccp(0,0);

	// Restore 32-bit texture format
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];

	//
	// Parallax Layers
	//
	CCParallaxNode *parallax = [CCParallaxNode node];
	
	// background is parallaxed
	[parallax addChild:background z:-10 parallaxRatio:ccp(0.08f, 0.08f) positionOffset:ccp(-30,-30)];
	
	// TIP: Disable this node in release mode
	// Box2dDebug draw in front of background
//	Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];
//	[parallax addChild:b2node z:0 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	
	// batch nodes: platforms should be drawn before sprites
	[parallax addChild:platformBatchNode_ z:5 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	[parallax addChild:spritesBatchNode_ z:10 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	[parallax addChild:invisibleBatchNode_ z:10 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	
	[self addChild:parallax];
}

- (void) dealloc
{
	[super dealloc];
}

-(CGRect) contentRect
{
	// These values were obtained from Inkscape
	return CGRectMake(-5, -60, 6890, 511);
}

-(NSString*) SVGFileName
{
	return @"level5.svg";
}

// This is the default behavior
-(void) addBodyNode:(BodyNode*)node z:(int)zOrder
{
	switch (node.preferredParent) {
		case BN_PREFERRED_PARENT_SPRITES_PNG:
			[spritesBatchNode_ addChild:node z:zOrder];
			break;
			
		case BN_PREFERRED_PARENT_PLATFORMS_PNG:
			// Add to platform batch node
			[platformBatchNode_ addChild:node z:zOrder];
			break;

		case BN_PREFERRED_PARENT_IGNORE:
			[invisibleBatchNode_ addChild:node z:zOrder];
			break;
			
		default:
			NSAssert(NO, @"LevelSVG Level0#addBodyNode unsupported preferred parent");
			break;
	}
}

@end