//
//  Bullet.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 05/05/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2D/Box2D.h>
#import "BodyNode.h"


@interface Bullet : BodyNode {

	ccTime	elapsedTime_;
	
	b2World	*world_;	// weak reference
}

// postion of the bullet
// direction: -1 is left, 1 is right
-(id) initWithPosition:(b2Vec2)position direction:(int)direction game:(GameNode*)game;

@end
