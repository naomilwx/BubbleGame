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
#import "Constants.h"

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
        [self handleMatchingCluster:matchingCluster];
        [self checkGridBubbles];
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

- (void)handleMatchingCluster:(NSSet *)matchingCluster{
//Remove matchingCluster and its orphaned neighbours if size of matchingCluster is bigger than 3
    if([matchingCluster count] >= 3){
        [self removeAllInCollection:matchingCluster removeType:POP_ANIMATION];
        [self removeOrphanedBubblesNeighbouringCluster:matchingCluster];
    }
}

- (void)removeOrphanedBubblesNeighbouringCluster:(NSSet *)cluster{
    //Takes in cluster of removed nodes
    NSMutableSet *orphaned = [self getOrphanedBubblesNeighbouringCluster:cluster];
    for(NSMutableSet *set in orphaned){
        [self removeAllInCollection:set removeType:DROP_ANIMATION];
    }
}

- (NSMutableSet *)getOrphanedBubblesNeighbouringCluster:(NSSet *)cluster{
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

- (void)removeAllInCollection:(id)cluster removeType:(NSInteger)animationType{
    for(BubbleEngine *engine in cluster){
        [engine removeBubbleWithAnimationType:animationType];
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
