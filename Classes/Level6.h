//
//  Level6.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 17/09/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "GameNode.h"


@interface Level6 : GameNode
{
	// batch nodes weak ref
	CCSpriteBatchNode	*spritesBatchNode_;

	// batch nodes weak ref
	CCSpriteBatchNode	*invisibleBatchNode_;
	
	CCSpriteBatchNode	*platformBatchNode_;
}

@end
