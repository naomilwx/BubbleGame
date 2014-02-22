//
//  Queue.m
//  CS3217-PS1
//
//  Copyright (c) 2014 NUS CS3217. All rights reserved.
//

#import "Queue.h"

@implementation Queue{
    NSMutableArray *container;
}

+ (Queue *)queue {
    return [[Queue alloc] init];
}

- (id)init {
    if ((self = [super init])) {
        container = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)enqueue:(id)obj {
    [container addObject:obj];
}

- (id)dequeue {
    id obj = [self peek];
    if(obj != nil){
        [container removeObjectAtIndex:0];
        return obj;
    }else{
        return nil;
    }
}

- (id)peek {
    NSUInteger size = [container count];
    if(size > 0){
        id obj = [container objectAtIndex:0];
        return obj;
    }else{
        return nil;
    }
}

- (NSUInteger)count {
    return [container count];
}

- (BOOL)isEmpty{
    return ([self count] == 0);
}

- (NSArray *)getAllObjects{
    return [NSArray arrayWithArray:container];
}

- (void)removeAllObjects {
    [container removeAllObjects];
}

@end
