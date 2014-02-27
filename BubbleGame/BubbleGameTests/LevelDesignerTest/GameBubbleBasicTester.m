//
//  GameBubbleBasicTester.m
//  ps03
//
//  Created by Naomi Leow on 5/2/14.
//
//

#import "GameBubbleBasicTester.h"
#import "GameLogic.h"

@interface GameBubbleBasicTester ()

@end

@implementation GameBubbleBasicTester{
    NSMutableArray *bubbleViews;
}

@synthesize gameLoader;
@synthesize bubbleControllerManager;

- (id)init{
    if(self = [super init]){
        bubbleViews = [[NSMutableArray alloc] init]; //For testing addToView. Removal of bubbles from view is not tracked
        
        gameLoader = [[GameLoader alloc] init];
        
        bubbleControllerManager = [[BubbleManager alloc] initWithNumofRows:NUM_OF_ROWS andColumns:NUM_CELLS_IN_ROW];

    }
    return self;
}


- (void)addToView:(UIView *)view{
    [bubbleViews addObject:view];
}



- (BOOL)hasView:(UIView *)view{
    return [bubbleViews containsObject:view];
}

- (NSInteger)numViewsInView{
    return [bubbleViews count];
}

- (NSInteger)getBubbleType:(NSInteger)bubbleID{
    return [gameLoader getBubbleType:(bubbleID)];
}

- (BOOL)hasBubbleID:(NSInteger)bubbleID{
    return [gameLoader getBubbleType:bubbleID] != INVALID;
}
@end
