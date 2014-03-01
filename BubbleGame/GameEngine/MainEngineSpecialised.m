//
//  MainEngineSpecialised.m
//  BubbleGame
//
//  Created by Naomi Leow on 26/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "MainEngineSpecialised.h"
#import "GameCommon.h"

@implementation MainEngineSpecialised

- (void)removeBubblesIfNecessary:(NSSet *)matchingCluster onInsertionOf:(id)object{
    [self handleMatchingCluster:matchingCluster];
    [self handleSpecialNeighbouringBubbles:object];
    [self removeAllOrphanedBubbles];
    [self checkGridBubbles];
}

- (void)handleSpecialNeighbouringBubbles:(BubbleEngine *)bubbleEngine{
    NSArray *specialNeighbours = [self getAllNeighbouringSpecialBubbles:bubbleEngine];
    for(BubbleEngine *neighbour in specialNeighbours){
        NSInteger specialType = [neighbour bubbleType];
        if(specialType == STAR){
            [self removeAllBubbleOfType:[bubbleEngine bubbleType]];
            [neighbour removeBubbleWithAnimationType:POP_ANIMATION];
        }else{
            [self applyChainableEffect:neighbour];
        }
    }
}
- (void)applyChainableEffect:(BubbleEngine *)engine{
    if([engine hasBeenChained] == NO){
        [engine setHasBeenChained:YES];
        NSInteger chainableType = [engine bubbleType];
        NSArray *affectedBubbles = nil;
        if(chainableType == LIGHTNING){
            affectedBubbles = [self removeAllBubblesInRow:[engine gridRow]];
        }else if(chainableType == BOMB){
            affectedBubbles = [self removeAllNeighboursForBubble:engine];
            [engine removeBubbleWithAnimationType:POP_ANIMATION];
        }
        if(affectedBubbles != nil){
            for(BubbleEngine *bubble in affectedBubbles){
                [self applyChainableEffect:bubble];
            }
        }
    }
}
- (NSArray *)getAllNeighbouringSpecialBubbles:(BubbleEngine *)bubbleEngine{
    NSArray *neighbourList = [self.bubbleGameState getNeighboursForObjectAtRow:bubbleEngine.gridRow andPosition:bubbleEngine.gridCol];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSSet *specialBubbles = [GameCommon specialBubbleTypes];
    for(BubbleEngine *engine in neighbourList){
        if([specialBubbles containsObject:[NSNumber numberWithInteger:[engine bubbleType]]]){
            [arr addObject:engine];
        }
    }
    return arr;
}

@end
