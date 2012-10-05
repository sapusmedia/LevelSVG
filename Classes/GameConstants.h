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



#pragma mark -
#pragma mark Physics - General

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define kPhysicsPTMRatio (40.0f)


// how many segments per bezier curve
// Try to reduce this value if you have lot of bezier curves and you also have performance problems
#define kPhysicsDefaultBezierSegments (15)

#pragma mark Physics - Bodies

// default friction used by all physics objects
#define kPhysicsDefaultFriction (0.2f)

// default density used by all physics objects. Default is static objects
#define kPhysicsDefaultDensity (0.0f)

// default restitution used by all physics objects.
#define kPhysicsDefaultRestitution (0.0f)

// default Enemy friction
#define kPhysicsDefaultEnemyFriction	(0.2f);

// default Enemy density
#define kPhysicsDefaultEnemyDensity		(0.3f)

// default Enemy Restitution
#define kPhysicsDefaultEnemyRestitution	(0.2f)


#pragma mark Physics - Forces and Impulses

// set to 1 to apply torque instead of force
//#define kPhysicsApplyTorque		1

// seconds that must elpase before a force is applied to the hero
#define kPhysicsHeroForceInterval (0.2f)

// gravity
#define kPhysicsWorldGravityX	(0)
#define kPhysicsWorldGravityY	(-10)

// How many nodes can be removed per cycle
#define kMaxNodesToBeRemoved	10
