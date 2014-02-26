//
//  GameDataManager.h
//  BubbleGame
//
//  Created by Naomi Leow on 26/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "DataManager.h"

@interface GameDataManager : DataManager

- (NSDictionary *)loadPreloadedLevel:(NSString *)levelFile;

- (NSDictionary *)loadDesignedLevel:(NSInteger)level;

@end
