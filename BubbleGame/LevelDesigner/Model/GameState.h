//
//  GameState.h
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import <Foundation/Foundation.h>
#import "BubbleModel.h"

@interface GameState : NSObject <NSCoding>

@property NSInteger nextBubbleID;
@property (strong) NSMutableDictionary* bubbles; //can't make it readonly because it has to be modifiable to subclasses, but this should not be set directly by other classes

- (void)addBubble:(BubbleModel *)bubble;

- (void)removeBubble:(BubbleModel *)bubble;

- (void)removeBubbleWithID:(NSInteger)bubbleID;

- (NSInteger)numberOfBubbles;

- (NSDictionary*)getAllBubbles;

- (BubbleModel*)getBubble:(NSInteger)bubbleID;

- (void)reset;
//Removes all stored BubbleModel instances

@end
