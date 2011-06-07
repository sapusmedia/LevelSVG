/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

#ifndef BEZIER_CURVES_H
#define BEZIER_CURVES_H

/* 
calculate_bezier:
 Input:
     p[4] - the 4 control points
     steps - the number of segments to have in the curve
 Returns:
    (steps) points that make up the bezier curve (alloc by new)

Fast bezier curves from:
http://www.niksula.cs.hut.fi/~hkankaan/Homepages/bezierfast.html
*/

#include <Box2D/Box2D.h>

b2Vec2* calculate_bezier(b2Vec2 p[4], uint32 steps);

b2Vec2* calculate_bezier(b2Vec2 p[4], uint32 steps=30) {
	if (steps == 0) {
		return NULL;
	}

    b2Vec2 f, fd, fdd, fddd, fdd_per_2, fddd_per_2, fddd_per_6;
    float32 t = 1.0f / float32(steps-1);
    float32 t2 = t * t;

    //I've tried to optimize the amount of
    //multiplications here, but these are exactly
    //the same formulas that were derived earlier
    //for f(0), f'(0)*t etc.
    f = p[0];
    fd = 3.0f * t * (p[1] - p[0]);
    fdd_per_2 = 3.0f * t2 * (p[0] - 2.0 * p[1] + p[2]);
    fddd_per_2 = 3.0f * t2 * t * (3.0 * (p[1] - p[2]) + p[3] - p[0]);

    fddd = fddd_per_2 + fddd_per_2;
    fdd = fdd_per_2 + fdd_per_2;
    fddd_per_6 = (1.0f / 3) * fddd_per_2;

    b2Vec2* ret=new b2Vec2[steps];

	if (!ret) {
		return NULL;
	}

    for (uint32 loop=0; loop < steps; loop++) {
        ret[loop] = f;

        f = f + fd + fdd_per_2 + fddd_per_6;
        fd = fd + fdd + fddd_per_2;
        fdd = fdd + fddd;
        fdd_per_2 = fdd_per_2 + fddd_per_2;
    }
	return ret;
}

#endif

