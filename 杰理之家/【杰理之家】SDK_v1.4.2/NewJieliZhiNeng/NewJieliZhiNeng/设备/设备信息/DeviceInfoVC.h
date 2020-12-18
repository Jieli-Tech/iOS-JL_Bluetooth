//
//  DeviceInfoVC.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SqliteManager.h"

NS_ASSUME_NONNULL_BEGIN
@class NormalSettingObject;

@interface DeviceInfoVC : UIViewController
@property(nonatomic,strong)NSDictionary *headsetDict;
@property(nonatomic,strong)NSArray<NormalSettingObject *> *settingArray;

@end

NS_ASSUME_NONNULL_END
