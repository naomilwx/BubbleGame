//
//  GameDataManager.m
//  BubbleGame
//
//  Created by Naomi Leow on 26/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameDataManager.h"

@implementation GameDataManager

- (id)init{
    if(self = [super init]){
    }
    return self;
}

- (NSDictionary *)loadPreloadedLevel:(NSString *)levelFileName{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:levelFileName ofType:nil];
    GameDesignerState *savedState = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return [savedState getAllBubbles];
}
- (NSDictionary *)loadDesignedLevel:(NSInteger)level{
    GameDesignerState *savedState = [self loadLevel:level];
    return [savedState getAllBubbles];
}

@end
