//
//  BubbleView.m
//  ps03
//
//  Created by Naomi Leow on 31/1/14.
//
//

#import "BubbleView.h"
#import "CGPointExtension.h"

#define SCALE_FACTOR 0
#define POP_ANIMATION_DURATION 1
#define DROP_ANIMATION_DURATION 1

@implementation BubbleView

+ (id)createWithCenter:(CGPoint)center andWidth:(CGFloat)width andImage:(UIImage *)image{
    CGFloat xPos = center.x - width/2;
    CGFloat yPos = center.y - width/2;
    CGRect frame = CGRectMake(xPos, yPos, width, width);
    return [[BubbleView alloc] initWithFrame:frame andImage:image];
}

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image{
    if(self = [super initWithFrame:frame]){
        [self loadImage:image];
    }
    return self;
}

- (void)loadImage:(UIImage *)image{
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.clipsToBounds = YES;
    [self setImage:image];
}

- (CGPoint)moveByOffset:(CGPoint)offset{
    CGPoint point = addVectors(self.center, offset);
//    point.x = point.x + offset.x;
//    point.y = point.y + offset.y;
    [self setCenter:point];
    return self.center;
}

- (CGFloat)getRadius{
    return self.frame.size.width/2;
}

- (void)moveToPoint:(CGPoint)point{
    [self setCenter:point];
}

- (void)activateForDeletionWithAnimationType:(NSInteger)animationType{
    if(animationType == NO_ANIMATION){
        [self removeFromSuperview];
    }else if(animationType == POP_ANIMATION){
        [self performPopAnimation];
    }else{
        [self performDropAnimation];
    }
        
}

- (void)performPopAnimation{
    [UIView animateWithDuration:POP_ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGAffineTransform scaleTransform = CGAffineTransformScale(self.transform, SCALE_FACTOR, SCALE_FACTOR);
                         self.transform = scaleTransform;
                     }
                     completion:^(BOOL done){
                         [self removeFromSuperview];
                     }];
}

- (void)performDropAnimation{
    CGFloat dropDistance = MAX_DROP_DISTANCE - self.center.y - self.frame.size.width;
    [UIView animateWithDuration:DROP_ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGAffineTransform translate = CGAffineTransformTranslate(self.transform, 0, dropDistance);
                         self.transform = translate;
                     }
                     completion:^(BOOL done){
                         [self performPopAnimation];
                     }];
}

- (BOOL)isRendered{
    return [self superview] != nil;
}

@end
