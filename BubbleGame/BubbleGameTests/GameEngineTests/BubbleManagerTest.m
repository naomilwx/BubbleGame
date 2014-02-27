//
//  BubbleManagerTest.m
//  ps04
//
//  Created by Naomi Leow on 15/2/14.
//
//

#import <XCTest/XCTest.h>
#import "BubbleEngineManager.h"
#import "BubbleEngine.h"

@interface BubbleManagerTest : XCTestCase

@end

@implementation BubbleManagerTest{
    BubbleEngineManager *bubbleManager;
}

NSInteger number = 0;

- (void)setUp{
    [super setUp];
    XCTAssertNoThrow(bubbleManager = [[BubbleEngineManager alloc] init]);
}

- (void)tearDown{
    [super tearDown];
}

- (void)testInsertObject{
    [self insertType:0 atRow:0 andPos:2];
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 1);
    NSSet *cluster = [self insertType:1 atRow:1 andPos:2];
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 2);
    XCTAssertTrue([cluster count] == 1);
}

- (void)testClusterMerge{
    XCTAssertTrue([[self insertType:1 atRow:0 andPos:7] count] == 1);
    XCTAssertTrue([[self insertType:1 atRow:1 andPos:7] count] == 2);
    
    XCTAssertTrue([[self insertType:1 atRow:2 andPos:4] count] == 1);
    XCTAssertTrue([[self insertType:1 atRow:2 andPos:5] count] == 2);
    
    XCTAssertTrue([[self insertType:1 atRow:3 andPos:7] count] == 1);
     XCTAssertTrue([[self insertType:1 atRow:4 andPos:7] count] == 2);
    
     XCTAssertTrue([[self insertType:1 atRow:2 andPos:6] count] == 7);
}

- (void)testNeighbours{
    [self insertType:0 atRow:0 andPos:1];
    [self insertType:0 atRow:0 andPos:2];
    [self insertType:0 atRow:1 andPos:1];
    [self insertType:0 atRow:1 andPos:2];
    [self insertType:0 atRow:1 andPos:3];
    [self insertType:0 atRow:2 andPos:1];
    [self insertType:0 atRow:2 andPos:2];
    
    [self insertType:0 atRow:1 andPos:4];
    [self insertType:2 atRow:2 andPos:3];
    [self insertType:2 atRow:2 andPos:4];
    [self insertType:2 atRow:3 andPos:3];
    [self insertType:2 atRow:3 andPos:4];
    
    XCTAssertTrue([[bubbleManager getNeighboursForObjectAtRow:1 andPosition:2] count] ==6);
    
    XCTAssertTrue([[bubbleManager getNeighboursForObjectAtRow:2 andPosition:3] count] ==6);
    XCTAssertTrue([[bubbleManager getNeighboursForObjectAtRow:3 andPosition:2] count] ==3);
}

- (void)testClusterInsert{
    NSSet *cluster;
    [self insertType:0 atRow:0 andPos:3];
    cluster = [self insertType:0 atRow:0 andPos:4];
    XCTAssertTrue([cluster count] == 2);
    XCTAssertTrue([[self insertType:1 atRow:0 andPos:5] count] == 1);
    [self insertType:2 atRow:0 andPos:6];
    
    XCTAssertTrue([[self insertType:0 atRow:1 andPos:4] count] ==3);
    XCTAssertTrue([[self insertType:1 atRow:1 andPos:5] count] ==2);
    XCTAssertTrue([[self insertType:2 atRow:1 andPos:6] count] ==2);
    XCTAssertTrue([[self insertType:0 atRow:1 andPos:7] count] ==1); //disjoint type 0 bubble. Test that merging doesn't occur when bubbles are not neighbours
    
    XCTAssertTrue([[self insertType:0 atRow:2 andPos:4] count] ==4);
    XCTAssertTrue([[self insertType:1 atRow:2 andPos:5] count] ==3);
    
    XCTAssertTrue([[self insertType:1 atRow:3 andPos:5] count] ==4);
    XCTAssertTrue([[self insertType:2 atRow:3 andPos:6] count] ==1);
    
    XCTAssertTrue([[self insertType:2 atRow:4 andPos:5] count] ==2);
    
    //Joining 2 sets
     XCTAssertTrue([[self insertType:2 atRow:2 andPos:6] count] == 5);
    
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 14);
    NSDictionary *allClusters = [bubbleManager getAllClusters];
    XCTAssertTrue([[allClusters objectForKey:@0] count] == 2);//2 clusters of type 0
    XCTAssertTrue([[allClusters objectForKey:@1] count] == 1);
    XCTAssertTrue([[allClusters objectForKey:@2] count] == 1);
}

- (NSSet *)insertType:(NSInteger)type atRow:(NSInteger)row andPos:(NSInteger)pos{
    BubbleEngine *engine = [self createBubbleEngineWith:type row:row andPos:pos];
    NSSet *cluster;
    XCTAssertNoThrow(cluster = [bubbleManager insertObject:engine AtRow:row andPosition:pos]);
    XCTAssertEqualObjects(engine, [bubbleManager getObjectAtRow:row andPosition:pos]);
    XCTAssertTrue([cluster containsObject:engine]);
    return cluster;
}

- (void)testRemoveObject{
    XCTAssertNoThrow([self insertType:0 atRow:1 andPos:3]);
    XCTAssertNoThrow([self insertType:1 atRow:1 andPos:4]);
    XCTAssertNoThrow([self insertType:1 atRow:1 andPos:5]);
    XCTAssertNoThrow([self insertType:2 atRow:2 andPos:8]);
    XCTAssertNoThrow([self insertType:3 atRow:3 andPos:1]);
    
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 5);
    XCTAssertNoThrow([bubbleManager removeObjectAtRow:1 andPosition:4]);
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 4);
    XCTAssertNoThrow([bubbleManager removeObjectAtRow:2 andPosition:8]);
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 3);
    XCTAssertNoThrow([bubbleManager removeObjectAtRow:3 andPosition:1]);
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 2);
    XCTAssertNoThrow([bubbleManager removeObjectAtRow:1 andPosition:3]);
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 1);
    XCTAssertNoThrow([bubbleManager removeObjectAtRow:1 andPosition:5]);
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 0);
}

- (void)testClusterRemove{
    XCTAssertNoThrow([self insertType:1 atRow:0 andPos:6]);
    XCTAssertNoThrow([self insertType:1 atRow:0 andPos:7]);
    XCTAssertTrue([[self insertType:1 atRow:0 andPos:8] count] == 3);
    XCTAssertNoThrow([self insertType:1 atRow:1 andPos:7]);
    XCTAssertNoThrow([self insertType:1 atRow:2 andPos:6]);
    XCTAssertNoThrow([self insertType:1 atRow:2 andPos:7]);
    XCTAssertTrue([[self insertType:1 atRow:3 andPos:8] count] == 7);
    XCTAssertTrue([[self insertType:2 atRow:3 andPos:7] count] == 1);
    
    XCTAssertNoThrow([bubbleManager removeObjectAtRow:1 andPosition:7]);
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 7);
    
    [self checkClusterCount:2 clusterType:1];
   
    XCTAssertNoThrow([bubbleManager removeObjectAtRow:0 andPosition:6]);
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 6);
    [self checkClusterCount:2 clusterType:1];
    
    XCTAssertNoThrow([bubbleManager removeObjectAtRow:2 andPosition:7]);
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 5);
    [self checkClusterCount:3 clusterType:1];
}

- (void)checkClusterCount:(NSInteger)expected clusterType:(NSInteger)type{
    NSDictionary *clusters = [bubbleManager getAllClusters];
    NSArray *clusterList = [clusters objectForKey:[NSNumber numberWithInteger:type]];
    XCTAssertTrue([clusterList count] == expected);
    
}

- (void)testBasicDepthFirsSearch{
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 0);
    XCTAssertNoThrow([self insertType:0 atRow:2 andPos:7]);
    XCTAssertNoThrow([self insertType:1 atRow:3 andPos:6]);
    XCTAssertNoThrow([self insertType:2 atRow:3 andPos:7]);
    XCTAssertNoThrow([self insertType:3 atRow:4 andPos:5]);
    XCTAssertNoThrow([self insertType:3 atRow:4 andPos:7]);
    XCTAssertNoThrow([self insertType:0 atRow:5 andPos:6]);
    XCTAssertNoThrow([self insertType:0 atRow:5 andPos:7]);
    XCTAssertNoThrow([self insertType:0 atRow:6 andPos:5]);
    XCTAssertNoThrow([self insertType:0 atRow:6 andPos:7]);
    XCTAssertNoThrow([self insertType:0 atRow:7 andPos:6]);
    XCTAssertNoThrow([self insertType:0 atRow:7 andPos:7]);
    XCTAssertTrue([[bubbleManager getAllObjects] count] == 11);
    NSMutableSet *set = [[NSMutableSet alloc] init];
    NSMutableSet *visited = [[NSMutableSet alloc] init];
    BubbleEngine *start = [bubbleManager getObjectAtRow:5 andPosition:6];
    [bubbleManager depthFirstSearchAndCluster:set startPoint:start accumulationCondition:nil andSearchConditions:nil visitedItems:visited];
    XCTAssertTrue([set count] == 11);
    XCTAssertTrue([visited count] == 11);
}
- (BubbleEngine *)createBubbleEngineWith:(NSInteger)type row:(NSInteger)row andPos:(NSInteger)pos{
    BubbleEngine *engine = [[BubbleEngine alloc] init];
    [engine setBubbleType:type];
    [engine setBubbleEngineID:number];
    [engine setGridRow:row];
    [engine setGridCol:pos];
    number +=1;
    return engine;
}

@end
