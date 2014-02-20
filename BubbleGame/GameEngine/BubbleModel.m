//
//  BubbleModel.m
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import "BubbleModel.h"

@implementation BubbleModel

@synthesize center;
@synthesize width;
@synthesize bubbleType;
@synthesize bubbleID;

- (void)encodeWithCoder: (NSCoder *)coder{
    [coder encodeCGPoint:center forKey:@"center"];
    [coder encodeFloat:width forKey:@"width"];
    [coder encodeInteger:bubbleType forKey:@"bubbleType"];
    [coder encodeInteger:bubbleID forKey:@"bubbleID"];
}

- (id)initWithCoder: (NSCoder *)coder{
    if(self = [super init]){
        center = [coder decodeCGPointForKey:@"center"];
        width = [coder decodeFloatForKey:@"width"];
        bubbleType = [coder decodeIntegerForKey:@"bubbleType"];
        bubbleID = [coder decodeIntegerForKey:@"bubbleID"];
    }
    return self;
}

- (id)initWithType:(NSInteger)type andWidth:(CGFloat)bubbleWidth andID:(NSInteger)ID{
    if(self = [super init]){
        bubbleType = type;
        width = bubbleWidth;
        bubbleID = ID;
    }
    return self;
}

- (id)initWithType:(NSInteger)type andWidth:(CGFloat)bubbleWidth andCenter:(CGPoint)centerPos andID:(NSInteger)ID{
    if(self = [super init]){
        bubbleType = type;
        width = bubbleWidth;
        center = centerPos;
        bubbleID = ID;
    }
    return self;
}

- (CGFloat)getXPos{
    return center.x;
}

- (CGFloat)getYPos{
    return center.y;
}

- (BOOL)isEqual:(id)object{
    //Returns YES if the object is a BubbleModel instance and has the same ID
    if([object isKindOfClass:[BubbleModel class]]){
        return self.bubbleID == ((BubbleModel *)object).bubbleID;
    }else{
        return NO;
    }
}

- (NSUInteger) hash {
    return [[NSNumber numberWithInteger:self.bubbleID] hash];
}
@end
