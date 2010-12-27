//
//  HeroBox.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 12/02/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "Hero.h"


@interface Herobox : Hero {
	
	// is the hero facing right or left (for bullets)
	BOOL	facingRight_;
	struct timeval	lastFire_;
	
	BOOL	antiGravityForce_;
	BOOL	touchingGround_;
}

@end
