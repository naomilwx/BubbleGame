//
//  BubbleLoader.m
//  BubbleGame
//
//  Created by Naomi Leow on 22/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "BubbleLoader.h"
#import "GameLogic.h"

@implementation BubbleLoader{
    Queue *bubbleQueue;
    NSArray *bubbleTypes;
}

@synthesize mainFrame;
@synthesize bubbleRadius;
@synthesize bubbleTypeMappings;

- (id)initWithFrame:(CGRect)frame andTypeMapping:(NSDictionary *)mapping andBubbleRadius:(CGFloat)radius{
    if(self = [super init]){
        mainFrame = [[UIView alloc] initWithFrame:frame];
        bubbleTypeMappings = mapping;
        bubbleRadius = radius;
        bubbleTypes = [bubbleTypeMappings allKeys];
        [self loadBubbleQueue];
    }
    return self;
}

- (void)loadBubbleQueue{
    bubbleQueue = [Queue queue];
    for(NSInteger i = 0; i < BUBBLE_QUEUE_SIZE; i++){
        [self addNextBubbleView];
    }
}

- (TaggedObject *)getNextBubble{
    TaggedObject *taggedBubble = [bubbleQueue dequeue];
    BubbleView *bubble = [taggedBubble object];
    [self shiftBubblesForward];
    [self addNextBubbleView];
    [bubble removeFromSuperview];
    return taggedBubble;
}

- (void)shiftBubblesForward{
    for(TaggedObject *taggedBubble in [bubbleQueue getAllObjects]){
        BubbleView *bubble = [taggedBubble object];
        CGPoint center = bubble.center;
        CGPoint newCenter = CGPointMake(center.x - 2 * bubbleRadius, center.y);
        [bubble setCenter:newCenter];
    }
}

- (void)addNextBubbleView{
    TaggedObject *taggedBubbleView = [self createNextBubbleView];
    BubbleView *bubbleView = [taggedBubbleView object];
    [bubbleQueue enqueue:taggedBubbleView];
    [self.mainFrame addSubview:bubbleView];
}

- (TaggedObject *)createNextBubbleView{
    NSInteger nextType = [self getNextBubbleType];
    NSNumber *nextTypeNumber = [NSNumber numberWithInteger:nextType];
    CGFloat bubbleCenterX = [bubbleQueue count] * 2 * self.bubbleRadius + self.bubbleRadius;
    CGFloat bubbleCenterY = self.bubbleRadius;
    CGPoint bubbleCenter = CGPointMake(bubbleCenterX, bubbleCenterY);
    BubbleView *bubbleView = [BubbleView createWithCenter:bubbleCenter andWidth:(self.bubbleRadius * 2) andImage:[self.bubbleTypeMappings objectForKey:nextTypeNumber]];
    return [TaggedObject createWithTag:nextTypeNumber AndObject:bubbleView];
}

- (NSInteger)getNextBubbleType{
    //TODO
    NSInteger typeIndex = arc4random_uniform(NUM_OF_BUBBLE_COLORS);
    return [[bubbleTypes objectAtIndex:typeIndex] integerValue];
}

@end
