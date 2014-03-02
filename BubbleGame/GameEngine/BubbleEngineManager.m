 #import "BubbleEngineManager.h"
#import "BubbleEngine.h"

@implementation BubbleEngineManager{
    NSMutableDictionary *gridItems; //mapping of bubble grid position to bubble ID in model and representation in view
    NSMutableDictionary *clusters; //techincally the consistency of the cluster records have to be maintained upon insert and delete, however this is not done for delete because currently bubbles are removed iff type clusters >= 3 are found at insertion or the bubble cluster has been orphaned. in other words, bubbles in any cluster are currenty being removed together. Nevertheless, methods to ensure the correctness of the clusters have been implemented to cater to the general case of any random bubble removal. However, this methods are invoked lazily ie when the representation of clusters is being retrieved.
}

- (id)init{
    if(self = [super init]){
        gridItems = [[NSMutableDictionary alloc] init];
        clusters = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSSet *)insertObject:(id)object AtRow:(NSInteger)row andPosition:(NSInteger)pos{
    //Modifies: representation of bubbles in grid - gridItems, representation of bubble type clusters - clusters
    //Effects: inserts object into corresponding row and column in gridItems, update record of bubble clusters
    //returns set with object
    NSMutableDictionary *bubbleRow = [gridItems objectForKey:[NSNumber numberWithInteger:row]];
    if(bubbleRow){
        [bubbleRow setObject:object forKey:[NSNumber numberWithInteger:pos]];
    }else{
        bubbleRow = [[NSMutableDictionary alloc] init];
        [bubbleRow setObject:object forKey:[NSNumber numberWithInteger:pos]];
        [gridItems setObject:bubbleRow forKey:[NSNumber numberWithInteger:row]];
    }
    return [self insertBubbleIntoClusterList:object];
}

- (NSSet *)insertBubbleIntoClusterList:(BubbleEngine *)object{
    //Private method. Updates record of bubble clusters. Returns cluster with object
    NSNumber *type = [NSNumber numberWithInteger:[object bubbleType]];
    NSMutableArray *clusterList = [clusters objectForKey:type];
    NSSet *clusterFound;
    NSMutableSet *cluster;
    if(clusterList == nil){
        clusterList = [[NSMutableArray alloc] init];
        cluster = [self addNewClusterWithObject:object toList:clusterList];
        [clusters setObject:clusterList forKey:type];
    }else{
        NSMutableArray *adjacentSets = [self getAdjacentSetsFor:object inClusterList:clusterList];
        if([adjacentSets count] > 0){
            [clusterList removeObjectsInArray:adjacentSets];
            cluster = [self mergeSetsInList:adjacentSets andAddObject:object];
            [clusterList addObject:cluster];
        }else{
            cluster = [self addNewClusterWithObject:object toList:clusterList];
        }
    }
    clusterFound = [self getPrunedClusterWithBubble:object fromCluster:cluster];
    return clusterFound;
}

- (NSSet *)getAllObjectsOfType:(NSInteger)type{
    NSArray *clusterList = [clusters objectForKey:[NSNumber numberWithInteger:type]];
    NSMutableSet *bubbles = [[NSMutableSet alloc] init];
    for(NSMutableSet *set in clusterList){
        for(BubbleEngine *bubbleEngine in set){
            [bubbles addObject:bubbleEngine];
        }
    }
    return bubbles;
}

- (NSSet *)getPrunedClusterWithBubble:(BubbleEngine *)object fromCluster:(NSSet *)cluster{
    NSMutableSet *visited = [[NSMutableSet alloc] init];
    NSMutableArray *bubbleClusters = [self getClustersForType:object.bubbleType inOriginalCluster:cluster withVisitedList:visited];
    NSSet *returnCluster = [[NSSet alloc] init];
    for(NSMutableSet *bubbleCluster in bubbleClusters){
        if([bubbleCluster containsObject:object]){
            returnCluster = [NSSet setWithSet:bubbleCluster];
            break;
        }
    }
    return returnCluster;
}

- (NSMutableArray *)getAdjacentSetsFor:(BubbleEngine *)object inClusterList:(NSMutableArray *)clusterList{
    NSMutableArray *adjacentSets = [[NSMutableArray alloc] init];
    NSArray *neighbourList = [self getNeighboursForObjectAtRow:object.gridRow andPosition:object.gridCol];
    for(NSMutableSet *set in clusterList){
        for(BubbleEngine *neighbour in neighbourList){
            if([set containsObject:neighbour]){
                [adjacentSets addObject:set];
                break;
            }
        }
    }
    return adjacentSets;
}

- (void)removeBubbleFromClusterList:(BubbleEngine *)object{
    //Private method. removes bubble from all cluster records
    NSNumber *type = [NSNumber numberWithInteger:[object bubbleType]];
    NSMutableArray *clusterList = [clusters objectForKey:type];
    NSMutableArray *emptyClusters = [[NSMutableArray alloc] init];
    if(clusterList){
        for(NSMutableSet *set in clusterList){
            [set removeObject:object];
            if([set count] == 0){
                [emptyClusters addObject:set];
            }
        }
    }
    [clusterList removeObjectsInArray:emptyClusters];
}

- (id)removeObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos{
    //Modifies: representation of bubbles in grid - gridItems, representation of bubble type clusters - clusters
    //Effect: removes bubble from the corresponding row and column in gridItems, remove bubble from all cluster records
    //Returns removedObject
    NSMutableDictionary *bubbleRow = [gridItems objectForKey:[NSNumber numberWithInteger:row]];
    BubbleEngine *removedObject = [bubbleRow objectForKey:[NSNumber numberWithInteger:pos]];
    if(removedObject){
        [bubbleRow removeObjectForKey:[NSNumber numberWithInteger:pos]];
        [self removeBubbleFromClusterList:removedObject];
    }
    return removedObject;
}

- (id)removeObjectAndPruneClusterAtRow:(NSInteger)row andPosition:(NSInteger)pos{
    BubbleEngine *removedObject = [self removeObjectAtRow:row andPosition:pos];
    if(removedObject){
        NSInteger type = [removedObject bubbleType];
        [self pruneClustersForType:type];
    }
    return removedObject;
}

- (void)pruneClustersForType:(NSInteger)type{
//private method to clean up disjointed clusters
//this is not called on every deletion because typically clusters of the same type get removed together anyway
    NSArray *clusterList = [clusters objectForKey:[NSNumber numberWithInteger:type]];
    NSMutableArray *newClusterList = [[NSMutableArray alloc] init];
    NSMutableSet *visited = [[NSMutableSet alloc] init];
    
    for(NSMutableSet *set in clusterList){
        NSMutableArray *clustersInSet = [self getClustersForType:type inOriginalCluster:set withVisitedList:visited];
        [newClusterList addObjectsFromArray:clustersInSet];
    }
    [clusters setObject:newClusterList forKey:[NSNumber numberWithInteger:type]];
}

- (NSMutableArray *)getClustersForType:(NSInteger)type inOriginalCluster:(NSSet *)set withVisitedList:(NSMutableSet *)visited{
    //Given a set, break it up into clusters of mutually reachable nodes
    //Returns NSMutableArray containing clusters
    NSMutableArray *newClusterList = [[NSMutableArray alloc] init];
    for(BubbleEngine *engine in set){
        if([visited containsObject:engine]){
            continue;
        }
        NSMutableSet *accumulatedCluster  = [[NSMutableSet alloc] init];
        
        BOOL (^filterCond)(BubbleEngine *) = ^(BubbleEngine *bubbleEngine){
            if(bubbleEngine.bubbleType == type){
                return YES;
            }else{
                return NO;
            }
        };
        BubbleEngine *start = engine;
        [self depthFirstSearchAndCluster:accumulatedCluster startPoint:start accumulationCondition:filterCond andSearchConditions:nil visitedItems:visited];
        [newClusterList addObject:accumulatedCluster];
    }
    return newClusterList;
}


- (BOOL)depthFirstSearchAndCluster:(NSMutableSet *)accumulatedCluster startPoint:(BubbleEngine *)bubble accumulationCondition:(BOOL(^)(BubbleEngine *))condBlock andSearchConditions:(BOOL(^)(BubbleEngine *))searchCond visitedItems:(NSMutableSet *)visited{
    //Recursivey finds all nodes reachable by the parameter bubble
    [visited addObject:bubble];
    [accumulatedCluster addObject:bubble];
    if(searchCond!= nil && searchCond(bubble)){
        return YES;
    }
    BOOL result = NO;
    for(BubbleEngine *engine in [self getNeighboursForObjectAtRow:bubble.gridRow andPosition:bubble.gridCol]){
        if(condBlock!= nil && !condBlock(engine)){
            continue;
        }
        if(![accumulatedCluster containsObject:engine]){            
            result = result ||[self depthFirstSearchAndCluster:accumulatedCluster startPoint:engine accumulationCondition:condBlock andSearchConditions:searchCond visitedItems:visited];;
        }
    }
    return result;
}
- (id)getObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos{
    //Returns object at given row and position in the grid
    id object =  [[gridItems objectForKey:[NSNumber numberWithInteger:row]] objectForKey:[NSNumber numberWithInteger:pos]];
    return object;
}
- (NSArray *)getObjectsAtRow:(NSInteger)row{
    NSDictionary *bubbleRow = [gridItems objectForKey:[NSNumber numberWithInteger:row]];
    return [bubbleRow allValues];
}

- (void)insertObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos intoArray:(NSMutableArray *)array{
    //Private method. Adds object at location in gridItems if it is not nil
    id object =  [[gridItems objectForKey:[NSNumber numberWithInteger:row]] objectForKey:[NSNumber numberWithInteger:pos]];
    if(object){
        [array addObject:object];
    }
}

- (NSArray *)getAllObjects{
    NSMutableArray *retArr = [[NSMutableArray alloc] init];
    for(NSNumber *rowNum in gridItems){
        NSMutableDictionary *row = [gridItems objectForKey:rowNum];
        for(NSNumber *colNum in row){
            id object = [row objectForKey:colNum];
            if(object){
                [retArr addObject:object];
            }
        }
    }
    return retArr;
}

- (void)clearAll{
    gridItems = [[NSMutableDictionary alloc] init];
    clusters = [[NSMutableDictionary alloc] init];
}

- (NSArray *)getNeighboursForObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos{
    //Returns array of neighbours of object at given row and pos
    NSMutableArray *returnArr = [self getTopAndBottomForObjectAtRow:row andPosition:pos];
    [self insertObjectAtRow:row andPosition:pos - 1 intoArray:returnArr];
    [self insertObjectAtRow:row andPosition:pos + 1 intoArray:returnArr];
    return returnArr;
}


- (NSMutableSet *)addNewClusterWithObject:(id)object toList:(NSMutableArray *)clusterList{
    //Private method. Creates new cluster with object (represented as a set) and adds it to given clusterList
    //Requires: object, clusterList not nil
    NSMutableSet *cluster = [[NSMutableSet alloc] init];
    [cluster addObject:object];
    [clusterList addObject:cluster];
    return cluster;
}

- (NSMutableSet *)mergeSetsInList:(NSArray *)sets andAddObject:(id)object{
    //Private method. Merges all sets in given array of sets into a single set and adds object to set
    //Requires: object not nil, size of sets > 0
    NSInteger size = [sets count];
    NSMutableSet *set = [sets objectAtIndex:0];
    for(NSInteger i = 1; i < size; i++){
        [set unionSet:[sets objectAtIndex:i]];
    }
    [set addObject:object];
    return set;
}

- (NSMutableArray *)getTopAndBottomForObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos{
    //Private method. Gets adjacent bubbles above and below the bubble at the given row and pos
    NSInteger leftPos;
    if(row %2 == 0){
        leftPos = pos;
    }else{
        leftPos = pos - 1;
    }
    NSMutableArray *returnArr = [[NSMutableArray alloc] init];
    [self insertObjectAtRow:row - 1 andPosition:leftPos intoArray:returnArr];
    [self insertObjectAtRow:row + 1 andPosition:leftPos intoArray:returnArr];
    [self insertObjectAtRow:row - 1 andPosition:leftPos + 1 intoArray:returnArr];
    [self insertObjectAtRow:row + 1 andPosition:leftPos + 1 intoArray:returnArr];
    return returnArr;
}

- (NSDictionary *)getAllClusters{
    NSMutableDictionary *returnClusters = [[NSMutableDictionary alloc] init];
    for(NSNumber *key in [clusters allKeys]){
        [self pruneClustersForType:[key integerValue]];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(NSMutableSet *set in [clusters objectForKey:key]){
            [arr addObject:[NSSet setWithSet:set]];
        }
        [returnClusters setObject:arr forKey:key];
    }
    return returnClusters;
}

@end
