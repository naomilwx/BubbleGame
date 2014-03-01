//
//  ScoreDisplay.m
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "ScoreDisplay.h"
#import "GameCommon.h"
#import "CGPointExtension.h"

#define SCORE_FONT @"Helvetica-Bold"
#define SCORE_FONT_SIZE 30
#define NOTIFICATION_FONT_SIZE 20
#define SCORE_TEXT @"Score: %d"
#define POP_TEXT @"Pop bonus: %d"
#define DROP_TEXT @"Drop bonus: %d"
#define NOTIFICATION_HEIGHT 50
#define NOTIFICATION_WIDTH 200
#define NOTIFICATION_YPOS 300
#define ANIMATION_DURATION 2

@implementation ScoreDisplay{
    NSInteger displayedScore;
    NSMutableArray *scoreIncrementDisplays;
}

- (id)initWithGameView:(UIView *)view andDisplayFrame:(CGRect)frame{
    if(self = [super init]){
        _gameView = view;
        scoreIncrementDisplays = [[NSMutableArray alloc] init];
        [self initialiseScoreDisplayWithFrame:frame];
        displayedScore = 0;
        [self setScoreDisplayToScore:displayedScore];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialiseScoreDisplayWithFrame:(CGRect)frame{
    _scoreDisplay = [[UILabel alloc] initWithFrame:frame];
    _scoreDisplay.font = [UIFont fontWithName:SCORE_FONT size:SCORE_FONT_SIZE];
    _scoreDisplay.textColor = [UIColor whiteColor];
    [self.gameView addSubview:_scoreDisplay];
    NSNotificationCenter *note = [NSNotificationCenter defaultCenter];
    [note addObserver:self selector:@selector(receiveScoreUpdate:) name:SCORE_NOTIFICATION object:nil];
}

- (void)displayAndAnimateScoreUpdate:(NSDictionary *)message{
    NSString *text;
    NSInteger change = [[message objectForKey:SCORE_CHANGE] integerValue];
    if([[message objectForKey:SCORE_CHANGE_TYPE] isEqual:POP_NOTIFICATION]){
        text = [NSString stringWithFormat:POP_TEXT, change];
    }else{
        text = [NSString stringWithFormat:DROP_TEXT, change];
    }
    UILabel *display = [self createScoreUpdateLabel:text];
    [self animateScoreUpdate:display];
}

- (UILabel *)createScoreUpdateLabel:(NSString *)text{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, NOTIFICATION_WIDTH, NOTIFICATION_HEIGHT)];
    NSInteger yOffset = [scoreIncrementDisplays count] * NOTIFICATION_HEIGHT;
    CGPoint center = yShift([self getScoreUpdateDisplayStartingPosition], yOffset);
    [label setCenter:center];
    [label setFont:[UIFont fontWithName:SCORE_FONT size:NOTIFICATION_FONT_SIZE]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:text];
    [label setAlpha:0];
    [self.gameView addSubview:label];
    [scoreIncrementDisplays addObject:label];
    return label;
}

- (void)animateScoreUpdate:(UIView *)view{
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.alpha = 1.0f;
                     }
                     completion:^(BOOL done){
                         [self fadeOutAndRemoveView:view];
                     }];
}

- (void)fadeOutAndRemoveView:(UIView *)view{
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.alpha = 0.0f;
                     }
                     completion:^(BOOL done){
                         [view removeFromSuperview];
                         [scoreIncrementDisplays removeObject:view];
                     }];
}

- (void)receiveScoreUpdate:(NSNotification *)notification{
    NSDictionary *message = [notification userInfo];
    NSInteger newScore = [[message objectForKey:SCORE_NOTIFICATION] integerValue];
    [self setScoreDisplayToScore:newScore];
    [self displayAndAnimateScoreUpdate:message];
}

- (CGPoint)getScoreUpdateDisplayStartingPosition{
    return CGPointMake(self.gameView.center.x, NOTIFICATION_YPOS);
}

- (void)setScoreDisplayToScore:(NSInteger)score{
    displayedScore = score;
    [self.scoreDisplay setText:[NSString stringWithFormat:SCORE_TEXT, displayedScore]];
}

@end
