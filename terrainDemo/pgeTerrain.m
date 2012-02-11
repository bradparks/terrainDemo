//
//  pgeTerrain.m
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// ----------------------------------------------------------
// import headers

#import "pgeTerrain.h"

// OBS OBS
// OPTIMIZE
#import "pgeWorld.h"

// ----------------------------------------------------------
// consts

const float TERRAIN_ELASTICITY[ TERRAIN_TYPE_COUNT ]    = { 0.20f, 0.20f, 0.20f };
const float TERRAIN_FRICTION[ TERRAIN_TYPE_COUNT ]      = { 0.80f, 0.80f, 0.80f };

// ----------------------------------------------------------
// implementation

@implementation pgeTerrain

// ----------------------------------------------------------
// properties

@synthesize chipmunkObjects = m_shapeList;
@synthesize texture = m_texture;
@synthesize size = m_size;

// ----------------------------------------------------------
// methods
// ----------------------------------------------------------

+( pgeTerrain* )terrainWithType:( TERRAIN_TYPE )type {
    return( [ [ [ self alloc ] initWithType:type ] autorelease ] );
}

// ----------------------------------------------------------

-( pgeTerrain* )initWithType:( TERRAIN_TYPE )type {
    // super
    self = [ super init ];
    // initialize
    m_size = [ [ CCDirector sharedDirector ] winSize ];
    m_shapeList = [ [ NSMutableArray arrayWithCapacity:TERRAIN_MAX_SEGMENTS ] retain ];
    // create texture, and load a default image
    m_texture = [ [ pgeTerrainTexture terrainTextureWithFile:@"terraindemo.bmp" ] retain ]; 
    // reset
    [ self reset:type ];
    
    
    
    
    // done
    return( self );
}

// ----------------------------------------------------------

-( void )dealloc {
    // clean up
    [ m_texture release ];
    [ m_shapeList release ];
    
    // done
    [ super dealloc ];
}

// ----------------------------------------------------------
// create a new terrain profile

-( void )reset:( TERRAIN_TYPE )type {
    ChipmunkShape* shape;
    CGPoint p0, p1;
    
    // set terrain type
    m_type = type;
    // clear current terrain
    [ m_shapeList removeAllObjects ];
    // get an normalized array of the terrain
    NSArray* terrain = [ NSArray arrayWithArray:[ m_texture scanImage ] ];
    
    // create static ground segments 
    for ( int index = 0; index < terrain.count; index ++ ) {
        p1 = [ [ terrain objectAtIndex:index ] CGPointValue ];
        p1 = CGPointMake( m_size.width * p1.x, m_size.height * ( 1 - p1.y ) );
        if ( index > 0 ) {
            shape = [ ChipmunkSegmentShape segmentWithBody:[ ChipmunkBody staticBody ] from:p0 to:p1 radius:TERRAIN_CRUST_THICKNESS ];
            // set ground properties
            shape.elasticity = TERRAIN_ELASTICITY[ type ]; 
            shape.friction = TERRAIN_FRICTION[ type ];
            // set collision type
            shape.collisionType = GAME_COLLISION_TERRAIN;
            // add to internal shape list
            [ m_shapeList addObject:shape ];
        }
        p0 = p1;
    }
    // 

}

// ----------------------------------------------------------

-( void )draw {    
#if GAME_DEBUG_DRAW == 1
    cpSegmentShape* segment;
    
    // draw own stuff
    glColor4f( 0, 1, 0, 1 );
    
    for ( ChipmunkShape* shape in m_shapeList ) {
        segment = ( cpSegmentShape* )shape.shape;
        ccDrawLine( segment->ta, segment->tb );
    }
#endif

}

// ----------------------------------------------------------

-( void )deform:( CGPoint )pos {
    ChipmunkShape* shape;
    ChipmunkShape* newShape;
    cpSegmentShape* segment;
    int index;
    
    index = pos.x / TERRAIN_CELL_SIZE;
    if ( index > m_shapeList.count - 2 ) return;

    shape = [ m_shapeList objectAtIndex:index ];
    segment = ( cpSegmentShape* )shape.shape;
    segment->tb.y = segment->tb.y + 4;

    newShape = [ ChipmunkSegmentShape segmentWithBody:[ ChipmunkBody staticBody ] from:segment->ta to:segment->tb radius:TERRAIN_CRUST_THICKNESS ];
    [ m_shapeList replaceObjectAtIndex:index withObject:newShape ];
    [ WORLD.space removeShape:shape ];
    [ WORLD.space addShape:newShape ];
    
    index ++;
    
    shape = [ m_shapeList objectAtIndex:index ];
    segment = ( cpSegmentShape* )shape.shape;
    segment->ta.y = segment->ta.y + 4;

    newShape = [ ChipmunkSegmentShape segmentWithBody:[ ChipmunkBody staticBody ] from:segment->ta to:segment->tb radius:TERRAIN_CRUST_THICKNESS ];
    [ m_shapeList replaceObjectAtIndex:index withObject:newShape ];
    [ WORLD.space removeShape:shape ];
    [ WORLD.space addShape:newShape ];
    
}

// ----------------------------------------------------------

@end

























