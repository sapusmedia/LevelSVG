//
//  Level1.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 06/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


//
// Level1:
//
// Details:
//
// It uses 1 batch node for the sprites
// The box2d objects are rendered using 1 big image (see level1.png)
//
// How to create a similar level ?
//	1. Open Inkscape and create a new document of 480x320. Actually it can be of any size, but it is useful as a reference.
//		-> Inkscape -> File -> Document Properties -> Custom size: width=480, height=320
//	2. Create 1 layer:
//		-> physics:objects
//	3. Design the world
//	4. Once you finish it, duplicate that layer
//		-> Inkscape -> Layer -> Duplicate current Layer
//	5. Rename the new layer to: "graphics"
//	6. Select the "graphics" layer and "paint it".
//	7. Disable the "physics:objects" layer
//		-> Inkscape -> Layer -> Layers -> click on the "eye" of "physics:objects" layer
//	8. Export the image as bitmap
//		-> Inkscape -> File -> Page
//	9. The new exported image (level1.png) will be used as the background image
//
//
// IMPORTANT: gravity and controls are read from the svg file
//

#import "Level1.h"
#import "BodyNode.h"
#import "Box2dDebugDrawNode.h"

@implementation Level1
-(void) initGraphics
{
	// sprites
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];

	// The physics world is drawn using 1 big image
	CCSprite *background = [CCSprite spriteWithFile:@"level1.png"];
	[background setAnchorPoint:ccp(0,0)];
//	// TIP: The correct postion can be obtained from Inkscape
	[background setPosition:ccp(-1,5.829f)];
	[self addChild:background z:-10];
	
	// TIP: Disable this node in release mode
	// Box2dDebug draw in front of background
//	Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];
//	[self addChild:b2node z:0];
	
	// weak ref
	spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];	
	[self addChild:spritesBatchNode_ z:10];
	
	
	// The size of the map is the size of the background image
	[self setContentSize:[background contentSize]];
}

- (void) dealloc
{
	[super dealloc];
}

-(CGRect) contentRect
{
	return CGRectMake(-1, -6, contentSize_.width, contentSize_.height);
}

-(NSString*) SVGFileName
{
	return @"level1.svg";
}

// This is the default behavior
-(void) addBodyNode:(BodyNode*)node z:(int)zOrder
{
	switch (node.preferredParent) {
		case BN_PREFERRED_PARENT_SPRITES_PNG:
			[spritesBatchNode_ addChild:node z:zOrder];
			break;
		default:
			NSAssert(NO,@"default unsupported");
			break;
	}
}
@end
