//
//  PathPlotter.h
//  BubbleGame
//
//  Created by Naomi Leow on 27/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathPlotter : NSObject

@property CGFloat plotterWidth;
@property CGFloat plotterInterval;
@property CGRect referenceFrame;
@property (nonatomic, copy) BOOL (^additionalStopCondition)(CGPoint);


- (id)initWithFrame:(CGRect)frame andWidth:(CGFloat)width andInterval:(CGFloat)interval;

- (NSArray *)getRayFromPoint:(CGPoint)point1 withVector:(CGPoint)posVector;

- (void)addRayFromPoint:(CGPoint)point1 withVector:(CGPoint)vector toView:(UIView *)view;

- (void)removePreviousRay;

@end
