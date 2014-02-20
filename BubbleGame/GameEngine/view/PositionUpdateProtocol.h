//
//  PositionUpdateProtocol.h
//  ps04
//
//  Created by Naomi Leow on 12/2/14.
//
//

#import <Foundation/Foundation.h>

#define NO_ANIMATION 0
#define POP_ANIMATION 1
#define DROP_ANIMATION 2
#define MAX_DROP_DISTANCE [UIScreen mainScreen].bounds.size.height

@protocol PositionUpdateProtocol <NSObject>

- (CGPoint)moveByOffset:(CGPoint)offset;

- (void)moveToPoint:(CGPoint)point;

- (CGFloat)getRadius;

- (void)activateForDeletionWithAnimationType:(NSInteger)animationType;

- (BOOL)isRendered;

@end
