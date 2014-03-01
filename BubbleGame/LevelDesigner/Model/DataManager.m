//
//  FileManager.m
//  ps03
//
//  Created by Naomi Leow on 2/2/14.
//
//

#import "DataManager.h"
#import "GameCommon.h"

#define GAME_FILE_PREFIX @"%@/gamebubble_%@"
#define GAME_LEVEL_FILE @"%@/gamebubble_levels"
#define GAME_TEMP_FILE @"%@/tempfile"

@implementation DataManager{
    NSMutableArray *availableLevels;
    NSString *currentPath;
    NSString *gameLevelFile;
    NSString *tempFilePath;
}

@synthesize nextLevel;

@synthesize loadedLevel;

- (id)init{
    if(self = [super init]){
        availableLevels = [[NSMutableArray alloc] init];
        nextLevel = STARTING_LEVEL;
        loadedLevel = INVALID;
        currentPath = [self getRootFilePath];
        gameLevelFile = [self getFullFilePathForLevelFile];
        tempFilePath = [NSString stringWithFormat:GAME_TEMP_FILE, currentPath];
        if([[NSFileManager defaultManager] fileExistsAtPath:gameLevelFile]){
            [self loadAvailableLevels];
        }
        
    }
    return self;
}

- (NSString *)getRootFilePath{
    NSArray *dirArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [dirArr lastObject];
}

- (NSString *)getFullFilePathForGameLevel:(NSInteger)level{
    return [NSString stringWithFormat:GAME_FILE_PREFIX,currentPath,[NSNumber numberWithInteger:level]];
}

- (NSString *)getFullFilePathForLevelFile{
    return [NSString stringWithFormat:GAME_LEVEL_FILE,currentPath];
}

- (void)loadAvailableLevels{
    NSMutableData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:gameLevelFile];
    if(data){
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        nextLevel = [decoder decodeIntegerForKey:@"nextLevel"];
        availableLevels = [decoder decodeObjectForKey:@"availableLevels"];
    }
}

- (void)updateAvailableLevels{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [encoder encodeInteger:nextLevel forKey:@"nextLevel"];
    [encoder encodeObject:availableLevels forKey:@"availableLevels"];
    [encoder finishEncoding];
    [NSKeyedArchiver archiveRootObject:data toFile:gameLevelFile];
    
}

- (void)saveGameStateToTempFile:(GameDesignerState *)game{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [encoder encodeInteger:loadedLevel forKey:@"loadedLevel"];
    [encoder encodeObject:game forKey:@"game"];
    [encoder finishEncoding];
    [NSKeyedArchiver archiveRootObject:data toFile:tempFilePath];
}

- (GameDesignerState *)loadGameStateFromTempFile{
    if([[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]){
        NSMutableData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:tempFilePath];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSInteger level = [decoder decodeIntegerForKey:@"loadedLevel"];
        GameDesignerState *state = [decoder decodeObjectForKey:@"game"];
        if(state){
            loadedLevel = level;
        }
        [self removeFile:tempFilePath];
        return state;
    }else{
        return nil;
    }
}

- (void)removeFile:(NSString *)filePath{
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

- (void)saveGame:(GameDesignerState *)game asLevel:(NSInteger)level{
    loadedLevel = level;
    BOOL success = [NSKeyedArchiver archiveRootObject:game toFile:[self getFullFilePathForGameLevel:level]];
    if(!success){
        NSException* exception = [NSException
                                  exceptionWithName:@"Save level"
                                  reason:@"Error occurred while saving level. Level has not been saved"
                                  userInfo:nil];
        @throw exception;
    }
}

- (NSInteger)saveGame:(GameDesignerState *)game{
    //Saves gamestate to file
    //Returns level of game saved
    
    NSInteger currentLevel = nextLevel;
    [self saveGame:game asLevel:currentLevel];
    [availableLevels addObject:[NSNumber numberWithInteger:currentLevel]];
    nextLevel += 1;
    [self updateAvailableLevels];
    return currentLevel;
}

- (NSArray *)getAvailableLevels{
    return [NSArray arrayWithArray:availableLevels];
}

- (GameDesignerState *)loadLevel:(NSInteger)level{
    loadedLevel = level;
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self getFullFilePathForGameLevel:level]];
}

- (NSInteger)getPreviousLevelNumber{
    if(loadedLevel > STARTING_LEVEL){
        return (loadedLevel - 1);
    }else if(nextLevel > STARTING_LEVEL){
        //Returns the latest level if current level is at starting level and there is at least 1 level
        return (nextLevel - 1);
    }else{
        NSException* exception = [NSException
                                  exceptionWithName:@"Load level"
                                  reason:@"No levels have been created!"
                                  userInfo:nil];
        @throw exception;
    }
}
- (void)resetForNewLevel{
    loadedLevel = INVALID;
}

- (BOOL)createFile:(NSString *)filepath{
    if(![[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        return [[NSFileManager defaultManager] createFileAtPath:filepath contents:nil attributes:nil];
    }else{
        return NO;
    }
}


@end
