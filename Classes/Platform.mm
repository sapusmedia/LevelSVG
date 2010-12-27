//
//  Platform.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 04/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameConstants.h"
#import "Platform.h"

//
// Platform: A solid plaform. It uses the "solid_platform.png" texture
//

@implementation Platform
-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game])) {
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"solid_platform.png"];
		[self setDisplayFrame:frame];

		// bodyNode properties
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_PLATFORMS_PNG;
		isTouchable_ = NO;
		
		[self setAnchorPoint: ccp(0,1)];
		
		CGSize size = CGSizeZero;
		
		b2Fixture *fixture = body->GetFixtureList();
		
		b2Shape::Type t = fixture->GetType();
		
		if( t ==  b2Shape::e_polygon ) {
			b2PolygonShape *box = dynamic_cast<b2PolygonShape*>(fixture->GetShape());
			if( box->GetVertexCount() == 4 ) {
				size.width = box->GetVertex(2).x * kPhysicsPTMRatio;
				size.height = -box->GetVertex(0).y * kPhysicsPTMRatio;
				
				[self setTextureRect:CGRectMake(rect_.origin.x, rect_.origin.y, size.width, size.height)];				 
				
			} else
				CCLOG(@"LevelSVG: Platform with unsupported number of vertices: %d", box->GetVertexCount() );
		} else
			CCLOG(@"LevelSVG: Platform with unsupported shape type");
	}
	return self;
}
@end
