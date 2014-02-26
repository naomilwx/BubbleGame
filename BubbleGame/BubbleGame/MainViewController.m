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

@implementation MainViewController{
    UIPopoverController *levelSelectorPopover;
}

@synthesize dataManager;
@synthesize levelSelector;
@synthesize menuButton;

- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadBackground];
    [self loadDataManager];
    [self loadLevelSelector];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (IBAction)menuButtonPressed:(UIButton *)sender {
    if([[sender.titleLabel text] isEqual:@"Play!"]){
        [levelSelectorPopover presentPopoverFromRect:menuButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    NSLog(@"sender %@", [[sender titleLabel] text]);
}

- (void)loadBackground{
    self.menuBackground.contentMode = UIViewContentModeScaleAspectFit;
    self.menuBackground.clipsToBounds = YES;
    self.menuBackground.userInteractionEnabled = YES;
    UIImage *background = [UIImage imageNamed:@"MenuBackground"];
    [self.menuBackground setImage:background];
}

- (void)loadDataManager{
    dataManager = [[GameDataManager alloc] init];
}

- (void)loadLevelSelector{
    levelSelector = [[MenuLevelSelector alloc] initWithStyle:UITableViewStylePlain andDelegate:self];
    levelSelectorPopover = [[UIPopoverController alloc] initWithContentViewController:levelSelector];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"menuToGame"]){
        id<GameEngineInitDelegate> controller = segue.destinationViewController;
        [controller setPreviousScreen:MAIN_MENU];
    }
}
#pragma mark - delegate methods for LevelSelectorDelegate

- (void)selectedLevel:(NSInteger)levelIndex{
    [levelSelectorPopover dismissPopoverAnimated:YES];
}

- (NSArray *)getAvailableLevels{
    NSLog(@"count %d",[[dataManager getAvailableLevels] count]);
    return [dataManager getAvailableLevels];
}

- (void)selectedPreloadedLevel:(NSInteger)levelIndex{
    [levelSelectorPopover dismissPopoverAnimated:YES];
}

@end
