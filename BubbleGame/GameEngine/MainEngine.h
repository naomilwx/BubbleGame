//
//  Engine.h
//  ps04
//
//  Created by Naomi Leow on 11/2/14.
//
//

#import <Foundation/Foundation.h>
#import "BubbleEngineManager.h"
#import "MainEngineDelegate.h"
#import "GridTemplateDelegate.h"

@interface MainEngine : NSObject<MainEngineDelegate>{
    NSMutableArray *mobileBubbles;
}

@property CGFloat defaultSpeed;
@property (strong) BubbleEngineManager *gridBubbles; //This stores the bubbleView objects encapsulated in BubbleEngine instances.
@property CGFloat frameWidth;
@property CGFloat frameHeight;
@property (weak) id<GridTemplateDelegate> gridTemplateDelegate;

- (void)checkGridBubbles;

- (void)addMobileEngine:(id)bubble withType:(NSInteger)type;

- (void)setDisplacementVectorForBubble:(CGPoint)vector;

- (void)addGridEngine:(id)bubble withType:(NSInteger)type andCenter:(CGPoint)center;

- (NSMutableSet *)getOrphanedBubblesIncludingCluster:(id)cluster;

- (void)removeAllOrphanedBubbles;

- (void)removeBubblesIfNecessary:(NSSet *)matchingCluster onInsertionOf:(id)object;

- (NSArray *)removeAllNeighboursForBubble:(BubbleEngine *)bubbleEngine;
- (void)removeAllBubbleOfType:(NSInteger)type;

- (NSArray *)removeAllBubblesInRow:(NSInteger)row;

- (void)handleMatchingCluster:(NSSet *)matchingCluster;

@end
