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
// Level3:
//
// Details:
//
// It uses 1 batch node for the sprites
// The platforms are rendered using 1 big image (see level3.png)
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
//	9. The new exported image (level3.png) will be used as the background image
//
//
// IMPORTANT: gravity and controls are read from the svg file
//

#import "Level3.h"
#import "BodyNode.h"
#import "Box2dDebugDrawNode.h"
#import "GameConfiguration.h"


@implementation Level3
-(void) initGraphics
{	
	// sprites
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
	
	// TIP: Disable this node in release mode
	// Box2dDebug draw in front of background
	if( [[GameConfiguration sharedConfiguration] enableWireframe] ) {
		Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];
		[self addChild:b2node z:30];
	}

	// weak ref
	spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];
	[self addChild:spritesBatchNode_ z:10];
	
	// The physics world is drawn using 1 big image
	CCSprite *background = [CCSprite spriteWithFile:@"level3.png"];
	[background setAnchorPoint:ccp(0,0)];
	//	// TIP: The correct postion can be obtained from Inkscape
	[background setPosition:ccp(-148.5f, -125.f)];
	[self addChild:background z:-10];
	
}

- (void) dealloc
{
	[super dealloc];
}

-(NSString*) SVGFileName
{
	return @"level3.svg";
}

-(CGRect) contentRect
{
	// These values were obtained from Inkscape
	return CGRectMake(-148, -125, 983, 490);
}

// This is the default behavior
-(void) addBodyNode:(BodyNode*)node z:(int)zOrder
{
	switch (node.preferredParent) {
		case BN_PREFERRED_PARENT_SPRITES_PNG:
			[spritesBatchNode_ addChild:node z:zOrder];
			break;
		default:
			NSAssert(NO, @"LevelSVG Level0#addBodyNode unsupported preferred parent");
			break;
	}
}

@end