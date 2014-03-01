//
//  DesignerMenuController.m
//  BubbleGame
//
//  Created by Naomi Leow on 1/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "DesignerMenuController.h"
#import "GameCommon.h"
#define SAVE_SUCCESSFUL_MSG @"Game level saved successfully"
#define SAVE_UNSUCCESSFUL_MSG @"An error occurred while saving. Game level is not saved."
#define LEVEL_INDICATOR_TEXT @"Level: %@"

@implementation DesignerMenuController{
    UIImage *backgroundImage;
    SEL selectorToExecute;
    NSInteger selectedLevel;
}

- (id)initWithDataController:(ControllerDataManager *)controllerDataManager andView:(UIView *)view{
    if(self = [super init]){
        _controllerDataManager = controllerDataManager;
        _gameArea = view;
    }
    return self;
}

- (IBAction)buttonPressed:(id)sender {
    NSString *label = [[(UIButton *)sender titleLabel] text];
    if([label isEqualToString:GAME_START]){
        
    }else if([label isEqualToString:GAME_LOAD]){
        [self load];
    }else if([label isEqualToString:GAME_SAVE]){
        if([self.controllerDataManager currentLevel] != INVALID){
            selectorToExecute = @selector(save);
            [self showConfirmationWithTitle:@"Save Level" andMessage:@"Existing level data will be overwritten. Continue?"];
        }else{
            [self save];
        }
    }else{
        if([self.controllerDataManager hasUnsavedBubbles]){
            selectorToExecute = @selector(reset);
            [self showConfirmationWithTitle:@"Reset Level" andMessage:@"Your unsaved changes will be lost! Are you sure you want to reset the game level?"];
        }else{
            [self reset];
        }
    }
}
#pragma mark - functions to handle load/save/reset
- (void)updateCurrentLevelView{
    NSInteger currentLevel = [self.controllerDataManager currentLevel];
    if(currentLevel == INVALID){
        [self.levelIndicator setText:[NSString stringWithFormat:LEVEL_INDICATOR_TEXT, @"NEW"]];
    }else{
        [self.levelIndicator setText:[NSString stringWithFormat:LEVEL_INDICATOR_TEXT, [NSNumber numberWithInteger:currentLevel]]];
    }
}

- (void)loadPreviousGameLevel{
    @try{
        [self reset];
        [self.controllerDataManager loadPreviousLevel];
    }@catch(NSException *e){
        [self showAlertWithTitle:@"Load Level" andMessage:[e reason]];
    }
}

- (void)loadGameLevel:(NSInteger)level{
    @try{
        [self reset];
        [self.controllerDataManager loadLevel:level];
    }@catch(NSException *e){
        [self showAlertWithTitle:@"Load Level" andMessage:[e reason]];
    }
}


- (void)loadNewLevel{
    [self.controllerDataManager loadNewLevel];
}

- (void)load{
    //Shows level selector popover view. currently selection of level will load the level and wipe whatever is on screen, even if it is an unsaved level. Future work: add warning dialog if level has not been saved.
    [self.levelSelectorPopover presentPopoverFromRect:self.loadButton.frame inView:self.gameArea permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)save{
    //Saves data model for current level to file.
    @try{
        [self.controllerDataManager saveLevel];
        [self showAlertWithTitle:@"Save Level" andMessage:SAVE_SUCCESSFUL_MSG];
        [self updateCurrentLevelView];
        [self.levelSelector updateLevelOptions];
    }@catch(NSException *e){
        [self showAlertWithTitle:@"Save Level" andMessage:SAVE_UNSUCCESSFUL_MSG];
    }
}

- (void)reset{
    [self.controllerDataManager resetLevel];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showConfirmationWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Proceed",nil];
    [alert show];
}

#pragma mark - alert view delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex != 0 & selectorToExecute != nil){
        IMP implementation = [self methodForSelector:selectorToExecute];
        void (*func)() = (void *)implementation;
        func();
    }
}

#pragma mark - delegate methods for LevelSelectorDelegate

- (void)selectedLevel:(NSInteger)levelIndex{
    selectedLevel = levelIndex;
    [self.levelSelectorPopover dismissPopoverAnimated:YES];
    if([self.controllerDataManager hasUnsavedBubbles]){
        selectorToExecute = @selector(handleLevelSelection);
        [self showConfirmationWithTitle:@"Load Level" andMessage:@"Your current unsaved changes will be lost when level is loaded. Continue?"];
    }else{
        [self handleLevelSelection];
    }
}
- (void)handleLevelSelection{
    if(selectedLevel == INVALID){
        [self loadNewLevel];
    }else{
        [self loadGameLevel:selectedLevel];
    }
    [self updateCurrentLevelView];
}
- (NSArray *)getAvailableLevels{
    return [self.controllerDataManager getAvailableLevels];
}

@end
