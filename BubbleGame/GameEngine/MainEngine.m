//
//  Engine.m
//  ps04
//
//  Created by Naomi Leow on 11/2/14.
//
//

#import "MainEngine.h"
#import "BubbleEngine.h"
#import "BubbleGridLayout.h"
#import <QuartzCore/QuartzCore.h>
#import "GameLogic.h"

#define DEFAULT_ID 0
#define DEFAULT_SPEED_FACTOR 20

//All bubbleviews will be wrapped in a BubbleEngine instance which will act as its controller
@implementation MainEngine{
    CADisplayLink *displayLink;
    NSMutableArray *mobileBubblesToRemove;
    NSInteger nextEngineID;
}

@synthesize defaultSpeed;
//@synthesize gridBubbles; //This will store all static bubble views
@synthesize bubbleGameState;
@synthesize frameHeight;
@synthesize frameWidth;
@synthesize gridTemplateDelegate;

- (void)checkGridBubbles{
    //Checks if stored GridBubbles tally with view, ie all of the BubbleEngine instances have their corresponding views rendered
    for(BubbleEngine *engine in [bubbleGameState getAllObjects]){
        id view = [engine bubbleView];
        if(view == nil || ![view isRendered]){
            [NSException raise:@"BubbleGrid and view rendering error" format:
             @"Bubble data stored inconsistent with view!"];
        }
    }
}

- (id)init{
    if(self = [super init]){
        defaultSpeed = DEFAULT_SPEED_FACTOR;
        nextEngineID = DEFAULT_ID;
        mobileBubbles = [[NSMutableArray alloc] init];
        mobileBubblesToRemove = [[NSMutableArray alloc] init];
        bubbleGameState = [[GameState alloc] init];
        [self createDisplayLink];
    }
    return self;
}

- (void)reload{
    [self clearAllExistingBubbles];
    mobileBubbles = [[NSMutableArray alloc] init];
    mobileBubblesToRemove = [[NSMutableArray alloc] init];
    bubbleGameState = [[GameState alloc] init];
}

- (void)shutdownDisplayLink{
    [displayLink invalidate];
}

- (void)clearAllExistingBubbles{
    NSArray *bubbles = [bubbleGameState getAllObjects];
    for(BubbleEngine *engine in bubbles){
        [engine removeBubbleWithAnimationType:NO_ANIMATION];
    }
    for(BubbleEngine *engine in mobileBubbles){
        [engine removeBubbleWithAnimationType:NO_ANIMATION];
    }
}

- (void)createDisplayLink{
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMobilePositions:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)addMobileEngine:(id)bubble withType:(NSInteger)type{
    BubbleEngine *bubbleEngine = [self createBubbleEngineWithView:(id)bubble andType:type];
    [mobileBubbles addObject:bubbleEngine];
    [bubbleGameState increaseLaunchedBubblesCount];
}

- (BubbleEngine *)createBubbleEngineWithView:(id)bubble andType:(NSInteger)type{
    BubbleEngine *bubbleEngine = [[BubbleEngine alloc] initWithBubbleView:bubble andID:nextEngineID];
    [bubbleEngine setBubbleType:type];
    nextEngineID += 1;
    [bubbleEngine setMainEngine:self];
    return bubbleEngine;
}

- (BubbleEngine *)createBubbleEngineWithView:(id)bubble andType:(NSInteger)type andCenter:(CGPoint)center{
    BubbleEngine *bubbleEngine = [[BubbleEngine alloc] initAsGridBubbleWithCenter:center view:bubble andID:nextEngineID];
    [bubbleEngine setBubbleType:type];
    nextEngineID += 1;
    [bubbleEngine setMainEngine:self];
    return bubbleEngine;
}
- (void)addGridEngine:(id)bubble withType:(NSInteger)type andCenter:(CGPoint)center{
    BubbleEngine *bubbleEngine = [self createBubbleEngineWithView:bubble andType:type andCenter:center];
    NSIndexPath *path = [gridTemplateDelegate indexPathForItemAtPoint:center];
    [self insertBubble:bubbleEngine intoGridAtIndexPath:path];
    [self checkGridBubbles];
}

- (void)setDisplacementVectorForBubble:(CGPoint)vector{
    BubbleEngine *bubbleEngine = [mobileBubbles lastObject];
    CGPoint displacement = CGPointMake(vector.x * defaultSpeed, vector.y * defaultSpeed);
    [bubbleEngine setDisplacementVector:displacement];
}

- (void)updateMobilePositions:(CADisplayLink *)sender{
    for(BubbleEngine *bubbleEngine in mobileBubbles){
        [bubbleEngine moveBubble];
    }
    [self cleanUpMobileArray];
}

- (void)cleanUpMobileArray{
    [mobileBubbles removeObjectsInArray:mobileBubblesToRemove];
    [mobileBubblesToRemove removeAllObjects];
}

- (void)setMobileBubbleAsGridBubble:(id)object{
    //Expects object to be of type BubbleEngine
    //Will update BubbleEngine to store center and coordinates of grid
    object = (BubbleEngine *)object;
    [mobileBubblesToRemove addObject:object];
    NSIndexPath *path = [gridTemplateDelegate indexPathForItemAtPoint:[object center]];
    if(!path){
        path = [gridTemplateDelegate indexPathForItemAtPoint:[object getBacktrackedCenter]];
    }
    if(path){
        CGPoint gridCenter = [gridTemplateDelegate getCenterForItemAtIndexPath:path];
        [object setCenter:gridCenter];
        NSSet *matchingCluster = [self insertBubble:object intoGridAtIndexPath:path];
        [self removeBubblesIfNecessary:matchingCluster onInsertionOf:object];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Game Over"
                                                        message:@"Maximum bubble layers exceeded"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self reload];
    }
}

- (void)removeBubblesIfNecessary:(NSSet *)matchingCluster onInsertionOf:(id)object{
    [self handleMatchingCluster:matchingCluster];
    [self removeAllOrphanedBubbles];
    [self checkGridBubbles];
}

- (void)handleMatchingCluster:(NSSet *)matchingCluster{
    if([matchingCluster count] >= 3){
        [self removeAllInCollection:matchingCluster removeType:POP_ANIMATION additionalRemoveFilter:nil];
    }
}

- (NSArray *)removeAllNeighboursForBubble:(BubbleEngine *)bubbleEngine{
    NSArray *neighbourList = nil;
    if(bubbleEngine){
        neighbourList = [bubbleGameState getNeighboursForObjectAtRow:bubbleEngine.gridRow andPosition:bubbleEngine.gridCol];
        BOOL (^filterCond)(BubbleEngine *) = ^(BubbleEngine *bubble){
            if(bubble.bubbleType == INDESTRUCTIBLE){
                return NO;
            }else{
                return YES;
            }
        };
        [self removeAllInCollection:neighbourList removeType:POP_ANIMATION additionalRemoveFilter:filterCond];
    }
    return neighbourList;
}

- (void)removeAllBubbleOfType:(NSInteger)type{
    NSSet *bubblesOfType = [bubbleGameState getAllObjectsOfType:type];
    [self removeAllInCollection:bubblesOfType removeType:POP_ANIMATION additionalRemoveFilter:nil];
}

- (NSArray *)removeAllBubblesInRow:(NSInteger)row{
    NSArray *bubblesInRow = [bubbleGameState getObjectsAtRow:row];
    BOOL (^filterCond)(BubbleEngine *) = ^(BubbleEngine *bubble){
        if(bubble.bubbleType == INDESTRUCTIBLE){
            return NO;
        }else{
            return YES;
        }
    };
    [self removeAllInCollection:bubblesInRow removeType:POP_ANIMATION additionalRemoveFilter:filterCond];
    return bubblesInRow;
}

- (NSSet *)insertBubble:(BubbleEngine *)bubbleEngine intoGridAtIndexPath:(NSIndexPath *)path{
    NSInteger row = [gridTemplateDelegate getRowNumberFromIndexPath:path];
    NSInteger col = [gridTemplateDelegate getRowPositionFromIndexPath:path];
    
    [bubbleEngine setGridCol:col];
    [bubbleEngine setGridRow:row];
    return [bubbleGameState insertBubble:bubbleEngine intoGridAtRow:row andCol:col];
}

- (NSMutableSet *)getOrphanedBubblesNeighbouringCluster:(NSSet *)cluster{
    //Deprecated but used in old tests
    return [bubbleGameState getOrphanedBubblesNeighbouringCluster:cluster];
}

- (void)removeAllOrphanedBubbles{
    NSSet *allBubbles = [NSSet setWithArray:[bubbleGameState getAllObjects]];
    NSMutableSet *orphaned = [bubbleGameState getOrphanedBubblesIncludingCluster:allBubbles];
    for(NSMutableSet *set in orphaned){
        [self removeAllInCollection:set removeType:DROP_ANIMATION additionalRemoveFilter:nil];
    }
}

- (void)popBubblesInCollection:(id)bubbles withCondition:(BOOL(^)(BubbleEngine *))filter{
    NSInteger numRemoved = [self removeAllInCollection:bubbles removeType:POP_ANIMATION additionalRemoveFilter:filter];
    [bubbleGameState updateTotalScoresForPoppedBubbles:numRemoved];
}

- (void)dropBubblesInCollection:(id)bubbles withCondition:(BOOL(^)(BubbleEngine *))filter{
    NSInteger numRemoved = [self removeAllInCollection:bubbles removeType:DROP_ANIMATION additionalRemoveFilter:filter];
    [bubbleGameState updateTotalScoresForPoppedBubbles:numRemoved];
}

- (NSInteger)removeAllInCollection:(id)cluster removeType:(NSInteger)animationType additionalRemoveFilter:(BOOL(^)(BubbleEngine *))filter{
    /*!
     @param cluster: Collection of bubbles to remove. Parameter can be any iterable collection 1 dimentional data structure
     @param animationType: NSInteger corresponding to animation to apply when the bubble's view is removed.
     @param filter: Boolean block. Additional condition to apply to each bubble to which will determine if the bubble is actually removed
     @return number of bubbles actually removed
     */
    NSInteger totalRemoved = 0;
    for(BubbleEngine *engine in cluster){
        if(filter == nil || filter(engine)){
            if([engine removeBubbleWithAnimationType:animationType]){
                totalRemoved += 1;
            }
        }
    }
    return totalRemoved;
}

- (void)removeGridBubbleAtRow:(NSInteger)row andPositions:(NSInteger)col{
    [bubbleGameState removeGridBubbleAtRow:row andPositions:col];
}

- (BOOL)hasCollisionWithGridForCenter:(CGPoint)point{
    NSArray *allGridBubbles = [bubbleGameState getAllObjects];
    for(BubbleEngine *engine in allGridBubbles){
        if([engine hasOverlapWithOtherCenter:point]){
            return YES;
        }
    }
    return NO;
}

@end
