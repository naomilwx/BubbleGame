//
//  GameLogic.m
//  BubbleGame
//
//  Created by Naomi Leow on 24/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameLogic.h"

@implementation GameLogic

+ (NSDictionary *)allBubbleImageMappings{
    NSDictionary *allBubbleImageMappings = @{[NSNumber numberWithInt:ORANGE]: [UIImage imageNamed:@"bubble-orange"],
                                             [NSNumber numberWithInt:BLUE]: [UIImage imageNamed:@"bubble-blue"],
                                             [NSNumber numberWithInt:GREEN]: [UIImage imageNamed:@"bubble-green"],
                                             [NSNumber numberWithInt:RED]: [UIImage imageNamed:@"bubble-red"],
                                             [NSNumber numberWithInt:INDESTRUCTIBLE]: [UIImage imageNamed:@"bubble-indestructible"],
                                             [NSNumber numberWithInt:LIGHTNING]: [UIImage imageNamed:@"bubble-lightning"],
                                             [NSNumber numberWithInt:STAR]: [UIImage imageNamed:@"bubble-star"],
                                             [NSNumber numberWithInt:BOMB]: [UIImage imageNamed:@"bubble-bomb"],
                                             };
    return allBubbleImageMappings;
}

+ (NSSet *)launchableBubbleTypes{
    NSSet *launchableTypes = [NSSet setWithObjects:[NSNumber numberWithInt:ORANGE], [NSNumber numberWithInt:BLUE], [NSNumber numberWithInt:GREEN], [NSNumber numberWithInt:RED], nil];
    return launchableTypes;
}

+ (NSSet *)specialBubbleTypes{
    NSSet *specialTypes = [NSSet setWithObjects:[NSNumber numberWithInt:INDESTRUCTIBLE], [NSNumber numberWithInt:LIGHTNING], [NSNumber numberWithInt:STAR], [NSNumber numberWithInt:BOMB], nil];
    return specialTypes;
}

@end
