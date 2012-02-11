//
//  pgeTerrain.h
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// ----------------------------------------------------------
// import headers

#import "GameConfig.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "pgeTerrainTexture.h"

// ----------------------------------------------------------
// defines

#define TERRAIN_MAX_SEGMENTS                    100
#define TERRAIN_CRUST_THICKNESS                 1

#define TERRAIN_CELL_SIZE                       4

// ----------------------------------------------------------
// typedefs

typedef enum {
    TERRAIN_TYPE_SAND,
    TERRAIN_TYPE_SOIL,
    TERRAIN_TYPE_ICE,
    TERRAIN_TYPE_COUNT,
} TERRAIN_TYPE;

/*
typedef struct _terrainData {
    CGPoint         p0;                 // points must be on 
    CGPoint         P1;
} terrainData;
*/

// ----------------------------------------------------------
// interface

@interface pgeTerrain : CCNode <ChipmunkObject> {
    CGSize                      m_size;
    TERRAIN_TYPE                m_type;
    NSMutableArray*				m_shapeList;                // add shapes to this list
    pgeTerrainTexture*          m_texture;
}

// ----------------------------------------------------------
// properties

@property ( readonly ) NSArray* chipmunkObjects;
@property ( readonly ) pgeTerrainTexture* texture;
@property ( readonly ) CGSize size;

// ----------------------------------------------------------
// methods

+( pgeTerrain* )terrainWithType:( TERRAIN_TYPE )type;
-( pgeTerrain* )initWithType:( TERRAIN_TYPE )type;

-( void )reset:( TERRAIN_TYPE )type;
-( void )deform:( CGPoint )pos;

// ----------------------------------------------------------

@end
