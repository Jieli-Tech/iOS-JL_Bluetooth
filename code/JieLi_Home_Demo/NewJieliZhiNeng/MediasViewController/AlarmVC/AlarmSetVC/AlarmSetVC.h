//
//  AlarmSetVC.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/29.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlarmSetVC : UIViewController
@property(nonatomic,assign)BOOL createType;//YES:新建 NO：编辑
@property(nonatomic,strong)JLModel_AlarmSetting *rtcSettingModel;
@property(nonatomic,strong)JLModel_RTC *rtcmodel;
@property(nonatomic,assign)uint8_t alarmIndex;
@end

NS_ASSUME_NONNULL_END
