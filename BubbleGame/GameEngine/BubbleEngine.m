//
//  BubbleEngine.m
//  ps04
//
//  Created by Naomi Leow on 12/2/14.
//
//

#import "BubbleEngine.h"
#define FLOATING_POINT_ALLOWANCE 0.00001

@implementation BubbleEngine{
    CGPoint previousCenter;
}

@synthesize bubbleEngineID;
@synthesize mainEngine;
@synthesize bubbleView;
@synthesize displacementVector;
@synthesize center;
@synthesize bubbleType;
@synthesize isGridBubble;
@synthesize gridCol;
@synthesize gridRow;

- (id)initWithBubbleView:(id<PositionUpdateProtocol>)view andID:(NSInteger)ID{
    if(self = [super init]){
        bubbleView = view;
        displacementVector = CGPointMake(0, 0);
        bubbleEngineID = ID;
        isGridBubble = NO;
    }
    return self;
}

- (id)initAsGridBubbleWithCenter:(CGPoint)point view:(id<PositionUpdateProtocol>)view andID:(NSInteger)ID{
    //For future integration with PS3
    if(self = [super init]){
        bubbleView = view;
        displacementVector = CGPointMake(0, 0);
        bubbleEngineID = ID;
        center = point;
        isGridBubble = YES;
    }
    return self;

}

- (void)moveBubble{
    if(![self stationaryBubble]){
        previousCenter = self.center;
        self.center = [bubbleView moveByOffset:displacementVector];
        if([self checkCollisionWithGrid] || [self checkFrameBoundsAndRebound]){
            [self addMobileBubbleToGrid];
        }
    }
}

- (void)addMobileBubbleToGrid{
    self.isGridBubble = YES;
    [mainEngine  setMobileBubbleAsGridBubble:self];
    [bubbleView moveToPoint:self.center];
}

- (CGPoint)getBacktrackedCenter{
    return previousCenter;
}

- (void)removeBubbleWithAnimationType:(NSInteger)type{
    [bubbleView activateForDeletionWithAnimationType:type];
    if(self.isGridBubble){
        [mainEngine removeGridBubbleAtRow:self.gridRow andPositions:self.gridCol];
    }
}

- (BOOL)checkCollisionWithGrid{
    if([mainEngine hasCollisionWithGridForCenter:self.center]){
        displacementVector = CGPointMake(0, 0);
        return YES;
    }else{
        return NO;
    }
}


- (BOOL)checkFrameBoundsAndRebound{
    //Returns true if stopped
    CGFloat collisionRadius = [bubbleView getRadius];
    if(self.center.y <= collisionRadius){
        //Top wall
        [self handleTopWallCollision];
        return YES;
    }
        
    if(self.center.x <= collisionRadius ||([mainEngine frameWidth] - self.center.x) <= collisionRadius){
        [self handleSideWallCollision];
    }
    if(([mainEngine frameHeight] - self.center.y) <= collisionRadius){
        //collision with bottom wall
        [self handleBottomCollision];
    }
    return NO;
}

- (void)handleTopWallCollision{
    displacementVector = CGPointMake(0, 0);
}

- (void)handleSideWallCollision{
    displacementVector.x = -1 * displacementVector.x;
}

- (void)handleBottomCollision{
    if(displacementVector.y > 0){
        displacementVector.y = -1 * displacementVector.y;
    }
}

- (BOOL)stationaryBubble{
    return abs(displacementVector.x) <= FLOATING_POINT_ALLOWANCE && abs(displacementVector.y)<= FLOATING_POINT_ALLOWANCE;
}

- (BOOL)hasOverlapWithOtherCenter:(CGPoint)point{
    CGFloat radius = [bubbleView getRadius];
    CGFloat distance = sqrt(pow((point.x - self.center.x),2) + pow((point.y - self.center.y),2));
    return distance < (2 * radius);
}


- (BOOL)isEqual:(id)object{
    if([object isKindOfClass:[BubbleEngine class]]){
        return [object bubbleEngineID] == [self bubbleEngineID];
    }else{
        return NO;
    }
}

- (NSUInteger) hash {
    return [[NSNumber numberWithInteger:self.bubbleEngineID] hash];
}

@end
