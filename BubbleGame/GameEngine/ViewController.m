//
//  ViewController.m
//  GameEngine
//
//  Created by Naomi Leow on 11/2/14.
//
//

#import "ViewController.h"
#import "BubbleView.h"
#import "BubbleGridLayout.h"
#import "BubbleModel.h"
#import "GameCommon.h"
#import "CGPointExtension.h"
#import "UIImageView+AnimationCompletion.h"

#define NUM_OF_CELLS_IN_ROW 12
#define BACK_BUTTON_XPOS 30
#define BACK_BUTTON_YPOS 980
#define BACK_BUTTON_WIDTH 45
#define BACK_BUTTON_HEIGHT 30
#define SCORE_HEIGHT 50
#define SCORE_WIDTH 300
#define SCORE_SIDE_BUFFER 20
#define SCORE_BOTTOM_BUFFER 10
#define LEVEL_NOTIFICATION_WIDTH 500
#define LEVEL_NOTIFICATION_HEIGHT 50
#define LEVEL_NOTIFICATION_DISPLAY_DURATION 5
#define CALLBACK_WAIT_DELAY 5
#define BACK_TO_MAIN_MENU @"gameToMenu"
#define BACK_TO_DESIGNER @"gameToDesigner"
#define GAME_LEVEL_DISPLAY @"Level: %@"
#define WIN_ALERT_TITLE @"Game Won"
#define LOSE_ALERT_TITLE @"Game Over"

@implementation ViewController{
    NSDictionary *originalBubbleModels;
    NSInteger previousScreen;
}

@synthesize gameBackground;
@synthesize defaultBubbleRadius;
@synthesize allBubbleMappings;
@synthesize launchableBubbleMappings;
@synthesize engine;
@synthesize bubbleGridTemplate;
@synthesize backButton;
@synthesize cannonController;
@synthesize stateDisplay;
@synthesize gameLevel;

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpGameEnvironment];
    [self loadScoreDisplay];
    [self showLoadedLevel];
    [self setUpEndGameObservation];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)setUpGameEnvironment{
    [self loadBackground];
    [self initialiseBubbleGrid];
    [self loadBackButton];
    [self loadBubbleMappings];
    [self loadEngine];
    [self loadGridBubblesFromModel];
    [self addGestureRecognisers];
    [self loadCannonController];
}

- (void)showLoadedLevel{
    CGPoint center = self.gameBackground.center;
    CGRect displayFrame = CGRectMake(center.x, center.y, LEVEL_NOTIFICATION_WIDTH, LEVEL_NOTIFICATION_HEIGHT);
    NSString *invalidLevel = [NSString stringWithFormat:@"%d",INVALID];
    if(![gameLevel isEqual:invalidLevel]){
        [stateDisplay showTextNotification:[NSString stringWithFormat:GAME_LEVEL_DISPLAY, gameLevel] withFrame:displayFrame];
        [self executeBlock:^{[stateDisplay hideTextNotification];} afterDelay:LEVEL_NOTIFICATION_DISPLAY_DURATION];
    }
}

- (void)loadScoreDisplay{
    CGRect scoreFrame = CGRectMake(BACK_BUTTON_XPOS + BACK_BUTTON_WIDTH + SCORE_SIDE_BUFFER, BACK_BUTTON_YPOS - SCORE_BOTTOM_BUFFER, SCORE_WIDTH, SCORE_HEIGHT);
    stateDisplay = [[StateDisplay alloc] initWithGameView:self.gameBackground andDisplayFrame:scoreFrame];
    [stateDisplay displayHighscore:[engine getPreviousHighscore]];
}

- (void)loadCannonController{
    cannonController = [[CannonController alloc] initWithGameView:self.gameBackground andEngine:engine andBubbleMappings:launchableBubbleMappings andBubbleRadius:self.defaultBubbleRadius];
}

- (void)loadBackButton{
    CGRect frame = CGRectMake(BACK_BUTTON_XPOS, BACK_BUTTON_YPOS, BACK_BUTTON_WIDTH, BACK_BUTTON_HEIGHT);
    backButton = [[UIButton alloc] initWithFrame:frame];
    [backButton setImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [backButton addTarget:self
               action:@selector(backButtonClicked)
     forControlEvents:UIControlEventTouchDown];
    [self.gameBackground addSubview:backButton];
}

- (void)loadEngine{
    if(!engine){
        engine = [[MainEngineSpecialised alloc] initWithGameLevel:gameLevel];
        [engine setFrameHeight:gameBackground.frame.size.height];
        [engine setFrameWidth:gameBackground.frame.size.width];
        [engine setGridTemplateDelegate:self];
    }
}

- (void)loadBackground{
    self.gameBackground.contentMode = UIViewContentModeScaleAspectFit;
    self.gameBackground.clipsToBounds = YES;
    self.gameBackground.userInteractionEnabled = YES;
    UIImage *background = [UIImage imageNamed:@"background"];
    [self.gameBackground setImage:background];
}

- (void)loadBubbleMappings{
    if(!self.allBubbleMappings){
        self.allBubbleMappings = [GameCommon allBubbleImageMappings];
        
    }
    if(!self.launchableBubbleMappings){
        self.launchableBubbleMappings = [self getLaunchableBubbleMappings];
    }
}

- (NSDictionary *)getLaunchableBubbleMappings{
    NSMutableDictionary *mappings = [[NSMutableDictionary alloc] init];
    for(NSNumber *key in self.allBubbleMappings){
        if([[GameCommon launchableBubbleTypes] containsObject:key]){
            [mappings setObject:[self.allBubbleMappings objectForKey:key] forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:mappings];
}

- (void)loadGridBubblesFromModel{
    if(originalBubbleModels){
        for(NSNumber *modelID in originalBubbleModels){
            BubbleModel *model = [originalBubbleModels objectForKey:modelID];
            NSInteger bubbleTypeNum = [model bubbleType];
            NSNumber *bubbleType = [NSNumber numberWithInteger:bubbleTypeNum];
            CGPoint bubbleCenter = [model center];
            BubbleView *bubbleView = [BubbleView createWithCenter:bubbleCenter andWidth:[model width] andImage:[self.allBubbleMappings objectForKey:bubbleType]];
            [self.gameBackground addSubview:bubbleView];
            [self addGridBubbleToEngine:bubbleView forType:bubbleTypeNum withCenter:bubbleCenter];
        }
        [engine removeAllOrphanedBubbles];
    }
}

- (void)addGridBubbleToEngine:(BubbleView *)bubble forType:(NSInteger)type withCenter:(CGPoint)center{
    [self.engine addGridEngine:bubble withType:type andCenter:center];
}

- (void)initialiseBubbleGrid{
    NSInteger frameWidth = self.gameBackground.frame.size.width;
    NSInteger frameHeight = self.gameBackground.frame.size.height;
    CGRect collectionFrame = CGRectMake(0, 0, frameWidth, frameHeight);
    NSInteger numOfRows = floor(NUM_OF_CELLS_IN_ROW*frameHeight/frameWidth);
    BubbleGridLayout *layout = [[BubbleGridLayout alloc] initWithFrameWidth:frameWidth andNumOfCellsInRow:NUM_OF_CELLS_IN_ROW andNumOfRows:numOfRows];
    bubbleGridTemplate = [[UICollectionView alloc] initWithFrame:collectionFrame collectionViewLayout:layout];

    [bubbleGridTemplate setBackgroundColor:[UIColor clearColor]];
    [bubbleGridTemplate setDataSource:self];
    [bubbleGridTemplate setDelegate:self];
    
    self.defaultBubbleRadius = (layout.cellWidth)/2;

}

- (void)addGestureRecognisers{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [self.gameBackground addGestureRecognizer:tapGesture];
    
      UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self.gameBackground addGestureRecognizer:panGesture];
    
       UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    [self.gameBackground addGestureRecognizer:longPressGesture];
}

- (void)backButtonClicked{
    [self goBackToPreviousScreen];
}

- (void)goBackToPreviousScreen{
    if(previousScreen == LEVEL_DESIGNER){
        [self performSegueWithIdentifier:BACK_TO_DESIGNER sender:self];
    }else if(previousScreen == MAIN_MENU){
        [self performSegueWithIdentifier:BACK_TO_MAIN_MENU sender:self];
    }
}

- (BubbleEngine *)addMobileBubbleToEngine:(BubbleView *)bubble forType:(NSInteger)type{
    return [self.engine addMobileEngine:bubble withType:type];
}

- (void)panHandler:(UIGestureRecognizer *)recogniser{
    [cannonController controlCannonWithGesture:recogniser showPath:YES];
}

- (void)longPressHandler:(UIGestureRecognizer *)recogniser{
    [cannonController controlCannonWithGesture:recogniser showPath:YES];
}

- (void)tapHandler:(UIGestureRecognizer *)recogniser{
    [cannonController controlCannonWithGesture:recogniser showPath:NO];
}

- (void)executeBlock:(void (^)(void))block afterDelay:(NSInteger)delay{
    dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(duration, dispatch_get_main_queue(), block);
}

#pragma mark - Handle end game
- (void)reload{
    [self.engine reload];
    [self loadGridBubblesFromModel];
    [self.cannonController reload];
    [self.stateDisplay resetScoreDisplay];
}

- (void)setUpEndGameObservation{
    NSNotificationCenter *note = [NSNotificationCenter defaultCenter];
    [note addObserver:self selector:@selector(receiveGameEndNotification:) name:ENDGAME object:nil];
}

- (void)receiveGameEndNotification:(NSNotification *)notification{
    NSDictionary *message = [notification userInfo];
    if([[message objectForKey:ENDGAME_STATUS] isEqual:[NSNumber numberWithBool:YES]]){
    //game won
        [self handleGameWin:message];
    }else{
        [self handleGameLose:message];
    }
}

- (void)handleGameWin:(NSDictionary *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: WIN_ALERT_TITLE
                                                    message:[message objectForKey:ENDGAME_MESSAGE]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil]; //TODO
    [alert show];
}

- (void)handleGameLose:(NSDictionary *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: LOSE_ALERT_TITLE
                                                    message:[message objectForKey:ENDGAME_MESSAGE]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self reload];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([[alertView title] isEqual:WIN_ALERT_TITLE]){
        if(previousScreen == MAIN_MENU){
            [self executeBlock:^{
                [engine saveGameHighScore];
                [self goBackToPreviousScreen];
            } afterDelay:CALLBACK_WAIT_DELAY];
        }else{
            [self goBackToPreviousScreen];
        }
    }
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate Methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [(BubbleGridLayout *)bubbleGridTemplate.collectionViewLayout defaultBubbleCellCount];
}

#pragma mark - Delegate method to get bubble grid details
- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)center{
    return [bubbleGridTemplate indexPathForItemAtPoint:center];
}

- (CGPoint)getCenterForItemAtIndexPath:(NSIndexPath *)path{
    return [(BubbleGridLayout *)bubbleGridTemplate.collectionViewLayout getCenterForItemAtIndex:path.item];
}

- (NSInteger)getRowNumberFromIndexPath:(NSIndexPath *)path{
   return [(BubbleGridLayout *)bubbleGridTemplate.collectionViewLayout getRowNumberFromIndex:path.item];
}

- (NSInteger) getRowPositionFromIndexPath:(NSIndexPath *)path{
   return [(BubbleGridLayout *)bubbleGridTemplate.collectionViewLayout getRowPositionFromIndex:path.item];
}

#pragma mark - GameEngineInitDelegate methods

- (void)setOriginalBubbleModels:(NSDictionary *)models{
    originalBubbleModels = models;
}

- (void)setPreviousScreen:(NSInteger)previous{
    previousScreen = previous;
}

- (void)setGameLevel:(NSString *)text{
    gameLevel = text;
}
@end
