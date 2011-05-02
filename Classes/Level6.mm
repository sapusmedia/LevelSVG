//
//  Level6.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 17/09/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "Level6.h"
#import "BodyNode.h"
#import "Box2dDebugDrawNode.h"
#import "GameConfiguration.h"

// 
// Level6
//
// Details:
//
// Instead of rendering the platoforms using the "self-render" platform objects,
// it uses a TMX tiled map.
// Both approaches have the same speed since both renders the plaforms using a TextureAtlas
//
// Pros/Cons of using TMX tiles for platforms:
//   + platforms are visually richer
//   - platforms can only be aligned horzintally
//
// It also uses a Parallax with 3 children:
//  - background image
//  - TMX tiled map
//  - sprites (hero, fruits, princess, etc)
//
//
// How to create a similar level ?
//
//	1. Create a tile map using Tiled ( http://mapeditor.org ). Tiled is supported by cocos2d
//	2. Save the project as "level4.tmx". 
//	3. Save the project as an image: "level4.png". This image is not used in the game
//		-> Tiled -> File -> Save As Image
//	4. Open Inkscape and create a new document of 480x320. Actually it can be of any size, but 480x320 is useful as a reference.
//		-> Inkscape -> File -> Document Properties -> Custom size: width=480, height=320
//	5. Create 2 layers:
//		-> physics:objects
//		-> tmx map
//	6. Select the "tmx map" layer, and import the "level4.png" image.
//		-> Inkscape -> File -> Import -> Select "level4.png"
//	7. Place the image at (0,0)
//		-> Select the image and modify x=0, y=0
//	8. Select the "physics:object" layer and start placing your physics object!
//
//
// IMPORTANT: gravity and controls are read from the svg file
//

@implementation Level6

-(void) initGraphics
{	
	// sprites
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
	
	//
	// Parallax Layers
	//
	CCParallaxNode *parallax = [CCParallaxNode node];
	
	// Background
	// TIP: Use 16-bit texture in background. It consumes half the memory
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
	CCSprite *background = [CCSprite spriteWithFile:@"background2.png"];
	background.anchorPoint = ccp(0,0);
	// Restore 32-bit texture format
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
	[parallax addChild:background z:-10 parallaxRatio:ccp(0.08f, 0.08f) positionOffset:ccp(-50,-50)];
	
	// Box2d debug info: 
	// TIP: Disable this node in release mode
	// Box2dDebug draw in front of background
	if( [[GameConfiguration sharedConfiguration] enableWireframe] ) {
		Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];	
		[parallax addChild:b2node z:30 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	}
		
	// tiled
	CCTMXTiledMap *tiled = [CCTMXTiledMap tiledMapWithTMXFile:@"level6.tmx"];
	[parallax addChild:tiled z:8 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];

	// sprites' batch node
	spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];
	
	// weak ref
	platformBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"platforms.png" capacity:10];
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[platformBatchNode_.texture setTexParameters:&params];
	
	// void batch node, for invisible nodes
	invisibleBatchNode_ = [CCSpriteBatchNode batchNodeWithTexture:nil];
	invisibleBatchNode_.visible = NO;

	// add batch nodes to parallax
	[parallax addChild:spritesBatchNode_ z:10 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	[parallax addChild:invisibleBatchNode_ z:10 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	[parallax addChild:platformBatchNode_ z:10 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];

	[self addChild:parallax];
	
	// The size of the map is the size of the TMX map
	[self setContentSize:[tiled contentSize]];

}

- (void) dealloc
{
	[super dealloc];
}

-(CGRect) contentRect
{
	// it is the size of "self", which is the size of the TMX map.
	return CGRectMake(0, 0, contentSize_.width, contentSize_.height);
}

//
// GameNode callbacks
//
-(NSString*) SVGFileName
{
	return @"level6.svg";
}

// This is the default behavior
-(void) addBodyNode:(BodyNode*)node z:(int)zOrder
{
	switch ( node.preferredParent) {
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
			CCLOG(@"Unknown body class: %@", [node class]);
			break;
	}
}

@end