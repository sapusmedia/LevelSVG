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


#import <Foundation/Foundation.h>

#if SVGPARSER_DEBUG
#define SVGLOG(...) NSLog(__VA_ARGS__)
#else
#define SVGLOG(...) do {} while (0)
#endif


class b2World;
class b2Body;

enum {
	kMaxTransformMatrix = 32,
};

struct SVGParserSettings
{
	// default restituion
	float defaultRestitution;
	
	// default friction
	float defaultFriction;
	
	// default density
	float defaultDensity;
	
	// number of segments for each bezier path
	unsigned int bezierSegments;
	
	CGPoint	defaultGravity;
	
	// PTM (pixels to meters) ratio
	float PTMratio;
};

#ifdef __IPHONE_4_0
@interface SVGParser : NSObject <NSXMLParserDelegate>
#else
@interface SVGParser : NSObject
#endif
{	
	// transform matrix stack
	CGAffineTransform	transformMatrix[kMaxTransformMatrix];
	int					transformMatrixIdx;

	// box2d world
	b2World		*box2Dworld;
	
	// SVG document size
	CGSize		SVGSize;
	
	// is the current SVG layer a "physics" layer
	BOOL		isPhysicsLayer;
	
	// Physics settings
	SVGParserSettings	settings;

	// callback
	NSInvocation	*callbackInvocation;
	
	// attribs
	NSString		*transformAttribs_;
	NSString		*physicsAttribs_;
	NSString		*gameAttribs_;
	
	// SVG path related
	unsigned int	pathIndex;
	NSString		*pathString;
	char			pathLastCommand;	
}

// attributes of the current element
@property (nonatomic,readwrite,retain) NSString* transformAttribs;
@property (nonatomic,readwrite,retain) NSString* gameAttribs;
@property (nonatomic,readwrite,retain) NSString* physicsAttribs;

// creates the parser with a filename, world, settings, and a callback
// important: the target is not retained
+(id) parserWithSVGFilename:(NSString*)filename b2World:(b2World*)world settings:(SVGParserSettings*)settings target:(id)target selector:(SEL)sel;

// initializes the parser with a filename, world, settings and a callback
// important: the target is not retained
-(id) initWithSVGFilename:(NSString*)filename b2World:(b2World*)world settings:(SVGParserSettings*)settings target:(id)target selector:(SEL)sel;
@end
