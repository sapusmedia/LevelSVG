//
//  Enemy.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 03/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BadGuy.h"


@interface Enemy : BadGuy <BodyNodeBulletProtocol> {

	BOOL	patrolActivated_;
	BOOL	patrolDirectionLeft_;
	float	patrolTime_;
	float	patrolSpeed_;
	ccTime	patrolDT_;
}

@end
