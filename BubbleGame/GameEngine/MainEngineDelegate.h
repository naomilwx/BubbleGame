//
//  MainEngineDelegate.h
//  ps04
//
//  Created by Naomi Leow on 12/2/14.
//
//

#import <Foundation/Foundation.h>

@protocol MainEngineDelegate <NSObject>

- (CGFloat)frameHeight;

- (CGFloat)frameWidth;

- (void)setMobileBubbleAsGridBubble:(id)object;

- (BOOL)hasCollisionWithGridForCenter:(CGPoint)point;

- (void)removeGridBubbleAtRow:(NSInteger)row andPositions:(NSInteger)col;

@end
