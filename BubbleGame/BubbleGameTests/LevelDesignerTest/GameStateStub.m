//
//  GameStateStub.m
//  ps03
//
//  Created by Naomi Leow on 7/2/14.
//
//

#import "GameStateStub.h"

@implementation GameStateStub

@synthesize nextBubbleID;
@synthesize bubbles;

-(id)init{
    if(self = [super init]){
        bubbles = [[NSMutableDictionary alloc] init];
        BubbleModel *bubble1 = [[BubbleModel alloc] initWithType:3 andWidth:50 andCenter:CGPointMake(40.0, 20.4) andID:1];
        BubbleModel *bubble2 = [[BubbleModel alloc] initWithType:2 andWidth:50 andCenter:CGPointMake(60.0, 20.4) andID:2];
        BubbleModel *bubble3 = [[BubbleModel alloc] initWithType:1 andWidth:50 andCenter:CGPointMake(20.0, 20.4) andID:3];
        nextBubbleID = 4;
        [bubbles setObject:bubble1 forKey:@1];
        [bubbles setObject:bubble2 forKey:@2];
        [bubbles setObject:bubble3 forKey:@3];
    }
    return self;
}

- (void)encodeWithCoder: (NSCoder *)coder{
    [coder encodeInteger:nextBubbleID forKey:@"nextBubbleID"];
    [coder encodeObject:self.bubbles forKey:@"bubbles"];
}

- (id)initWithCoder: (NSCoder *)coder{
    if(self = [super init]){
        nextBubbleID = [coder decodeIntegerForKey:@"nextBubbleID"];
        self.bubbles = [coder decodeObjectForKey:@"bubbles"];
    }
    return self;
}

- (BOOL)isEqual:(GameState *)gameState{
    if([gameState numberOfBubbles] != [self numberOfBubbles]){
        return NO;
    }
    NSDictionary *gameStateBubbles = [gameState getAllBubbles];
    for(NSNumber *key in gameStateBubbles){
        BubbleModel *bubble = [gameStateBubbles objectForKey:key];
        BubbleModel *original = [bubbles objectForKey:key];
        if(original){
            CGFloat tol = 0.000001;
            if(![bubble bubbleType] == [original bubbleType]){
                return NO;
            }
            if(!fabsf([bubble width] - [original width])< tol){
                return NO;
            }
            if(!fabsf(bubble.center.x - original.center.x) < tol){
                return NO;
            }
            if(!fabsf(bubble.center.y - original.center.y) < tol){
                return NO;
            }
        }else{
            return NO;
        }
    }
    return YES;
}
@end
