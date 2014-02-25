//
//  ViewController.h
//  BubbleGame
//
//  Created by Naomi Leow on 21/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LevelSelector.h"
#import "LevelSelectorDelegate.h"

@interface MainViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIImageView *menuBackground;
@property (strong, nonatomic) LevelSelector *levelSelector;

@end
