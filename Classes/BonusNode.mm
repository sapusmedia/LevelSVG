//
//  BonusNode.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 24/03/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION

#import <Box2d/Box2D.h>
#import "cocos2d.h"

#import "GameNode.h"
#import "GameConstants.h"
#import "BonusNode.h"

//
// BonusNode: base class of all the "sensor" nodes
// When the hero touches the sensor, the method "touchedByHero" will be called.
//   -> Override "touchedByHero" method so customize your own sensor
//
// Supported Parameters:
//	"respawnTime" (float). If 0, then the node won't be respawned.
//		Otherwise the node will be respwawn N seconds after it has been touched by the hero

@implementation BonusNode

-(id) initWithBody:(b2Body*)body game:(GameNode*)game
{
	if( (self=[super initWithBody:body game:game] ) ) {

		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		isTouchable_ = NO;
		
		// 1. destroy already created fixtures
		[self destroyAllFixturesFromBody:body];
		
		// 2. create new fixture
		b2CircleShape	shape;
		shape.m_radius = 0.25f;		// 0.5 meter of diameter
		b2FixtureDef	fd;
		fd.shape = &shape;
		fd.isSensor = true;			// it is a sensor
		body->CreateFixture(&fd);
		
		respawnTime_ = 0;
	}
	return self;
}

-(void) setParameters:(NSDictionary *)params
{
	[super setParameters:params];
	
	NSString *respawn = [params objectForKey:@"respawnTime"];
	
	if( respawn )
		respawnTime_ = [respawn floatValue];		
}

-(void) touchedByHero
{
	if( respawnTime_ ) {
		
		// sprite is invisible
		self.visible = NO;

		// save body position for the respawn
		bodyPosition_ = body_->GetPosition();
		
		// UserData = NULL to prevent the removal of the BodyNode too
		body_->SetUserData(NULL); 
		[game_ removeB2Body:body_];
		
		[self schedule:@selector(respawnBody:) interval:respawnTime_];
		 
		
	} else 
		
		// remove it
		[game_ removeB2Body:body_];

}

-(void) respawnBody:(id)sender
{
	// unschedule respawnBody callback
	[self unschedule:_cmd];
	
	// turn on sprite visibility
	self.visible = YES;

	// 1. create new body in the old position
	b2BodyDef def;
	def.position = bodyPosition_;
	def.angle = 0;
	
	b2World *world = [game_ world];
	body_ = world->CreateBody(&def);
	
	// 2. create fixture
	b2CircleShape	shape;
	shape.m_radius = 0.25f;		// 0.5 meter of diameter
	b2FixtureDef	fd;
	fd.shape = &shape;
	fd.isSensor = true;			// it is a sensor
	body_->CreateFixture(&fd);
	
	// 3. link b2Body with BodyNode
	body_->SetUserData(self);	
}
@end
