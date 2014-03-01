//
//  DesignerViewController+Menu.h
//  BubbleGame
//
//  Created by Naomi Leow on 1/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "DesignerViewController.h"

@interface DesignerViewController (Menu)

//
//@property (strong, nonatomic) IBOutlet UILabel *levelIndicator;
//@property (strong, nonatomic) LevelSelector *levelSelector;
//@property (strong, nonatomic) UIPopoverController *levelSelectorPopover;
//@property (strong, nonatomic) IBOutlet UIButton *loadButton;

@property (nonatomic) SEL selectorToExecute;
@property (nonatomic) NSInteger selectedLevel;

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
