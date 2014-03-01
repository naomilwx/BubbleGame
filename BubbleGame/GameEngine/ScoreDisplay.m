//
//  ScoreDisplay.m
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "ScoreDisplay.h"
#import "GameCommon.h"

#define SCORE_FONT @"Helvetica-Bold"
#define SCORE_FONT_SIZE 24
#define SCORE_TEXT @"Score: %d"

@implementation ScoreDisplay{
    NSInteger displayedScore;
}

- (id)initWithGameView:(UIView *)view andDisplayFrame:(CGRect)frame{
    if(self = [super init]){
        _gameView = view;
        [self initialiseScoreDisplayWithFrame:frame];
        displayedScore = 0;
        [self setScoreDisplayWithScore:displayedScore];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialiseScoreDisplayWithFrame:(CGRect)frame{
    _scoreDisplay = [[UILabel alloc] initWithFrame:frame];
    _scoreDisplay.font = [UIFont fontWithName:SCORE_FONT size:SCORE_FONT_SIZE];
    _scoreDisplay.adjustsFontSizeToFitWidth = YES;
    [self.gameView addSubview:_scoreDisplay];
    NSNotificationCenter *note = [NSNotificationCenter defaultCenter];
    [note addObserver:self selector:@selector(receiveScoreUpdate:) name:SCORE_NOTIFICATION object:nil];
}

- (void)receiveScoreUpdate:(NSNotification *)notification{
    NSInteger newScore = [[[notification userInfo] objectForKey:SCORE_NOTIFICATION] integerValue];
    [self updateDisplayedScoreTo:newScore];
}

- (void)setScoreDisplayWithScore:(NSInteger)score{
    [self.scoreDisplay setText:[NSString stringWithFormat:SCORE_TEXT, displayedScore]];
}

- (void)updateDisplayedScoreTo:(NSInteger)score{
    NSInteger (^scoreCount)(NSInteger);
    if(score < displayedScore){
        scoreCount = ^NSInteger(NSInteger oldScore){
            return displayedScore - 1;
        };
    }else{
        scoreCount = ^NSInteger(NSInteger oldScore){
            return displayedScore + 1;
        };
    }
    while(displayedScore != score){
        displayedScore = scoreCount(displayedScore);
        [self setScoreDisplayWithScore:displayedScore];
    }
}
@end
