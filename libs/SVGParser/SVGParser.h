//
//  SVGParser.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 12/08/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//


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
