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
// Level2:
//
// Details:
//
// It uses 2 batch nodes:
//
//  * 1 batch node for the sprites
//  * 1 batch node for the platorms
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

#import "Level2.h"
#import "BodyNode.h"
#import "Box2dDebugDrawNode.h"
#import "GameConfiguration.h"


@implementation Level2
-(void) initGraphics
{	
	// sprites
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
	// platforms
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];

	//
	// TIP
	// Use 16-bit texture in background. It consumes half the memory
	//
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
	CCSprite *background = [CCSprite spriteWithFile:@"background3.png"];
	background.anchorPoint = ccp(0,0);
	
	// Restore 32-bit texture format
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
	
	// weak ref
	spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];
	
	// weak ref
	platformBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"platforms.png" capacity:10];
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[platformBatchNode_.texture setTexParameters:&params];
	
	//
	// Parallax Layers
	//
	CCParallaxNode *parallax = [CCParallaxNode node];
	
	// background is parallaxed
	[parallax addChild:background z:-10 parallaxRatio:ccp(0.08f, 0.08f) positionOffset:ccp(-30,-30)];
	
	// TIP: Disable this node in release mode
	// Box2dDebug draw in front of background
	if( [[GameConfiguration sharedConfiguration] enableWireframe] ) {
		Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];
		[parallax addChild:b2node z:30 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	}
	
	// batchnodes: platforms should be drawn before sprites
	[parallax addChild:platformBatchNode_ z:5 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	[parallax addChild:spritesBatchNode_ z:10 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	
	[self addChild:parallax];
}

- (void) dealloc
{
	[super dealloc];
}

-(CGRect) contentRect
{
	// These values were obtained from Inkscape
	return CGRectMake(-313, -120, 1240, 464);
}

-(NSString*) SVGFileName
{
	return @"level2.svg";
}

// This is the default behavior
-(void) addBodyNode:(BodyNode*)node z:(int)zOrder
{
	switch (node.preferredParent) {
		case BN_PREFERRED_PARENT_SPRITES_PNG:
		
			// Add to sprites' batch node
			[spritesBatchNode_ addChild:node z:zOrder];
			break;

		case BN_PREFERRED_PARENT_PLATFORMS_PNG:
			// Add to platform batch node
			[platformBatchNode_ addChild:node z:zOrder];
			break;
			
		default:
			CCLOG(@"Level2: Unknonw preferred parent");
			break;
	}
}

@end