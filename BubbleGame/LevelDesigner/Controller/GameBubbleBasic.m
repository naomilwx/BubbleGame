//
//  GameBubbleBasic.m
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import "GameBubbleBasic.h"
#import "Constants.h"
#import "BubbleController.h"

typedef enum GamePaletteBasic{
    NONE = INVALID,
    ORANGE = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3,
    ERASER = 4
} GamePaletteSelection; //Order must be as set in storyboard

#define SAVE_SUCCESSFUL_MSG @"Game level saved successfully"
#define SAVE_UNSUCCESSFUL_MSG @"An error occurred while saving. Game level is not saved."

@interface GameBubbleBasic ()

@property (nonatomic) GamePaletteSelection selectedType;

@end

@implementation GameBubbleBasic

@synthesize orangeButton;
@synthesize blueButton;
@synthesize greenButton;
@synthesize redButton;
@synthesize eraser;
@synthesize selectedType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedType = NONE;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)loadBubbleImages{
    if(!self.paletteImages){
        self.paletteImages = @{[NSNumber numberWithInt:ORANGE]: [UIImage imageNamed:@"bubble-orange"],
                               [NSNumber numberWithInt:BLUE]: [UIImage imageNamed:@"bubble-blue"],
                               [NSNumber numberWithInt:GREEN]: [UIImage imageNamed:@"bubble-green"],
                               [NSNumber numberWithInt:RED]: [UIImage imageNamed:@"bubble-red"],
                               [NSNumber numberWithInt:ERASER]: [UIImage imageNamed:@"eraser-1"]
                               };
    }
}

- (void)initialisePaletteButtonsArray{
    if(!self.paletteButtons){
        self.paletteButtons = @{[NSNumber numberWithInt:ORANGE]: orangeButton,
                                [NSNumber numberWithInt:BLUE]: blueButton,
                                [NSNumber numberWithInt:GREEN]: greenButton,
                                [NSNumber numberWithInt:RED]: redButton,
                                [NSNumber numberWithInt:ERASER]: eraser
                                };
    }
}

- (void)loadPalette{
    [self initialisePaletteButtonsArray];
    for(NSNumber *key in [self.paletteButtons keyEnumerator]){
        UIImageView *imageView = [self.paletteButtons objectForKey:key];
        [self loadImage:[self.paletteImages objectForKey:key] IntoUIView:imageView];
        imageView.userInteractionEnabled = YES;
    }
}

- (NSInteger)getNextBubbleTypeFromType:(NSInteger)type{
    return (type + 1)%NUM_OF_PALETTE_BUBBLE_TYPES;
}

#pragma mark - gesture handling
- (IBAction)paletteTap:(id)sender {
    UIImageView *tapped = (UIImageView *)[sender view];
    NSInteger viewTag = [tapped tag];
    
    if(self.selectedType != NONE && self.selectedType != viewTag){
        UIImageView *previousSelected = [self.paletteButtons objectForKey:[NSNumber numberWithInt:self.selectedType]];
        [self toggleUIViewTransparancy:previousSelected];
    }
    
    if(self.selectedType != viewTag){
        self.selectedType = viewTag;
    }else{
        self.selectedType = NONE;
    }
    
    [self toggleUIViewTransparancy:tapped];
}

- (void)tapHandler:(UIGestureRecognizer *)gesture{
    NSLog(@"tap");
    CGPoint point = [gesture locationInView:self.bubbleGrid];
    NSIndexPath *cellIndexPath = [self.bubbleGrid indexPathForItemAtPoint:point];
    if(cellIndexPath){
        if(self.selectedType != NONE){
            [self usePaletteItemAtCollectionViewIndex:cellIndexPath];
        }else{
            [self cycleBubbleAtCollectionViewIndex:cellIndexPath];
        }
    }
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture{
    NSLog(@"press");
    CGPoint point = [gesture locationInView:self.bubbleGrid];
    NSIndexPath *cellIndexPath = [self.bubbleGrid indexPathForItemAtPoint:point];
    if(cellIndexPath){
        [self removeBubbleAtCollectionViewIndex:cellIndexPath];
    }
}
- (void)gridPanHandler:(UIGestureRecognizer *)gesture{
    NSLog(@"pan");
    if(self.selectedType != NONE){
        NSInteger numOfTouches = [gesture numberOfTouches];
        for(int i = 0; i < numOfTouches; i++){
            CGPoint point = [gesture locationOfTouch:i inView:self.bubbleGrid];
            NSIndexPath *cellIndexPath = [self.bubbleGrid indexPathForItemAtPoint:point];
            if(cellIndexPath){
                [self usePaletteItemAtCollectionViewIndex:cellIndexPath];
            }
        }
    }
}

- (void)usePaletteItemAtCollectionViewIndex:(NSIndexPath *)index{
    //Requires: index path not nil
    if(self.selectedType != ERASER){
        [self addOrModifyBubbleAtCollectionViewIndex:index];
    }else{
        [self removeBubbleAtCollectionViewIndex:index];
    }
}

#pragma mark - operations on bubble in bubble grid for level creator

- (void)addOrModifyBubbleAtCollectionViewIndex:(NSIndexPath *)index{
    //Requires: index path not nil
    BubbleController *bubble = [self getBubbleControllerAtCollectionViewIndex:index];
    if([bubble isEqual:[NSNull null]]){
        [self addBubbleAtCollectionViewIndex:index withType:self.selectedType];
    }else{
        [bubble modifyBubbletoType:self.selectedType];
    }
}

@end
