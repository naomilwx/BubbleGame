//
//  ViewController.m
//  BubbleGame
//
//  Created by Naomi Leow on 21/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "MainViewController.h"
#import "GameEngineInitDelegate.h"
#import "GameCommon.h"

#define TO_GAME_SEGUE @"menuToGame"

@implementation MainViewController{
    UIPopoverController *levelSelectorPopover;
    NSDictionary *dataToGame;
    NSString *gameLevelText;
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
        [controller setGameLevel:gameLevelText];
    }
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - delegate methods for LevelSelectorDelegate

- (void)selectedLevel:(NSInteger)levelIndex{
    [levelSelectorPopover dismissPopoverAnimated:YES];
    @try{
        NSDictionary *bubbles = [dataManager loadDesignedLevel:levelIndex];
        dataToGame = bubbles;
        gameLevelText = [NSString stringWithFormat:@"%ld", levelIndex];
        [self performSegueWithIdentifier:TO_GAME_SEGUE sender:self];
    }@catch(NSException *e){
        [self showAlertWithTitle:@"Load Designer Level" andMessage:[e reason]];
    }
}

- (NSArray *)getAvailableLevels{
    return [dataManager getAvailableLevels];
}

- (void)selectedPreloadedLevel:(NSInteger)levelIndex{
    [levelSelectorPopover dismissPopoverAnimated:YES];
    @try{
        NSString *levelName = [[GameCommon preloadedLevelMappings] objectForKey:[NSNumber numberWithInteger:levelIndex]];
        NSDictionary *bubbles = [dataManager loadPreloadedLevel:levelName];
        dataToGame = bubbles;
        gameLevelText = levelName;
        [self performSegueWithIdentifier:TO_GAME_SEGUE sender:self];
    }@catch(NSException *e){
        [self showAlertWithTitle:@"Load Preloaded Level" andMessage:[e reason]];
    }
}

@end
