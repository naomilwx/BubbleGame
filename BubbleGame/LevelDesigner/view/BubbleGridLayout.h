//
//  BubblePaletteLayout.h
//  ps03
//
//  Created by Naomi Leow on 30/1/14.
//
//

#import <UIKit/UIKit.h>

@interface BubbleGridLayout : UICollectionViewLayout

@property (nonatomic) CGFloat layoutWidth;
@property (nonatomic) NSInteger numOfCellsInRow;
@property (nonatomic) NSInteger numOfRows;
@property (nonatomic) CGFloat cellWidth;

- (id)initWithFrameWidth:(NSInteger)width andNumOfCellsInRow:(NSInteger)num andNumOfRows:(NSInteger)numRows;

//Methods overriden from UICollectionViewLayout
- (void)prepareLayout;

- (CGSize)collectionViewContentSize;

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
//

- (NSInteger)defaultBubbleCellCount;
//Get default number of bubbles in bubble grid

- (CGPoint)getCenterForItemAtRow:(NSInteger)row andPosition:(NSInteger)pos;
//Get center of bubble for bubble at given row and position in the bubble grid

- (NSInteger)getRowNumberFromIndex:(NSInteger)index;
//Given NSIndexPath item number, returns the row number of the corresponding item in the bubble grid

- (NSInteger)getRowPositionFromIndex:(NSInteger)index;
//Given NSIndexPath item number, returns the row position of the corresponding item in the bubble grid

- (CGPoint)getCenterForItemAtIndex:(NSInteger) index;
//Given NSIndexPath item number, center point of the corresponding BubbleCell in the bubble grid

@end
