//
//  GameBubble.h
//  Game
//
//  Created by Naomi Leow on 27/1/14.
//
// Abstract Class

#import <UIKit/UIKit.h>
#import "BubbleView.h"
#import "ControllerDataManager.h"
#import "LevelSelector.h"

#define GAME_START @"Start"
#define GAME_LOAD @"Load"
#define GAME_SAVE @"Save"
#define GAME_RESET @"Reset"
#define TRANSLUCENT_ALPHA 0.35


@interface DesignerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, LevelSelectorDelegate>

@property (strong, nonatomic) NSDictionary *paletteImages;
@property (strong, nonatomic) NSDictionary *paletteButtons;
@property (strong, nonatomic) IBOutlet UIView *gameArea;
@property (strong, nonatomic) IBOutlet UIView *palette;
@property (strong, nonatomic) IBOutlet UIImageView *background;
@property (strong, nonatomic) IBOutlet UICollectionView *bubbleGrid;
@property (strong, nonatomic) IBOutlet UILabel *levelIndicator;
@property (strong, nonatomic) LevelSelector *levelSelector;
@property (strong, nonatomic) UIPopoverController *levelSelectorPopover;
@property (strong, nonatomic) IBOutlet UIButton *loadButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong) ControllerDataManager *controllerDataManager;

- (void)tapHandler:(UIGestureRecognizer *)gesture;
// MODIFIES: bubble model (color)
// REQUIRES: game in designer mode
// EFFECTS: the user taps the bubble with one finger
//          if the bubble is active, it will change its color

- (void)longpressHandler:(UIGestureRecognizer *)gesture;
// MODIFIES: bubble model (state from active to inactive)
// REQUIRES: game in designer mode, bubble active in the grid
// EFFECTS: the bubble is 'erased' after being long-pressed

- (void)gridPanHandler:(UIGestureRecognizer *)gesture;
//REQUIRES: game in designer mode
//Effect: Cells being swipped will be filled with the selected bubble color
//Abstract. To be overridden by subclass

- (void)loadPaletteImageMappings;
//Initialise mapping of image icon to palette selection type
//Abstract method. Must be overridden by subclasses.

- (void)loadPalette;
//Initialise mapping of bubble icons to palette selection type and loadsimage icons for bubble palette.
//Requires: bubble icon images to be already initialised. Must not be called before loadBubbleImages
//Abstract method. Must be overridden by subclasses.

- (void)toggleUIViewTransparancy:(UIView *)view;
//Modifies: Alpha value of view
//Effect: Makes view opaque if it currently is translucent, makes it translucent if it currently is opaque
//Requires: view not nil

- (void)loadImage:(UIImage *)image IntoUIView:(UIImageView *)view;
//Modifies: Image attribute of view
//Requires: image and view not null
//Effect: Makes given image the image of view

- (void)cycleBubbleAtCollectionViewIndex:(NSIndexPath *)index;

- (NSInteger)getNextBubbleTypeFromType:(NSInteger)type;

@end
