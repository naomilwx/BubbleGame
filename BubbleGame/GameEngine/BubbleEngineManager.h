//
//  BubbleManager.h
//  ps04
//
//  Created by Naomi Leow on 2/2/14.
//
//

#import <Foundation/Foundation.h>
#import "BubbleEngine.h"

@interface BubbleEngineManager : NSObject
//This was the datastucture modified from ps03. It requires stored objects to be of type BubbleEngine because of the type cluster tracking implemented. 

- (id)getObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos;
//Returns nil if object does not exist

- (NSSet *)insertObject:(id)object AtRow:(NSInteger)row andPosition:(NSInteger)pos;

- (id)removeObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos;

- (id)removeObjectAndPruneClusterAtRow:(NSInteger)row andPosition:(NSInteger)pos;

- (NSArray *)getNeighboursForObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos;

- (NSArray *)getObjectsAtRow:(NSInteger)row;

- (NSArray *)getAllObjects;

- (NSSet *)getAllObjectsOfType:(NSInteger)type;

- (NSDictionary *)getAllClusters;

- (BOOL)depthFirstSearchAndCluster:(NSMutableSet *)accumulatedCluster startPoint:(BubbleEngine *)bubble accumulationCondition:(BOOL(^)(BubbleEngine *))condBlock andSearchConditions:(BOOL(^)(BubbleEngine *))searchCond visitedItems:(NSMutableSet *)visited;

- (void)clearAll;
//Removes all GameEngine instances stored in the data structure

@end