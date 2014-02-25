//
//  GameLoader.h
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import <Foundation/Foundation.h>

@interface GameLoader : NSObject

@property NSInteger currentLevel;
//game level. level is set when game is saved or a stored game is loaded.
@property BOOL hasUnsavedBubbles;

- (NSArray *)getAvailableLevels;

- (NSDictionary *)getAllBubbleModels;

- (NSDictionary *)loadLevel:(NSInteger)level;

- (NSDictionary *)loadPreviousLevel;
//Returns BubbleModel instances for level before the currently loaded level

- (NSInteger)saveLevel;

- (void)removeBubble:(NSInteger)ID;

- (void)modifyBubbleTypeTo:(NSInteger)type forBubble:(NSInteger)ID;

- (NSInteger)getBubbleType:(NSInteger)ID;

- (NSInteger)addBubbleWithType:(NSInteger)type andWidth:(CGFloat)bubbleWidth andCenter:(CGPoint)centerPos;

//- (NSInteger)addBubbleWithType:(NSInteger)type andWidth:(CGFloat)bubbleWidth;

- (void)loadNewLevel;

- (void)reset;
@end
