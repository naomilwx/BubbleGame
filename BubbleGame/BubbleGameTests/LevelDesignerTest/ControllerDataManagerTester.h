//
//  GameBubbleBasicTester.h
//  ps03
//
//  Created by Naomi Leow on 5/2/14.
//
//

#import "CustomDesignerController.h"

@interface ControllerDataManagerTester : ControllerDataManager

- (BOOL)hasView:(UIView *)view;
- (NSInteger)numViewsInView;
- (NSInteger)getBubbleType:(NSInteger)bubbleID;
- (BOOL)hasBubbleID:(NSInteger)bubbleID;
@end
