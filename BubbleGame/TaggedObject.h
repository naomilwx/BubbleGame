//
//  TaggedObject.h
//  BubbleGame
//
//  Created by Naomi Leow on 22/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

/*!
 Object which stores mapping of a tag (which can be of any object type) to any object
 */
#import <Foundation/Foundation.h>

@interface TaggedObject : NSObject
@property (readonly) id tag;
@property (strong, readonly) id object;

+ (id)createWithTag:(id)tag AndObject:(id)obj;

- (id)initWithTag:(id)tag AndObject:(id)obj;

@end
