//
//  BubbleGridLayout.m
//  ps03
//
//  Created by Naomi Leow on 30/1/14.
//
//

#import "BubbleGridLayout.h"

@implementation BubbleGridLayout

@synthesize layoutWidth;
@synthesize numOfCellsInRow;
@synthesize numOfRows;
@synthesize cellWidth;

- (id)initWithFrameWidth:(NSInteger)width andNumOfCellsInRow:(NSInteger)num andNumOfRows:(NSInteger)numRows{
    if(self = [super init]){
        layoutWidth = width;
        numOfCellsInRow = num;
        numOfRows = numRows;
        cellWidth = layoutWidth / numOfCellsInRow;
    }
    return self;
}

- (void)prepareLayout{
    [super prepareLayout];
}

- (CGSize)collectionViewContentSize{
    return self.collectionView.frame.size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray* attributes = [[NSMutableArray alloc] init];
    NSInteger numOfCells = (2 * self.numOfCellsInRow - 1) * (self.numOfRows / 2) + (self.numOfRows % 2) * self.numOfCellsInRow;
    for (NSInteger i = 0 ; i < numOfCells; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

- (NSInteger)defaultBubbleCellCount{
    return (2 * self.numOfCellsInRow - 1) * (self.numOfRows / 2) + (self.numOfRows % 2) * self.numOfCellsInRow;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes* attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
   
    attribute.size = CGSizeMake(self.cellWidth, self.cellWidth);
    attribute.center = [self getCenterForItemAtIndex:indexPath.item];
    
    return attribute;
}

- (NSInteger)getRowNumberFromIndex:(NSInteger)index{
    NSInteger rowNum = index / (2 * self.numOfCellsInRow - 1);
    NSInteger rowPos = index % (2 * self.numOfCellsInRow - 1);
    
    if(rowPos >= self.numOfCellsInRow){
        rowNum = rowNum * 2 + 1;
    }else{
        rowNum = rowNum * 2;
    }
    
    return rowNum;
}

- (NSInteger)getRowPositionFromIndex:(NSInteger)index{
    NSInteger rowPos = index % (2 * self.numOfCellsInRow - 1);
    
    if(rowPos >= self.numOfCellsInRow){
        rowPos = rowPos - self.numOfCellsInRow + 1; //odd rows start counting from 1
    }
    
    return rowPos;
}

- (CGPoint)getCenterForItemAtRow:(NSInteger)row andPosition:(NSInteger)pos{
    CGFloat centerY = row * self.cellWidth / 2 * sqrt(3) + self.cellWidth / 2;
    CGFloat centerX = self.cellWidth * pos;
    
    if(row % 2 == 0){
        centerX += self.cellWidth / 2;
    }
    
    return  CGPointMake(centerX, centerY);
}

- (CGPoint)getCenterForItemAtIndex:(NSInteger) index{
    NSInteger rowNum = [self getRowNumberFromIndex:index];
    NSInteger rowPos = [self getRowPositionFromIndex:index];
    return [self getCenterForItemAtRow:rowNum andPosition:rowPos];
}

@end
