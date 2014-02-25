//
//  ViewController.m
//  BubbleGame
//
//  Created by Naomi Leow on 21/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "MainViewController.h"
#import "GameEngineInitDelegate.h"
#import "GameLogic.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadBackground];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (IBAction)menuButtonPressed:(UIButton *)sender {
    NSLog(@"sender %@", [[sender titleLabel] text]);
}

- (void)loadBackground{
    self.menuBackground.contentMode = UIViewContentModeScaleAspectFit;
    self.menuBackground.clipsToBounds = YES;
    self.menuBackground.userInteractionEnabled = YES;
    UIImage *background = [UIImage imageNamed:@"MenuBackground"];
    [self.menuBackground setImage:background];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"menuToGame"]){
        id<GameEngineInitDelegate> controller = segue.destinationViewController;
        [controller setPreviousScreen:MAIN_MENU];
    }
}
#pragma mark - delegate methods for LevelSelectorDelegate

- (void)selectedLevel:(NSInteger)levelIndex{
    
}

- (NSArray *)getAvailableLevels{
    return nil;
}
@end
