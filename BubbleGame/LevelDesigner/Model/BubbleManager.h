//
//  BubbleControllerManager.h
//  ps03
//
//  Created by Naomi Leow on 2/2/14.
//
//

#import <Foundation/Foundation.h>

@interface BubbleManager : NSObject

- (id)initWithNumofRows:(NSInteger)rows andColumns:(NSInteger)cols;

- (id)getObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos;

- (void)insertObject:(id)controller AtRow:(NSInteger)row andPosition:(NSInteger)pos;

- (void)removeObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos;

- (NSArray *)getAllObjects;

- (void)clearAll;
//Removes all BubbleController instances stored in the data structure

@end
