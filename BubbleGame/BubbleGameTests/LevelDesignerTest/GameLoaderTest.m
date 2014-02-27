//
//  GameLoaderTest.m
//  ps03
//
//  Created by Naomi Leow on 5/2/14.
//
//

#import <XCTest/XCTest.h>
#import "GameLevelLoader.h"
#import "DataManager.h"
#import "GameLogic.h"

@interface GameLoaderTest : XCTestCase

@end

@implementation GameLoaderTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testLoadLevel{
    //Only test that currentLevel is loaded properly, the rest is handled by GameState and DataManager
    GameLevelLoader *loader = [[GameLevelLoader alloc] init];
    NSInteger levels = [[loader getAvailableLevels] count];
    if(levels > 0){
        NSInteger n = 1 + arc4random_uniform(STARTING_LEVEL + levels - 1);
        [loader loadLevel:n];
        XCTAssertEqual([loader currentLevel], n);
    }
}

- (void)testAddBubble{
     GameLevelLoader *loader = [[GameLevelLoader alloc] init];
    //New level
    XCTAssertTrue([loader currentLevel] == INVALID);
    
    NSInteger id1 = [loader addBubbleWithType:1 andWidth:40.4];
    XCTAssertTrue([loader getBubbleType:id1] == 1);
    XCTAssertTrue([loader getBubbleType:id1 + 1] == INVALID);
    NSInteger id2 = [loader addBubbleWithType:2 andWidth:40.4];
    XCTAssertTrue([loader getBubbleType:id2] == 2);
    XCTAssertTrue(id2 == (id1 + 1));
    
    XCTAssertTrue([loader getBubbleType:id2 + 1] == INVALID);
    NSInteger id3 = [loader addBubbleWithType:1 andWidth:50 andCenter:CGPointMake(0.5, 10.4)];
    XCTAssertTrue([loader getBubbleType:id3] == 1);
    XCTAssertTrue(id3 == (id2 + 1));
}

- (void)testModifyBubbleType{
    GameLevelLoader *loader = [[GameLevelLoader alloc] init];
    NSInteger id1 = [loader addBubbleWithType:2 andWidth:40.4];
    NSInteger id2 = [loader addBubbleWithType:3 andWidth:40.4];
    NSInteger id3 = [loader addBubbleWithType:1 andWidth:40.4];
    XCTAssertTrue([loader getBubbleType:id2] == 3);
    XCTAssertNoThrow([loader modifyBubbleTypeTo:1 forBubble:id2]);
    XCTAssertTrue([loader getBubbleType:id2] == 1);
    XCTAssertTrue([loader getBubbleType:id1] == 2);
    XCTAssertTrue([loader getBubbleType:id3] == 1);
    
    XCTAssertNoThrow([loader modifyBubbleTypeTo:3 forBubble:id3]);
    XCTAssertTrue([loader getBubbleType:id3] == 3);
    XCTAssertTrue([loader getBubbleType:id2] == 1);
    XCTAssertTrue([loader getBubbleType:id1] == 2);
}

// Not testing removeBubble as it only relays message to GameState
@end
