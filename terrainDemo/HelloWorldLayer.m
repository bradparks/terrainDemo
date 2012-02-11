//
//  HelloWorldLayer.m
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright Protec Electronics 2012. All rights reserved.
//
// ----------------------------------------------------------
// Import the interfaces

#import "HelloWorldLayer.h"

// ----------------------------------------------------------
// HelloWorldLayer implementation

@implementation HelloWorldLayer

// ----------------------------------------------------------

+( CCScene* )scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	// add layer as a child to scene
	[scene addChild: layer];
	// return the scene
	return scene;
}

// ----------------------------------------------------------

-( id )init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	self = [ super init ];
	// initialize touch 
	[ [ CCTouchDispatcher sharedDispatcher ] addTargetedDelegate:self priority:0 swallowsTouches:YES ];

    // create world
    [ self addChild:WORLD ];
    
    // create terrain
    m_terrain = [ pgeTerrain terrainWithType:TERRAIN_TYPE_SOIL ];
#if GAME_DEBUG_DRAW == 1
    // watch the actual texture
    CGSize size = [ [ CCDirector sharedDirector ] winSize ];
    CCSprite* sprite = [ CCSprite spriteWithTexture:m_terrain.texture.texture ];
    sprite.color = ( ccColor3B ){ 128, 128, 255 };
    sprite.opacity = 64;
    sprite.position = ccpMult( ccp( size.width, size.height ), 0.5f );
    sprite.scaleX = size.width / m_terrain.texture.size.width;
    sprite.scaleY = -( size.height / m_terrain.texture.size.height );
    [ self addChild:sprite ];
#endif 
    [ self addChild:m_terrain ];    
    
    // add terrain to world
    [ WORLD.space add:m_terrain ];
		
    // buttons
    m_plus = [ CCSprite spriteWithFile:PLUS_FILE ];
    m_plus.position = PLUS_POSITION;
    m_plus.color = BUTTON_COLOR_OFF;
    [ self addChild:m_plus ];
    
    m_minus = [ CCSprite spriteWithFile:MINUS_FILE ];
    m_minus.position = MINUS_POSITION;
    m_minus.color = BUTTON_COLOR_OFF;
    [ self addChild:m_minus ];
    
	// init animation
	[ self schedule:@selector( animate: ) ];	
	
    // done
	return( self );
}

// ----------------------------------------------------------

-( void ) dealloc {
    // clean up

	
	// done
	[ super dealloc ];
}

// ----------------------------------------------------------
// scheduled animation

-( void )animate:( ccTime )dt {
    
    [ WORLD update:dt ];


}


// ----------------------------------------------------------

-( BOOL )ccTouchBegan:( UITouch* )touch withEvent:( UIEvent* )event {
	CGPoint pos;
	
	// get touch position and convert to screen coordinates
	pos = [ touch locationInView: [ touch view ] ];
	pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];
    
    [ self ccTouchMoved:touch withEvent:event ];
    // done
    return( YES );
}

// ----------------------------------------------------------

-( void )ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint pos;
	
	// get touch position and convert to screen coordinates
	pos = [ touch locationInView: [ touch view ] ];
	pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];
    
    switch ( m_mode ) {
        case USER_MODE_ADD:
 
            [ m_terrain.texture modify:[ m_terrain.texture worldToTexture:pos ] size:12 add:YES ];
            
            [ WORLD.space remove:m_terrain ];
            [ m_terrain reset:TERRAIN_TYPE_ICE ];
            [ WORLD.space add:m_terrain ];
                        
            break;
            
        case USER_MODE_REMOVE:
  
            [ m_terrain.texture modify:[ m_terrain.texture worldToTexture:pos ] size:12 add:NO ];
            
            [ WORLD.space remove:m_terrain ];
            [ m_terrain reset:TERRAIN_TYPE_ICE ];
            [ WORLD.space add:m_terrain ];
            
            break;
            
        default:
            break;
    }
    
}

// ----------------------------------------------------------

-( void )ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint pos;
	
	// get touch position and convert to screen coordinates
	pos = [ touch locationInView: [ touch view ] ];
	pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];

    if ( ccpDistance( pos, PLUS_POSITION ) < BUTTON_DETECTION_RANGE ) {
        m_mode = USER_MODE_ADD;
        m_plus.color = BUTTON_COLOR_ON;
        return;
    } else {
        m_plus.color = BUTTON_COLOR_OFF;
    }
    if ( ccpDistance( pos, MINUS_POSITION ) < BUTTON_DETECTION_RANGE ) {
        m_mode = USER_MODE_REMOVE;
        m_minus.color = BUTTON_COLOR_ON;
        return;
    } else {
        m_minus.color = BUTTON_COLOR_OFF;
    }

    if ( m_mode == USER_MODE_BALL ) {
        if ( [ m_terrain.texture pointInside:[ m_terrain.texture worldToTexture:pos ] ] == NO ) [ WORLD addBall:pos ];
    } 

    m_mode = USER_MODE_BALL;
    
}




// ----------------------------------------------------------

@end






















