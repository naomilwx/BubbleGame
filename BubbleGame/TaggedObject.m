//
//  TaggedObject.m
//  BubbleGame
//
//  Created by Naomi Leow on 22/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "TaggedObject.h"

@implementation TaggedObject

+ (id)createWithTag:(id)tag AndObject:(id)obj{
    return [[TaggedObject alloc] initWithTag:tag AndObject:obj];
}

- (id)initWithTag:(id)tag AndObject:(id)obj{
    if(self = [super init]){
        _tag = tag;
        _object = obj;
    }
    return self;
}

@end
