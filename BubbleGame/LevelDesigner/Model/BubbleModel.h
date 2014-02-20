//
//  BubbleModel.h
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import <Foundation/Foundation.h>

@interface BubbleModel : NSObject <NSCoding>

@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat width;
@property (nonatomic) NSInteger bubbleType;
@property (nonatomic) NSInteger bubbleID;

- (id)initWithType:(NSInteger)type andWidth:(CGFloat)bubbleWidth andID:(NSInteger)ID;

- (id)initWithType:(NSInteger)type andWidth:(CGFloat)bubbleWidth andCenter:(CGPoint)centerPos andID:(NSInteger)ID;

- (CGFloat)getXPos;

- (CGFloat)getYPos;

- (BOOL)isEqual:(id)object;
//Returns YES if the object is a BubbleModel instance and has the same ID

@end
