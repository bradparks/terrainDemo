//
//  pgeWorld.h
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright (c) 2012 Protec Electronics. All rights reserved.
//
// ----------------------------------------------------------
// import headers

#import "GameConfig.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ObjectiveChipmunk.h"

// ----------------------------------------------------------
// defines

#define WORLD                       [ pgeWorld sharedWorld ]
#define WORLD_GRAVITY               -500
#define WORLD_DAMPING               0.5f

// ----------------------------------------------------------
// typedefs

// ----------------------------------------------------------
// interface

@interface pgeWorld : CCNode {
    ChipmunkSpace*              m_space;
    NSMutableArray*             m_shapeList;
}

// ----------------------------------------------------------
// properties

@property ( readonly ) ChipmunkSpace* space;

// ----------------------------------------------------------
// methods

+( pgeWorld* )sharedWorld;
-( pgeWorld* )init;

-( void )update:( ccTime )dt;

-( void )addBall:( CGPoint )pos;

// ----------------------------------------------------------

@end
