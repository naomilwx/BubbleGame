//
//  GameLoader.m
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import "GameLoader.h"
#import "GameState.h"
#import "BubbleModel.h"
#import "DataManager.h"
#import "Constants.h"
//TODO: warn user if level has not been saved
@implementation GameLoader{
    GameState *currentState;
    DataManager *dataManager;
}

@synthesize currentLevel;

- (id)init{
    if(self = [super init]){
        currentState = [[GameState alloc] init];
        dataManager = [[DataManager alloc] init];
        currentLevel = INVALID;
    }
    return self;
}

- (NSArray *)getAvailableLevels{
    return [dataManager getAvailableLevels];
}

- (NSDictionary *)getAllBubbleModels{
    return [currentState getAllBubbles];
}

- (NSDictionary *)loadLevel:(NSInteger)level{
    GameState *newLevelState = [dataManager loadLevel:level];
    if(newLevelState){
        currentLevel = level;
        currentState = newLevelState;
        return [currentState getAllBubbles];
    }else{
        NSException* exception = [NSException
                                  exceptionWithName:@"Load levels"
                                  reason:@"Level Data Empty!"
                                  userInfo:nil];
        @throw exception;
    }
}

- (NSDictionary *)loadPreviousLevel{
    NSInteger previousLevelNum = [dataManager getPreviousLevelNumber];
    return [self loadLevel:previousLevelNum];
}

- (NSInteger)saveLevel{
    if(currentLevel == INVALID){
        currentLevel = [dataManager saveGame:currentState];
    }else{
        [dataManager saveGame:currentState asLevel:currentLevel];
    }
    return currentLevel;
}

- (void)removeBubble:(NSInteger)ID{
    [currentState removeBubbleWithID:ID];
}

- (void)modifyBubbleTypeTo:(NSInteger)type forBubble:(NSInteger)ID{
    BubbleModel *bubble = [currentState getBubble:ID];
    [bubble setBubbleType:type]; 
}

- (NSInteger)getBubbleType:(NSInteger)ID{
    BubbleModel *bubbleModel = [currentState getBubble:ID];
    if(bubbleModel){
        return bubbleModel.bubbleType;
    }else{
        return INVALID;
    }
}

- (NSInteger)addBubbleWithType:(NSInteger)type andWidth:(CGFloat)bubbleWidth andCenter:(CGPoint)centerPos{
    //returns ID of bubble added
    NSInteger nextID = [currentState nextBubbleID];
    BubbleModel *bubble = [[BubbleModel alloc] initWithType:type andWidth:bubbleWidth andCenter:centerPos andID:nextID];
    [currentState addBubble:bubble];
    return nextID;
}

- (NSInteger)addBubbleWithType:(NSInteger)type andWidth:(CGFloat)bubbleWidth{
    //returns ID of bubble added
    NSInteger nextID = [currentState nextBubbleID];
    BubbleModel *bubble = [[BubbleModel alloc] initWithType:type andWidth:bubbleWidth andID:nextID];
    [currentState addBubble:bubble];
    return nextID;
}

- (void)reset{
    [currentState reset];
}

- (void)loadNewLevel{
    currentLevel = INVALID;
    [currentState reset];
    [dataManager resetForNewLevel];
}

@end
