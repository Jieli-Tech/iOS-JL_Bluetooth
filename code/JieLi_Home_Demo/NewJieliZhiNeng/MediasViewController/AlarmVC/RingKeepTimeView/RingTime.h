//
//  RingTime.h
//  JieliJianKang
//
//  Created by 李放 on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RingTimeDelegate <NSObject>
@optional
-(void)onRingTimeCancel;
-(void)onRingTimeSure:(int) time WithIndex:(int) index;
@end

@interface RingTime : UIView

@property(nonatomic,strong)JLModel_AlarmSetting *rtcSettingModel;
@property (weak, nonatomic) id <RingTimeDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
