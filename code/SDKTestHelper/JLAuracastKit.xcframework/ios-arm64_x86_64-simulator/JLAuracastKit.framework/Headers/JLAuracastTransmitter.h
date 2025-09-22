//
//  JLIAuracastTransmitter.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/9/4.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JLGattProxyHandler;
@class JLDevStatusManager;
@class JLDevInfoManager;
@class JLGattModel;
@class JLAuracastTransmitter;

typedef void(^JLAuracastTransmitterInitBlock)(BOOL success,NSError *_Nullable error);

/// 设备通讯的上下文基类
/// 所有其他的命令通讯都依赖此类
/// 使用 SDK 时必须初始化此类作为基本的上下文通讯参数
@interface JLAuracastTransmitter : NSObject

/// 设备基础信息
@property(nonatomic,strong)JLDevInfoManager *devInfoSystem;

/// 设备状态信息
@property(nonatomic,strong)JLDevStatusManager *devInfoStatus;

/// GATT Proxy Handler
@property(nonatomic,strong,readonly)JLGattProxyHandler *handler;

/// cmdHandler
@property(nonatomic,readonly)id cmdHandler;

/// 禁用原有初始化方法
-(instancetype)init __attribute__((unavailable("Use initWithGattProxyHandler:withBlock: instead")));

/// 初始化
/// - Parameters:
///   - handler: GATT Proxy Handler
///   - block: 初始化结果
-(instancetype)initWithGattProxyHandler:(JLGattProxyHandler *)handler withBlock:(JLAuracastTransmitterInitBlock)block;


/// 设置命令重发次数
/// - Parameters:
///   - count: 重发次数 默认再发1次
///   timeOutMax: 超时时间 默认 3 s
- (void)setCommandMaxResendCount:(NSInteger)count timeOutMax:(NSInteger)timeOutMax;

/// 释放
- (void) onRelease;

@end

NS_ASSUME_NONNULL_END
