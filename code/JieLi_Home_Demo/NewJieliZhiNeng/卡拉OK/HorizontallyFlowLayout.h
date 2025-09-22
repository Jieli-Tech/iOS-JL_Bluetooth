#import <UIKit/UIKit.h>

@interface HorizontallyFlowLayout : UICollectionViewFlowLayout

- (instancetype)initWithItemCountPerRow:(NSInteger)itemCountPerRow
                            maxRowCount:(NSInteger)maxRowCount itemCountTotal:(NSInteger) itemCountTotal;

@end
