//
//  BubbleControllerTest.m
//  ps03
//
//  Created by Naomi Leow on 5/2/14.
//
//

#import <XCTest/XCTest.h>
#import "BubbleController.h"
#import "GameBubbleBasicTester.h"
#import "GameCommon.h"

@interface BubbleControllerTest : XCTestCase

@end

//The purpose of this test is to ensure that the bubble controller updates the model and the view accordingly with for each operation. The focus is not on the correctness of the update, as the acutal updating is done the delegate, but that the model and the view indeed gets updated

@implementation BubbleControllerTest{
    GameBubbleBasicTester *gameBubble;
}

int numOfCells = (2*NUM_CELLS_IN_ROW-1) * (NUM_OF_ROWS/2) + (NUM_OF_ROWS%2)*NUM_CELLS_IN_ROW;

- (void)setUp{
    [super setUp];
    gameBubble = [[GameBubbleBasicTester alloc] init];

}

- (void)tearDown{
    [super tearDown];
}

- (void)testAddBubbleAtIndex{
    NSMutableSet *indexes = [[NSMutableSet alloc] init];
    while([indexes count] < 5){
        int ind = arc4random_uniform(numOfCells);
        [indexes addObject:[NSNumber numberWithInt:ind]];
    }
    int count = 0;
    for(NSNumber *num in indexes){
        NSIndexPath *path = [NSIndexPath indexPathForItem:[num integerValue] inSection:0];
        BubbleController *bubble =[[BubbleController alloc] initWithMasterController:gameBubble];
        int type = arc4random_uniform(NUM_OF_PALETTE_BUBBLE_TYPES);
        XCTAssertNoThrow([bubble addBubbleAtCollectionViewIndex:path withType:type]);
        XCTAssertTrue([gameBubble hasView:[bubble bubbleView]]);
        XCTAssertTrue([bubble bubbleModelID] == count);
        XCTAssertTrue([gameBubble getBubbleType:[bubble bubbleModelID]] == type); //BubbleModel is retrievable
        count += 1;
        
    }
    XCTAssertTrue([gameBubble numViewsInView] == 5);
}

- (void)testModifyBubble{
    BubbleController *bubble =[[BubbleController alloc] initWithMasterController:gameBubble];
    int type = arc4random_uniform(NUM_OF_PALETTE_BUBBLE_TYPES);
    NSIndexPath *path = [NSIndexPath indexPathForItem:arc4random_uniform(numOfCells) inSection:0];
    XCTAssertNoThrow([bubble addBubbleAtCollectionViewIndex:path withType:type]);
    XCTAssertTrue([gameBubble getBubbleType:[bubble bubbleModelID]] == type);
    XCTAssertTrue([gameBubble hasBubbleID:[bubble bubbleModelID]]);
    type = (type + 1) % NUM_OF_PALETTE_BUBBLE_TYPES;
    [bubble modifyBubbletoType:type];
    XCTAssertTrue([gameBubble getBubbleType:[bubble bubbleModelID]] == type);
}

- (void)testRemoveBubble{
    NSMutableSet *indexes = [[NSMutableSet alloc] init];
    NSMutableArray *bubbles = [[NSMutableArray alloc] init];
    
    while([indexes count] < 3){
        int ind = arc4random_uniform(numOfCells);
        [indexes addObject:[NSNumber numberWithInt:ind]];
    }
    for(NSNumber *num in indexes){
        NSIndexPath *path = [NSIndexPath indexPathForItem:[num integerValue] inSection:0];
        BubbleController *bubble =[[BubbleController alloc] initWithMasterController:gameBubble];
        [bubbles addObject:bubble];
        int type = arc4random_uniform(NUM_OF_PALETTE_BUBBLE_TYPES);
        XCTAssertNoThrow([bubble addBubbleAtCollectionViewIndex:path withType:type]);
    }

    BubbleController *bubbleToRem = [bubbles objectAtIndex:2];
    [bubbleToRem removeBubble];
    XCTAssertFalse([gameBubble hasBubbleID:[bubbleToRem bubbleModelID]]);
    bubbleToRem = [bubbles objectAtIndex:0];
    [bubbleToRem removeBubble];
    XCTAssertFalse([gameBubble hasBubbleID:[bubbleToRem bubbleModelID]]);
    XCTAssertNil([[bubbleToRem bubbleView] superview]);
    
    bubbleToRem = [bubbles objectAtIndex:1];
    [bubbleToRem removeBubble];
    XCTAssertFalse([gameBubble hasBubbleID:[bubbleToRem bubbleModelID]]);
    XCTAssertNil([[bubbleToRem bubbleView] superview]);
}

- (void)testAddBubbleFromModel{
    //Only test that view for the model is added
    BubbleModel *model1 = [[BubbleModel alloc] initWithType:0 andWidth:50 andCenter:CGPointMake(10, 10) andID:1];
    BubbleModel *model2 = [[BubbleModel alloc] initWithType:0 andWidth:50 andCenter:CGPointMake(10, 20) andID:2];
    //Initially there should be no bubbles in view
    XCTAssertTrue([gameBubble numViewsInView] == 0);
    BubbleController *bubbleToAdd = [[BubbleController alloc] initWithMasterController:gameBubble];
    [bubbleToAdd addBubbleFromModel:model1];
    XCTAssertTrue([gameBubble numViewsInView] == 1);
    bubbleToAdd = [[BubbleController alloc] initWithMasterController:gameBubble];
    [bubbleToAdd addBubbleFromModel:model2];
    XCTAssertTrue([gameBubble numViewsInView] == 2);
}

@end
