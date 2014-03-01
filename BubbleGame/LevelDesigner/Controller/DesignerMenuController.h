//
//  DesignerMenuController.h
//  BubbleGame
//
//  Created by Naomi Leow on 1/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelSelector.h"
#import "ControllerDataManager.h"

#define GAME_START @"Start"
#define GAME_LOAD @"Load"
#define GAME_SAVE @"Save"
#define GAME_RESET @"Reset"

@interface DesignerMenuController : NSObject

@property (strong, nonatomic) IBOutlet UILabel *levelIndicator;
@property (strong, nonatomic) LevelSelector *levelSelector;
@property (strong, nonatomic) UIPopoverController *levelSelectorPopover;
@property (strong, nonatomic) IBOutlet UIButton *loadButton;
@property (strong) ControllerDataManager *controllerDataManager;
@property (strong) UIView *gameArea;

- (id)initWithDataController:(ControllerDataManager *)controllerDataManager andView:(UIView *)view;

- (void)save;
// REQUIRES: game in designer mode
// EFFECTS: game state (grid) is saved

- (void)load;
// MODIFIES: self (game bubbles in the grid)
// REQUIRES: game in designer mode
// EFFECTS: game level is loaded in the grid

- (void)reset;
// MODIFIES: self (game bubbles in the grid)
// REQUIRES: game in designer mode
// EFFECTS: current game bubbles in the grid are deleted

@end
