//
//  Portal.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 06/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BodyNode.h"


@interface Portal : BodyNode {

	// Where should the hero be teleported ?
	CGPoint teleportTo_;
}

/** Where should the hero be teleported ? */
@property (readwrite,nonatomic) CGPoint teleportTo;

// the bonus object was touched by the hero. What should it do ?
-(void) touchedByHero;

@end
