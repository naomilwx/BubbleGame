//
//  BubbleEngine.h
//  ps04
//
//  Created by Naomi Leow on 12/2/14.
//
//

#import <Foundation/Foundation.h>
#import "view/PositionUpdateProtocol.h"
#import "MainEngineDelegate.h"

@interface BubbleEngine : NSObject

@property id<PositionUpdateProtocol> bubbleView;
@property CGPoint displacementVector;
@property CGPoint center;
@property (weak) id<MainEngineDelegate> mainEngine;
@property NSInteger bubbleEngineID;
@property NSInteger bubbleType;
@property BOOL isGridBubble;
@property NSInteger gridRow;
@property NSInteger gridCol;

- (id)initWithBubbleView:(id<PositionUpdateProtocol>)view andID:(NSInteger)ID;

- (id)initAsGridBubbleWithCenter:(CGPoint)point view:(id<PositionUpdateProtocol>)view andID:(NSInteger)ID;

- (void)moveBubble;

- (BOOL)hasOverlapWithOtherCenter:(CGPoint)point;

- (void)removeBubbleWithAnimationType:(NSInteger)type;

- (CGPoint)getBacktrackedCenter;

@end
