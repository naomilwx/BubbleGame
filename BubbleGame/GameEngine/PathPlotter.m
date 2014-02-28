//
//  PathPlotter.m
//  BubbleGame
//
//  Created by Naomi Leow on 27/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "PathPlotter.h"
#import "CGPointExtension.h"
#import "BubbleView.h"

@implementation PathPlotter{
    NSArray *previousPlot;
}

@synthesize referenceFrame;
@synthesize plotterInterval;
@synthesize plotterWidth;

- (id)initWithFrame:(CGRect)frame andWidth:(CGFloat)width andInterval:(CGFloat)interval{
    if(self = [super init]){
        referenceFrame = frame;
        plotterWidth = width;
        plotterInterval = interval;
        previousPlot = nil;
    }
    return self;
}

- (NSArray *)getRayFromPoint:(CGPoint)point1 withVector:(CGPoint)posVector{
    NSMutableArray *ray = [[NSMutableArray alloc] init];
    CGPoint vectorToAdd = scaleVector(posVector, self.plotterInterval);
    if(getMagnitude(vectorToAdd) != 0){
        CGPoint currentCenter = addVectors(point1, vectorToAdd);
        BubbleView *currentView = [BubbleView createWithCenter:currentCenter andWidth:self.plotterWidth andColor:[UIColor blackColor]];
        while(CGRectContainsRect(referenceFrame, currentView.frame)){
            [ray addObject:currentView];
            currentCenter = addVectors(currentCenter, vectorToAdd);
            currentView = [BubbleView createWithCenter:currentCenter andWidth:self.plotterWidth andColor:[UIColor blackColor]];
        }
    }
    return ray;
}

- (void)addRayFromPoint:(CGPoint)point1 withVector:(CGPoint)vector toView:(UIView *)view{
    [self removePreviousRay];
    NSArray *ray = [self getRayFromPoint:point1 withVector:vector];
    for(BubbleView *rayPoint in ray){
        [view addSubview:rayPoint];
    }
    previousPlot = ray;
}

- (void)removePreviousRay{
    if(previousPlot != nil){
        for(BubbleView *view in previousPlot){
            [view removeFromSuperview];
        }
        previousPlot = nil;
    }
}
@end
