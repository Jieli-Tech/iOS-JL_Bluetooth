#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

#define kTongTou_GAP    35.0
#define kTongTou_SCALE  1.0

NS_ASSUME_NONNULL_BEGIN

@interface TongTouPlate : UIView
@property(nonatomic,assign)NSInteger startPiont;
@property(nonatomic,assign)long maxValue;

- (instancetype)initWithIndex:(NSInteger)index WithHeight:(float)height;
- (UIImage *)snapshotImage;

@end

NS_ASSUME_NONNULL_END
