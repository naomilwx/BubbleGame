//
//  GameDataManager.h
//  BubbleGame
//
//  Created by Naomi Leow on 26/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

/*!
  Extends DataManager as defined in LevelDesigner component. Allows both loading of preloaded levels and levels designed using the LevelDesigner component
 */
#import "DataManager.h"

@interface GameDataManager : DataManager

- (NSDictionary *)loadPreloadedLevel:(NSString *)levelFile;

- (NSDictionary *)loadDesignedLevel:(NSInteger)level;

@end
