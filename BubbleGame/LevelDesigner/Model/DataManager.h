//
//  FileManager.h
//  ps03
//
//  Created by Naomi Leow on 2/2/14.
//
//

#import <Foundation/Foundation.h>
#import "GameDesignerState.h"

#define STARTING_LEVEL 1
@interface DataManager : NSObject

@property (readonly) NSInteger nextLevel;

@property (readonly) NSInteger loadedLevel;

- (NSArray *)getAvailableLevels;
//Returns array of saved level numbers

- (GameDesignerState *)loadLevel:(NSInteger)level;

- (void)saveGame:(GameDesignerState *)game asLevel:(NSInteger)level;

- (NSInteger)saveGame:(GameDesignerState *)game;
//Saves given game state. Sets game level as the next available game level

- (NSInteger)getPreviousLevelNumber;
//Gets the level number of the level before the currently loaded level. Cycles through all the levels

- (void)resetForNewLevel;
//Clears in memory data in the DataManager instance for the currently loaded level

- (void)saveGameStateToTempFile:(GameDesignerState *)game;
//Saves given game state to the predefined DataManager temp file so it is retrievable in future

- (GameDesignerState *)loadGameStateFromTempFile;
//Loads game state from temp file and removes temp file if the file exists. Returns nil if the file doesn't exist

@end
