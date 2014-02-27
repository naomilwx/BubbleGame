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
    NSMutableArray *bubblesToRemove;
    NSInteger nextEngineID;
}

@synthesize defaultSpeed;
@synthesize gridBubbles; //This will store all static bubble views
@synthesize frameHeight;
@synthesize frameWidth;
@synthesize gridTemplateDelegate;

- (void)checkGridBubbles{
    //Checks if stored GridBubbles tally with view, ie all of the BubbleEngine instances have their corresponding views rendered
    for(BubbleEngine *engine in [gridBubbles getAllObjects]){
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
        bubblesToRemove = [[NSMutableArray alloc] init];
        gridBubbles = [[BubbleEngineManager alloc] init];
        [self createDisplayLink];
    }
    return self;
}

- (void)reload{
    [self clearAllExistingBubbles];
    mobileBubbles = [[NSMutableArray alloc] init];
    bubblesToRemove = [[NSMutableArray alloc] init];
    gridBubbles = [[BubbleEngineManager alloc] init];
}

- (void)shutdownDisplayLink{
    [displayLink invalidate];
}

- (void)clearAllExistingBubbles{
    NSArray *bubbles = [gridBubbles getAllObjects];
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
    BubbleEngine *bubbleEngine = [[BubbleEngine alloc] initWithBubbleView:bubble andID:nextEngineID];
    [bubbleEngine setBubbleType:type];
    nextEngineID += 1;
    [bubbleEngine setMainEngine:self];
    [mobileBubbles addObject:bubbleEngine];
}

- (void)addGridEngine:(id)bubble withType:(NSInteger)type andCenter:(CGPoint)center{
    BubbleEngine *bubbleEngine = [[BubbleEngine alloc] initAsGridBubbleWithCenter:center view:bubble andID:nextEngineID];
    [bubbleEngine setBubbleType:type];
    nextEngineID += 1;
    [bubbleEngine setMainEngine:self];
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
    [mobileBubbles removeObjectsInArray:bubblesToRemove];
    [bubblesToRemove removeAllObjects];
}

- (NSSet *)insertBubble:(BubbleEngine *)bubbleEngine intoGridAtIndexPath:(NSIndexPath *)path{
    NSInteger row = [gridTemplateDelegate getRowNumberFromIndexPath:path];
    NSInteger col = [gridTemplateDelegate getRowPositionFromIndexPath:path];
    
    [bubbleEngine setGridCol:col];
    [bubbleEngine setGridRow:row];
    return [gridBubbles insertObject:bubbleEngine AtRow:row andPosition:col];
}

- (void)setMobileBubbleAsGridBubble:(id)object{
    //Expects object to be of type BubbleEngine
    //Will update BubbleEngine to store center and coordinates of grid
    object = (BubbleEngine *)object;
    [bubblesToRemove addObject:object];
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

- (NSArray *)removeAllNeighboursForBubble:(BubbleEngine *)bubbleEngine{
    NSArray *neighbourList = nil;
    if(bubbleEngine){
        neighbourList = [gridBubbles getNeighboursForObjectAtRow:bubbleEngine.gridRow andPosition:bubbleEngine.gridCol];
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
    NSSet *bubblesOfType = [gridBubbles getAllObjectsOfType:type];
    [self removeAllInCollection:bubblesOfType removeType:POP_ANIMATION additionalRemoveFilter:nil];
}

- (NSArray *)removeAllBubblesInRow:(NSInteger)row{
    NSArray *bubblesInRow = [gridBubbles getObjectsAtRow:row];
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

- (void)handleMatchingCluster:(NSSet *)matchingCluster{
    if([matchingCluster count] >= 3){
        [self removeAllInCollection:matchingCluster removeType:POP_ANIMATION additionalRemoveFilter:nil];
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

- (void)removeAllOrphanedBubbles{
    NSSet *allBubbles = [NSSet setWithArray:[gridBubbles getAllObjects]];
    NSMutableSet *orphaned = [self getOrphanedBubblesIncludingCluster:allBubbles];
    for(NSMutableSet *set in orphaned){
        [self removeAllInCollection:set removeType:DROP_ANIMATION additionalRemoveFilter:nil];
    }
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

- (void)removeAllInCollection:(id)cluster removeType:(NSInteger)animationType additionalRemoveFilter:(BOOL(^)(BubbleEngine *))filter{
    for(BubbleEngine *engine in cluster){
        if(filter == nil || filter(engine)){
            [engine removeBubbleWithAnimationType:animationType];
        }
    }
}

- (void)removeGridBubbleAtRow:(NSInteger)row andPositions:(NSInteger)col{
    [gridBubbles removeObjectAtRow:row andPosition:col];
}

- (BOOL)hasCollisionWithGridForCenter:(CGPoint)point{
    NSArray *allGridBubbles = [gridBubbles getAllObjects];
    for(BubbleEngine *engine in allGridBubbles){
        if([engine hasOverlapWithOtherCenter:point]){
            return YES;
        }
    }
    return NO;
}

@end
