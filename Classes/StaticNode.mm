/*
 * Copyright (c) 2009-2011 Ricardo Quesada
 * Copyright (c) 2011-2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameNode.h"
#import "GameConstants.h"
#import "StaticNode.h"

//
// StaticNode: subclass this class if you want to move box2d objects manually (eg: using cocos2d actions)
//

@implementation StaticNode
-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game]) ) {
		//
		// TIP:
		// Tell the engine not to update the sprite. It will be updated manually
		//
		properties_ = properties_ & ~BN_PROPERTY_SPRITE_UPDATED_BY_PHYSICS;
		
		//
		// TIP: Static bodies won't collide with static and kinematic bodies
		//
		body->SetType(b2_staticBody);
		
	}
	return self;
}

-(void) setPosition:(CGPoint)position
{
	[super setPosition:position];
	body_->SetTransform( b2Vec2( position_.x / kPhysicsPTMRatio, position_.y / kPhysicsPTMRatio),  - CC_DEGREES_TO_RADIANS(rotation_) );
}

-(void) setRotation:(float)angle
{
	[super setRotation:angle];
	body_->SetTransform( b2Vec2( position_.x / kPhysicsPTMRatio, position_.y / kPhysicsPTMRatio),  - CC_DEGREES_TO_RADIANS(rotation_) );
}
@end
