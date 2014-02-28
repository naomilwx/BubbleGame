//
//  GameLoader.m
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import "GameLevelLoader.h"
#import "GameDesignerState.h"
#import "BubbleModel.h"
#import "DataManager.h"
#import "GameLogic.h"
//TODO: warn user if level has not been saved
@implementation GameLevelLoader{
    GameDesignerState *currentState;
    DataManager *dataManager;
}

@synthesize currentLevel;
@synthesize hasUnsavedBubbles;

- (id)init{
    if(self = [super init]){
        currentState = [[GameDesignerState alloc] init];
        dataManager = [[DataManager alloc] init];
        currentLevel = INVALID;
        hasUnsavedBubbles = NO;
    }
    return self;
}

- (void)saveUnsavedStateToTempFile{
    if(hasUnsavedBubbles){
        [dataManager saveGameStateToTempFile:currentState];
    }
}

- (NSDictionary *)loadUnsavedStateFromTempFile{
    GameDesignerState *state = [dataManager loadGameStateFromTempFile];
    if(state != nil){
        currentLevel = [dataManager loadedLevel];
        currentState = state;
        hasUnsavedBubbles = YES;
        return [state getAllBubbles];
    }else{
        [dataManager resetForNewLevel];
        return nil;
    }
}

- (NSArray *)getAvailableLevels{
    return [dataManager getAvailableLevels];
}

- (NSDictionary *)getAllBubbleModels{
    return [currentState getAllBubbles];
}

- (NSDictionary *)loadLevel:(NSInteger)level{
    GameDesignerState *newLevelState = [dataManager loadLevel:level];
    if(newLevelState){
        currentLevel = level;
        currentState = newLevelState;
        hasUnsavedBubbles = NO;
        return [currentState getAllBubbles];
    }else{
        [self resetLevel];
        currentLevel = level;
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
    hasUnsavedBubbles = NO;
    return currentLevel;
}

- (void)removeBubble:(NSInteger)ID{
    hasUnsavedBubbles = YES;
    [currentState removeBubbleWithID:ID];
}

- (void)modifyBubbleTypeTo:(NSInteger)type forBubble:(NSInteger)ID{
    hasUnsavedBubbles = YES;
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
    hasUnsavedBubbles = YES;
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

- (void)resetLevel{
    [currentState reset];
    hasUnsavedBubbles = NO;
}

- (void)loadNewLevel{
    currentLevel = INVALID;
    [currentState reset];
    [dataManager resetForNewLevel];
    hasUnsavedBubbles = NO;
}

@end
