//
//  GameStateStorer.m
//  BubbleGame
//
//  Created by Naomi Leow on 1/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameStateStorer.h"
#define FILE_NAME @"bubblelevel_data"

@implementation GameStateStorer{
    NSMutableDictionary *gameScores;
}

- (id)init{
    if(self = [super init]){
        gameScores = [[NSMutableDictionary alloc] init];
    }
    return self;
}
@end
