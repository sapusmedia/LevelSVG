//
//  HeroCarTopDown.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 11/12/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "Hero.h"

// The car
@interface Herocartopdown : Hero {

	// weak ref
	b2Body	*leftWheel_;
	b2Body	*rightWheel_;
	b2Body	*leftRearWheel_;
	b2Body	*rightRearWheel_;

	b2RevoluteJoint *leftJoint_;
	b2RevoluteJoint *rightJoint_;
	
	float	engineSpeed_;
	float	steeringAngle_;
}

@end
