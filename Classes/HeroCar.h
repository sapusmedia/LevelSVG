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
