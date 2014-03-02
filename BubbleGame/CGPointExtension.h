//
//  CGPointExtension.h
//  BubbleGame
//
//  Created by Naomi Leow on 26/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//
// Extension for the iOS implemention of CGPoint to allow easy manupulation of CGPoint objects as required for the purposes of this game

#import <Foundation/Foundation.h>

CGPoint addVectors(CGPoint vector1, CGPoint vector2);
CGPoint yShift(CGPoint vector, CGFloat amount);
CGPoint xShift(CGPoint vector, CGFloat amount);
CGPoint scaleVector(CGPoint v, CGFloat scale);
CGFloat getMagnitude(CGPoint vector);
CGPoint getUnitVector(CGPoint vector);
CGPoint getUnitPositionVector(CGPoint start, CGPoint end);
CGPoint uniformShift(CGPoint point, CGFloat amount);