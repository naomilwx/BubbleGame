//
//  GameState.m
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import "GameDesignerState.h"
#import "GameLogic.h"
#import "BubbleModel.h"
#define INITIAL_BUBBLE_ID 0

@implementation GameDesignerState

@synthesize nextBubbleID;
@synthesize bubbles;

- (void)encodeWithCoder: (NSCoder *)coder{
    [coder encodeInteger:nextBubbleID forKey:@"nextBubbleID"];
    [coder encodeObject:bubbles forKey:@"bubbles"];
}

- (id)initWithCoder: (NSCoder *)coder{
    if(self = [super init]){
        nextBubbleID = [coder decodeIntegerForKey:@"nextBubbleID"];
        bubbles = [coder decodeObjectForKey:@"bubbles"];
    }
    return self;
}


- (id)init{
    if(self = [super init]){
        bubbles = [[NSMutableDictionary alloc] init];
        nextBubbleID = INITIAL_BUBBLE_ID;
    }
    return self;
}

- (void)addBubble:(BubbleModel *)bubble{
    //Note this is not a time freeze of the bubble added, reference to bubble is stored, but the bubble can still be modified by other classes
    NSInteger bubbleID = bubble.bubbleID;
    [self.bubbles setObject:bubble forKey:[NSNumber numberWithInteger:bubbleID]];
    if(bubbleID == self.nextBubbleID){
        self.nextBubbleID += 1;
    }
}

- (void)removeBubble:(BubbleModel *)bubble{
    //only removes bubble from data structure, bubble will still exist if other objects have a reference to it
    NSInteger bubbleID = bubble.bubbleID;
    [self.bubbles removeObjectForKey:[NSNumber numberWithInteger:bubbleID]];
}

- (void)removeBubbleWithID:(NSInteger)bubbleID{
    [self.bubbles removeObjectForKey:[NSNumber numberWithInteger:bubbleID]];
}

- (NSInteger)numberOfBubbles{
    return [[self.bubbles allKeys] count];
}

- (NSDictionary*)getAllBubbles{
    NSDictionary *bubbleModels = [NSDictionary dictionaryWithDictionary:self.bubbles];
    if(bubbleModels){
        return bubbleModels;
    }else{
        NSException* exception = [NSException
                                  exceptionWithName:@"Load levels"
                                  reason:@"Bubble data empty!"
                                  userInfo:nil];
        @throw exception;
    }
}

- (BubbleModel*)getBubble:(NSInteger)bubbleID{
    return [self.bubbles objectForKey:[NSNumber numberWithInteger:bubbleID]];
}

- (void)reset{
    [self.bubbles removeAllObjects];
    self.nextBubbleID = INITIAL_BUBBLE_ID;
}

@end
