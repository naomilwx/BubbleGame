//
//  ViewController.m
//  Game
//
//  Created by Naomi Leow on 27/1/14.
//
//

#import "GameBubble.h"
#import <UIKit/UIKit.h>
#import "BubbleGridLayout.h"
#import "BubbleCell.h"
#import "GameLogic.h"
#import "BubbleController.h"

#define SAVE_SUCCESSFUL_MSG @"Game level saved successfully"
#define SAVE_UNSUCCESSFUL_MSG @"An error occurred while saving. Game level is not saved."
#define LEVEL_INDICATOR_TEXT @"Level: %@"

@interface GameBubble()

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

@implementation GameBubble {
    UIImage *backgroundImage;
}
@synthesize gameArea;
@synthesize palette;
@synthesize background;
@synthesize bubbleGrid;
@synthesize paletteImages;
@synthesize paletteButtons;
@synthesize gameLoader;
@synthesize bubbleControllerManager;
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
    @try{
        if(!gameLoader){
            gameLoader = [[GameLoader alloc] init];
        }
    }@catch(NSException *e){
        [self showAlertWithTitle:@"Set up" andMessage:@"Failed to load game, your game data may be corrupted"];
    }
    if(!bubbleControllerManager){
        bubbleControllerManager = [[BubbleManager alloc] initWithNumofRows:NUM_OF_ROWS andColumns:NUM_CELLS_IN_ROW];
    }
    [self initRequiredUIImages];
    [self loadBackground];
    [self loadPalette];
    [self initialiseCollectionView];
    [self addGestureRecognisersToCollectionView];
    [self.gameArea insertSubview:bubbleGrid belowSubview:backButton];
    [self initialiseLevelSelectorPopover];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self loadImage:backgroundImage IntoUIView:background];
}
- (void)loadImage:(UIImage *)image IntoUIView:(UIImageView *)view{
    view.contentMode = UIViewContentModeScaleAspectFit;
    view.clipsToBounds = YES;
    [view setImage:image];
}

- (IBAction)buttonPressed:(id)sender {
    NSString *label = [[(UIButton *)sender titleLabel] text];
    if([label isEqualToString:GAME_START]){
        
    }else if([label isEqualToString:GAME_LOAD]){
        [self load];
    }else if([label isEqualToString:GAME_SAVE]){
        [self save];
    }else{
        [self reset];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//TODO:
}

- (void)toggleUIViewTransparancy:(UIView *)view{
    if([view alpha] == 1){
        [view setAlpha:TRANSLUCENT_ALPHA];
    }else{
        [view setAlpha:1];
    }
}

#pragma mark - Delegate Methods for BubbleController
- (void)addToView:(UIView *)view{
    [self.gameArea addSubview:view];
}

- (BubbleGridLayout *)getGridLayout{
    return (BubbleGridLayout *)self.bubbleGrid.collectionViewLayout;
}

- (NSInteger)addBubbleModelWithType:(NSInteger)type andWidth:(CGFloat)width andCenter:(CGPoint)center{
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

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate Methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BubbleCell *bubble = [collectionView dequeueReusableCellWithReuseIdentifier:@"bubbleCell" forIndexPath:indexPath];
    return bubble;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [(BubbleGridLayout *)bubbleGrid.collectionViewLayout defaultBubbleCellCount];
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

#pragma mark - operations on bubble in bubble grid for level creator
- (void)cycleBubbleAtCollectionViewIndex:(NSIndexPath *)index{
    BubbleController *bubble = [self getBubbleControllerAtCollectionViewIndex:index];
    if(![bubble isEqual:[NSNull null]]){
        NSInteger bubbleID = [bubble bubbleModelID];
        NSInteger bubbleType = [self.gameLoader getBubbleType:bubbleID];
        bubbleType = [self getNextBubbleTypeFromType:bubbleType];
        [bubble modifyBubbletoType:bubbleType];
    }
}

- (void)addBubbleAtCollectionViewIndex:(NSIndexPath *)index withType:(NSInteger)type{
    BubbleController *bubble = [[BubbleController alloc] initWithMasterController:self];
    [bubble addBubbleAtCollectionViewIndex:index withType:type];
    [self insertBubbleController:bubble AtCollectionViewIndex:index];
}

- (void)removeBubbleAtCollectionViewIndex:(NSIndexPath *)index{
    BubbleController *bubble = [self getBubbleControllerAtCollectionViewIndex:index];
    if(![bubble isEqual:[NSNull null]]){
        [bubble removeBubble];
        [self removeBubbleControllerAtCollectionViewIndex:index];
    }
}

#pragma mark - update datastructure which holds the individual bubble controllers
- (BubbleController *)getBubbleControllerAtCollectionViewIndex:(NSIndexPath *)index{
    BubbleGridLayout *layoutManager = (BubbleGridLayout *)self.bubbleGrid.collectionViewLayout;
    NSInteger rowInGrid = [layoutManager getRowNumberFromIndex:index.item];
    NSInteger rowPosInGrid = [layoutManager getRowPositionFromIndex:index.item];
    return [self.bubbleControllerManager getObjectAtRow:rowInGrid andPosition:rowPosInGrid];
}

- (void)insertBubbleController:(BubbleController *)controller AtCollectionViewIndex:(NSIndexPath *)index{
    BubbleGridLayout *layoutManager = (BubbleGridLayout *)self.bubbleGrid.collectionViewLayout;
    NSInteger rowInGrid = [layoutManager getRowNumberFromIndex:index.item];
    NSInteger rowPosInGrid = [layoutManager getRowPositionFromIndex:index.item];
    [self.bubbleControllerManager insertObject:controller AtRow:rowInGrid andPosition:rowPosInGrid];
}

- (void)removeBubbleControllerAtCollectionViewIndex:(NSIndexPath *)index{
    BubbleGridLayout *layoutManager = (BubbleGridLayout *)self.bubbleGrid.collectionViewLayout;
    NSInteger rowInGrid = [layoutManager getRowNumberFromIndex:index.item];
    NSInteger rowPosInGrid = [layoutManager getRowPositionFromIndex:index.item];
    [self.bubbleControllerManager removeObjectAtRow:rowInGrid andPosition:rowPosInGrid];
    
}
#pragma mark - functions to handle load/save/reset
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
        BubbleController *bubble = [[BubbleController alloc] initWithMasterController:self];
        [bubble addBubbleFromModel:model];
        [self insertBubbleController:bubble AtCollectionViewIndex:gridIndex];
    }
}

- (void)removeAllBubbles{
    //Gets invokes removeBubble method of all controllers, which removes all bubble models and bubble views
    NSArray *allBubbles = [self.bubbleControllerManager getAllObjects];
    for(BubbleController *bubble in allBubbles){
        [bubble removeBubble];
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
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - delegate methods for LevelSelectorDelegate

- (void)selectedLevel:(NSInteger)levelIndex{
    if(levelIndex == INVALID){
        [self loadNewLevel];
    }else{
        [self loadGameLevel:levelIndex];
    }
    [levelSelectorPopover dismissPopoverAnimated:YES];
}

- (NSArray *)getAvailableLevels{
    return [self.gameLoader getAvailableLevels];
}

@end
