//
//  Playground1.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 11/02/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "Playground1.h"
#import "Box2dDebugDrawNode.h"
#import "BodyNode.h"

@implementation Playground1

-(void) initGraphics
{	
	// sprites
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
	
	// TIP: Disable this node in release mode
	// Box2dDebug draw in front of background
	Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];
	[self addChild:b2node z:0];
	
	// weak ref
	spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];
	[self addChild:spritesBatchNode_ z:10];	
}

-(CGRect) contentRect
{
	// These values were obtained from Inkscape
	return CGRectMake(-264, -142, 1110, 501);
}

-(NSString*) SVGFileName
{
	return @"playground1.svg";
}

// This is the default behavior
-(void) addBodyNode:(BodyNode*)node z:(int)zOrder
{
	switch (node.preferredParent) {
		case BN_PREFERRED_PARENT_SPRITES_PNG:
			[spritesBatchNode_ addChild:node z:zOrder];
			break;
		default:
			CCLOG(@"Unknown preferred parent");
			break;
	}
}
@end
