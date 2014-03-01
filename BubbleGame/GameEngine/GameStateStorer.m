//
//  GameStateStorer.m
//  BubbleGame
//
//  Created by Naomi Leow on 1/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameStateStorer.h"
#define FILE_NAME @"%@/bubblelevel_data"

@implementation GameStateStorer{
    NSMutableDictionary *gameScores;
    NSString *dataFile;
}

- (id)init{
    if(self = [super init]){
        gameScores = [[NSMutableDictionary alloc] init];
        dataFile = [self getGameDataFile];
        if([[NSFileManager defaultManager] fileExistsAtPath:dataFile]){
            [self getGameDataFile];
        }
    }
    return self;
}

- (NSString *)getRootFilePath{
    NSArray *dirArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [dirArr lastObject];
}

- (NSString *)getGameDataFile{
    return [NSString stringWithFormat:[self getRootFilePath], FILE_NAME];
}

- (NSMutableDictionary *)getDataFromFile{
    gameScores = [NSKeyedUnarchiver unarchiveObjectWithFile:dataFile];
    return gameScores;
}

- (id)getDataForLevel:(NSString *)level{
    return [gameScores objectForKey:level];
}

- (void)updateAndSaveData:(id)data forLevel:(NSString *)level{
    [gameScores setObject:data forKey:level];
    [NSKeyedArchiver archiveRootObject:gameScores toFile:dataFile];
}

@end
