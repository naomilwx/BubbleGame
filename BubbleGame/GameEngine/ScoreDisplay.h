//
//  ScoreDisplay.h
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScoreDisplay : NSObject

@property (strong) UIView *gameView;
@property (strong) UILabel *scoreDisplay;

- (id)initWithGameView:(UIView *)view andDisplayFrame:(CGRect)frame;

- (void)receiveScoreUpdate:(NSNotification *)notification;

@end
