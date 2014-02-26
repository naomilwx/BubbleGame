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

#define TO_GAME_SEGUE @"menuToGame"

@implementation MainViewController{
    UIPopoverController *levelSelectorPopover;
    NSDictionary *dataToGame;
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
    if([segue.identifier isEqualToString:TO_GAME_SEGUE]){
        id<GameEngineInitDelegate> controller = segue.destinationViewController;
        [controller setPreviousScreen:MAIN_MENU];
        [controller setOriginalBubbleModels:dataToGame];
    }
}
#pragma mark - delegate methods for LevelSelectorDelegate

- (void)selectedLevel:(NSInteger)levelIndex{
    [levelSelectorPopover dismissPopoverAnimated:YES];
    NSDictionary *bubbles = [dataManager loadDesignedLevel:levelIndex];
    dataToGame = bubbles;
    [self performSegueWithIdentifier:TO_GAME_SEGUE sender:self];
}

- (NSArray *)getAvailableLevels{
    return [dataManager getAvailableLevels];
}

- (void)selectedPreloadedLevel:(NSInteger)levelIndex{
    [levelSelectorPopover dismissPopoverAnimated:YES];
    NSString *levelName = [[GameLogic preloadedLevelMappings] objectForKey:[NSNumber numberWithInteger:levelIndex]];
    NSDictionary *bubbles = [dataManager loadPreloadedLevel:levelName];
    dataToGame = bubbles;
    [self performSegueWithIdentifier:TO_GAME_SEGUE sender:self];
}

@end
