//
//  GameBubbleBasic.m
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import "CustomDesignerController.h"
#import "BubbleController.h"
#import "GameCommon.h"

#define SAVE_SUCCESSFUL_MSG @"Game level saved successfully"
#define SAVE_UNSUCCESSFUL_MSG @"An error occurred while saving. Game level is not saved."
#define EXCLUDED_TYPES @[[NSNumber numberWithInt:ERASER]]
#define NUM_PALETTE_SELECTION 9

@interface CustomDesignerController ()

@property (nonatomic) GamePaletteSelection selectedType;

@end

@implementation CustomDesignerController

@synthesize orangeButton;
@synthesize blueButton;
@synthesize greenButton;
@synthesize redButton;
@synthesize eraser;
@synthesize selectedType;
@synthesize indestructibleButton;
@synthesize lightningButton;
@synthesize starButton;
@synthesize bombButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedType = NONE;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


- (void)loadPaletteImageMappings{
    if(!self.paletteImages){
        NSMutableDictionary *items = [[NSMutableDictionary alloc] initWithDictionary:[GameCommon allBubbleImageMappings]];
        [items setObject:[UIImage imageNamed:@"eraser-1"] forKey:[NSNumber numberWithInt:ERASER]];
        self.paletteImages = items;
    }
}

- (void)initialisePaletteButtonsMapping{
    if(!self.paletteButtons){
        self.paletteButtons = @{[NSNumber numberWithInt:ORANGE]: orangeButton,
                                [NSNumber numberWithInt:BLUE]: blueButton,
                                [NSNumber numberWithInt:GREEN]: greenButton,
                                [NSNumber numberWithInt:RED]: redButton,
                                [NSNumber numberWithInt:ERASER]: eraser,
                                [NSNumber numberWithInt:INDESTRUCTIBLE]:indestructibleButton,
                                [NSNumber numberWithInt:LIGHTNING]: lightningButton,
                                [NSNumber numberWithInt:STAR]: starButton,
                                [NSNumber numberWithInt:BOMB]: bombButton,
                                };
    }
}

- (void)loadPalette{
    [self initialisePaletteButtonsMapping];
    for(NSNumber *key in [self.paletteButtons keyEnumerator]){
        UIImageView *imageView = [self.paletteButtons objectForKey:key];
        [self loadImage:[self.paletteImages objectForKey:key] IntoUIView:imageView];
        imageView.userInteractionEnabled = YES;
    }
}

- (NSInteger)getNextBubbleTypeFromType:(NSInteger)type{
    NSInteger newType = (type + 1) % NUM_PALETTE_SELECTION;
    while([EXCLUDED_TYPES containsObject:[NSNumber numberWithInteger:newType]]){
        newType = (newType + 1) % NUM_PALETTE_SELECTION;
    }
    return newType;
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
    CGPoint point = [gesture locationInView:self.bubbleGrid];
    NSIndexPath *cellIndexPath = [self.bubbleGrid indexPathForItemAtPoint:point];
    if(cellIndexPath){
        [self.controllerDataManager removeBubbleAtCollectionViewIndex:cellIndexPath];
    }
}
- (void)gridPanHandler:(UIGestureRecognizer *)gesture{
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
        [self.controllerDataManager addOrModifyBubbleAtCollectionViewIndex:index withType:self.selectedType];
    }else{
        [self.controllerDataManager removeBubbleAtCollectionViewIndex:index];
    }
}

@end
