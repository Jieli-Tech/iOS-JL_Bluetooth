//
//  JLDeviceConfig.h
//  JL_BLEKit
//
//  Created by EzioChan on 2022/10/31.
//  Copyright © 2022 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JL_BLEKit/JL_TypeEnum.h>

@class JL_ManagerM;
@class JLDeviceConfigBasic;
@class JLDeviceConfigModel;
@class JLDeviceConfigTws;
@class JLDeviceConfigDongle;
@class JLDeviceConfigSoundBox;
@class JLDeviceConfigAIGlasses;

NS_ASSUME_NONNULL_BEGIN
typedef void(^JLConfigRsp)(JL_CMDStatus status, uint8_t sn, JLDeviceConfigModel* __nullable config);

typedef void(^JLConfigTwsRsp)(JL_CMDStatus status, uint8_t sn, JLDeviceConfigTws* __nullable config);

typedef void(^JLConfigAuracastRsp)(JL_CMDStatus status, uint8_t sn, JLDeviceConfigDongle* __nullable config);

typedef void (^JLConfigSoundBoxRsp)(JL_CMDStatus status, uint8_t sn, JLDeviceConfigSoundBox* __nullable config);

typedef void (^JLConfigAIGlassesRsp)(JL_CMDStatus status, uint8_t sn, JLDeviceConfigAIGlasses* __nullable config);


/// 设备配置类型（与 JLDeviceConfigBasic.deviceType 取值一致）
typedef NS_ENUM(uint8_t, JLDeviceConfigType) {
    /// 手表
    JLDeviceConfigTypeWatch = 0,
    /// TWS 耳机
    JLDeviceConfigTypeTws = 1,
    /// SoundBox
    JLDeviceConfigTypeSoundBox = 2,
    /// Dongle
    JLDeviceConfigTypeDongle = 3,
    /// 智能眼镜
    JLDeviceConfigTypeAIGlasses = 4,
};



/// 固件设置配置回调协议
/// 遵循时，可通过父类的- (void)addDelegate:(id)delegate方法添加遵循
@protocol JLConfigPtl <NSObject>

@optional
/// 监听回调协议
/// - Parameter configModel: 固件设置配置回调
-(void)deviceConfigWith:(JLDeviceConfigModel *)configModel;

/// TWS监听回调协议
/// - Parameter configModel: 固件设置配置回调
-(void)deviceTwsConfigWith:(JLDeviceConfigTws *)configModel;

/// SoundBox监听回调协议
/// - Parameter configModel: 固件设置配置回调
-(void)deviceSoundBoxConfigWith:(JLDeviceConfigSoundBox *)configModel;

/// Dongle 监听回调协议
/// - Parameter configModel: 固件设置配置回调
-(void)deviceAuracastConfigWith:(JLDeviceConfigDongle *)configModel;

/// 智能眼镜监听回调协议
/// - Parameter configModel: 固件设置配置回调
-(void)deviceAIGlassesConfigWith:(JLDeviceConfigAIGlasses *)configModel;

@end

@interface JLDeviceConfig : NSObject


@property(nonatomic,weak) id<JLConfigPtl> _Nullable delegate;

+(instancetype)share;

/// 获取设备配置信息
-(void)deviceConfigGet:(JL_ManagerM *)manager;


/// 手表查询设备当前固件配置内容
/// - Parameters:
///   - manager: manager
///   - result: 回调功能配置内容
-(void)deviceGetConfig:(JL_ManagerM *)manager result:(JLConfigRsp)result;

/// 手表多设备管理时，可通过对应的设备UUID 获取相关的设备配置
/// - Parameter entity: 设备uuidStr
-(JLDeviceConfigModel *_Nullable)deviceGetConfigWithUUID:(NSString *)uuidStr;

/// TWS查询设备当前固件配置内容
/// - Parameters:
///   - manager: manager
///   - result: 回调功能配置内容
-(void)deviceTwsGetConfig:(JL_ManagerM *)manager result:(JLConfigTwsRsp)result;

/// Dongle 查询设备当前固件配置内容
/// - Parameters:
///   - manager: manager
///   - result: 回调功能配置内容
-(void)deviceDongleGetConfig:(JL_ManagerM *)manager result:(JLConfigAuracastRsp)result;

/// SoundBox 查询设备当前固件配置内容
/// - Parameters:
///   - manager: manager
///   - result: 回调功能配置内容
-(void)deviceSoundBoxGetConfig:(JL_ManagerM *)manager result:(JLConfigSoundBoxRsp)result;

/// 智能眼镜查询设备当前固件配置内容
/// - Parameters:
///   - manager: manager
///   - result: 回调功能配置内容
-(void)deviceAIGlassesGetConfig:(JL_ManagerM *)manager result:(JLConfigAIGlassesRsp)result;


/// Tws多设备管理时，可通过对应的设备UUID 获取相关的设备配置
/// - Parameter entity: 设备uuidStr
-(JLDeviceConfigTws *)deviceGetTwsConfigWithUUID:(NSString *)uuidStr;

/// Dongle 查询设备当前固件配置内容
/// - Parameters:
///     - uuidStr: 设备uuidStr
-(JLDeviceConfigDongle *)deviceGetAuracastConfigWithUUID:(NSString *)uuidStr;


/// SoundBox 多设备管理时，可通过对应的设备 UUID 获取相关的设备配置信息
/// - Parameter uuidStr: 设备 uuid
-(JLDeviceConfigSoundBox *)deviceGetSoundBoxConfigWithUUID:(NSString *)uuidStr;

/// 智能眼镜多设备管理时，可通过对应的设备 UUID 获取相关的设备配置信息
/// - Parameter uuidStr: 设备 uuid
-(JLDeviceConfigAIGlasses *_Nullable)deviceGetAIGlassesConfigWithUUID:(NSString *)uuidStr;


/// 指定设备、指定类型是否已成功获取到真实配置
/// 用于区分“真实配置”与“占位空对象/默认兜底”
/// - Parameters:
///   - uuidStr: 设备 uuid
///   - type: 设备配置类型
-(BOOL)deviceHasConfigWithUUID:(NSString *)uuidStr type:(JLDeviceConfigType)type;

/// 按设备类型获取已缓存的真实配置；未获取到返回 nil（不做默认兜底）
/// - Parameters:
///   - uuidStr: 设备 uuid
///   - type: 设备配置类型
-(JLDeviceConfigBasic *_Nullable)deviceGetConfigWithUUID:(NSString *)uuidStr type:(JLDeviceConfigType)type;


/// 私有测试接口请勿使用
/// - Parameter data: 用于测试数据
/// - Parameter st: 是否开启测试模式
-(void)pDeviceTest:(NSData *)data Status:(BOOL)st;

@end

NS_ASSUME_NONNULL_END
