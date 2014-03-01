//
//  ScoreDisplay.m
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "StateDisplay.h"
#import "GameCommon.h"
#import "CGPointExtension.h"

#define SCORE_FONT @"Helvetica-Bold"
#define SCORE_FONT_SIZE 30
#define NOTIFICATION_FONT_SIZE 20
#define SCORE_TEXT @"Score: %d"
#define HIGH_SCORE_TEXT @"Highscore: %d"
#define POP_TEXT @"Pop bonus: %d"
#define DROP_TEXT @"Drop bonus: %d"
#define NOTIFICATION_HEIGHT 50
#define NOTIFICATION_WIDTH 200
#define NOTIFICATION_YPOS 300
#define ANIMATION_DURATION 2

@implementation StateDisplay{
    NSInteger displayedScore;
    NSMutableArray *scoreIncrementDisplays;
    UILabel *notificationDisplay;
}

- (id)initWithGameView:(UIView *)view andDisplayFrame:(CGRect)frame{
    if(self = [super init]){
        _gameView = view;
        scoreIncrementDisplays = [[NSMutableArray alloc] init];
        [self initialiseScoreDisplayWithFrame:frame];
        displayedScore = 0;
        [self setScoreDisplayToScore:displayedScore];
        CGPoint offset = CGPointMake(0, frame.size.height * -1);
        [self initialiseHighScoreDisplayWithFrame:frame andOffset:offset];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialiseScoreDisplayWithFrame:(CGRect)frame{
    _scoreDisplay = [[UILabel alloc] initWithFrame:frame];
    [self configureAndShowScoreDisplay:_scoreDisplay];
    NSNotificationCenter *note = [NSNotificationCenter defaultCenter];
    [note addObserver:self selector:@selector(receiveScoreUpdate:) name:SCORE_NOTIFICATION object:nil];
}

- (void)initialiseHighScoreDisplayWithFrame:(CGRect)frame andOffset:(CGPoint)offset{
    CGRect newFrame = CGRectMake(frame.origin.x + offset.x, frame.origin.y + offset.y, frame.size.width, frame.size.height);
    _highScoreDisplay = [[UILabel alloc] initWithFrame:newFrame];
    [self configureAndShowScoreDisplay:_highScoreDisplay];
}

- (void)displayHighscore:(NSInteger)highscore{
    NSString *display = @"";
    if(highscore){
        display = [NSString stringWithFormat:HIGH_SCORE_TEXT, highscore];
    }
    [self.highScoreDisplay setText:display];
}

- (void)configureAndShowScoreDisplay:(UILabel *)display{
    display.font = [UIFont fontWithName:SCORE_FONT size:SCORE_FONT_SIZE];
    display.textColor = [UIColor whiteColor];
    [self.gameView addSubview:display];
}

- (void)showTextNotification:(NSString *)text withFrame:(CGRect)frame{
    notificationDisplay = [[UILabel alloc] initWithFrame:frame];
    [notificationDisplay setFont:[UIFont fontWithName:SCORE_FONT size:NOTIFICATION_FONT_SIZE]];
    [notificationDisplay adjustsFontSizeToFitWidth];
    [notificationDisplay setTextColor:[UIColor whiteColor]];
    [notificationDisplay setText:text];
    [self.gameView addSubview:notificationDisplay];
}

- (void)hideTextNotification{
    if(notificationDisplay){
        [self fadeOutAndRemoveView:notificationDisplay
                    withCompletion:^(BOOL done){
                        [notificationDisplay removeFromSuperview];}
                       andDuration:ANIMATION_DURATION];
    }
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
    void(^finalAction)(BOOL) = ^(BOOL done){
        [view removeFromSuperview];
        [scoreIncrementDisplays removeObject:view];
    };
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.alpha = 1.0f;
                     }
                     completion:^(BOOL done){
                         [self fadeOutAndRemoveView:view withCompletion:finalAction andDuration:ANIMATION_DURATION];
                     }];
}

- (void)fadeOutAndRemoveView:(UIView *)view withCompletion:(void (^)(BOOL))completionBlock andDuration:(NSTimeInterval)duration{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.alpha = 0.0f;
                     }
                     completion:^(BOOL done){
                         completionBlock(done);
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
