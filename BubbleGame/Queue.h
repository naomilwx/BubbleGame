//
//  Queue.h
//  CS3217-PS1
//
//  Copyright (c) 2013 NUS CS3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Queue : NSObject

/*! 
 Class method which creates and returns an empty queue.
 */
+ (Queue *)queue;

/*! 
 Adds an object to the tail of the queue.
 */
- (void)enqueue:(id)obj;

/*! 
 Removes and returns the object at the head of the queue.
 If the queue is empty, returns `nil'.
 */
- (id)dequeue;

/*! 
 Returns, but does not remove, the object at the head of the queue.
 If the queue is empty, returns `nil'.
 */
- (id)peek;

/*! 
 Returns the number of objects currently in the queue.
 */
- (NSUInteger)count;

- (BOOL)isEmpty;

/*!
 Returns array of all objects currently in the queue
 */
- (NSArray *)getAllObjects;

/*! 
 Removes all objects in the queue.
 */
- (void)removeAllObjects;

@end
