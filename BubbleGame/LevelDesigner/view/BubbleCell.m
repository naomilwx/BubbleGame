//
//  BubbleCell.m
//  ps03
//
//  Created by Naomi Leow on 30/1/14.
//
//

#import "BubbleCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation BubbleCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initialiseBubbleCellWithBorder:YES];
    }
    return self;
}

- (void)initialiseBubbleCellWithBorder:(BOOL)showBorder{
    [self setBackgroundColor:[[UIColor alloc] initWithWhite:0.5f alpha:0.5f]];
    [self.layer setCornerRadius:self.frame.size.width/2];
    if(showBorder){
        [self showBorder];
    }
}

- (void)hideBorder{
    [self.layer setBorderColor:[UIColor clearColor].CGColor];
}

- (void)showBorder{
    [self.layer setBorderWidth:2.0f];
    [self.layer setBorderColor:[UIColor blackColor].CGColor];
}
@end
