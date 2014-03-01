//
//  ScoreDisplay.m
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "ScoreDisplay.h"

@implementation ScoreDisplay

- (id)initWithGameView:(UIView *)view{
    if(self = [super init]){
        _gameView = view;
    }
    return self;
}

- (void)receiveScoreUpdate:(NSInteger)newScore{
    
}

@end
