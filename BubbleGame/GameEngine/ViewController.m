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
#import "GameLogic.h"
#import "CGPointExtension.h"

#define NUM_OF_CELLS_IN_ROW 12
#define BUBBLE_LOADER_BUFFER 5
#define CANNON_SIDE_BUFFER 10
#define CANNON_HEIGHT 150
#define CANNON_ANIMATION_DURATION 1
#define RELOAD_DELAY 1
#define BACK_BUTTON_XPOS 30
#define BACK_BUTTON_YPOS 980
#define BACK_BUTTON_WIDTH 45
#define BACK_BUTTON_HEIGHT 30
#define BACK_TO_MAIN_MENU @"gameToMenu"
#define BACK_TO_DESIGNER @"gameToDesigner"
#define PLOTTER_WIDTH 10
#define PLOTTER_INTERVAL 100

@implementation ViewController{
    NSMutableArray *cannonAnimation;
    UIImageView *cannon;
    TaggedObject *taggedCannonBubble;
    CGPoint cannonDefaultCenter;
    NSDictionary *originalBubbleModels;
    NSInteger previousScreen;
    BOOL bubbleInCannon;
    BOOL cannonLaunching;
}

@synthesize gameBackground;
@synthesize defaultBubbleRadius;
@synthesize allBubbleMappings;
@synthesize launchableBubbleMappings;
@synthesize engine;
@synthesize bubbleGridTemplate;
@synthesize bubbleLoader;
@synthesize backButton;
@synthesize plotter;

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpGameEnvironment];
    [self loadPathPlotter];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)setUpGameEnvironment{
    [self loadBackground];
    [self initialiseBubbleGrid];
    [self loadBackButton];
    [self loadCannon];
    [self loadBubbleMappings];
    [self loadEngine];
    [self setUpBubbles];
    [self addGestureRecognisers];
}

- (void)setUpBubbles{
    [self loadBubbleLoader];
    [self loadGridBubblesFromModel];
    [self loadNextBubble];
}

- (void)loadBubbleLoader{
    CGFloat height = self.defaultBubbleRadius * 2 + BUBBLE_LOADER_BUFFER;
    CGFloat width = self.defaultBubbleRadius * 2 * BUBBLE_QUEUE_SIZE + BUBBLE_LOADER_BUFFER;
    CGFloat xPos = self.gameBackground.center.x + CANNON_HEIGHT + self.defaultBubbleRadius * 2;
    CGFloat yPos = self.gameBackground.frame.size.height - height;
    CGRect loaderFrame = CGRectMake(xPos, yPos, width, height);
    bubbleLoader = [[BubbleLoader alloc] initWithFrame:loaderFrame andTypeMapping:launchableBubbleMappings andBubbleRadius:self.defaultBubbleRadius];
    [self.gameBackground addSubview:[bubbleLoader mainFrame]];
}

- (void)loadCannon{
    [self loadCannonImages];
    [self loadCannonBody];
    [self setUpCannonAnimation];
    [self loadCannonBase];
    cannonLaunching = NO;
}

- (void)loadPathPlotter{
    if(!plotter){
        CGRect frame = CGRectMake(self.gameBackground.frame.origin.x, self.gameBackground.frame.origin.y, self.gameBackground.frame.size.width, self.gameBackground.frame.size.height);
        plotter = [[PathPlotter alloc] initWithFrame:frame andWidth:PLOTTER_WIDTH andInterval:PLOTTER_INTERVAL];
    }
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

- (void)loadCannonBody{
    CGFloat width = self.defaultBubbleRadius * 2 + CANNON_SIDE_BUFFER * 2;
    CGFloat xPos = self.gameBackground.center.x - width / 2;
    CGFloat yPos = self.gameBackground.frame.size.height - CANNON_HEIGHT;
    CGRect baseFrame = CGRectMake(xPos, yPos, width, CANNON_HEIGHT);
    cannon = [[UIImageView alloc] initWithFrame:baseFrame];
    [cannon setImage:[cannonAnimation objectAtIndex:0]];
    cannonDefaultCenter = cannon.center;
    [self.gameBackground addSubview:cannon];
}

- (void)setUpCannonAnimation{
    [cannon setAnimationImages:cannonAnimation];
    [cannon setAnimationRepeatCount:1];
    [cannon setAnimationDuration:CANNON_ANIMATION_DURATION];
}

- (void)loadCannonImages{
    if(!cannonAnimation){
        cannonAnimation = [[NSMutableArray alloc] init];
        UIImage *cannonImage = [UIImage imageNamed:@"cannon"];
        CGFloat imageWidth = cannonImage.size.width;
        CGFloat imageHeight = cannonImage.size.height;
        NSInteger spritesRow = 2;
        NSInteger spritesCol = 6;
        for(NSInteger i = 0; i < spritesRow; i++){
            CGFloat xPos = 0;
            CGFloat yPos = i * imageHeight / spritesRow;
            for(NSInteger j  = 0; j < spritesCol ; j++){
                CGImageRef imageRef = CGImageCreateWithImageInRect(cannonImage.CGImage, CGRectMake(xPos, yPos, imageWidth / spritesCol, imageHeight / spritesRow));
                [cannonAnimation addObject:[UIImage imageWithCGImage:imageRef]];
                xPos += imageWidth / spritesCol;
            }
        }
    }
}

- (void)loadCannonBase{
    CGFloat width = self.defaultBubbleRadius * 2 + CANNON_SIDE_BUFFER * 2;
    CGFloat height = self.defaultBubbleRadius;
    CGFloat xPos = self.gameBackground.center.x - width / 2;
    CGFloat yPos = self.gameBackground.frame.size.height - height;
    CGRect baseFrame = CGRectMake(xPos, yPos, width, height);
    UIImageView *cannonBase = [[UIImageView alloc] initWithFrame:baseFrame];
    [cannonBase setImage:[UIImage imageNamed:@"cannon-base"]];
    [self.gameBackground addSubview:cannonBase];
}

- (void)loadEngine{
    if(!engine){
        engine = [[MainEngineSpecialised alloc] init];
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
        self.allBubbleMappings = [GameLogic allBubbleImageMappings];
        
    }
    if(!self.launchableBubbleMappings){
        self.launchableBubbleMappings = [self getLaunchableBubbleMappings];
    }
}

- (NSDictionary *)getLaunchableBubbleMappings{
    NSMutableDictionary *mappings = [[NSMutableDictionary alloc] init];
    for(NSNumber *key in self.allBubbleMappings){
        if([[GameLogic launchableBubbleTypes] containsObject:key]){
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

- (void)loadNextBubble{
    //Method to load bubble view for the next bubble to its position at the tip of the cannon
    taggedCannonBubble = [bubbleLoader getNextBubble];
    BubbleView *bubbleView = [taggedCannonBubble object];
    [bubbleView setCenter:[self getStartingBubbleCenter]];
    [self.gameBackground insertSubview:bubbleView belowSubview:cannon];
    bubbleInCannon = YES;
}

- (void)backButtonClicked{
    if(previousScreen == LEVEL_DESIGNER){
        [self performSegueWithIdentifier:BACK_TO_DESIGNER sender:self];
    }else if(previousScreen == MAIN_MENU){
        [self performSegueWithIdentifier:BACK_TO_MAIN_MENU sender:self];
    }
}

- (BubbleView *)createAndAddNewBubbleViewWithType:(NSInteger)type{
    CGPoint bubbleCenter = [self getStartingBubbleCenter];
    BubbleView *bubbleView = [BubbleView createWithCenter:bubbleCenter andWidth:(self.defaultBubbleRadius * 2) andImage:[self.allBubbleMappings objectForKey:[NSNumber numberWithInteger:type]]];
    [self.gameBackground addSubview:bubbleView];
    return bubbleView;
}

- (CGPoint)getStartingBubbleCenter{
    CGPoint base = [self getLaunchBaseCoordinates];
    CGPoint offset = getUnitPositionVector(base, cannon.center);
    CGFloat scalor = (CANNON_HEIGHT / 2 - self.defaultBubbleRadius);
    CGPoint scaledOffset = scaleVector(offset, scalor);
    return addVectors(scaledOffset, cannon.center);
}

- (void)addMobileBubbleToEngine:(BubbleView *)bubble forType:(NSInteger)type{
    [self.engine addMobileEngine:bubble withType:type];
}

- (void)panHandler:(UIGestureRecognizer *)recogniser{
    [self controlCannonWithGesture:recogniser showPath:YES];
}

- (void)longPressHandler:(UIGestureRecognizer *)recogniser{
    [self controlCannonWithGesture:recogniser showPath:YES];
}

- (void)tapHandler:(UIGestureRecognizer *)recogniser{
    [self controlCannonWithGesture:recogniser showPath:NO];
}

- (void)controlCannonWithGesture:(UIGestureRecognizer *)recogniser showPath:(BOOL)show{
    CGPoint point = [recogniser locationInView:self.gameBackground];
    if(show == YES){
        [self.plotter addRayFromPoint:[self getStartingBubbleCenter] andPoint:point toView:self.gameBackground];
    }
    if(!cannonLaunching){
        [self rotateCannonInDirection:point];
    }
    if(recogniser.state == UIGestureRecognizerStateEnded && bubbleInCannon){
        [self.plotter removePreviousRay];
        [self launchBubbleWithInputPoint:point];
    }
}

- (CGPoint)getLaunchBaseCoordinates{
    return CGPointMake(self.gameBackground.center.x, self.gameBackground.frame.size.height);
}

- (void)rotateCannonInDirection:(CGPoint)point{
    CGPoint base = [self getLaunchBaseCoordinates];
    CGPoint unitOffSet = getUnitPositionVector(base, point);
    if(unitOffSet.y != 0){
        [self updateCannonPosition:base withOffset:unitOffSet];
        CGFloat tanRatio = (unitOffSet.x / unitOffSet.y) * -1; //negative of angle because it is with respecto to normal
        CGFloat angle = atanf(tanRatio);
        cannon.transform = CGAffineTransformMakeRotation(angle);
    }
}

- (void)updateCannonPosition:(CGPoint)base withOffset:(CGPoint)unitOffSet{
    CGPoint scaledOffset = scaleVector(unitOffSet, CANNON_HEIGHT/2);
    CGPoint newCannonCenter = addVectors(base, scaledOffset);
    [cannon setCenter:newCannonCenter];
    [self shiftBubbleInCannonWithOffset:unitOffSet];
}

- (void)shiftBubbleInCannonWithOffset:(CGPoint)unitOffset{
    if(bubbleInCannon){
        CGPoint newCenter = [self getStartingBubbleCenter];
        [[taggedCannonBubble object] setCenter:newCenter];
    }
}

- (void)launchBubbleWithInputPoint:(CGPoint)point{
    cannonLaunching = YES;
    bubbleInCannon = NO;
    [cannon startAnimating];
    void (^launchCode)() = ^{
        cannonLaunching = NO;
        CGPoint displacement = [self calculateLaunchDisplacementForInputPoint:point];
        [self addMobileBubbleToEngine:[taggedCannonBubble object] forType:[[taggedCannonBubble tag] integerValue]];
        [self launchBubbleWithDisplacementVector:displacement];
    };
    [self executeBlock:launchCode afterDelay:CANNON_ANIMATION_DURATION];
}

- (CGPoint)calculateLaunchDisplacementForInputPoint:(CGPoint)point{
    CGPoint start;
    if(CGRectContainsPoint(cannon.frame, point)){
        start = [self getLaunchBaseCoordinates];
    }else{
        start = [self getStartingBubbleCenter];
    }
    CGPoint displacement = getUnitPositionVector(start, point);
    return displacement;
}

- (void)launchBubbleWithDisplacementVector:(CGPoint)vector{
    //Sets displacement vector for bubble in its corresponding BubbleEngine instance
    [engine setDisplacementVectorForBubble:vector];
    [self executeBlock:^{[self loadNextBubble];}
            afterDelay:RELOAD_DELAY];
}

- (void)executeBlock:(void (^)(void))block afterDelay:(NSInteger)delay{
    dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(duration, dispatch_get_main_queue(), block);
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
@end
