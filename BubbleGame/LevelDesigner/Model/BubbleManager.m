//
//  BubbleControllerManager.m
//  ps03
//
//  Created by Naomi Leow on 2/2/14.
//
//

#import "BubbleManager.h"
#import "GameCommon.h"

@implementation BubbleManager{
    NSMutableDictionary *createdHangingBubbles; //mapping of bubble grid position to bubble ID in model and representation in view
    NSInteger numRows;
    NSInteger numCols;

}

- (id)initWithNumofRows:(NSInteger)rows andColumns:(NSInteger)cols{
    if(self = [super init]){
        [self initialiseBubbleMappingWithRows:rows andColumns:cols];
        numRows = rows;
        numCols = cols;
    }
    return self;
}

- (void)initialiseBubbleMappingWithRows:(NSInteger)rowNum andColumns:(NSInteger)colNum{
    createdHangingBubbles = [[NSMutableDictionary alloc] init];
    for(int row = 0; row < rowNum; row++){
        int col;
        if((row % 2) == 0){
            col = 0;
        }else{
                col = 1;
        }
        NSMutableDictionary *bubbleRow = [[NSMutableDictionary alloc] init];
        while(col < colNum){
            [bubbleRow setObject:[NSNull null] forKey:[NSNumber numberWithInt:col]];
            col += 1;
        }
        [createdHangingBubbles setObject:bubbleRow forKey:[NSNumber numberWithInt:row]];
    }
}

- (void)insertObject:(id)controller AtRow:(NSInteger)row andPosition:(NSInteger)pos{
    NSMutableDictionary *bubbleRow = [createdHangingBubbles objectForKey:[NSNumber numberWithInteger:row]];
    [bubbleRow setObject:controller forKey:[NSNumber numberWithInteger:pos]];
}


- (void)removeObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos{
    NSMutableDictionary *bubbleRow = [createdHangingBubbles objectForKey:[NSNumber numberWithInteger:row]];
    [bubbleRow setObject:[NSNull null] forKey:[NSNumber numberWithInteger:pos]];
}

- (id)getObjectAtRow:(NSInteger)row andPosition:(NSInteger)pos{
    return [[createdHangingBubbles objectForKey:[NSNumber numberWithInteger:row]] objectForKey:[NSNumber numberWithInteger:pos]];
}

- (NSArray *)getAllObjects{
    NSMutableArray *retArr = [[NSMutableArray alloc] init];
    for(NSNumber *rowNum in createdHangingBubbles){
        NSMutableDictionary *row = [createdHangingBubbles objectForKey:rowNum];
        for(NSNumber *colNum in row){
            id bubbleController = [row objectForKey:colNum];
            if(![bubbleController isEqual:[NSNull null]]){
                [retArr addObject:bubbleController];
            }
        }
    }
    return retArr;
}

- (void)clearAll{
    createdHangingBubbles = nil;
    [self initialiseBubbleMappingWithRows:numRows andColumns:numCols];
}
@end
