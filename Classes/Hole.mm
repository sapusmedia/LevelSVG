//
//  Hole.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 05/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameNode.h"
#import "GameConstants.h"
#import "Hole.h"

//
// Hole: an static object that can kill the Hero
//

@implementation Hole
-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game]) ) {
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"sprite_hole_01.png"];
		[self setDisplayFrame:frame];

		// bodyNode properties
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		isTouchable_ = NO;

	}
	return self;
}
@end
