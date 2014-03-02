//
//  ScoreDisplay.h
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StateDisplay : NSObject

@property (strong) UIView *gameView;
@property (strong) UILabel *scoreDisplay;
@property (strong) UILabel *highScoreDisplay;

- (id)initWithGameView:(UIView *)view andDisplayFrame:(CGRect)frame;

- (void)receiveScoreUpdate:(NSNotification *)notification;

- (void)showTextNotification:(NSString *)text withFrame:(CGRect)frame;

- (void)hideTextNotification;

- (void)displayHighscore:(NSInteger)highscore;

- (void)resetScoreDisplay;

@end
