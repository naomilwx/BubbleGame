//
//  GameLogic.h
//  BubbleGame
//
//  Created by Naomi Leow on 24/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef Game_Logic_h
#define Game_Logic_h

# define NUM_OF_PALETTE_BUBBLE_TYPES 8
# define NUM_OF_BUBBLE_COLORS 4
# define INVALID -1
# define NUM_CELLS_IN_ROW 12
# define NUM_OF_ROWS 9
# define BUBBLE_QUEUE_SIZE 2
# define MAIN_MENU 1
# define LEVEL_DESIGNER 2

#endif

typedef enum GamePalette{
    NONE = INVALID,
    ORANGE = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3,
    ERASER = 4,
    INDESTRUCTIBLE = 5,
    LIGHTNING = 6,
    STAR = 7,
    BOMB = 8
} GamePaletteSelection; //Order in level designer storyboard must be as defined here

@interface GameLogic : NSObject

+ (NSDictionary *)allBubbleImageMappings;

+ (NSSet *)launchableBubbleTypes;

+ (NSSet *)specialBubbleTypes;


@end
