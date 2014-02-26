//
//  CGPointExtension.h
//  BubbleGame
//
//  Created by Naomi Leow on 26/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

CGPoint addVectors(CGPoint vector1, CGPoint vector2);
CGPoint scaleVector(CGPoint v, CGFloat scale);
CGFloat getMagnitude(CGPoint vector);
CGPoint getUnitVector(CGPoint vector);
CGPoint getUnitPositionVector(CGPoint start, CGPoint end);