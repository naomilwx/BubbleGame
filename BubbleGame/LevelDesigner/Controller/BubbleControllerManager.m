////
////  BubbleControllerManager.m
////  BubbleGame
////
////  Created by Naomi Leow on 28/2/14.
////  Copyright (c) 2014 nus.cs3217. All rights reserved.
////
//
//#import "BubbleControllerManager.h"
//
//#import "GameLogic.h"
//
//@implementation BubbleControllerManager
//
//@synthesize bubbleControllerManager;
//
//- (id)init{
//    if(self = [super init]){
//        bubbleControllerManager = [[BubbleManager alloc] initWithNumofRows:NUM_OF_ROWS andColumns:NUM_CELLS_IN_ROW];
//    }
//    return self;
//}
//
//#pragma mark - Delegate Methods for BubbleController
//- (void)addToView:(UIView *)view{
//    [self.gameArea addSubview:view];
//}
//
//- (BubbleGridLayout *)getGridLayout{
//    return (BubbleGridLayout *)self.bubbleGrid.collectionViewLayout;
//}
//
//- (NSInteger)addBubbleModelWithType:(NSInteger)type andWidth:(CGFloat)width andCenter:(CGPoint)center{
//    return [self.gameLoader addBubbleWithType:type andWidth:width andCenter:center];
//}
//
//- (void)modifyBubbleModelTypeTo:(NSInteger)type forBubble:(NSInteger)ID{
//    [self.gameLoader modifyBubbleTypeTo:type forBubble:ID];
//}
//
//- (void)removeBubbleModel:(NSInteger)ID{
//    [self.gameLoader removeBubble:ID];
//}
//
//- (void)modifyBubbleView:(BubbleView *)bubble toType:(NSInteger)type{
//    UIImage *image = [self.paletteImages objectForKey:[NSNumber numberWithInteger:type]];
//    [bubble loadImage:image];
//}
//
//- (BubbleView *)createBubbleViewWithCenter:(CGPoint)center andWidth:(CGFloat)width andType:(NSInteger)type{
//    UIImage *image = [self.paletteImages objectForKey:[NSNumber numberWithInteger:type]];
//    return [BubbleView createWithCenter:center andWidth:width andImage:image];
//}
//
//#pragma mark - operations on bubble in bubble grid for level creator
//- (void)cycleBubbleAtCollectionViewIndex:(NSIndexPath *)index{
//    BubbleController *bubble = [self getBubbleControllerAtCollectionViewIndex:index];
//    if(![bubble isEqual:[NSNull null]]){
//        NSInteger bubbleID = [bubble bubbleModelID];
//        NSInteger bubbleType = [self.gameLoader getBubbleType:bubbleID];
//        bubbleType = [self getNextBubbleTypeFromType:bubbleType];
//        [bubble modifyBubbletoType:bubbleType];
//    }
//}
//
//- (void)addBubbleAtCollectionViewIndex:(NSIndexPath *)index withType:(NSInteger)type{
//    BubbleController *bubble = [[BubbleController alloc] initWithMasterController:self];
//    [bubble addBubbleAtCollectionViewIndex:index withType:type];
//    [self insertBubbleController:bubble AtCollectionViewIndex:index];
//}
//
//- (void)removeBubbleAtCollectionViewIndex:(NSIndexPath *)index{
//    BubbleController *bubble = [self getBubbleControllerAtCollectionViewIndex:index];
//    if(![bubble isEqual:[NSNull null]]){
//        [bubble removeBubble];
//        [self removeBubbleControllerAtCollectionViewIndex:index];
//    }
//}
//
//#pragma mark - update datastructure which holds the individual bubble controllers
//- (BubbleController *)getBubbleControllerAtCollectionViewIndex:(NSIndexPath *)index{
//    BubbleGridLayout *layoutManager = (BubbleGridLayout *)self.bubbleGrid.collectionViewLayout;
//    NSInteger rowInGrid = [layoutManager getRowNumberFromIndex:index.item];
//    NSInteger rowPosInGrid = [layoutManager getRowPositionFromIndex:index.item];
//    return [self.bubbleControllerManager getObjectAtRow:rowInGrid andPosition:rowPosInGrid];
//}
//
//- (void)insertBubbleController:(BubbleController *)controller AtCollectionViewIndex:(NSIndexPath *)index{
//    BubbleGridLayout *layoutManager = (BubbleGridLayout *)self.bubbleGrid.collectionViewLayout;
//    NSInteger rowInGrid = [layoutManager getRowNumberFromIndex:index.item];
//    NSInteger rowPosInGrid = [layoutManager getRowPositionFromIndex:index.item];
//    [self.bubbleControllerManager insertObject:controller AtRow:rowInGrid andPosition:rowPosInGrid];
//}
//
//- (void)removeBubbleControllerAtCollectionViewIndex:(NSIndexPath *)index{
//    BubbleGridLayout *layoutManager = (BubbleGridLayout *)self.bubbleGrid.collectionViewLayout;
//    NSInteger rowInGrid = [layoutManager getRowNumberFromIndex:index.item];
//    NSInteger rowPosInGrid = [layoutManager getRowPositionFromIndex:index.item];
//    [self.bubbleControllerManager removeObjectAtRow:rowInGrid andPosition:rowPosInGrid];
//    
//}
//@end
