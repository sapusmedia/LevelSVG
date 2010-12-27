//
//  HeroCar.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 7/07/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "Hero.h"

// The wheels
@interface WheelNode : BodyNode
{
	// sprite is blinking
	BOOL	isBlinking_;

	// collision detection stuff, needed for jumping
@public
	ContactPoint			contactPoints_[kMaxContactPoints];
	int32					contactPointCount_;
}
@end

// The car
@interface Herocar : Hero {
	// weak references
	WheelNode			*wheel1Node_, *wheel2Node_;

	b2Body				*wheel1_;
	b2Body				*wheel2_;

	b2Body				*axle1_;
	b2Body				*axle2_;

	b2PrismaticJoint	*spring1_;
	b2PrismaticJoint	*spring2_;
	b2RevoluteJoint		*motor1_;
	b2RevoluteJoint		*motor2_;
	
	float				baseSpringForce_;
}

@end
