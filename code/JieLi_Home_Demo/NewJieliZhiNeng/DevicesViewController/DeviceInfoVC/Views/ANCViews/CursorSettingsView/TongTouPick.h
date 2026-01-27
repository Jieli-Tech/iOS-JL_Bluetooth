#import <UIKit/UIKit.h>

#define kTongTouPickGAP  40.0


NS_ASSUME_NONNULL_BEGIN


@class TongTouPick;
@protocol TongTouPickDelegate <NSObject>
@optional
-(void)onTongTouPick:(TongTouPick *)view didChangeLeft:(NSInteger)point;
-(void)onTongTouPick:(TongTouPick *)view didChangeRight:(NSInteger)point;
-(void)onTongTouPick:(TongTouPick *)view didSelect:(NSInteger)point;
@end

@interface TongTouPick : UIView
@property (nonatomic,assign) int type; // 0:修改左耳通透增益值 1：修改右耳通透增益值
@property(nonatomic,weak)id<TongTouPickDelegate>delegate;
@property(nonatomic,assign)int maxValue;
-(instancetype)initWithFrame:(CGRect)frame
                   StartPoint:(NSInteger)sPoint
                     EndPoint:(NSInteger)ePoint;

-(void)setTongTouPoint:(NSInteger)point;
@end

NS_ASSUME_NONNULL_END
