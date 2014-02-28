//
//  BubbleControllerManager.h
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BubbleManager.h"
#import "GameLevelLoader.h"
#import "BubbleGridLayout.h"
#import "BubbleControllerDelegate.h"

@interface BubbleControllerManager : NSObject <BubbleControllerDelegate>

@property (strong) BubbleManager *bubbleControllerManager;
@property (strong) GameLevelLoader *gameLoader;
@property (strong) BubbleGridLayout *gridTemplate;
@property (strong) UIView *gameArea;
@property (strong, nonatomic) NSDictionary *paletteImages;

- (id)initWithView:(UIView *)view andDataModel:(GameLevelLoader *)model andGridTemplate:(BubbleGridLayout *)template;

- (id)getBubbleControllerAtCollectionViewIndex:(NSIndexPath *)index;

- (void)insertBubbleController:(id)controller AtCollectionViewIndex:(NSIndexPath *)index;

- (void)removeBubbleControllerAtCollectionViewIndex:(NSIndexPath *)index;

- (void)addBubbleAtCollectionViewIndex:(NSIndexPath *)index withType:(NSInteger)type;

- (void)removeBubbleAtCollectionViewIndex:(NSIndexPath *)index;

@end
