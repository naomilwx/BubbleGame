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

#define NUM_TYPES 4
#define NUM_OF_CELLS_IN_ROW 12

@implementation ViewController

@synthesize gameBackground;
@synthesize defaultBubbleRadius;
@synthesize bubbleMappings;
@synthesize engine;
@synthesize bubbleGridTemplate;

- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadBackground];
    [self initialiseBubbleGrid];
    [self loadDefaultBubbles]; //for testing
    [self loadEngine];
    [self addGestureRecognisers];
    [self loadNextBubble];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)loadEngine{
    if(!engine){
        engine = [[MainEngine alloc] init];
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

- (void)loadDefaultBubbles{
    //for testing mapping will be passed from game designer when PS3 is fully integrated with this.
    if(!self.bubbleMappings){
        self.bubbleMappings =
                       @{[NSNumber numberWithInt:0]: [UIImage imageNamed:@"bubble-orange"],
                         [NSNumber numberWithInt:1]: [UIImage imageNamed:@"bubble-blue"],
                         [NSNumber numberWithInt:2]: [UIImage imageNamed:@"bubble-green"],
                         [NSNumber numberWithInt:3]: [UIImage imageNamed:@"bubble-red"],
                        };
    }
}

- (void)loadDefaultBubbleMapping:(NSDictionary *)mapping{
    self.bubbleMappings = mapping;
}

- (void)loadGridBubblesFromModel:(NSDictionary *)models{
    for(BubbleModel *model in models){
        CGPoint bubbleCenter = [model center];
        NSInteger bubbleTypeNum = [model bubbleType];
        NSNumber *bubbleType = [NSNumber numberWithInteger:bubbleTypeNum];
        BubbleView *bubbleView = [BubbleView createWithCenter:bubbleCenter andWidth:[model width] andImage:[self.bubbleMappings objectForKey:bubbleType]];
        [self addGridBubbleToEngine:bubbleView forType:bubbleTypeNum withCenter:bubbleCenter];
        [self.gameBackground addSubview:bubbleView];
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
    CGPoint bubbleCenter = [self getStartingBubbleCenter];
    NSInteger nextTypeNum = [self getNextBubbleType];
    NSNumber *nextBubbleType = [NSNumber numberWithInteger:nextTypeNum];
    BubbleView *bubbleView = [BubbleView createWithCenter:bubbleCenter andWidth:(self.defaultBubbleRadius * 2) andImage:[self.bubbleMappings objectForKey:nextBubbleType]];
    [self addMobileBubbleToEngine:bubbleView forType:nextTypeNum];
    [self.gameBackground addSubview:bubbleView];
}

- (CGPoint)getStartingBubbleCenter{
    CGFloat xPos = self.gameBackground.center.x;
    CGFloat yPos = self.gameBackground.frame.size.height - self.defaultBubbleRadius;
    return CGPointMake(xPos, yPos);
}

- (void)addMobileBubbleToEngine:(BubbleView *)bubble forType:(NSInteger)type{
    [self.engine addMobileEngine:bubble withType:type];
}


- (NSInteger)getNextBubbleType{
    return arc4random_uniform(NUM_TYPES);
}

- (void)panHandler:(UIGestureRecognizer *)recogniser{
    if(recogniser.state == UIGestureRecognizerStateEnded){
        [self launchBubbleWithInputPoint:[recogniser locationInView:self.gameBackground]];
    }
}

- (void)longPressHandler:(UIGestureRecognizer *)recogniser{
    if(recogniser.state == UIGestureRecognizerStateEnded){
        [self launchBubbleWithInputPoint:[recogniser locationInView:self.gameBackground]];
    }
}

- (void)tapHandler:(UIGestureRecognizer *)recogniser{
    [self launchBubbleWithInputPoint:[recogniser locationInView:self.gameBackground]];
}

- (void)launchBubbleWithInputPoint:(CGPoint)point{
    CGPoint end = point;
    CGPoint start = [self getStartingBubbleCenter];
    CGPoint displacement = [self getUnitVectorStart:start toEnd:end];
    [self launchBubbleWithDisplacementVector:displacement];
}

- (void)launchBubbleWithDisplacementVector:(CGPoint)vector{
    [engine setDisplacementVectorForBubble:vector];
    [self loadNextBubble];
}

- (CGPoint)getUnitVectorStart:(CGPoint)start toEnd:(CGPoint)end{
    CGPoint vector = CGPointMake(end.x - start.x, end.y - start.y);
    CGFloat magnitude = sqrt(pow(vector.x, 2) + pow(vector.y, 2));
    return CGPointMake(vector.x/magnitude , vector.y/magnitude);
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

@end
