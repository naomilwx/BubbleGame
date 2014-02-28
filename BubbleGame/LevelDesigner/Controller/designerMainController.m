//
//  ViewController.m
//  Game
//
//  Created by Naomi Leow on 27/1/14.
//
//

#import "designerMainController.h"
#import <UIKit/UIKit.h>
#import "BubbleGridLayout.h"
#import "BubbleCell.h"
#import "GameLogic.h"
#import "GameEngineInitDelegate.h"

#define SAVE_SUCCESSFUL_MSG @"Game level saved successfully"
#define SAVE_UNSUCCESSFUL_MSG @"An error occurred while saving. Game level is not saved."
#define LEVEL_INDICATOR_TEXT @"Level: %@"
#define DESIGNER_TO_MENU @"designerToMenu"

@interface designerMainController()

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

@implementation designerMainController {
    UIImage *backgroundImage;
    SEL selectorToExecute;
    NSInteger selectedLevel;
}

@synthesize gameArea;
@synthesize palette;
@synthesize background;
@synthesize bubbleGrid;
@synthesize paletteImages;
@synthesize paletteButtons;
@synthesize controllerDataManager;
@synthesize loadButton;
@synthesize levelIndicator;
@synthesize levelSelector;
@synthesize levelSelectorPopover;
@synthesize backButton;

//override to disable auto rotation
- (BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initRequiredUIImages];
    [self loadBackground];
    [self loadPalette];
    [self initialiseCollectionView];
    [self addGestureRecognisersToCollectionView];
    [self.gameArea insertSubview:bubbleGrid belowSubview:backButton];
    [self initialiseBubbleControllerManager];
    [self initialiseLevelSelectorPopover];
    [self.controllerDataManager loadLevelFromTempIfTempFileExists];
    [self updateCurrentLevelView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialiseBubbleControllerManager{
    @try{
        controllerDataManager = [[ControllerDataManager alloc] initWithView:self.gameArea  andBubbleGrid:bubbleGrid andImageMappings:self.paletteImages];
    }@catch(NSException *e){
        [self showAlertWithTitle:@"Set up" andMessage:@"Failed to load game, your game data may be corrupted"];
    }
}

- (void)initialiseCollectionView{
    NSInteger frameWidth = self.gameArea.frame.size.width;
    NSInteger frameHeight = self.gameArea.frame.size.height - self.palette.frame.size.height;
    CGRect collectionFrame = CGRectMake(0, 0, frameWidth, frameHeight);
    bubbleGrid = [[UICollectionView alloc] initWithFrame:collectionFrame collectionViewLayout:[[BubbleGridLayout alloc] initWithFrameWidth:frameWidth andNumOfCellsInRow:NUM_CELLS_IN_ROW andNumOfRows:NUM_OF_ROWS]];
    [bubbleGrid registerClass:[BubbleCell class] forCellWithReuseIdentifier:@"bubbleCell"];
    [bubbleGrid setBackgroundColor:[UIColor clearColor]];
    [bubbleGrid setDataSource:self];
    [bubbleGrid setDelegate:self];
}

- (void)initialiseLevelSelectorPopover{
    levelSelector = [[LevelSelector alloc] initWithStyle:UITableViewStylePlain andDelegate:self];
    levelSelectorPopover = [[UIPopoverController alloc] initWithContentViewController:levelSelector];
    [levelSelector updateLevelOptions];
}

- (void)addGestureRecognisersToCollectionView{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gridPanHandler:)];
    panGesture.maximumNumberOfTouches = 1;
    [bubbleGrid addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressHandler:)];
    [bubbleGrid addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [bubbleGrid addGestureRecognizer:tapGesture];

}

- (void)initRequiredUIImages{
    backgroundImage = [UIImage imageNamed:@"background.png"];
    [self loadPaletteImageMappings];
}
- (void)loadBackground{
    CGFloat gameHeight = self.gameArea.frame.size.height;
    CGFloat gameWidth = self.gameArea.frame.size.width;
    background.frame = CGRectMake(0, 0, gameWidth, gameHeight);
    [background setImage:backgroundImage];
}
- (void)loadImage:(UIImage *)image IntoUIView:(UIImageView *)view{
    view.contentMode = UIViewContentModeScaleAspectFit;
    view.clipsToBounds = YES;
    [view setImage:image];
}

- (IBAction)backButtonPressed:(id)sender {
    if([self.controllerDataManager hasUnsavedBubbles]){
        selectorToExecute = @selector(goBackToMainMenu);
        [self showConfirmationWithTitle:@"Go to Main Menu" andMessage:@"Your unsaved changes will be lost! Are you sure you want to leave this page without saving?"];
    }else{
        [self goBackToMainMenu];
    }
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

- (void)toggleUIViewTransparancy:(UIView *)view{
    if([view alpha] == 1){
        [view setAlpha:TRANSLUCENT_ALPHA];
    }else{
        [view setAlpha:1];
    }
}
#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"designerToGame"]){
        [self.controllerDataManager saveUnsavedStateToTempFile];
        id<GameEngineInitDelegate> controller = segue.destinationViewController;
        [controller setOriginalBubbleModels:[self.controllerDataManager getAllBubbleModels]];
        [controller setPreviousScreen:LEVEL_DESIGNER];
    }
}

- (void)goBackToMainMenu{
    [self performSegueWithIdentifier:DESIGNER_TO_MENU sender:self];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate Methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BubbleCell *bubble = [collectionView dequeueReusableCellWithReuseIdentifier:@"bubbleCell" forIndexPath:indexPath];
    return bubble;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [(BubbleGridLayout *)bubbleGrid.collectionViewLayout defaultBubbleCellCount];
}


#pragma mark - operations on bubble in bubble grid for level creator
- (void)cycleBubbleAtCollectionViewIndex:(NSIndexPath *)index{
    NSInteger previousType = [self.controllerDataManager getBubbleTypeForBubbleAtCollectionViewIndex:index];
    NSInteger newType = [self getNextBubbleTypeFromType:previousType];
    [self.controllerDataManager modifyBubbleAtCollectionViewIndex:index ToType:newType];
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
    [levelSelectorPopover presentPopoverFromRect:loadButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)save{
    //Saves data model for current level to file.
    //Loads blank palette for next level
    @try{
        [self.controllerDataManager saveLevel];
        [self showAlertWithTitle:@"Save Level" andMessage:SAVE_SUCCESSFUL_MSG];
        [self updateCurrentLevelView];
        [levelSelector updateLevelOptions];
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
    [levelSelectorPopover dismissPopoverAnimated:YES];
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

#pragma mark - Abstract Methods
- (void)loadPaletteImageMappings{
    //loads the mapping of bubble type to the corresponding images
}
- (void)loadPalette{
    //loads the mapping of bubble type to the corresponding view representation in the selector palette
}

- (NSInteger)getNextBubbleTypeFromType:(NSInteger)type{
    return 0;
}

- (void)tapHandler:(UIGestureRecognizer *)gesture{
    // MODIFIES: bubble model (color)
    // REQUIRES: game in designer mode
    // EFFECTS: the user taps the bubble with one finger
    //          if the bubble is active, it will change its color
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture{
    // MODIFIES: bubble model (state from active to inactive)
    // REQUIRES: game in designer mode, bubble active in the grid
    // EFFECTS: the bubble is 'erased' after being long-pressed
}

- (void)gridPanHandler:(UIGestureRecognizer *)gesture{
    //REQUIRES: game in designer mode
    //Effect: Cells being swipped will be filled with the selected bubble color
}

@end
