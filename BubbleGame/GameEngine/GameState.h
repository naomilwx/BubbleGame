//
//  GameState.h
//  BubbleGame
//
//  Created by Naomi Leow on 27/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BubbleEngineManager.h"
#import "GridTemplateDelegate.h"
#import "GameStateStorer.h"

@interface GameState : NSObject

@property (strong) BubbleEngineManager *gridBubbles; //This stores the bubbleView objects encapsulated in BubbleEngine instances.
@property (readonly) NSInteger totalScore;
@property (strong) NSString *gameLevel;
@property (strong) GameStateStorer *storer;

- (id)initWithLevel:(NSString *)level;

- (NSSet *)insertBubble:(BubbleEngine *)bubbleEngine intoGridAtRow:(NSInteger)row andCol:(NSInteger)col;

- (NSArray *)getNeighboursForObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos;

- (NSArray *)getObjectsAtRow:(NSInteger)row;

- (NSArray *)getAllObjects;

- (NSSet *)getAllObjectsOfType:(NSInteger)type;

- (NSDictionary *)getAllClusters;

- (NSMutableSet *)getOrphanedBubblesIncludingCluster:(id)cluster;

- (NSMutableSet *)getOrphanedBubblesNeighbouringCluster:(NSSet *)cluster;

- (void)removeGridBubbleAtRow:(NSInteger)row andPositions:(NSInteger)col;

- (void)increaseLaunchedBubblesCount;

- (void)updateTotalScoresForDroppedBubbles:(NSInteger)num;

- (void)updateTotalScoresForPoppedBubbles:(NSInteger)num;

- (NSInteger)getPreviousHighscore;

- (void)reload;

@end
