//
//  ViewController.h
//  BubbleGame
//
//  Created by Naomi Leow on 21/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuLevelSelector.h"
#import "LevelSelectorDelegate.h"
#import "GameDataManager.h"

@interface MainViewController : UIViewController<LevelSelectorDelegate>
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIImageView *menuBackground;
@property (strong, nonatomic) MenuLevelSelector *levelSelector;
@property (strong, nonatomic) GameDataManager *dataManager;
@end
