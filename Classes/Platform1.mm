//
//  Platform1.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 03/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameConstants.h"
#import "Platform1.h"

//
// Platform1: A one-sided platform. It uses the "platform.png" as a texture
//
// Supported parameters:
//	visible (string): "no" means that this will be an invisible platform
//

@implementation Platform1

-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game])) {
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"platform.png"];
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
				CCLOG(@"LevelSVG: Platform1 with unsupported number of vertices: %d", box->GetVertexCount() );
		} else
			CCLOG(@"LevelSVG: Platform1 with unsupported shape type");
	}
	return self;
}

-(void) setParameters:(NSDictionary*)params
{
	[super setParameters:params];
	
	NSString *visible = [params objectForKey:@"visible"];
	if( [visible isEqual:@"no"] )
		[self setVisible:NO];
	else
		[self setVisible:YES];
}
@end
