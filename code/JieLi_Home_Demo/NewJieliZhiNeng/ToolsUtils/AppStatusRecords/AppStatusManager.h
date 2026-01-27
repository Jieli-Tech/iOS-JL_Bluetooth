//
//  AppStatusManager.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/8/1.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppStatusManager : NSObject

/// APP正在OTA升级
@property(nonatomic,assign)BOOL isOTAIng;
/// 是否支持Auracast
@property(nonatomic,assign)BOOL isSupportAuracast;
/// 是否支持Auracast 接收器
@property(nonatomic,assign)BOOL isAuracastReceiver;
/// 是否支持Auracast 发射器
@property(nonatomic,assign)BOOL isAuracastLancer;

+(instancetype)shareInstance;
@end

NS_ASSUME_NONNULL_END
