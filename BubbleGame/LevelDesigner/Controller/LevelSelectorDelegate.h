//
//  LevelSelectorDelegate.h
//  ps03
//
//  Created by Naomi Leow on 6/2/14.
//
//

#import <Foundation/Foundation.h>

@protocol LevelSelectorDelegate <NSObject>

- (void)selectedLevel:(NSInteger)levelIndex;

- (NSArray *)getAvailableLevels;

@optional
- (void)selectedPreloadedLevel:(NSInteger)levelIndex;

@end
