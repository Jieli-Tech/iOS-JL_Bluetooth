//
//  JLDevStatusManager.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/28.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class JLDevStatusManager;
@class JLAuracastTransmitter;

/// 设备状态查询可选类型
typedef NS_OPTIONS(NSUInteger, JLDevStatusOptions) {
    JLDevStatusOptionsBattery = 1 << 0,
    JLDevStatusOptionsVolume = 1 << 1,
    JLDevStatusOptionsCallStatus = 1 << 2,
    JLDevStatusOptionsWorkMode = 1 << 3,
    JLDevStatusOptionsUpdateStatus = 1 << 4,
    JLDevStatusOptionsIsLogined = 1 << 5,
    JLDevStatusOptionsAll = 0xFFFFFFFF
};

/// 设备通话状态
typedef NS_ENUM(NSUInteger, JLAuraCallStatus) {
    /// 无通话
    JLAuraCallStatusNone = 0,
    /// 通话中
    JLAuraCallStatusCalling = 1,
};

/// 设备升级状态
typedef NS_ENUM(NSUInteger, JLAuraUpdateStatus) {
    /// 不在更新状态
    JLAuraUpdateStatusNone = 0,
    /// 正在更新
    JLAuraUpdateStatusUpdating = 1,
    /// 强制更新
    JLAuraUpdateStatusForceUpdate = 2,
};

/// 请求设备状态管理回调
typedef void(^JLDevStatusManagerBlock)(JLDevStatusManager *devStatusManager, NSError * _Nullable error);

/// 设备状态管理协议
@protocol JLDevStatusManagerProtocol <NSObject>

/// 命令错误回复
/// - Parameters:
///   - devStatusManager: JLDevStatusManager
///   - error: 错误
-(void)jlDevStatusManager:(JLDevStatusManager *)devStatusManager error:(NSError *)error;

/// 电池电量
/// - Parameters:
///   - devStatusManager: JLDevStatusManager
///   - battery: 电池电量
///   - batteryIsCharging: 电池是否充电
-(void)jlDevStatusManager:(JLDevStatusManager *)devStatusManager battery:(NSInteger)battery batteryIsCharging:(BOOL)batteryIsCharging;

/// 音量信息
/// - Parameters:
///   - devStatusManager: JLDevStatusManager
///   - currentVolume: 音量
///   isSupportSync: 是否支持同步
-(void)jlDevStatusManager:(JLDevStatusManager *)devStatusManager volume:(uint8_t) currentVolume isSupportSync:(BOOL)isSupportSync;

/// 通话状态
/// - Parameters:
///   - devStatusManager: JLDevStatusManager
///   - callStatus: 通话状态
-(void)jlDevStatusManager:(JLDevStatusManager *)devStatusManager callStatus:(JLAuraCallStatus)callStatus;

/// 工作模式
/// - Parameters:
///   - devStatusManager: JLDevStatusManager
///   - workModel: 工作模式
-(void)jlDevStatusManager:(JLDevStatusManager *)devStatusManager workModel:(NSInteger)workModel;

/// 登录/认证状态
/// - Parameters:
///   - devStatusManager: JLDevStatusManager
///   - isLogined: 登录/认证状态
-(void)jlDevStatusManager:(JLDevStatusManager *)devStatusManager isLogined:(BOOL)isLogined;

/// 升级状态
/// - Parameters:
///   - devStatusManager: JLDevStatusManager
///   - updateStatus: 升级状态
-(void)jlDevStatusManager:(JLDevStatusManager *)devStatusManager updateStatus:(JLAuraUpdateStatus)updateStatus;


@end

/// 设备状态信息管理类
@interface JLDevStatusManager : NSObject

/// 电池电量
@property (nonatomic, assign) NSInteger battery;

/// 电池是否充电
@property (nonatomic, assign) BOOL batteryIsCharging;

/// 音量信息
@property (nonatomic, assign) uint8_t currentVolume;

/// 是否支持音量同步
@property (nonatomic, assign) BOOL isSupportVolumeSync;

/// 通话状态
@property (nonatomic, assign) JLAuraCallStatus callStatus;

/// 工作模式
@property (nonatomic, assign)NSInteger workModel;

/// 升级状态
@property (nonatomic, assign) JLAuraUpdateStatus updateStatus;

/// 登录/认证状态
@property (nonatomic, assign) BOOL isLogined;

/// 初始化
/// - Parameter protocol: 协议
-(instancetype)initWithProtocol:(id<JLDevStatusManagerProtocol>)protocol;


/// 获取设备的状态信息
/// - Parameters:
///   - type: 设备类型可选型
///   example : JLDevStatusOptionsBattery | JLDevStatusOptionsVolume
///   - transmitter: 发射器
///   - block: 获取设备状态信息回调
-(void)getDevStatus:(JLDevStatusOptions)type Transmitter:(JLAuracastTransmitter *)transmitter block:(JLDevStatusManagerBlock)block;



/// 释放
- (void)onRelease;


@end

NS_ASSUME_NONNULL_END
