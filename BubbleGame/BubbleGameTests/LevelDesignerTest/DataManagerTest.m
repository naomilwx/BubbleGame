//
//  DataManagerTest.m
//  ps03
//
//  Created by Naomi Leow on 5/2/14.
//
//

#import <XCTest/XCTest.h>
#import "DataManager.h"
#import "GameStateStub.h"
#import "GameLogic.h"

@interface DataManagerTest : XCTestCase

@end
//NOTE: tests in this file must be done in order. The test here will affect the application's saved game levels because the saving by the DataManager instance is still done in the same directory
@implementation DataManagerTest

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

//Note: running the below method alone will cause the app to be unable to load level 1 because GameStateStub is not linked in the main game
- (void)testSaveAndLoad{
    GameDesignerState *stub = (GameDesignerState *)[[GameStateStub alloc] init];
    DataManager *dataManager = [[DataManager alloc] init];
    XCTAssertNoThrow([dataManager saveGame:stub asLevel:STARTING_LEVEL]);
    GameDesignerState *retrieved;
    XCTAssertNoThrow(retrieved = [dataManager loadLevel:STARTING_LEVEL]);
    XCTAssertNotNil(retrieved);
    XCTAssertTrue([stub isEqual:retrieved]);
}

- (void)testSaveAndLoadAgain{
    //Test that game can be overwritten
    GameStateStub *stub = [[GameStateStub alloc] init];
    GameDesignerState *replace = [[GameDesignerState alloc] init];
    XCTAssertFalse([stub isEqual:replace]);
    
    DataManager *dataManager = [[DataManager alloc] init];
    GameDesignerState *retrieved = [dataManager loadLevel:STARTING_LEVEL];
    XCTAssertTrue([stub isEqual:retrieved]);
    
    XCTAssertNoThrow([dataManager saveGame:replace asLevel:STARTING_LEVEL]);
    retrieved = [dataManager loadLevel:STARTING_LEVEL];
    XCTAssertTrue([retrieved numberOfBubbles] == 0);
    XCTAssertFalse([stub isEqual:retrieved]);
}

- (void)testLevels{
    //Test that the available levels are set correctly when game states are saved
    DataManager *dataManager = [[DataManager alloc] init];
    NSInteger currentNextLevel = [dataManager nextLevel];
    XCTAssertTrue([dataManager loadedLevel] == INVALID);
    GameDesignerState *gameState = [[GameDesignerState alloc] init];
    XCTAssertTrue([[dataManager getAvailableLevels] count] == currentNextLevel - 1);
    [dataManager saveGame:gameState];
    currentNextLevel += 1;
    XCTAssertTrue([[dataManager getAvailableLevels] count] == currentNextLevel - 1);
    XCTAssertTrue([dataManager nextLevel] == currentNextLevel);
    //The levels should be persistent, so a new instance of DataManager should have the same levels
    dataManager = [[DataManager alloc] init];
    XCTAssertTrue([[dataManager getAvailableLevels] count] == currentNextLevel - 1);
    XCTAssertTrue([dataManager nextLevel] == currentNextLevel);
    //The number of levels should remain the same in this case
    [dataManager saveGame:gameState asLevel:STARTING_LEVEL];
    XCTAssertTrue([[dataManager getAvailableLevels] count] == currentNextLevel - 1);
    XCTAssertTrue([dataManager nextLevel] == currentNextLevel);
}

@end
