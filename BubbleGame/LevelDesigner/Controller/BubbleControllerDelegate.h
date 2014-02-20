//
//  BubbleControllerDelegate.h
//  ps03
//
//  Created by Naomi Leow on 4/2/14.
//
//

#import <Foundation/Foundation.h>
#import "BubbleGridLayout.h"

@protocol BubbleControllerDelegate <NSObject>

- (BubbleView *)createBubbleViewWithCenter:(CGPoint)center andWidth:(CGFloat)width andType:(NSInteger)type;

- (NSInteger)addBubbleModelWithType:(NSInteger)type andWidth:(CGFloat)width andCenter:(CGPoint)center;

- (void)modifyBubbleView:(BubbleView *)bubble toType:(NSInteger)type;
//Modifies: the BubbleView instance: bubble
//Effect: Image of bubble will be changed to the corresponding image for type
//Requires: type to be valid, bubble not nil

- (void)modifyBubbleModelTypeTo:(NSInteger)type forBubble:(NSInteger)ID;
//Modifies: BubbleModel for given ID
//Effect: bubbleType attribute in the associated BubbleModel will be modified.
//Requires: type and bubble to be valid

- (void)removeBubbleModel:(NSInteger)ID;

- (void)addToView:(UIView *)view;
//Effect: Adds given image to main view
//Requires: view not nil

- (BubbleGridLayout *)getGridLayout;

@end
