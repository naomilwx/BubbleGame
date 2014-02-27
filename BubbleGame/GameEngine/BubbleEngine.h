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
@property BOOL hasBeenChained; //Indicates if the bubble has been probed for chainable special effects

- (id)initWithBubbleView:(id<PositionUpdateProtocol>)view andID:(NSInteger)ID;

- (id)initAsGridBubbleWithCenter:(CGPoint)point view:(id<PositionUpdateProtocol>)view andID:(NSInteger)ID;

- (void)moveBubble;

- (BOOL)hasOverlapWithOtherCenter:(CGPoint)point;

- (BOOL)removeBubbleWithAnimationType:(NSInteger)type;
/*!
 @param type: NSInteger corresponding to bubble view removal animation type
 It is possible for a message to be sent to a BubbleEngine instance whose view has already been removed
 The returned boolean type indicates if the instance's view has been removed from the view as a result of the method call.
 */

- (CGPoint)getBacktrackedCenter;

@end
