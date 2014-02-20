//
//  GridTemplateDelegate.h
//  ps04
//
//  Created by Naomi Leow on 15/2/14.
//
//

#import <Foundation/Foundation.h>

@protocol GridTemplateDelegate <NSObject>

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)center;

- (CGPoint)getCenterForItemAtIndexPath:(NSIndexPath *)path;

- (NSInteger)getRowNumberFromIndexPath:(NSIndexPath *)path;

- (NSInteger) getRowPositionFromIndexPath:(NSIndexPath *)path;

@end
