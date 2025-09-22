//
//  JLDevInfoManager.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/23.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JLDevInfoBasic;
@class JLDevInfoBle;
@class JLDevInfoExtend;
@class JLDevInfoManager;
@class JLAuracastTransmitter;

typedef NS_ENUM(NSUInteger, JLDevInfoType) {
    JLDevInfoTypeBasic = 0x01,
    JLDevInfoTypeBle = 0x02,
    JLDevInfoTypeExtend = 0x03,
};


/// 设备基础信息回调
@protocol JLDevInfoManagerProtocol <NSObject>

/// 读取设备基础信息
/// - Parameter infoModel: 设备基础信息
-(void)jlReadDeviceInfoBasic:(JLDevInfoBasic *)infoModel;

/// 读取设备蓝牙信息
/// - Parameter infoModel: 设备蓝牙信息
-(void)jlReadDeviceInfoBle:(JLDevInfoBle *)infoModel;

/// 读取设备扩展信息
/// - Parameter infoModel: 设备扩展信息
-(void)jlReadDeviceInfoExtend:(JLDevInfoExtend *)infoModel;

/// 读取设备失败
/// - Parameters:
///   - type: 设备类型
///   - error: 错误
-(void)jlReadDeviceInfoFailed:(JLDevInfoType)type Error:(NSError *)error;

@end

typedef void(^JLDevInfoCallBack)(JLDevInfoManager *manager,JLDevInfoType type, NSError *_Nullable err);

/// 设备基础信息
@interface JLDevInfoManager : NSObject

/// 设备基础信息
@property (nonatomic,strong)JLDevInfoBasic *infoBasic;

/// 设备蓝牙信息
@property (nonatomic,strong)JLDevInfoBle *infoBle;

/// 设备扩展信息
@property (nonatomic,strong)JLDevInfoExtend *infoExtend;


/// 初始化
/// - Parameter ptl: 回调协议
-(instancetype)initWith:(id<JLDevInfoManagerProtocol>)ptl;


/// 读取设备信息
/// - Parameter type: 设备类型
/// - Parameter transmitter: 读取设备
/// - Parameter callBack: 回调
-(void)jlReadDeviceInfo:(JLDevInfoType)type Transmitter:(JLAuracastTransmitter *)transmitter callBack:(JLDevInfoCallBack)callBack;


/// 释放
-(void)onRelease;

@end

NS_ASSUME_NONNULL_END
