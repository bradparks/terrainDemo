//
//  pgeTerrainTexture.h
//  terrainDemo
//
//  Created by Lars Birkemose on 09/02/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// ----------------------------------------------------------
// A pgeTerrainTexture is a bitmap holding the terrain
// The size is not related to screen size, but any part of it can be grabbed as a texture
// ----------------------------------------------------------
// headers

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// ----------------------------------------------------------
// defines

#define TERRAIN_BYTES_PR_PIXEL                  4
#define TERRAIN_SCAN_POSITIONS                  8

#define TERRAIN_SCAN_SEARCH_FROM                3               // used when searching for terrain
#define TERRAIN_SCAN_SEACRH_TO                  5

#define TERRAIN_IMAGE_TRESHOLD                  32

#define IS_AIR( color )                         ( color > 128 )
#define IS_TERRAIN( color )                     ( color <= 128 )

#define TERRAIN_CICLE_TEXTURE                   @"circle.png"

#define TERRAIN_CLEAR                           0x00
#define TERRAIN_USED                            0xFF

// ----------------------------------------------------------
// typedefs

// ----------------------------------------------------------
// interface

@interface pgeTerrainTexture : CCNode {
    CGSize                      m_size;                     // size of texture
    CCRenderTexture*            m_render;                   // render surface
    CCSprite*                   m_circle;                   // circle to add and remove terrain
    float                       m_circleSize;               // default circle size
    unsigned char*              m_renderData;               // render surface raw data
    unsigned char*              m_terrainUsed;              // terrain at that position have been used in scan
}

// ----------------------------------------------------------
// properties

@property ( readonly ) CGSize size;
@property ( readonly ) CCTexture2D* texture;

// ----------------------------------------------------------
// methods

+( pgeTerrainTexture* )terrainTextureWithWidth:( int )width andHeight:( int )height;
-( pgeTerrainTexture* )initWithWidth:( int )width andHeight:( int )height;

+( pgeTerrainTexture* )terrainTextureWithFile:( NSString* )filename;
-( pgeTerrainTexture* )initWithFile:( NSString* )filename;

-( NSArray* )scanImage;
-( CGPoint )findNearestTerrain:( CGPoint )pos;
-( CGPoint )worldToTexture:( CGPoint )pos;
-( BOOL )pointInside:( CGPoint )pos;
-( void )modify:( CGPoint )pos size:( float )size add:( BOOL )add;

// ----------------------------------------------------------

@end
