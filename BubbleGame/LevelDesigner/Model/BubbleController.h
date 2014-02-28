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
#import "BubbleGridLayout.h"

@interface BubbleController : NSObject

@property (weak, readonly) id<BubbleControllerDelegate> mainController;

@property NSInteger bubbleModelID;

@property (strong) BubbleView *bubbleView;

- (id)initWithMasterController:(id<BubbleControllerDelegate>)controller andGridTemplate:(BubbleGridLayout *)layoutTemplate;

- (void)addBubbleFromModel:(BubbleModel *)model;

- (void)addBubbleAtCollectionViewIndex:(NSIndexPath *)index withType:(NSInteger)type;

- (void)removeBubble;

- (void)modifyBubbletoType:(NSInteger)type;

@end
