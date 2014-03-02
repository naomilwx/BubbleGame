//
//  BubbleLoader.h
//  BubbleGame
//
//  Created by Naomi Leow on 22/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BubbleView.h"
#import "Queue.h"
#import "TaggedObject.h"

//Maintains a queue of 3 bubbles
@interface BubbleLoader : NSObject

@property (strong) UIView *mainFrame;
@property CGFloat bubbleRadius;
@property (strong) NSDictionary *bubbleTypeMappings;
@property NSInteger maxBubblesToLoad;

- (id)initWithFrame:(CGRect)frame andTypeMapping:(NSDictionary *)mapping andBubbleRadius:(CGFloat)radius;

- (TaggedObject *)getNextBubble;

- (void)reset;

@end
