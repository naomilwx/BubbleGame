//
//  CannonController.h
//  BubbleGame
//
//  Created by Naomi Leow on 28/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BubbleLoader.h"
#import "MainEngineSpecialised.h"
#import "PathPlotter.h"

@interface CannonController : NSObject

@property (strong) NSDictionary *launchableBubbleMappings;
@property CGFloat defaultBubbleRadius;
@property (strong) MainEngine *engine;
@property (strong) BubbleLoader *bubbleLoader;
@property (strong) PathPlotter *plotter;
@property (strong) UIView *gameView;

- (id)initWithGameView:(UIView *)view andEngine:(MainEngine *)mainEngine andBubbleMappings:(NSDictionary *)mapping andBubbleRadius:(CGFloat)radius;

- (void)controlCannonWithGesture:(UIGestureRecognizer *)recogniser showPath:(BOOL)show;

@end
