//
//  Box2dDebugDrawNode.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 05/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//


#import <Box2D/Box2D.h>
#import "cocos2d.h"

#import "GLES-Render.h"


@interface Box2dDebugDrawNode : CCNode {
	b2World			*world_;
	GLESDebugDraw	*debugDraw_;
}

+(id) nodeWithWorld:(b2World*)world;
-(id) initWithWorld:(b2World*)world;

@end
