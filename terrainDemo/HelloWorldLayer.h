//
//  HelloWorldLayer.h
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright Protec Electronics 2012. All rights reserved.
//
// ----------------------------------------------------------

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import <Foundation/Foundation.h>
#import "pgeTerrain.h"
#import "pgeWorld.h"
#import "GameConfig.h"

// ----------------------------------------------------------

#define PLUS_FILE                   @"plus.png"
#define PLUS_POSITION               CGPointMake( 410, 290 )

#define MINUS_FILE                  @"minus.png"
#define MINUS_POSITION              CGPointMake( 460, 290 )

#define BUTTON_COLOR_OFF            ccORANGE
#define BUTTON_COLOR_ON             ccYELLOW

#define BUTTON_DETECTION_RANGE      32

// ----------------------------------------------------------

typedef enum {
    USER_MODE_BALL,
    USER_MODE_ADD,
    USER_MODE_REMOVE,
} USER_MODE;

// ----------------------------------------------------------

@interface HelloWorldLayer : CCLayer {
    pgeTerrain*             m_terrain;
    CCSprite*               m_plus;
    CCSprite*               m_minus;
    USER_MODE               m_mode;
}

// ----------------------------------------------------------

// ----------------------------------------------------------

+( CCScene* )scene;
-( void )animate:( ccTime )dt;

// ----------------------------------------------------------

@end
