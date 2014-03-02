//
//  ViewController.m
//  GameEngine
//
//  Created by Naomi Leow on 11/2/14.
//
//

#import "CannonController.h"
#import "BubbleView.h"
#import "BubbleGridLayout.h"
#import "BubbleModel.h"
#import "GameCommon.h"
#import "TaggedObject.h"
#import "CGPointExtension.h"
#import "UIImageView+AnimationCompletion.h"

#define BUBBLE_LOADER_BUFFER 5
#define CANNON_SIDE_BUFFER 10
#define CANNON_HEIGHT 130
#define CANNON_ANIMATION_DURATION 0.5
#define RELOAD_DELAY 1
#define PLOTTER_WIDTH 20
#define PLOTTER_INTERVAL 100

@implementation CannonController{
    NSMutableArray *cannonAnimation;
    UIImageView *cannon;
    TaggedObject *taggedCannonBubble;
    CGPoint cannonDefaultCenter;
    BOOL bubbleInCannon;
    BOOL cannonLaunching;
}

@synthesize defaultBubbleRadius;
@synthesize launchableBubbleMappings;
@synthesize engine;
@synthesize bubbleLoader;
@synthesize plotter;
@synthesize gameView;

- (id)initWithGameView:(UIView *)view andEngine:(MainEngine *)mainEngine andBubbleMappings:(NSDictionary *)mapping andBubbleRadius:(CGFloat)radius{
    if(self = [super init]){
        gameView = view;
        engine = mainEngine;
        launchableBubbleMappings = mapping;
        defaultBubbleRadius = radius;
        [self setUpCannonContoller];
    }
    return self;
}

- (void)setUpCannonContoller{
    [self loadCannon];
    [self loadBubbleLoader];
    [self loadNextBubble];
    [self loadPathPlotter];
}

- (void)loadBubbleLoader{
    CGFloat height = self.defaultBubbleRadius * 2 + BUBBLE_LOADER_BUFFER;
    CGFloat width = self.defaultBubbleRadius * 2 * BUBBLE_QUEUE_SIZE + BUBBLE_LOADER_BUFFER;
    CGFloat xPos = self.gameView.center.x + CANNON_HEIGHT + self.defaultBubbleRadius * 2;
    CGFloat yPos = self.gameView.frame.size.height - height;
    CGRect loaderFrame = CGRectMake(xPos, yPos, width, height);
    bubbleLoader = [[BubbleLoader alloc] initWithFrame:loaderFrame andTypeMapping:launchableBubbleMappings andBubbleRadius:self.defaultBubbleRadius];
    [self.gameView addSubview:[bubbleLoader mainFrame]];
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
        CGRect frame = CGRectMake(self.gameView.frame.origin.x, self.gameView.frame.origin.y, self.gameView.frame.size.width, self.gameView.frame.size.height);
        plotter = [[PathPlotter alloc] initWithFrame:frame andWidth:PLOTTER_WIDTH andInterval:PLOTTER_INTERVAL];
        BOOL (^gridCollision)(CGPoint) = ^BOOL(CGPoint point){
            return [engine hasCollisionWithGridForCenter:point];
        };
        [plotter setAdditionalStopCondition:gridCollision];
    }
}

- (void)loadCannonBody{
    CGFloat width = self.defaultBubbleRadius * 2 + CANNON_SIDE_BUFFER * 2;
    CGFloat xPos = self.gameView.center.x - width / 2;
    CGFloat yPos = self.gameView.frame.size.height - CANNON_HEIGHT;
    CGRect baseFrame = CGRectMake(xPos, yPos, width, CANNON_HEIGHT);
    cannon = [[UIImageView alloc] initWithFrame:baseFrame];
    [cannon setImage:[cannonAnimation objectAtIndex:0]];
    cannonDefaultCenter = cannon.center;
    [self.gameView addSubview:cannon];
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
    CGFloat xPos = self.gameView.center.x - width / 2;
    CGFloat yPos = self.gameView.frame.size.height - height;
    CGRect baseFrame = CGRectMake(xPos, yPos, width, height);
    UIImageView *cannonBase = [[UIImageView alloc] initWithFrame:baseFrame];
    [cannonBase setImage:[UIImage imageNamed:@"cannon-base"]];
    [self.gameView addSubview:cannonBase];
}

- (void)loadNextBubble{
    //Method to load bubble view for the next bubble to its position at the tip of the cannon
    taggedCannonBubble = [bubbleLoader getNextBubble];
    BubbleView *bubbleView = [taggedCannonBubble object];
    [bubbleView setCenter:[self getStartingBubbleCenter]];
    [self.gameView insertSubview:bubbleView belowSubview:cannon];
    bubbleInCannon = YES;
}

- (CGPoint)getStartingBubbleCenter{
    CGPoint base = [self getLaunchBaseCoordinates];
    CGPoint offset = getUnitPositionVector(base, cannon.center);
    CGFloat scalor = (CANNON_HEIGHT / 2 - self.defaultBubbleRadius);
    CGPoint scaledOffset = scaleVector(offset, scalor);
    return addVectors(scaledOffset, cannon.center);
}

- (BubbleEngine *)addMobileBubbleToEngine:(BubbleView *)bubble forType:(NSInteger)type{
    return [self.engine addMobileEngine:bubble withType:type];
}

- (void)controlCannonWithGesture:(UIGestureRecognizer *)recogniser showPath:(BOOL)show{
    CGPoint point = [recogniser locationInView:self.gameView];
    if(show == YES){
        CGPoint vector = getUnitPositionVector([self getLaunchBaseCoordinates], point);
        [self.plotter addRayFromPoint:[self getStartingBubbleCenter] withVector:vector toView:self.gameView];
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
    return CGPointMake(self.gameView.center.x, self.gameView.frame.size.height);
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
    void (^launchCode)(BOOL) = ^(BOOL complete){
        cannonLaunching = NO;
        CGPoint displacement = [self calculateLaunchDisplacementForInputPoint:point];
        [self launchBubbleandReloadCannonWithDisplacementVector:displacement];
    };
    [cannon startAnimatingWithCompletionBlock:launchCode];
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

- (void)launchBubbleandReloadCannonWithDisplacementVector:(CGPoint)vector{
    //Sets displacement vector for bubble in its corresponding BubbleEngine instance
    [self.engine addMobileEngine:[taggedCannonBubble object] withType:[[taggedCannonBubble tag] integerValue] andInitialUnitDisplacement:vector];
    [self executeBlock:^{[self loadNextBubble];}
            afterDelay:RELOAD_DELAY];
}

- (void)executeBlock:(void (^)(void))block afterDelay:(NSInteger)delay{
    dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(duration, dispatch_get_main_queue(), block);
}

- (void)removeLoadedBubble{
    if(taggedCannonBubble){
        [[taggedCannonBubble object] removeFromSuperview];
    }
    taggedCannonBubble = nil;
}

- (void)reload{
    [self removeLoadedBubble];
    [bubbleLoader reset];
}

@end
