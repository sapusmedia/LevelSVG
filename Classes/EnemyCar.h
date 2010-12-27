//
//  EnemyCar.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 17/09/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BadGuy.h"


@interface Enemycar : BadGuy <BodyNodeBulletProtocol> {
	float motorRPM_;

	b2Body		*wheelLeft_;
	b2Body		*wheelRight_;
	b2Body		*suspensionLeft_;
	b2Body		*suspensionRight_;

	b2RevoluteJoint		*motor_;
}

@end
