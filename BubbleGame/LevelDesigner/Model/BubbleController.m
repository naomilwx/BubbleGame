//
//  BubbleController.m
//  ps03
//
//  Created by Naomi Leow on 3/2/14.
//
//

#import "BubbleController.h"
#import "BubbleGridLayout.h"
#import "BubbleManager.h"

@implementation BubbleController {
    BubbleModel *bubbleModel;
    BubbleGridLayout *layoutManager;
}

@synthesize mainController;
@synthesize bubbleModelID;
@synthesize bubbleView;

- (id)initWithMasterController:(id<BubbleControllerDelegate>)controller andGridTemplate:(BubbleGridLayout *)layoutTemplate{
    if(self = [super init]){
        mainController = controller;
        layoutManager = layoutTemplate;
    }
    return self;
}

- (void)addBubbleFromModel:(BubbleModel *)model{
    bubbleModel = model;
    self.bubbleModelID = [bubbleModel bubbleID];
    CGFloat width = [bubbleModel width];
    CGPoint center = [bubbleModel center];
    NSInteger type = [bubbleModel bubbleType];
    self.bubbleView = [self.mainController createBubbleViewWithCenter:center andWidth:width andType:type];
    [self.mainController addToView:self.bubbleView];
}

- (void)addBubbleAtCollectionViewIndex:(NSIndexPath *)index withType:(NSInteger)type{
    if(!self.bubbleView){ //ensure that associated bubble will only be created once
        CGFloat width = [layoutManager cellWidth];
        CGPoint center = [layoutManager getCenterForItemAtIndex:index.item];
    
        self.bubbleView = [self.mainController createBubbleViewWithCenter:center andWidth:width andType:type];
        [self.mainController addToView:self.bubbleView];
        self.bubbleModelID =  [self.mainController addBubbleModelWithType:type andWidth:width andCenter:center];
    }
}

- (void)modifyBubbletoType:(NSInteger)type{
    [self.mainController modifyBubbleView:bubbleView toType:type];
    [self.mainController modifyBubbleModelTypeTo:type forBubble:self.bubbleModelID];
}

- (void)removeBubble{
    [self.bubbleView removeFromSuperview];
    [self.mainController removeBubbleModel:self.bubbleModelID];
}

@end
