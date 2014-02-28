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

- (id)initWithFrame:(CGRect)frame andWidth:(CGFloat)width andInterval:(CGFloat)interval;

- (NSArray *)getRayFromPoint:(CGPoint)point1 andPoint:(CGPoint)point2;

- (void)addRayFromPoint:(CGPoint)point1 andPoint:(CGPoint)point2 toView:(UIView *)view;

- (void)removePreviousRay;

@end
