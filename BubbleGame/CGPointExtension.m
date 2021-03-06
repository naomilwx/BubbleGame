//
//  CGPointExtension.m
//  BubbleGame
//
//  Created by Naomi Leow on 26/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "CGPointExtension.h"

CGPoint addVectors(CGPoint vector1, CGPoint vector2){
    CGFloat x = vector1.x + vector2.x;
    CGFloat y = vector1.y + vector2.y;
    return CGPointMake(x, y);
}

CGPoint yShift(CGPoint vector, CGFloat amount){
    return CGPointMake(vector.x, vector.y + amount);
}

CGPoint xShift(CGPoint vector, CGFloat amount){
    return CGPointMake(vector.x + amount, vector.y);
}

CGPoint scaleVector(CGPoint v, CGFloat scale){
    return CGPointMake(v.x * scale, v.y*scale);
}

CGFloat getMagnitude(CGPoint vector){
    return sqrt(pow(vector.x, 2) + pow(vector.y, 2));
}

CGPoint getUnitVector(CGPoint vector){
    CGFloat magnitude = getMagnitude(vector);
    if(magnitude == 0){
        return CGPointMake(0, 0);
    }else{
        return scaleVector(vector, (1 / magnitude));
    }
}

CGPoint getUnitPositionVector(CGPoint start, CGPoint end){
    CGFloat x = end.x - start.x;
    CGFloat y = end.y - start.y;
    CGPoint vector = CGPointMake(x, y);
    return getUnitVector(vector);
}

CGPoint uniformShift(CGPoint point, CGFloat amount){
    return CGPointMake(point.x + amount, point.y + amount);
}