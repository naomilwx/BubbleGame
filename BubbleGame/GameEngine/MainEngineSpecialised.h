//
//  MainEngineSpecialised.h
//  BubbleGame
//
//  Created by Naomi Leow on 26/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//
// Child of MainEngine with specialised methods to handle the behaviour of special bubbles
#import "MainEngine.h"

@interface MainEngineSpecialised : MainEngine

- (NSArray *)getAllNeighbouringSpecialBubbles:(BubbleEngine *)bubbleEngine;

@end
