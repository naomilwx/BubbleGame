//
//  MainEngineTest.m
//  ps04
//
//  Created by Naomi Leow on 16/2/14.
//
//

#import <XCTest/XCTest.h>
#import "GameState.h"
#import "BubbleEngine.h"
#import "BubbleGridLayout.h"
#import "ViewController.h"

#define BUBBLEWIDTH [controller defaultBubbleRadius] * 2

@interface EngineGameStateTest : XCTestCase

@end

@implementation EngineGameStateTest{
    GameState *mainEngineState;
    BubbleEngineManager *bubbleManager;
}
//The purpose of this is to test the implementation of the detection of orphaned bubbles in MainEngine. The rest of the functionalities involve correctly invoking the rest of the modules which will be manually integration tested
NSInteger num = 0;

- (void)setUp{
    [super setUp];
    mainEngineState = [[GameState alloc] init];
    bubbleManager = [[BubbleEngineManager alloc] init];
    [mainEngineState setGridBubbles:bubbleManager];
}

- (void)tearDown{
    [super tearDown];
}


- (void)testSingleOrphaned{
    BubbleEngine *r1 = [self createBubbleEngineWith:1 row:0 andPos:4];
    BubbleEngine *r2 = [self createBubbleEngineWith:1 row:1 andPos:4];
    BubbleEngine *r3 = [self createBubbleEngineWith:1 row:2 andPos:4];
    NSSet *removed = [NSSet setWithObjects:r1, r2, r3, nil];
    
    NSSet *orphaned = [self singleOrphanedTestAtRow:1 andPos:5 withRemoved:removed];
    XCTAssertTrue([orphaned count] == 1);
    
    orphaned = [self singleOrphanedTestAtRow:2 andPos:5 withRemoved:removed];
    XCTAssertTrue([orphaned count] == 1);

    orphaned = [self singleOrphanedTestAtRow:0 andPos:5 withRemoved:removed];
    XCTAssertTrue([orphaned count] == 0);
    
    orphaned = [self singleOrphanedTestAtRow:1 andPos:7 withRemoved:removed];
    XCTAssertTrue([orphaned count] == 0);
}


- (void)testSurroundingOrphaned{
    BubbleEngine *r1 = [self createBubbleEngineWith:1 row:0 andPos:4];
    BubbleEngine *r2 = [self createBubbleEngineWith:1 row:1 andPos:4];
    BubbleEngine *r3 = [self createBubbleEngineWith:1 row:2 andPos:4];
    NSSet *removed = [NSSet setWithObjects:r1, r2, r3, nil];
    
    [self createAndInsertBubbleAtRow:1 andPos:5];
    [self createAndInsertBubbleAtRow:2 andPos:5];
    [self createAndInsertBubbleAtRow:3 andPos:5];
    [self createAndInsertBubbleAtRow:3 andPos:4];
    [self createAndInsertBubbleAtRow:3 andPos:3];
    [self createAndInsertBubbleAtRow:2 andPos:3];
    [self createAndInsertBubbleAtRow:1 andPos:3];
    NSSet *orphaned = [mainEngineState getOrphanedBubblesNeighbouringCluster:removed];
    XCTAssertNotNil(orphaned);
    XCTAssertTrue([orphaned count] == 1);
    XCTAssertTrue([[[orphaned allObjects] objectAtIndex:0] count] == 7);
}

- (void)testDisjointOrphaned{
    BubbleEngine *r1 = [self createBubbleEngineWith:1 row:0 andPos:4];
    BubbleEngine *r2 = [self createBubbleEngineWith:1 row:1 andPos:4];
    BubbleEngine *r3 = [self createBubbleEngineWith:1 row:2 andPos:4];
    NSSet *removed = [NSSet setWithObjects:r1, r2, r3, nil];
    
    [self createAndInsertBubbleAtRow:1 andPos:5];
    [self createAndInsertBubbleAtRow:2 andPos:5];
    [self createAndInsertBubbleAtRow:3 andPos:5];
    [self createAndInsertBubbleAtRow:3 andPos:3];
    [self createAndInsertBubbleAtRow:2 andPos:3];
    [self createAndInsertBubbleAtRow:1 andPos:3];
    NSSet *orphaned = [mainEngineState getOrphanedBubblesNeighbouringCluster:removed];
    XCTAssertNotNil(orphaned);
    XCTAssertTrue([orphaned count] == 2);
    NSArray *allOrphaned = [orphaned allObjects];
    XCTAssertTrue([[allOrphaned objectAtIndex:0] count] == 3);
    XCTAssertTrue([[allOrphaned objectAtIndex:1] count] == 3);
}

- (void)testNotOrphaned{
    BubbleEngine *r1 = [self createBubbleEngineWith:1 row:0 andPos:5];
    BubbleEngine *r2 = [self createBubbleEngineWith:1 row:1 andPos:5];
    BubbleEngine *r3 = [self createBubbleEngineWith:1 row:2 andPos:5];
    NSSet *removed = [NSSet setWithObjects:r1, r2, r3, nil];
    
    [self createAndInsertBubbleAtRow:1 andPos:6];
    [self createAndInsertBubbleAtRow:1 andPos:7];
    [self createAndInsertBubbleAtRow:0 andPos:7];
    [self createAndInsertBubbleAtRow:2 andPos:6];
    [self createAndInsertBubbleAtRow:2 andPos:7];
    NSSet *orphaned = [mainEngineState getOrphanedBubblesNeighbouringCluster:removed];
    XCTAssertNotNil(orphaned);
    XCTAssertTrue([orphaned count] == 0);
}

- (void)createAndInsertBubbleAtRow:(NSInteger)row andPos:(NSInteger)pos{
    BubbleEngine *bubble = [self createBubbleEngineWith:2 row:row andPos:pos];
    [bubbleManager insertObject:bubble AtRow:row andPosition:pos];
}
- (NSSet *)singleOrphanedTestAtRow:(NSInteger)row andPos:(NSInteger)pos withRemoved:(NSSet *)removed{
    [bubbleManager clearAll];
    [self createAndInsertBubbleAtRow:row andPos:pos];
    NSSet *orphaned = [mainEngineState getOrphanedBubblesNeighbouringCluster:removed];
    XCTAssertNotNil(orphaned);
    return orphaned;
}
- (BubbleEngine *)createBubbleEngineWith:(NSInteger)type row:(NSInteger)row andPos:(NSInteger)pos{
    BubbleEngine *engine = [[BubbleEngine alloc] init];
    [engine setBubbleType:type];
    [engine setBubbleEngineID:num];
    [engine setGridRow:row];
    [engine setGridCol:pos];
    num += 1;
    return engine;
}
@end
