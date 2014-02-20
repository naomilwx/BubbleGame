//
//  BubbleController.h
//  ps03
//
//  Created by Naomi Leow on 3/2/14.
//
//

#import <Foundation/Foundation.h>
#import "BubbleModel.h"
#import "BubbleView.h"
#import "BubbleControllerDelegate.h"

@interface BubbleController : NSObject

@property (weak, readonly) UIViewController<BubbleControllerDelegate>* gameBubble;

@property NSInteger bubbleModelID;

@property (strong) BubbleView *bubbleView;

- (id)initWithMasterController:(UIViewController<BubbleControllerDelegate> *)controller;

- (void)addBubbleFromModel:(BubbleModel *)model;

- (void)addBubbleAtCollectionViewIndex:(NSIndexPath *)index withType:(NSInteger)type;

- (void)removeBubble;

- (void)modifyBubbletoType:(NSInteger)type;

@end
