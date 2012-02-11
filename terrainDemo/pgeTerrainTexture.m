//
//  pgeTerrainTexture.m
//  terrainDemo
//
//  Created by Lars Birkemose on 09/02/12.
//  Copyright 2012 Protec Electronics. All rights reserved.
//
// ----------------------------------------------------------
// headers

#import "pgeTerrainTexture.h"

// ----------------------------------------------------------
// consts

const int TERRAIN_X_ADJUST[ ]                           = {  1,  1,  0, -1, -1, -1,  0,  1 };
const int TERRAIN_Y_ADJUST[ ]                           = {  0,  1,  1,  1,  0, -1, -1, -1 };

// ----------------------------------------------------------
// implementation

@implementation pgeTerrainTexture

// ----------------------------------------------------------
// properties

@synthesize size = m_size;

// ----------------------------------------------------------
// methods
// ----------------------------------------------------------

+( pgeTerrainTexture* )terrainTextureWithWidth:( int )width andHeight:( int )height {
    return( [ [ [ self alloc ] initWithWidth:width andHeight:height ] autorelease ] );
}

// ----------------------------------------------------------

+( pgeTerrainTexture* )terrainTextureWithFile:( NSString* )filename {
    return( [ [ [ self alloc ] initWithFile:filename ] autorelease ] );
}

// ----------------------------------------------------------

-( pgeTerrainTexture* )initWithWidth:( int )width andHeight:( int )height {
    self = [ super init ];
    // initialize
    m_size = CGSizeMake( width, height );
    // create render texture
    m_render = [ CCRenderTexture renderTextureWithWidth:width height:height ];
    [ self addChild:m_render ];
    // allocate data
    m_renderData = malloc( width * height * TERRAIN_BYTES_PR_PIXEL );
    m_terrainUsed = malloc( width * height );
    // create circle
    m_circle = [ [ CCSprite spriteWithFile:TERRAIN_CICLE_TEXTURE ] retain ];
    m_circleSize = m_circle.contentSizeInPixels.width;
    //
    return( self );
}

// ----------------------------------------------------------

-( pgeTerrainTexture* )initWithFile:( NSString* )filename {
    CCSprite* sprite;
    
    self = [ super init ];
    // initialize
    // load file
    sprite = [ CCSprite spriteWithFile:filename ];
    m_size = sprite.contentSizeInPixels;
    // create render texture
    m_render = [ CCRenderTexture renderTextureWithWidth:m_size.width height:m_size.height ];
    [ self addChild:m_render ];
    // allocate data
    m_renderData = malloc( m_size.width * m_size.height * TERRAIN_BYTES_PR_PIXEL );
    m_terrainUsed = malloc( m_size.width * m_size.height );
    // create circle
    m_circle = [ [ CCSprite spriteWithFile:TERRAIN_CICLE_TEXTURE ] retain ];
    m_circleSize = m_circle.contentSizeInPixels.width;
    // render sprite and read pixels
    [ m_render begin ];
    // place sprite in center, and reverse y 
    sprite.position = CGPointMake( m_size.width / 2, m_size.height / 2 );
    [ sprite visit ];
    glReadPixels( 0, 0, m_size.width, m_size.height, GL_RGBA, GL_UNSIGNED_BYTE, m_renderData );
    [ m_render end ];
    //
    return( self );
}

// ----------------------------------------------------------

-( void )dealloc {
    // clean up
    [ m_circle release ]; 
    free( m_terrainUsed );
    free( m_renderData );
    [ m_render release ];
    // done
    [ super dealloc ];
}

// ----------------------------------------------------------

-( CCTexture2D* )texture {
    return( m_render.sprite.texture );
}

// ----------------------------------------------------------
// scans the nearest pixels until terrain is foun

-( int )scanForTerrain:( int )col {
    int result = m_size.height / 2;


    return( result );
}

// ----------------------------------------------------------
// OBS OBS BUG
// terrain will sometimes get flat because handling repeating terrain just defaults to searching right
// optimize consecutive segments ( use scanDirection to check )
//
// scan positions ( X = pixel )
// 3 2 1
// 4 X 0
// 5 6 7

-( NSArray* )scanImage {
    int scanOffset[ TERRAIN_SCAN_POSITIONS ];
    int bytesPrLine;
    int imagePointer;
    unsigned char colorData;
    unsigned char lastColorData;
    int x, y;
    NSMutableArray* result;
    CGPoint pos;
    int scanDirection;
    int terrainPointer;
    BOOL terrainFound;
    
    // bytes in an image line
    bytesPrLine = m_size.width * TERRAIN_BYTES_PR_PIXEL;
    // calculate the 8 scanning indexes in the bitmap
    // Index 0 is x+1, and then counting CCW, so
    // Index 7 is x+1, y-1 ( cocos2d coordinates )
    // image is expected to have 0,0 at lower left corner
    scanOffset[ 0 ] = TERRAIN_BYTES_PR_PIXEL;
    scanOffset[ 1 ] = scanOffset[ 0 ] + bytesPrLine;
    scanOffset[ 2 ] = scanOffset[ 1 ] - TERRAIN_BYTES_PR_PIXEL;
    scanOffset[ 3 ] = scanOffset[ 2 ] - TERRAIN_BYTES_PR_PIXEL;
    scanOffset[ 4 ] = scanOffset[ 3 ] - bytesPrLine;
    scanOffset[ 5 ] = scanOffset[ 4 ] - bytesPrLine;
    scanOffset[ 6 ] = scanOffset[ 5 ] + TERRAIN_BYTES_PR_PIXEL;
    scanOffset[ 7 ] = scanOffset[ 6 ] + TERRAIN_BYTES_PR_PIXEL;
    
    // find air / terrain transition
    // set defaults
    imagePointer = 0;
    lastColorData = m_renderData[ imagePointer ];
    y = m_size.height / 2;
    memset( m_terrainUsed, TERRAIN_CLEAR, m_size.width * m_size.height );
    // scan through left coloumn if image, from top to bottom
    for ( int yScan = 0; yScan < m_size.height; yScan ++ ) {
        colorData = m_renderData[ imagePointer ];
        imagePointer += bytesPrLine;
        // check for terrain / air transition
        if ( IS_AIR( colorData ) ) {
            // set terrain height
            y = yScan;
            break;
        } 
    }
    
    // track terrain contour
    // set defaults
    x = 1;
    result = [ NSMutableArray arrayWithCapacity:( 2 * m_size.width ) ];
    pos = CGPointMake( 0, 1 - ( y / m_size.height ) );
    [ result addObject:[ NSValue valueWithCGPoint:pos ] ];
    scanDirection = 0;
    // scan from left to right
    while ( x < m_size.width ) {
        //
        terrainFound = NO;
        imagePointer = ( x + ( y * m_size.width ) ) * TERRAIN_BYTES_PR_PIXEL;
        // check if scan should be CCW or CW by checking pixel to the right
        colorData = m_renderData[ imagePointer + scanOffset[ scanDirection ] ];
        if ( IS_AIR( colorData ) ) {
            // pixel was air
            // scan pixel CW, and look for terrain
            for ( int count = 1; count < TERRAIN_SCAN_POSITIONS; count ++ ) {
                scanDirection --;
                if ( scanDirection < 0 ) scanDirection += TERRAIN_SCAN_POSITIONS;
                colorData = m_renderData[ imagePointer + scanOffset[ scanDirection ] ];
                if ( IS_TERRAIN( colorData ) ) {
                    // terrain found
                    terrainFound = YES;
                    // done
                    break;
                }
            }
        } else {
            // pixel was terrain
            // scan pixels CCW, and look for air
            for ( int count = 1; count < TERRAIN_SCAN_POSITIONS; count ++ ) {
                scanDirection ++;
                if ( scanDirection >= TERRAIN_SCAN_POSITIONS ) scanDirection = 0;
                colorData = m_renderData[ imagePointer + scanOffset[ scanDirection ] ];
                if ( IS_AIR( colorData ) ) {
                    // air found
                    // terrain is previous position
                    terrainFound = YES;
                    scanDirection --;
                    if ( scanDirection < 0 ) scanDirection += TERRAIN_SCAN_POSITIONS;
                    // done
                    break;
                }            
            }
        }
        // if no terrain found, scan right
        if ( terrainFound == NO ) scanDirection = 0;
        // adjust x
        x += TERRAIN_X_ADJUST[ scanDirection ];
        // adjust y
        y += TERRAIN_Y_ADJUST[ scanDirection ];
        // check terrain
        terrainPointer = x + ( y * m_size.width );
        if ( m_terrainUsed[ terrainPointer ] != TERRAIN_CLEAR ) {
            // terrain has been used
            // scan right for unused terrain
            scanDirection = 0;
            CGPoint pos = [ self findNearestTerrain:ccp( x, y ) ]; 
            // set position
            x = ( int )pos.x;
            y = ( int )pos.y;
            terrainPointer = x + ( y * m_size.width );
        }
        m_terrainUsed[ terrainPointer ] = TERRAIN_USED;
        // add coordinate
        pos = CGPointMake( x / m_size.width, 1 - ( y / m_size.height ) );
        [ result addObject:[ NSValue valueWithCGPoint:pos ] ];
    }
    // done
    return( result );
}

// ----------------------------------------------------------
// if terrain mismatch, search around position for nearest unused terrain

-( CGPoint )findNearestTerrain:( CGPoint )pos {
    CGPoint result;
    BOOL found = NO;
    int multiplyer = 1;
    int pointer;
    
    // scan, until unused terrain is found
    do {
        for ( int scan = 0; scan < TERRAIN_SCAN_POSITIONS; scan ++ ) {
            result = ccp( pos.x + ( TERRAIN_X_ADJUST[ scan ] * multiplyer ), pos.y + ( TERRAIN_Y_ADJUST[ scan ] * multiplyer ) );
            pointer = ( ( int )result.x + ( ( int )result.y * m_size.width ) );
            if ( m_terrainUsed[ pointer ] == TERRAIN_CLEAR ) {
                pointer *= TERRAIN_BYTES_PR_PIXEL;
                if ( IS_TERRAIN( m_renderData[ pointer ] ) ) {
                    found = YES;
                    break;
                }
            }
        }
        multiplyer += 1;
    } while ( found == NO ); 
    //
    return( result );
}

// ----------------------------------------------------------

-( CGPoint )worldToTexture:( CGPoint )pos {
    CGSize size;
    
    size = [ [ CCDirector sharedDirector ] winSize ];
    // convert coordinates to image coordinates
    return( CGPointMake( 
                      clampf( pos.x * m_size.width / size.width, 0, m_size.width - 1 ), 
                      clampf( pos.y * m_size.height / size.height, 0, m_size.height - 1 ) ) );
}

// ----------------------------------------------------------

-( BOOL )pointInside:( CGPoint )pos {
    int pointer;

    // get image pointer
    pointer = ( ( int )pos.x + ( ( int )pos.y * m_size.width ) ) * TERRAIN_BYTES_PR_PIXEL;
    // return if data is terrain
    return( IS_TERRAIN( m_renderData[ pointer ] ) );
}

// ----------------------------------------------------------
// modify terrain
// terrain must be manually rebuild after this

-( void )modify:( CGPoint )pos size:( float )size add:( BOOL )add {
    m_circle.color = ( add == YES ) ? ccBLACK : ccWHITE;
    m_circle.scale = size / m_circleSize;
    // dont draw close to edges
    pos.x = clampf( pos.x, size, m_size.width - size );
    pos.y = clampf( pos.y, size, m_size.height - size );
    m_circle.position = pos;
    //
    [ m_render begin ];
    [ m_circle visit ];
    glReadPixels( 0, 0, m_size.width, m_size.height, GL_RGBA, GL_UNSIGNED_BYTE, m_renderData );
    [ m_render end ];
    
    // [ m_render saveBuffer:@"modify.png" format:kCCImageFormatPNG ];
    
}

// ----------------------------------------------------------

@end









































