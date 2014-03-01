//
//  GameStateStorer.h
//  BubbleGame
//
//  Created by Naomi Leow on 1/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//
/*!
    Class which stores and loads game data to file. Currently it only saves each level's highscore.
    But it is extendable and can be made to store any form of game data object which implements the NSCoding protocol
 */

#import <Foundation/Foundation.h>

@interface GameStateStorer : NSObject

- (NSMutableDictionary *)getDataFromFile;

- (void)updateAndSaveData:(id)data forLevel:(NSString *)level;

- (id)getDataForLevel:(NSString *)level;


@end
