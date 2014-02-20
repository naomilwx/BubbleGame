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

@synthesize gameBubble;
@synthesize bubbleModelID;
@synthesize bubbleView;

- (id)initWithMasterController:(UIViewController<BubbleControllerDelegate> *)controller{
    if(self = [super init]){
        gameBubble = controller;
        layoutManager = [controller getGridLayout];
    }
    return self;
}

- (void)addBubbleFromModel:(BubbleModel *)model{
    bubbleModel = model;
    self.bubbleModelID = [bubbleModel bubbleID];
    CGFloat width = [bubbleModel width];
    CGPoint center = [bubbleModel center];
    NSInteger type = [bubbleModel bubbleType];
    self.bubbleView = [self.gameBubble createBubbleViewWithCenter:center andWidth:width andType:type];
    [self.gameBubble addToView:self.bubbleView];
}

- (void)addBubbleAtCollectionViewIndex:(NSIndexPath *)index withType:(NSInteger)type{
    if(!self.bubbleView){ //ensure that associated bubble will only be created once
        CGFloat width = [layoutManager cellWidth];
        CGPoint center = [layoutManager getCenterForItemAtIndex:index.item];
    
        self.bubbleView = [self.gameBubble createBubbleViewWithCenter:center andWidth:width andType:type];
        [self.gameBubble addToView:self.bubbleView];
        self.bubbleModelID =  [self.gameBubble addBubbleModelWithType:type andWidth:width andCenter:center];
    }
}

- (void)modifyBubbletoType:(NSInteger)type{
    [self.gameBubble modifyBubbleView:bubbleView toType:type];
    [self.gameBubble modifyBubbleModelTypeTo:type forBubble:self.bubbleModelID];
}

- (void)removeBubble{
    [self.bubbleView removeFromSuperview];
    [self.gameBubble removeBubbleModel:self.bubbleModelID];
}

@end
