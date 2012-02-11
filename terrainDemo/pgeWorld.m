//
//  pgeWorld.m
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright (c) 2012 Protec Electronics. All rights reserved.
//
// ----------------------------------------------------------
// import headers

#import "pgeWorld.h"

// ----------------------------------------------------------
// implementation

@implementation pgeWorld

// ----------------------------------------------------------
// properties

@synthesize space = m_space;

// ----------------------------------------------------------
// methods
// ----------------------------------------------------------

+( pgeWorld* )sharedWorld {
    // the instance of this class is stored here
    static pgeWorld* g_world = nil;
    // check to see if an instance already exists
    if ( g_world == nil ) {
        g_world = [ [ [ self class ] alloc ] init ];
	}
    // return the instance of this class
    return( g_world );
}

// ----------------------------------------------------------

-( pgeWorld* )init {
    self = [ super init ]; 
    // initialize
    m_shapeList = [ [ NSMutableArray arrayWithCapacity:10 ] retain ];
    // create chipmunk space
    m_space = [ [ [ ChipmunkSpace alloc ] init ] retain ];
    m_space.gravity = CGPointMake( 0, WORLD_GRAVITY );
    m_space.damping = WORLD_DAMPING;
    m_space.iterations = 5;
    // 
    
    // done
    return( self );
}

// ----------------------------------------------------------

-( void )dealloc {
    // clean up
    [ m_shapeList release ];
    // done
    [ super dealloc ];
}

// ----------------------------------------------------------
// update the world

-( void )update:( ccTime )dt {
    
    [ m_space step:dt ];
    
}

// ----------------------------------------------------------

-( void )draw {
    [ super draw ];
    //
#if GAME_DEBUG_DRAW == 1
    ChipmunkShape* shape;
    cpCircleShape* circle;
    
    // draw own stuff
    glColor4f( 1, 1, 1, 1 );
    
    // scan through balls
    for ( int index = m_shapeList.count - 1; index >= 0; index -- ) {
        shape = [ m_shapeList objectAtIndex:index ];
        circle = ( cpCircleShape* )shape.shape;
        if ( circle->tc.y > 0 ) {
            // draw circle
            ccDrawCircle( circle->tc, circle->r, shape.body.angle, 32, YES );
        } else {
            // delete circle
            [ m_space removeBody:shape.body ];
            [ m_space removeShape:shape ];
            [ m_shapeList removeObjectAtIndex:index ];
        }
    }
#endif
}

// ----------------------------------------------------------

-( void )addBall:( CGPoint )pos {
    float mass = 20;
    float radius = 8;
    // float radius = 8 + ( CCRANDOM_0_1( ) * 8 );
    
    ChipmunkBody* body = [ [ ChipmunkBody alloc ] initWithMass:mass andMoment:cpMomentForCircle( mass, 0, radius, CGPointZero ) ];
    body.pos = pos;
    body.angle = M_PI;
    [ m_space addBody:body ];
    
    ChipmunkShape* shape = [ ChipmunkCircleShape circleWithBody:body radius:radius offset:CGPointZero ];
    shape.elasticity = 0.8f;
    shape.friction = 0.2f;
    [ m_space addShape:shape ];
    
    [ m_shapeList addObject:shape ];

}

// ----------------------------------------------------------

@end























