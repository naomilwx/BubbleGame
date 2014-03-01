//
//  BubbleControllerManager.m
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "ControllerDataManager.h"
#import "BubbleController.h"
#import "GameCommon.h"

@implementation ControllerDataManager

@synthesize bubbleControllerManager;
@synthesize gameLoader;
@synthesize gridTemplate;
@synthesize bubbleGrid;
@synthesize gameArea;
@synthesize paletteImages;


- (id)initWithView:(UIView *)view andBubbleGrid:(UICollectionView *)grid andImageMappings:(NSDictionary *)mappings{
    if(self = [super init]){
        bubbleControllerManager = [[BubbleManager alloc] initWithNumofRows:NUM_OF_ROWS andColumns:NUM_CELLS_IN_ROW];
        gameArea = view;
        bubbleGrid = grid;
        gridTemplate = (BubbleGridLayout*)bubbleGrid.collectionViewLayout;
        paletteImages = mappings;
        gameLoader = [[GameLevelLoader alloc] init];
    }
    return self;

}

- (NSArray *)getAllObjects{
    return [self.bubbleControllerManager getAllObjects];
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

#pragma mark - game loader methods

- (BOOL)hasUnsavedBubbles{
    return [gameLoader hasUnsavedBubbles];
}

- (NSInteger)currentLevel{
    return [gameLoader currentLevel];
}

- (NSDictionary *)getAllBubbleModels{
    return [gameLoader getAllBubbleModels];
}

- (NSArray *)getAvailableLevels{
    return [gameLoader getAvailableLevels];
}

#pragma mark - functions to handle load/save/reset
- (void)resetLevel{
    [self removeAllBubbles];
    [self.bubbleControllerManager clearAll];
    [gameLoader resetLevel];
}

- (void)loadNewLevel{
    [self removeAllBubbles];
    [self.bubbleControllerManager clearAll];
    [gameLoader loadNewLevel];
}

- (void)loadBubblesFromModels:(NSDictionary *)bubbleModels{
    for(NSNumber *ID in bubbleModels){
        BubbleModel *model = [bubbleModels objectForKey:ID];
        NSIndexPath *gridIndex = [self.bubbleGrid indexPathForItemAtPoint:[model center]];
        [self addBubbleFromModel:model atIndex:gridIndex];
    }
}

- (void)loadGameLevelWithModels:(NSDictionary *)models{
    [self.bubbleControllerManager clearAll];
    [self loadBubblesFromModels:models];
}

- (void)loadLevelFromTempIfTempFileExists{
    NSDictionary *models = [self loadUnsavedStateFromTempFile];
    if(models != nil){
        [self loadGameLevelWithModels:models];
    }
}

- (void)saveUnsavedStateToTempFile{
    [gameLoader saveUnsavedStateToTempFile];
}

- (NSDictionary *)loadUnsavedStateFromTempFile{
    return [gameLoader loadUnsavedStateFromTempFile];
}

- (NSDictionary *)loadPreviousLevel{
    NSDictionary *levelModels = [gameLoader loadPreviousLevel];
    [self loadGameLevelWithModels:levelModels];
    return levelModels;
}

- (NSDictionary *)loadLevel:(NSInteger)level{
    NSDictionary *levelModels = [gameLoader loadLevel:level];
    [self loadGameLevelWithModels:levelModels];
    return levelModels;
}

- (NSInteger)saveLevel{
    return [gameLoader saveLevel];
}
@end
