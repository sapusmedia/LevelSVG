//
//  BodyNode.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 19/12/09.
//  Copyright 2009,2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


// box2d classes
class b2Body;
class b2Contact;
struct b2ContactImpulse;
struct b2Manifold;
@class GameNode;

#import "cocos2d.h"

@protocol Box2dCollisionProtocol
-(void) beginContact:(b2Contact*) contact;
-(void) endContact:(b2Contact*) contact;
-(void) preSolveContact:(b2Contact*)contact  manifold:(const b2Manifold*) oldManifold;
-(void) postSolveContact:(b2Contact*)contact impulse:(const b2ContactImpulse*) impulse;
@end

enum {
	BN_PREFERRED_PARENT_SPRITES_PNG,
	BN_PREFERRED_PARENT_PLATFORMS_PNG,
	BN_PREFERRED_PARENT_IGNORE,				// for invisible objects like Ladder
};

enum {
	BN_CONTACT_NONE = 0,
	BN_CONTACT_BEGIN = 1 << 0,
	BN_CONTACT_END = 1 << 1,
	BN_CONTACT_PRESOLVE = 1 << 2,
	BN_CONTACT_POSTSOLVE = 1 << 3,
	BN_CONTACT_ALL = BN_CONTACT_BEGIN | BN_CONTACT_END | BN_CONTACT_PRESOLVE | BN_CONTACT_POSTSOLVE,
};

enum {
	BN_PROPERTY_NONE = 0,
	BN_PROPERTY_SPRITE_UPDATED_BY_PHYSICS = 1 << 0,
};

// box2d filtering
enum {
	kCollisionFilterGroupIndexEnemy = 1 << 0,
	kCollisionFilterGroupIndexHero = 1 << 1,
};

/** A CocosNode that links a b2Body with the cocos2d world.
 It also receives contact callbacks.
 If you move this node, it will move the box2d body.
 For example, you can apply actions to this node.
 
 IMPORTANT: In order to move the b2 body using actions, the body must be "kinematic" or "static" type.
 */
@interface BodyNode : CCSprite <Box2dCollisionProtocol> {

	// weak ref to box2d body
	b2Body			*body_;
	
	// weak ref to GameNode
	GameNode		*game_;

	// report contacts
	unsigned int	reportContacts_;
	
	// is this node touchable
	BOOL			isTouchable_;	
	
	// preferred parent (helper)
	int				preferredParent_;

	// TIP:
	// Are you going to access an ivar many times per step ?
	// To impromve the performance you can make it public, or compile the accessor method
@public
	// properties:
	unsigned int	properties_;
}

/** box2d body */
@property (readwrite, nonatomic, assign) b2Body *body;

/** contacts that will receive. None by default */
@property (readwrite, nonatomic) unsigned int reportContacts;

/** is this node touchable ? */
@property (readwrite, nonatomic) BOOL isTouchable;

/** prefered parent for the node */
@property (readwrite,nonatomic) int preferredParent;

/** properties of the node */
@property (readonly, nonatomic) unsigned int properties;


/** initializes the node with a box2d body */
-(id) initWithBody:(b2Body*)body game:(GameNode*)game;

/** destroy all fixtures from body */
-(void) destroyAllFixturesFromBody:(b2Body*)body;

/** the possibility to customize the node using SVG
 @since v2.4
 */
-(void) setParameters:(NSDictionary*)params;

@end

// protocols
@protocol BodyNodeBulletProtocol
-(void) touchedByBullet:(id)bullet;
@end

