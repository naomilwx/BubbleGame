//
//  BubbleModelStorageTest.m
//  ps03
//
//  Created by Naomi Leow on 6/2/14.
//
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "BubbleModel.h"

@interface BubbleModelStorageTest : XCTestCase

@end

//Check that encoding and decoding by of the bubble model objects work and no field is missed in the encoding/decoding process

@implementation BubbleModelStorageTest

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (BOOL)approxEqual:(CGFloat) f1 and:(CGFloat)f2{
    CGFloat tol = 0.0000001;
    CGFloat diff = f1 - f2;
    if(diff < 0){
        diff = -1 * diff;
    }
    return diff < tol;
}

- (void)checkSame:(BubbleModel *)initialBubble and:(BubbleModel *)decodedBubble{
    XCTAssertEqual([initialBubble width],[decodedBubble width]);
    XCTAssertTrue([self approxEqual:[initialBubble width] and:[decodedBubble width]]);
    XCTAssertEqual([initialBubble bubbleType], [decodedBubble bubbleType]);
    XCTAssertEqual([initialBubble bubbleID], [decodedBubble bubbleID]);
    XCTAssertEqual([initialBubble center], [decodedBubble center]);
}

- (void)encodeDecodeTest:(BubbleModel *)initialBubble{
    NSMutableData * data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [initialBubble encodeWithCoder:coder];
    [coder finishEncoding];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    BubbleModel *decodedBubble = [[BubbleModel alloc] initWithCoder:decoder];
    [self checkSame:initialBubble and:decodedBubble];
}

- (void)testEncodeDecode{
    BubbleModel *initialBubble = [[BubbleModel alloc] initWithType:3 andWidth:45.5 andCenter:CGPointMake(10.5, 99) andID:5];
    [self encodeDecodeTest:initialBubble];
    initialBubble = [[BubbleModel alloc] initWithType:0 andWidth:100 andCenter:CGPointMake(10.5, 30.5) andID:2];
    [self encodeDecodeTest:initialBubble];
    initialBubble = [[BubbleModel alloc] initWithType:2 andWidth:0.5 andCenter:CGPointMake(0, 30.5) andID:100];
    [self encodeDecodeTest:initialBubble];

}

@end
