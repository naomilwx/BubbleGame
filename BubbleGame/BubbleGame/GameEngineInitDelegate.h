//
//  GameEngineInitDelegate.h
//  BubbleGame
//
//  Created by Naomi Leow on 24/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameEngineInitDelegate <NSObject>

- (void)loadDefaultBubbleMapping:(NSDictionary *)mapping;

- (void)loadColorBubbleMapping:(NSDictionary *)mapping;

- (void)setOriginalBubbleModels:(NSDictionary *)models;

@end
