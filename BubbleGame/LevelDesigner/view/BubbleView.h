//
//  BubbleView.h
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import <UIKit/UIKit.h>
#import "PositionUpdateProtocol.h"

@interface BubbleView : UIImageView <PositionUpdateProtocol>

+ (id)createWithCenter:(CGPoint)center andWidth:(CGFloat)width andImage:(UIImage *)image;

- (void)loadImage:(UIImage *)image;
//Modifies: image attribute of BubbleView instance
//Requires: image not nil
//Effect: Changes display image of BubbleView instance

@end
