//
//  FileManager.h
//  ps03
//
//  Created by Naomi Leow on 2/2/14.
//
//

#import <Foundation/Foundation.h>
#import "GameState.h"

#define STARTING_LEVEL 1
@interface DataManager : NSObject

@property (readonly) NSInteger nextLevel;

@property (readonly) NSInteger loadedLevel;

- (NSArray *)getAvailableLevels;

- (GameState *)loadLevel:(NSInteger)level;

- (void)saveGame:(GameState *)game asLevel:(NSInteger)level;

- (NSInteger)saveGame:(GameState *)game;

- (NSInteger)getPreviousLevelNumber;
//Gets the level number of the level before the currently loaded level. Cycles through all the levels

- (void)resetForNewLevel;
//Clears in memory data in the DataManager instance for the currently loaded level

@end
