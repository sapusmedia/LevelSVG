//
//  Level4.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 06/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "GameNode.h"


@interface Level4 : GameNode
{
	// batch nodes weak ref
	CCSpriteBatchNode	*spritesBatchNode_;
	CCSpriteBatchNode	*invisibleBatchNode_;
	CCSpriteBatchNode	*platformBatchNode_;
}

@end
