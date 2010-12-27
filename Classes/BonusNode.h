//
//  BonusNode.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 24/03/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BodyNode.h"


@interface BonusNode : BodyNode {
	
	float	respawnTime_;
	
	// needed in case it needs to be respawned
	b2Vec2	bodyPosition_;
}

// the bonus object was touched by the hero. What should it do ?
-(void) touchedByHero;

@end
