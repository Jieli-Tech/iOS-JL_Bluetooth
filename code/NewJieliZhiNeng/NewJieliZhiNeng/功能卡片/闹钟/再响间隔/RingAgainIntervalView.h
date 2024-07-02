//
//  RingAgainIntervalView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RingAgainIntervalDelegate <NSObject>
@optional
-(void)onRingAgainIntervalCancel;
-(void)onRingAgainIntervalSure:(int) interval WithCount:(int) count WithIndex:(int) index;
@end

@interface RingAgainIntervalView : UIView

@property(nonatomic,strong)JLModel_AlarmSetting *rtcSettingModel;
@property (weak, nonatomic) id <RingAgainIntervalDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
