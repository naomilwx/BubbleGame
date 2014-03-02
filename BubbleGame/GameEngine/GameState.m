//
//  GameState.m
//  BubbleGame
//
//  Created by Naomi Leow on 27/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameState.h"
#import "GameCommon.h"

#define DROPPED_SCORE 25
#define POPPED_SCORE 15
#define MIN_BUBBLES_FOR_BONUS 3
#define ADDITIONAL_BONUS 10
#define ENDGAME_WITH_HIGHSCORE_MSG @"Congratulations! You win the game with highscore!"
#define ENDGAME_WIN @"Congratulations! You have successfully cleared all the bubbles."
#define ENDGAME_LOSE @"Game over! Try harder next time!"
#define OUT_OF_BUBBLES_MSG @"No more bubbles to fire!"
#define BASE_NUM_LAUNCHED_BUBBLES 10
#define ALLOWANCE_PER_CLUSTER 2

@implementation GameState{
    NSInteger totalBubbles;
    NSInteger previousHighscore;
    NSInteger maxLaunchedBubbles;
}

@synthesize gridBubbles;
@synthesize totalScore;
@synthesize gameLevel;
@synthesize storer;

- (id)initWithLevel:(NSString *)level{
    if(self = [super init]){
        gridBubbles = [[BubbleEngineManager alloc] init];
        totalBubbles = 0;
        totalScore = 0;
        gameLevel = level;
        storer = [[GameStateStorer alloc] init];
        maxLaunchedBubbles = [self determineMaxNumberOfLaunchedBubbles];
        [self getStoredHighscoreFromFile];
    }
    return self;
}

- (NSInteger)determineMaxNumberOfLaunchedBubbles{
    NSInteger totalInitialClusters = [gridBubbles getTotalClusterCount];
    NSInteger maxNum = totalInitialClusters * ALLOWANCE_PER_CLUSTER + BASE_NUM_LAUNCHED_BUBBLES;
    return maxNum;
}

- (NSInteger)getMaxLaunchedBubbles{
    return maxLaunchedBubbles;
}

- (void)getStoredHighscoreFromFile{
    NSNumber *score = [storer getDataForLevel:gameLevel];
    if(score){
        previousHighscore = [score integerValue];
    }else{
        previousHighscore = 0;
    }
}

- (void)updateStoredHighscore{
    NSString *emptyLevel = [NSString stringWithFormat:@"%d", INVALID];
    if(totalScore > previousHighscore && ![gameLevel isEqual:emptyLevel]){
        [storer updateAndSaveData:[NSNumber numberWithInteger:totalScore] forLevel:gameLevel];
    }
}

- (NSInteger)getPreviousHighscore{
    return previousHighscore;
}

- (void)notifyGameEndStatusWin:(BOOL)win withDisplayMessage:(NSString *)message{
    NSDictionary *notificationMsg = @{ENDGAME_MESSAGE: message,
                              ENDGAME_STATUS: [NSNumber numberWithBool:win]};
    [self postGameStateNotification:notificationMsg withNotificationName:ENDGAME];
}

- (void)updateTotalScoresForDroppedBubbles:(NSInteger)num{
    totalScore += num * DROPPED_SCORE;
    NSDictionary *message = @{SCORE_NOTIFICATION: [NSNumber numberWithInteger:totalScore],
                              SCORE_CHANGE: [NSNumber numberWithInteger:num*DROPPED_SCORE],
                              SCORE_CHANGE_TYPE: DROP_NOTIFICATION
                              };
    [self postGameStateNotification:message withNotificationName:SCORE_NOTIFICATION];
    [self checkAndApplyBonus:num];
}

- (void)updateTotalScoresForPoppedBubbles:(NSInteger)num{
    totalScore += num * POPPED_SCORE;
    NSDictionary *message = @{SCORE_NOTIFICATION: [NSNumber numberWithInteger:totalScore],
                              SCORE_CHANGE: [NSNumber numberWithInteger:num*POPPED_SCORE],
                              SCORE_CHANGE_TYPE: POP_NOTIFICATION
                              };
    [self postGameStateNotification:message withNotificationName:SCORE_NOTIFICATION];
    [self checkAndApplyBonus:num];
}

- (void)checkAndApplyBonus:(NSInteger)numOfBubbles{
    if(numOfBubbles > MIN_BUBBLES_FOR_BONUS){
        NSInteger bonus = (numOfBubbles - MIN_BUBBLES_FOR_BONUS) * ADDITIONAL_BONUS;
        totalScore += bonus;
        NSDictionary *message = @{SCORE_NOTIFICATION: [NSNumber numberWithInteger:totalScore],
                                  SCORE_CHANGE: [NSNumber numberWithInteger:bonus],
                                  SCORE_CHANGE_TYPE: BONUS_NOTIFICATION
                                  };
        [self postGameStateNotification:message withNotificationName:SCORE_NOTIFICATION];

    }
}

- (void)postGameStateNotification:(NSDictionary *)message withNotificationName:(NSString *)name{
    NSNotificationCenter *note = [NSNotificationCenter defaultCenter];
    [note postNotificationName:name object:self userInfo:message];
}

- (NSSet *)insertBubble:(BubbleEngine *)bubbleEngine intoGridAtRow:(NSInteger)row andCol:(NSInteger)col{
    totalBubbles += 1;
    return [gridBubbles insertObject:bubbleEngine AtRow:row andPosition:col];
}

- (NSArray *)getNeighboursForObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos{
    return [gridBubbles getNeighboursForObjectAtRow:row andPosition:pos];
}

- (NSArray *)getObjectsAtRow:(NSInteger)row{
    return [gridBubbles getObjectsAtRow:row];
}

- (NSArray *)getAllObjects{
    return [gridBubbles getAllObjects];
}

- (NSSet *)getAllObjectsOfType:(NSInteger)type{
    return [gridBubbles getAllObjectsOfType:type];
}

- (NSDictionary *)getAllClusters{
    return [gridBubbles getAllClusters];
}

- (void)removeGridBubbleAtRow:(NSInteger)row andPositions:(NSInteger)col{
    id removedObject = [gridBubbles removeObjectAtRow:row andPosition:col];
    if(removedObject){
        totalBubbles -= 1;
        if(totalBubbles == 0){
            [self sendRemovedAllGridBubblesGameEndNotification];
        }
    }
}

- (void)sendRemovedAllGridBubblesGameEndNotification{
    if(totalScore >= previousHighscore){
        [self notifyGameEndStatusWin:YES withDisplayMessage:ENDGAME_WITH_HIGHSCORE_MSG];
    }else{
        [self notifyGameEndStatusWin:YES withDisplayMessage:ENDGAME_WIN];
    }
}

- (NSMutableSet *)getOrphanedBubblesIncludingCluster:(id)cluster{
    NSMutableSet *accumulated = nil;
    NSMutableSet *allAccumulated = [[NSMutableSet alloc] init];
    NSMutableSet *visited = [[NSMutableSet alloc] init];
    BOOL searchResult;
    
    for(BubbleEngine *engine in cluster){
        if([visited containsObject:engine]){
            continue;
        }
        //New cluster
        accumulated = [[NSMutableSet alloc] init];
        searchResult = [self searchForRootBubble:accumulated startPoint:engine visitedBubbles:visited];
        if(!searchResult){
            [allAccumulated addObject:accumulated];
        }
    }
    return allAccumulated;
}

- (NSMutableSet *)getOrphanedBubblesNeighbouringCluster:(NSSet *)cluster{
    //Deprecated but used in old tests
    NSMutableSet *accumulated = nil;
    NSMutableSet *allAccumulated = [[NSMutableSet alloc] init];
    NSMutableSet *visited = [[NSMutableSet alloc] init];
    BOOL searchResult;
    for(BubbleEngine *removedEngine in cluster){
        NSArray *neighbours = [gridBubbles getNeighboursForObjectAtRow:removedEngine.gridRow andPosition:removedEngine.gridCol];
        for(BubbleEngine *engine in neighbours){
            if([visited containsObject:engine]){
                continue;
            }
            //New cluster
            accumulated = [[NSMutableSet alloc] init];
            searchResult = [self searchForRootBubble:accumulated startPoint:engine visitedBubbles:visited];
            if(!searchResult){
                [allAccumulated addObject:accumulated];
            }
        }
    }
    return allAccumulated;
}

- (BOOL)searchForRootBubble:(NSMutableSet *)accumulatedCluster startPoint:(BubbleEngine *)bubble visitedBubbles:(NSMutableSet *)visited{
    BOOL (^searchCondition)(BubbleEngine *) = ^(BubbleEngine *bubbleEngine){
        if(bubbleEngine.gridRow == 0){
            return YES;
        }else{
            return NO;
        }
    };
    return [gridBubbles depthFirstSearchAndCluster:accumulatedCluster
                                        startPoint:bubble
                             accumulationCondition:nil
                               andSearchConditions:searchCondition
                                      visitedItems:visited];
}

- (void)reload{
    [gridBubbles clearAll];
    totalBubbles = 0;
    totalScore = 0;
}

@end
