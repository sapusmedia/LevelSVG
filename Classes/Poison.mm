//
//  Poison.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 06/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameNode.h"
#import "GameConstants.h"
#import "Poison.h"

//
// Poison: An invisible, static object that can kill the hero.
// It is invisible because it should be drawn using a tiled map.
//

@implementation Poison
-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game]) ) {
		
		// bodyNode properties
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_IGNORE;
		isTouchable_ = NO;
	}
	return self;
}

@end
