/*
 * Copyright (c) 2009-2011 Ricardo Quesada
 * Copyright (c) 2011-2012 Zynga Inc.
 * SVGZ Support - Copyright (c) 2012 Yann Fripp - Play Fripp
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


/*
 Features and limitations of SVG to BOX2D parser
 
 Features:
   * supported elements:
     * path: cubic bezier, line, move
     * rect
     * ellipses
     * groups
   * supported attributes:
     * transform: matrix, translate, rotate, scale, skewX, skewY
     * physics extensions: physics (isSensor, density, restitution, friction, type, fixedRotation)
     * game extensions: game_data
     * game configuration: gravity, control type
  
  Limitations:
   * it doesn't support compound shapes. This is supported by the game_data extension
   * it doesn't support relative path commands. Only absolute
   * it doesn't support arc path command
 */


#import <Box2D/Box2D.h>
#import "cocos2d.h"

#import "SVGParser.h"
#import "BezierCurves.h"
#import "GameConfiguration.h"
#import "DDData.h"

@interface SVGParser (Private)

// elements parser
-(b2Body*) parseEllipseWithCenter:(CGPoint)center raidus:(CGPoint)radius;
-(b2Body*) parseRect:(NSDictionary*) dict;
-(b2Body*) parsePath:(NSDictionary*) dict;
-(void) parseAttribs:(NSDictionary*) dict;

// transform parser
-(CGAffineTransform) parseTransformAttribs;
-(CGAffineTransform) parseMatrix:(NSString*)str;
-(CGAffineTransform) parseScale:(NSString*)str;
-(CGAffineTransform) parseTranslate:(NSString*)str;
-(CGAffineTransform) parseRotate:(NSString*)str;
-(CGAffineTransform) parseSkewX:(NSString*)str;
-(CGAffineTransform) parseSkewY:(NSString*)str;

// game configuration parser
-(void) parseGameConfigurationAttributes:(NSString*)str;

// helper
-(void) applyPhysicsPropertiesInFixture:(b2FixtureDef*)shape inBody:(b2Body*)body;
-(b2Vec2) convertPoint:(CGPoint)point;
-(b2Vec2) convertToLocal:(CGPoint)point;

// path related
-(void) pathSkipUntilNextCommand;
-(char) pathNextCommand;
-(float) pathNextFloat;
-(NSMutableString*) normalizePath:(NSString*)path;

@end

@implementation SVGParser

@synthesize gameAttribs=gameAttribs_, physicsAttribs=physicsAttribs_, transformAttribs=transformAttribs_;

+(id) parserWithSVGFilename:(NSString*)filename b2World:(b2World*)world settings:(SVGParserSettings*)settings target:(id)t selector:(SEL)s
{
	return [[[self alloc] initWithSVGFilename:filename b2World:world settings:settings target:t selector:s] autorelease];
}

-(id) initWithSVGFilename:(NSString*)filename b2World:(b2World*)world settings:(SVGParserSettings*)sett target:(id)t selector:(SEL)s
{
	if( (self=[super init]) ) {
		
		// store settings locally
		settings = *sett;
		
		// callback used when the SVG entity has the "game_data" property
		NSMethodSignature * sig = [[t class] instanceMethodSignatureForSelector:s];
		callbackInvocation = [NSInvocation invocationWithMethodSignature:sig];
		[callbackInvocation setTarget:t];
		[callbackInvocation setSelector:s];
		[callbackInvocation retain];
		
		// box2d world
		box2Dworld = world;
		
		// transform matrix stack
		for( int i=0;i<kMaxTransformMatrix;i++)
			transformMatrix[i] =  CGAffineTransformIdentity;
		transformMatrixIdx = 0;
		
		isPhysicsLayer = NO;

		BOOL needURL = YES;
		NSURL *url;
		NSData *data;
		
		if([filename hasPrefix:@"http://"])
			url=[NSURL URLWithString:filename];
		else
		{
			url = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
			
			if ([filename hasSuffix:@"gz"])
			{
				SVGLOG(@"SVGParser: Parse GZipped file.");
				data = [[NSData dataWithContentsOfURL:url] gzipInflate];
				needURL = NO;
			}
		}
		
		NSXMLParser *parser;
		
		if (needURL)
			parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
		else
			parser = [[NSXMLParser alloc] initWithData:data];
		
		// we'll do the parsing
		[parser setDelegate:self];
		[parser setShouldProcessNamespaces:NO];
		[parser setShouldReportNamespacePrefixes:NO];
		[parser setShouldResolveExternalEntities:NO];
		[parser parse];
		
		NSError *parseError = [parser parserError];
		if(parseError) {
			SVGLOG(@"SVGParser: Error parsing SVG file: %@", parseError);
		}
		
		[parser release];		

	}
	return self;
}

- (void) dealloc
{
	SVGLOG(@"SVGParser: deallocing %@", self);
	[gameAttribs_ release];
	[physicsAttribs_ release];
	[transformAttribs_ release];
	
	[callbackInvocation release];
	[super dealloc];
}


#pragma mark SVGParser - Matrix manipulation

-(void) pushTransformMatrix
{
	CGAffineTransform matrix = [self parseTransformAttribs];
	matrix = CGAffineTransformConcat( matrix, transformMatrix[transformMatrixIdx]);

	transformMatrixIdx++;
	
	transformMatrix[transformMatrixIdx] = matrix;

	NSAssert( transformMatrixIdx < kMaxTransformMatrix, @"SVG Parser: Transform matrix stack overflow");
}

-(void) popTransformMatrix
{
	transformMatrixIdx--;
	NSAssert( transformMatrixIdx >= 0, @"SVG Parser: Transform matrix stack underflow");	
}

-(void) parseAttribs:(NSDictionary*)attributeDict
{
	self.transformAttribs = [attributeDict valueForKey:@"transform"];
	self.physicsAttribs = [attributeDict valueForKey:@"physics"];
	self.gameAttribs = [attributeDict valueForKey:@"game_data"];
}
-(CGAffineTransform) parseTransformAttribs
{
	CGAffineTransform matrix = CGAffineTransformIdentity;
	
	int stringLen = [transformAttribs_ length];
	int start=0, len=0;
	int tokenLen = 0;

	if( [transformAttribs_ hasPrefix:@"translate"] ) {
		tokenLen = strlen("translate") + 1;
		len = stringLen - tokenLen - 1;
		start = tokenLen;
		NSRange range = NSMakeRange(start, len);
		NSString *sub = [transformAttribs_ substringWithRange:range];
		
		matrix = [self parseTranslate:sub];
	}
	else if( [transformAttribs_ hasPrefix:@"scale"] ) {
		tokenLen = strlen("scale") + 1;
		len = stringLen - tokenLen - 1;
		start = tokenLen;
		NSRange range = NSMakeRange(start, len);
		NSString *sub = [transformAttribs_ substringWithRange:range];
		
		matrix = [self parseScale:sub];
	}
	else if( [transformAttribs_ hasPrefix:@"rotate"] ) {
		tokenLen = strlen("rotate") + 1;
		len = stringLen - tokenLen - 1;
		start = tokenLen;
		NSRange range = NSMakeRange(start, len);
		NSString *sub = [transformAttribs_ substringWithRange:range];
		
		matrix = [self parseRotate:sub];
	}
	else if( [transformAttribs_ hasPrefix:@"matrix"] ) {
		tokenLen = strlen("matrix") + 1;
		len = stringLen - tokenLen - 1;
		start = tokenLen;
		NSRange range = NSMakeRange(start, len);
		NSString *sub = [transformAttribs_ substringWithRange:range];
		
		matrix = [self parseMatrix:sub];
	}
	else if( [transformAttribs_ hasPrefix:@"skewX"] ) {
		tokenLen = strlen("skewX") + 1;
		len = stringLen - tokenLen - 1;
		start = tokenLen;
		NSRange range = NSMakeRange(start, len);
		NSString *sub = [transformAttribs_ substringWithRange:range];
		
		matrix = [self parseSkewX:sub];
	}
	else if( [transformAttribs_ hasPrefix:@"skewY"] ) {
		tokenLen = strlen("skewY") + 1;
		len = stringLen - tokenLen - 1;
		start = tokenLen;
		NSRange range = NSMakeRange(start, len);
		NSString *sub = [transformAttribs_ substringWithRange:range];
		
		matrix = [self parseSkewY:sub];
	}

	return matrix;
}

#pragma mark SVGParser - Parse Transform

-(CGAffineTransform) parseTranslate:(NSString*)str
{
	NSArray *values = [str componentsSeparatedByString:@","];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue;
	
	// tx
	propertyValue = [nse nextObject];
	float tx = [propertyValue floatValue];
	
	// ty
	propertyValue = [nse nextObject];
	float ty = [propertyValue floatValue];

	return CGAffineTransformMakeTranslation(tx, ty);
}

-(CGAffineTransform) parseMatrix:(NSString*)str
{
	NSArray *values = [str componentsSeparatedByString:@","];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue;
	
	// SVG Matrix
	// a  b  0
	// c  d  0
	// tx ty 1
	
	// a
	propertyValue = [nse nextObject];
	float a = [propertyValue floatValue];
	
	// b
	propertyValue = [nse nextObject];
	float b = [propertyValue floatValue];
	
	// c
	propertyValue = [nse nextObject];
	float c = [propertyValue floatValue];
	
	// d
	propertyValue = [nse nextObject];
	float d = [propertyValue floatValue];
	
	// tx
	propertyValue = [nse nextObject];
	float tx = [propertyValue floatValue];
	
	// ty
	propertyValue = [nse nextObject];
	float ty = [propertyValue floatValue];
	
	return CGAffineTransformMake(a,b,c,d,tx,ty);
}

-(CGAffineTransform) parseRotate:(NSString*)str
{
	NSArray *values = [str componentsSeparatedByString:@","];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue;
	
	propertyValue = [nse nextObject];
	float a = [propertyValue floatValue];
	
	return CGAffineTransformMakeRotation( CC_DEGREES_TO_RADIANS(a) );
}

-(CGAffineTransform) parseScale:(NSString*)str
{
	NSArray *values = [str componentsSeparatedByString:@","];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue;
	
	// sx
	propertyValue = [nse nextObject];
	float sx = [propertyValue floatValue];
	
	// sy
	propertyValue = [nse nextObject];
	float sy = [propertyValue floatValue];

	return CGAffineTransformMakeScale(sx, sy);
}

-(CGAffineTransform) parseSkewX:(NSString*)str
{
	NSArray *values = [str componentsSeparatedByString:@","];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue;
	
	// skewX
	propertyValue = [nse nextObject];
	float x = [propertyValue floatValue];

	return CGAffineTransformMake(1, 0, tanf( CC_DEGREES_TO_RADIANS(x)), 1, 0, 0);
}

-(CGAffineTransform) parseSkewY:(NSString*)str
{
	NSArray *values = [str componentsSeparatedByString:@","];
	NSEnumerator *nse = [values objectEnumerator];	
	NSString *propertyValue;
	
	// skewY
	propertyValue = [nse nextObject];
	float y = [propertyValue floatValue];
	
	return CGAffineTransformMake(1, tanf( CC_DEGREES_TO_RADIANS(y)), 0, 1, 0, 0);
}

#pragma mark SVGParser - Body and Shape initializers

//
// sensor, restitution and friction can be changed in runtime
// but density can only be changed on body creation time (at least with box2d r22, http://code.google.com/p/box2d/issues/detail?id=20 )
// Once issue #20 is fixed, this method could be improved
//
-(void) applyPhysicsPropertiesInFixture:(b2FixtureDef*)fixture inBody:(b2Body*)body
{
	
	BOOL sensor = NO;
	BOOL fixedRotation = NO;
	float restitution = settings.defaultRestitution;
	float density = settings.defaultDensity;
	float friction = settings.defaultFriction;
	b2BodyType bodyType = b2_staticBody;

	NSArray *values = [physicsAttribs_ componentsSeparatedByString:@","];
	NSEnumerator *nse = [values objectEnumerator];

	for( NSString *propertyValue in nse ) {
		NSArray *arr = [propertyValue componentsSeparatedByString:@"="];
		NSString *key = [arr objectAtIndex:0];
		NSString *value = [arr objectAtIndex:1];
		
		if( [key isEqualToString:@"isSensor"] )
			sensor = [value boolValue];
		
		if( [key isEqualToString:@"fixedRotation"] )
			fixedRotation = [value boolValue];

		// values should be between 0 and 1
		else if( [key isEqualToString:@"restitution"])
			restitution = [value floatValue];
		
		// if density is == 0, then it will create static bodies
		else if( [key isEqualToString:@"density"] )
			density = [value floatValue];
		
		// values should be between 0 and 1
		else if( [key isEqualToString:@"friction"] )
			friction = [value floatValue];
		
		else if( [key isEqualToString:@"type"] ) {
			if( [value isEqualToString:@"static"] )
				bodyType = b2_staticBody;
			else if( [value isEqualToString:@"dynamic"] )
				bodyType = b2_dynamicBody;
			else if( [value isEqualToString:@"kinematic"] )
				bodyType = b2_kinematicBody;
			else
				SVGLOG(@"Unknow value '%@' for type", value);
		}
	}	

	// Backward compatible:
	// static bodies don't have density.
	// if it is set, then it will be a dynamic body.
	if( density && bodyType == b2_staticBody )
		bodyType = b2_dynamicBody;

	fixture->isSensor = sensor;
	fixture->restitution = restitution;
	fixture->density = density;
	fixture->friction = friction;
	
	body->CreateFixture(fixture);
	body->SetType(bodyType);
	body->SetFixedRotation(fixedRotation);
}

#pragma mark SVGParser - Rect parser

-(b2Body*) parseRect:(NSDictionary*) attributeDict
{	
	// parse dictionary and obtain the rect attributes
	CGAffineTransform matrix = [self parseTransformAttribs];
	matrix = CGAffineTransformConcat( matrix, transformMatrix[transformMatrixIdx]);

	float width = [[attributeDict valueForKey:@"width"] floatValue];
	float height = [[attributeDict valueForKey:@"height"] floatValue];
	float x = [[attributeDict valueForKey:@"x"] floatValue];
	float y = [[attributeDict valueForKey:@"y"] floatValue];

//	y += (height/2);
//	x += (width/2);
	
	CGPoint xformPoint = CGPointApplyAffineTransform( CGPointMake(x,y), matrix);
	
	NSAssert( width >= 0, @"SVGParser: width < 0");
	NSAssert( height >= 0, @"SVGParser: height < 0");
	
	b2BodyDef def;
	def.position = [self convertToLocal:xformPoint];
	def.angle = atan2f( matrix.c, matrix.a );
	b2Body *body = box2Dworld->CreateBody(&def);	
	
	// Define the ground box shape.
	b2FixtureDef fd;
	b2PolygonShape rectShape;
	fd.shape = &rectShape;
	
	width /= settings.PTMratio;
	height /= settings.PTMratio;

	// vertices should be in Counter Clock-Wise order, orderwise it will crash
	b2Vec2 vertices[4];
	vertices[0].Set(0,-height);
	vertices[1].Set(width,-height);
	vertices[2].Set(width,0);
	vertices[3].Set(0,0);
	
	rectShape.Set(vertices, 4);
	[self applyPhysicsPropertiesInFixture:&fd inBody:body];
		
	return body;
}

#pragma mark SVGParser - Ellipse parser

-(b2Body*) parseEllipse:(NSDictionary*)attributeDict
{
	// arcs are easier to parse using metadata from inkscape
	float cx = [[attributeDict valueForKey:@"sodipodi:cx"] floatValue];
	float cy = [[attributeDict valueForKey:@"sodipodi:cy"] floatValue];
	float rx = [[attributeDict valueForKey:@"sodipodi:rx"] floatValue];
	float ry = [[attributeDict valueForKey:@"sodipodi:ry"] floatValue];		
	
	// parse dictionary and obtain the rect attributes
	CGAffineTransform matrix = [self parseTransformAttribs];
	matrix = CGAffineTransformConcat( matrix, transformMatrix[transformMatrixIdx] );
	CGPoint center = CGPointApplyAffineTransform(CGPointMake(cx,cy), matrix );
	CGPoint scale = CGPointMake( matrix.a, matrix.d );

	// physics: body
	b2BodyDef def;
	def.position = [self convertToLocal: center];
	def.angle =  atan2f( matrix.c, matrix.a );
	b2Body *body = box2Dworld->CreateBody(&def);

	// physics: shape
	b2CircleShape circleShape;
	circleShape.m_radius = (rx * scale.x+ ry * scale.y) / 2 / settings.PTMratio;

	// body with shape
	b2FixtureDef fd;
	fd.shape = &circleShape;
	[self applyPhysicsPropertiesInFixture:&fd inBody:body];

	return body;
}

#pragma mark SVGParser - path parser

-(b2Body*) parsePath:(NSDictionary*) attributeDict
{
	NSString *subtype = [attributeDict valueForKey:@"sodipodi:type"];
	if( [subtype isEqualToString:@"arc"] ) {
		return [self parseEllipse:attributeDict];
	}
	
	// else, parse manually the path
	NSString *path = [attributeDict valueForKey:@"d"];
	pathString = [self normalizePath:path];	
	
	// parse dictionary and obtain the rect attributes
	CGAffineTransform matrix = [self parseTransformAttribs];
	matrix = CGAffineTransformConcat( matrix, transformMatrix[transformMatrixIdx] );

	// physics: body creation
	b2BodyDef def;
	def.position = [self convertToLocal: CGPointMake(matrix.tx, matrix.ty)];
	def.angle = atan2( matrix.c, matrix.a);
	b2Body *body = box2Dworld->CreateBody(&def);	

	// physics: fixture 
	b2FixtureDef fd;
	b2EdgeShape pathShape;
	fd.shape = &pathShape;
	
	
	// path, bezier aux vars
	float x,y;
	pathIndex = 0;
	b2Vec2 currentPoint = b2Vec2_zero;	
	b2Vec2	startPath = b2Vec2_zero;
	b2Vec2	vect;
	b2Vec2	bezierPoints[4];
	b2Vec2	*bezierVerts;
	

	BOOL finished = NO;
	while( ! finished ) {
		char c = [self pathNextCommand];
		switch( c ) {
			case 0x0:
				finished = YES;
				break;
			// move to
			case 'm':
				SVGLOG(@"SVGParser: command 'm' not supported yet");
				[self pathSkipUntilNextCommand];
				break;
			case 'M':
				x = [self pathNextFloat];
				y = [self pathNextFloat];
				startPath = currentPoint = [self convertPoint:CGPointMake(x,y)];
				break;

			// Curve
			case 'c':
				SVGLOG(@"SVGParser: command 'c' not supported yet");
				[self pathSkipUntilNextCommand];
				break;
			case 'C':
				bezierPoints[0] = currentPoint;
	
				x = [self pathNextFloat];
				y = [self pathNextFloat];
				bezierPoints[1] = [self convertPoint:CGPointMake(x,y)];

				x = [self pathNextFloat];
				y = [self pathNextFloat];
				bezierPoints[2] = [self convertPoint:CGPointMake(x,y)];
				
				x = [self pathNextFloat];
				y = [self pathNextFloat];
				bezierPoints[3] = [self convertPoint:CGPointMake(x,y)];

				
				bezierVerts = calculate_bezier( bezierPoints, settings.bezierSegments);
				for( int i=0;i<settings.bezierSegments;i++)
				{
					pathShape.Set(currentPoint, bezierVerts[i]);
					[self applyPhysicsPropertiesInFixture:&fd inBody:body];
					currentPoint = bezierVerts[i];
				}
				delete [] bezierVerts;					
				break;
				
			// line to
			case 'l':
				SVGLOG(@"SVGParser: command 'l' not supported yet");
				[self pathSkipUntilNextCommand];
				break;				
			case 'L':
				x = [self pathNextFloat];
				y = [self pathNextFloat];
				vect = [self convertPoint:CGPointMake(x,y)];
				
				pathShape.Set(currentPoint, vect);
				[self applyPhysicsPropertiesInFixture:&fd inBody:body];
				currentPoint = vect;
				break;
			
			// close path
			case 'z':
			case 'Z':
				pathShape.Set(currentPoint, startPath);
				[self applyPhysicsPropertiesInFixture:&fd inBody:body];
				currentPoint = startPath;
				break;
			case 'a':
			case 'A':
				SVGLOG(@"SVGParser: 'a' command is not supported. Treating it as a line");
				[self pathSkipUntilNextCommand];
				break;

			default:
				[self pathSkipUntilNextCommand];
		}
	}
	
	return body;
}

-(char) pathNextCommand
{
	if( pathIndex >= [pathString length] )
		return 0;
	
	const char *str = [pathString UTF8String];
	char c = str[ pathIndex];
	
	// cases when the command is repeated
	if( (c >= '0' && c <='9') || c=='-')
		return pathLastCommand;
	
	pathIndex += 2; //  skip comma, next char
	pathLastCommand = c;
	return c;
}

-(void) pathSkipUntilNextCommand
{
	if( pathIndex >= [pathString length] )
		return;
	const char *str = [pathString UTF8String];
	unsigned int stringLen = [pathString length];
	
	for(;pathIndex < stringLen;pathIndex++) {
		char c = str[pathIndex];
		if( (c >= 'a' && c <='z') || (c >= 'A' && c<='Z') )
			return;
	}
}

-(float) pathNextFloat
{
	NSAssert( pathIndex < [pathString length], @"SVNParser: path parse error");
	
	unsigned int stringLen = [pathString length];
//	unsigned int len = stringLen - pathIndex;
	const char *str = [pathString UTF8String];
	
	NSString *string = [NSString stringWithCString:&str[pathIndex] encoding: NSASCIIStringEncoding];
//	NSString *string = [NSString stringWithCString:&str[pathIndex] length:len];
	NSScanner *scanner = [NSScanner scannerWithString:string];
	
	float ret = 0;
	BOOL ok = [scanner scanFloat:&ret];
	NSAssert(ok, @"SVG parser: path error parsing float");
	
	// find next comma (ok is here just to trick the parser)
	for( ; ok && pathIndex < stringLen ; pathIndex++ ) {
		if( str[pathIndex] == ',' ) {
			pathIndex++;
			break;
		}
	}
	return ret;
}

-(b2Vec2) convertPoint:(CGPoint)point
{
	b2Vec2 vect(point.x / settings.PTMratio, 
				((SVGSize.height-point.y) - SVGSize.height) / settings.PTMratio );
	
	return vect;
}

-(b2Vec2) convertToLocal:(CGPoint)point
{
	b2Vec2 vect(point.x / settings.PTMratio,
				(SVGSize.height-point.y) / settings.PTMratio );
	return vect;
}


-(NSMutableString*) normalizePath:(NSString*)path
{
	// each token is separated by commas
	//	NSString *separators = @"MmLlZzHhVvCcSsQqTtAa";
	NSMutableString *mutablePath = [NSMutableString stringWithString:path];
	
	// remove whitespaces, replace spaces with commas
	[mutablePath replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [mutablePath length])];
	[mutablePath replaceOccurrencesOfString:@"\t" withString:@"" options:0 range:NSMakeRange(0, [mutablePath length])];
	[mutablePath replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0, [mutablePath length])];
	[mutablePath replaceOccurrencesOfString:@" " withString:@"," options:0 range:NSMakeRange(0, [mutablePath length])];
	
	//	NSLog(@"old string: %@", path);
	//	NSLog(@"new string: %@", mutablePath);
	
	return mutablePath;
}

#pragma mark SVGParser - Game configuration parser

-(void) parseGameConfigurationAttributes:(NSString*)str
{
	GameConfiguration *config = [GameConfiguration sharedConfiguration];
	
	float gravityX = settings.defaultGravity.x; // kPhysicsWorldGravityX
	float gravityY = settings.defaultGravity.y; // kPhysicsWorldGravityY
	ControlDirection	direction = kControlDirectionDefault;
	ControlButton		button = kControlButtonDefault;

	NSArray *values = [str componentsSeparatedByString:@","];
	NSEnumerator *nse = [values objectEnumerator];
	
	for( NSString *propertyValue in nse ) {
		NSArray *arr = [propertyValue componentsSeparatedByString:@"="];
		NSString *key = [arr objectAtIndex:0];
		NSString *value = [arr objectAtIndex:1];
		
		if( [key isEqualToString:@"gravity_x"] )
			gravityX = [value floatValue];
		
		// values should be between 0 and 1
		else if( [key isEqualToString:@"gravity_y"])
			gravityY= [value floatValue];
		
		else if( [key isEqualToString:@"controls"] ) {
			if( [value isEqualToString:@"4way"] ) {
				direction=kControlDirection4Way;
			} else if( [value isEqualToString:@"4waycar"] ) {
				direction=kControlDirection4WayCar;
			} else if( [value isEqualToString:@"2way"] ) {
				direction=kControlDirection2Way;
			} else
				SVGLOG(@"SVG Parser Game Configuration: unkown param in controls type: %@", value);
		}
		
		else if( [key isEqualToString:@"buttons"] ) {
			if( [value isEqualToString:@"0"] )
				button=kControlButton0;
			else if( [value isEqualToString:@"1"] )
				button=kControlButton1;
			else if( [value isEqualToString:@"2"] )
				button=kControlButton2;
			else
				SVGLOG(@"SVG Parser Game Configuration: unkown param in buttons type: %@", value);			
		}

		else
			SVGLOG(@"SVGParser Game configuration: Unrecognized attribute: %@", key);
	}
	
	config.controlDirection = direction;
	config.controlButton = button;
	config.gravity = CGPointMake( gravityX, gravityY);
	
	box2Dworld->SetGravity( b2Vec2( gravityX, gravityY) );
}

#pragma mark SVGParser - parser main loop

// the XML parser calls here with all the elements
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	b2Body *body = NULL;
	if([elementName isEqualToString:@"svg"]) {
		float width = [[attributeDict valueForKey:@"width"] floatValue];
		float height = [[attributeDict valueForKey:@"height"] floatValue];
		SVGSize = CGSizeMake(width,height);
		
		// game configuration paramters
		NSString *conf = [attributeDict valueForKey:@"game_config"];
		[self parseGameConfigurationAttributes:conf];
		
		return;
	}

	[self parseAttribs:attributeDict];
	
	if([elementName isEqualToString:@"g"]) {
		[self pushTransformMatrix];
	
		// If new layer, and layer name begins with "physics:" then parse it
		NSString *label = [attributeDict valueForKey:@"inkscape:label"];
		if( label ) {
			if( [label hasPrefix:@"physics:"] )
				isPhysicsLayer = YES;
			else
				isPhysicsLayer = NO;
		}
	}
	
	// only parse the layer if the name begins with "physics:"
	// skip non physics layers
	if( ! isPhysicsLayer )
		return;
			
	if([elementName isEqualToString:@"path"]) {
		body = [self parsePath:attributeDict];

	} else if([elementName isEqualToString:@"rect"]) {
		body = [self parseRect:attributeDict];
		
	} else if([elementName isEqualToString:@"circle"]) {
		SVGLOG(@"SVGParser: circle not supported yet");
		
	} else if([elementName isEqualToString:@"ellipse"]) {
		SVGLOG(@"SVGParser: ellipse not supported yet");
		
	} else if([elementName isEqualToString:@"line"]) {
		SVGLOG(@"SVGParser: line not supported yet");
		
	} else if([elementName isEqualToString:@"polyline"]) {
		SVGLOG(@"SVGParser: polyline not supported yet");
		
	} else if([elementName isEqualToString:@"polygon"]) {
		SVGLOG(@"SVGParser: polygon not supported yet");

	} else {
		;
	}
	
	if( body && gameAttribs_) {		
			[callbackInvocation setArgument:&body atIndex:2];
			[callbackInvocation setArgument:&gameAttribs_ atIndex:3];
			[callbackInvocation invoke];
		}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	// reset tmp ivars
	self.transformAttribs = nil;
	self.gameAttribs = nil;
	self.physicsAttribs = nil;
	
	if( [elementName isEqualToString:@"g"] )
		[self popTransformMatrix];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}


//
// the level did not load, file not found, etc.
//
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	SVGLOG(@"SVGParser: Error parsing SVG file: %@", [parseError localizedDescription] );
}

@end
