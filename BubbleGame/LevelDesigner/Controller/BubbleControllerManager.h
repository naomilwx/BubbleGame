//
//  BubbleControllerManager.h
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BubbleManager.h"

@interface BubbleControllerManager : NSObject

@property (strong) BubbleManager *bubbleControllerManager;

- (id)getBubbleControllerAtCollectionViewIndex:(NSIndexPath *)index;

- (void)insertBubbleController:(id)controller AtCollectionViewIndex:(NSIndexPath *)index;

- (void)removeBubbleControllerAtCollectionViewIndex:(NSIndexPath *)index;

- (void)cycleBubbleAtCollectionViewIndex:(NSIndexPath *)index;

- (void)addBubbleAtCollectionViewIndex:(NSIndexPath *)index withType:(NSInteger)type;

- (void)removeBubbleAtCollectionViewIndex:(NSIndexPath *)index;

@end
