//
//  GameTests.m
//  GameTests
//
//  Created by Naomi Leow on 27/1/14.
//
//

#import <XCTest/XCTest.h>
#import "GameState.h"

#define INITIAL_BUBBLE_ID 0

@interface GameStateTest : XCTestCase

@end

@implementation GameStateTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddAndRetrieve{
    GameState *gameState = [[GameState alloc] init];
    XCTAssertTrue([gameState numberOfBubbles] == 0);
    BubbleModel *model = [[BubbleModel alloc] init];
    [model setBubbleID:1];
    XCTAssertNoThrow([gameState addBubble:model]);
    XCTAssertTrue([gameState numberOfBubbles] == 1);
    BubbleModel *retrieved = [gameState getBubble:1];
    XCTAssertNil([gameState getBubble:0]);
    XCTAssertEqualObjects(model, retrieved);
    
    //Add bubble with same ID, should not increase count
    model = [[BubbleModel alloc] init];
    [model setBubbleID:1];
    XCTAssertNoThrow([gameState addBubble:model]);
    XCTAssertTrue([gameState numberOfBubbles] == 1);

    
    model = [[BubbleModel alloc] init];
    [model setBubbleID:10];
    XCTAssertNoThrow([gameState addBubble:model]);
    XCTAssertTrue([gameState numberOfBubbles] == 2);
    XCTAssertNil([gameState getBubble:9]);
    retrieved = [gameState getBubble:10];
    XCTAssertEqualObjects(model, retrieved);
}

- (void)testRemove{
    GameState *gameState = [[GameState alloc] init];
    BubbleModel *model1 = [[BubbleModel alloc] init];
    [model1 setBubbleID:5];
    BubbleModel *model2 = [[BubbleModel alloc] init];
    [model2 setBubbleID:7];
    BubbleModel *model3 = [[BubbleModel alloc] init];
    [model3 setBubbleID:1];
    [gameState addBubble:model1];
    [gameState addBubble:model2];
    [gameState addBubble:model3];
    XCTAssertTrue([gameState numberOfBubbles] == 3);
    XCTAssertNotNil([gameState getBubble:1]);
    XCTAssertNoThrow([gameState removeBubbleWithID:1]);
    XCTAssertNil([gameState getBubble:1]);
    XCTAssertTrue([gameState numberOfBubbles] == 2);
     XCTAssertNoThrow([gameState removeBubbleWithID:10]);
    XCTAssertTrue([gameState numberOfBubbles] == 2);
    XCTAssertNoThrow([gameState removeBubble:model1]);
    XCTAssertTrue([gameState numberOfBubbles] == 1);
}

- (void)testReset{
    GameState *gameState = [[GameState alloc] init];
    BubbleModel *model = [[BubbleModel alloc] initWithType:3 andWidth:50 andID:INITIAL_BUBBLE_ID];
    BubbleModel *model1 = [[BubbleModel alloc] initWithType:3 andWidth:50 andID:INITIAL_BUBBLE_ID + 1];
    BubbleModel *mode2 = [[BubbleModel alloc] initWithType:2 andWidth:50 andID:INITIAL_BUBBLE_ID + 2];
    [gameState addBubble:model];
    [gameState addBubble:model1];
    [gameState addBubble:mode2];
    XCTAssertTrue([gameState nextBubbleID] == 3);
    XCTAssertTrue([gameState numberOfBubbles] == 3);
    XCTAssertNoThrow([gameState reset]);
    XCTAssertTrue([gameState nextBubbleID] == INITIAL_BUBBLE_ID);
    XCTAssertTrue([gameState numberOfBubbles] == 0);
}

@end
