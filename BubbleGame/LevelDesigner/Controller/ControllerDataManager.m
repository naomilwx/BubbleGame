//
//  BubbleControllerManager.m
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "ControllerDataManager.h"
#import "BubbleController.h"
#import "GameLogic.h"

@implementation ControllerDataManager{
    SEL selectorToExecute;
    NSInteger selectedLevel;
}

@synthesize bubbleControllerManager;
@synthesize gameLoader;
@synthesize gridTemplate;
@synthesize gameArea;
@synthesize paletteImages;

- (id)initWithView:(UIView *)view andDataModel:(GameLevelLoader *)model andGridTemplate:template{
    if(self = [super init]){
        bubbleControllerManager = [[BubbleManager alloc] initWithNumofRows:NUM_OF_ROWS andColumns:NUM_CELLS_IN_ROW];
        gameArea = view;
        gameLoader = model;
        gridTemplate = template;
    }
    return self;
}
- (NSArray *)getAllObjects{
    return [self.bubbleControllerManager getAllObjects];
}

- (void)clearAll{
    [self.bubbleControllerManager clearAll];
}

- (void)addBubbleFromModel:(BubbleModel *)model atIndex:(NSIndexPath *)index{
    BubbleController *bubble = [[BubbleController alloc] initWithMasterController:self andGridTemplate:gridTemplate];
    [bubble addBubbleFromModel:model];
    [self insertBubbleController:bubble AtCollectionViewIndex:index];
}

#pragma mark - Delegate Methods for BubbleController
- (void)addToView:(UIView *)view{
    [self.gameArea addSubview:view];
}

- (NSInteger)addOrModifyBubbleModelWithType:(NSInteger)type andWidth:(CGFloat)width andCenter:(CGPoint)center{
    return [self.gameLoader addBubbleWithType:type andWidth:width andCenter:center];
}


- (void)modifyBubbleModelTypeTo:(NSInteger)type forBubble:(NSInteger)ID{
    [self.gameLoader modifyBubbleTypeTo:type forBubble:ID];
}

- (void)removeBubbleModel:(NSInteger)ID{
    [self.gameLoader removeBubble:ID];
}

- (void)modifyBubbleView:(BubbleView *)bubble toType:(NSInteger)type{
    UIImage *image = [self.paletteImages objectForKey:[NSNumber numberWithInteger:type]];
    [bubble loadImage:image];
}

- (BubbleView *)createBubbleViewWithCenter:(CGPoint)center andWidth:(CGFloat)width andType:(NSInteger)type{
    UIImage *image = [self.paletteImages objectForKey:[NSNumber numberWithInteger:type]];
    return [BubbleView createWithCenter:center andWidth:width andImage:image];
}

#pragma mark - operations on bubble in bubble grid for level creator

- (void)addOrModifyBubbleAtCollectionViewIndex:(NSIndexPath *)index withType:(NSInteger)type{
    if(![self modifyBubbleAtCollectionViewIndex:index ToType:type]){
        BubbleController *bubble = [[BubbleController alloc] initWithMasterController:self andGridTemplate:gridTemplate];
        [bubble addBubbleAtCollectionViewIndex:index withType:type];
        [self insertBubbleController:bubble AtCollectionViewIndex:index];
    }
}

- (void)removeBubbleAtCollectionViewIndex:(NSIndexPath *)index{
    BubbleController *bubble = [self getBubbleControllerAtCollectionViewIndex:index];
    if(![bubble isEqual:[NSNull null]]){
        [bubble removeBubble];
        [self removeBubbleControllerAtCollectionViewIndex:index];
    }
}

- (BOOL)modifyBubbleAtCollectionViewIndex:(NSIndexPath *)index ToType:(NSInteger)type{
    BubbleController *bubble = [self getBubbleControllerAtCollectionViewIndex:index];
    if(![bubble isEqual:[NSNull null]]){
        [bubble modifyBubbletoType:type];
        return YES;
    }else{
        return NO;
    }
}

- (NSInteger)getBubbleTypeForBubbleAtCollectionViewIndex:(NSIndexPath *)index{
    BubbleController *bubble = [self getBubbleControllerAtCollectionViewIndex:index];
    NSInteger bubbleType = INVALID;
    if(![bubble isEqual:[NSNull null]]){
        NSInteger bubbleID = [bubble bubbleModelID];
        bubbleType = [self.gameLoader getBubbleType:bubbleID];
    }
    return bubbleType;
}

#pragma mark - update datastructure which holds the individual bubble controllers
- (BubbleController *)getBubbleControllerAtCollectionViewIndex:(NSIndexPath *)index{
    NSInteger rowInGrid = [gridTemplate getRowNumberFromIndex:index.item];
    NSInteger rowPosInGrid = [gridTemplate getRowPositionFromIndex:index.item];
    return [self.bubbleControllerManager getObjectAtRow:rowInGrid andPosition:rowPosInGrid];
}

- (void)insertBubbleController:(BubbleController *)controller AtCollectionViewIndex:(NSIndexPath *)index{
    NSInteger rowInGrid = [gridTemplate getRowNumberFromIndex:index.item];
    NSInteger rowPosInGrid = [gridTemplate getRowPositionFromIndex:index.item];
    [self.bubbleControllerManager insertObject:controller AtRow:rowInGrid andPosition:rowPosInGrid];
}

- (void)removeBubbleControllerAtCollectionViewIndex:(NSIndexPath *)index{
    NSInteger rowInGrid = [gridTemplate getRowNumberFromIndex:index.item];
    NSInteger rowPosInGrid = [gridTemplate getRowPositionFromIndex:index.item];
    [self.bubbleControllerManager removeObjectAtRow:rowInGrid andPosition:rowPosInGrid];
}

- (void)removeAllBubbles{
    //Gets invokes removeBubble method of all controllers, which removes all bubble models and bubble views
    NSArray *allBubbles = [self.bubbleControllerManager getAllObjects];
    for(BubbleController *bubble in allBubbles){
        [bubble removeBubble];
    }
}
/*
#pragma mark - functions to handle load/save/reset
- (void)loadLevelFromTempIfTempFileExists{
    NSDictionary *models = [gameLoader loadUnsavedStateFromTempFile];
    if(models != nil){
        [self loadGameLevelWithModels:models];
    }
}

- (void)loadPreviousGameLevel{
    @try{
        [self reset];
        NSDictionary *models = [self.gameLoader loadPreviousLevel];
        [self loadGameLevelWithModels:models];
    }@catch(NSException *e){
        [self showAlertWithTitle:@"Load Level" andMessage:[e reason]];
    }
}

- (void)loadGameLevel:(NSInteger)level{
    @try{
        [self reset];
        NSDictionary *models = [self.gameLoader loadLevel:level];
        [self loadGameLevelWithModels:models];
    }@catch(NSException *e){
        [self updateCurrentLevelView];
        [self showAlertWithTitle:@"Load Level" andMessage:[e reason]];
    }
}

- (void)loadGameLevelWithModels:(NSDictionary *)models{
    [self.bubbleControllerManager clearAll];
    [self loadBubblesFromModels:models];
    [self updateCurrentLevelView];
}

- (NSInteger)getCurrentLevel{
    return [gameLoader currentLevel];
}

- (void)updateCurrentLevelView{
    NSInteger currentLevel = [self getCurrentLevel];
    if(currentLevel == INVALID){
        [self.levelIndicator setText:[NSString stringWithFormat:LEVEL_INDICATOR_TEXT, @"NEW"]];
    }else{
        [self.levelIndicator setText:[NSString stringWithFormat:LEVEL_INDICATOR_TEXT, [NSNumber numberWithInteger:currentLevel]]];
    }
}

- (void)loadBubblesFromModels:(NSDictionary *)bubbleModels{
    for(NSNumber *ID in bubbleModels){
        BubbleModel *model = [bubbleModels objectForKey:ID];
        NSIndexPath *gridIndex = [self.bubbleGrid indexPathForItemAtPoint:[model center]];
        BubbleController *bubble = [[BubbleController alloc] initWithMasterController:self andGridTemplate:gridTemplate];
        [bubble addBubbleFromModel:model];
        [self insertBubbleController:bubble AtCollectionViewIndex:gridIndex];
    }
}

- (void)resetControllerState{
    [self removeAllBubbles];
    [self.bubbleControllerManager clearAll];
}

- (void)loadNewLevel{
    [self resetControllerState];
    [self.gameLoader loadNewLevel];
    [self updateCurrentLevelView];
}

- (void)load{
    //Shows level selector popover view. currently selection of level will load the level and wipe whatever is on screen, even if it is an unsaved level. Future work: add warning dialog if level has not been saved.
    [levelSelectorPopover presentPopoverFromRect:loadButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)save{
    //Saves data model for current level to file.
    //Loads blank palette for next level
    @try{
        [self.gameLoader saveLevel];
        [self showAlertWithTitle:@"Save Level" andMessage:SAVE_SUCCESSFUL_MSG];
        [self updateCurrentLevelView];
        [levelSelector updateLevelOptions];
    }@catch(NSException *e){
        [self showAlertWithTitle:@"Save Level" andMessage:SAVE_UNSUCCESSFUL_MSG];
    }
}

- (void)reset{
    [self resetControllerState];
    [self.gameLoader reset];
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
*/
@end
