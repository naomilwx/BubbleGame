//
//  GameStateStorer.h
//  BubbleGame
//
//  Created by Naomi Leow on 1/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameStateStorer : NSObject

- (NSMutableDictionary *)getDataFromFile;

- (void)updateAndSaveData:(id)data forLevel:(NSString *)level;

- (id)getDataForLevel:(NSString *)level;


@end
