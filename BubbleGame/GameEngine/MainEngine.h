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

- (void)addMobileEngine:(id)bubble withType:(NSInteger)type;

- (void)setDisplacementVectorForBubble:(CGPoint)vector;

- (void)addGridEngine:(id)bubble withType:(NSInteger)type andCenter:(CGPoint)center;

- (NSMutableSet *)getOrphanedBubblesNeighbouringCluster:(NSSet *)cluster;

@end
