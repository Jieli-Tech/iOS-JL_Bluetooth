//
//  JLAuraDeviceType.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/23.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 设备类型
typedef NS_ENUM(NSUInteger, JLAuraDeviceMainType) {
    /// 耳机类型
    JLAuraDeviceMainTypeEarphone = 0x01,
    /// 音箱类型
    JLAuraDeviceMainTypeSpeaker = 0x02,
    /// 适配器类型
    JLAuraDeviceMainTypeAdapter = 0x03,
};

///  耳机类型子类型
typedef NS_ENUM(NSUInteger, JLAuraDeviceEarphoneType) {
    /// TWS 耳机
    JLAuraDeviceEarphoneTypeTws = 0x01,
    /// 头戴耳机
    JLAuraDeviceEarphoneTypeHead = 0x02,
    /// 颈挂耳机
    JLAuraDeviceEarphoneTypeNeckHanging = 0x03,
    /// 开放式耳机
    JLAuraDeviceEarphoneTypeOpenEnd = 0x04,
    /// 单耳耳机
    JLAuraDeviceEarphoneTypeSingle = 0x05,
    /// 助听器耳机
    JLAuraDeviceEarphoneTypeHearAid = 0x06
};

///  音箱类型子类型
typedef NS_ENUM(NSUInteger, JLAuraDeviceSpeakerType) {
    /// 单箱
    JLAuraDeviceSpeakerTypeSingle = 0x01,
    /// 双箱
    JLAuraDeviceSpeakerTypeDouble = 0x02,
};

///  适配器类型
typedef NS_ENUM(NSUInteger, JLAuraDeviceAdapterType) {
    /// USB适配器
    JLAuraDeviceAdapterTypeUSB = 0x01,
    /// 多源适配器
    JLAuraDeviceAdapterTypeMultiSource = 0x02,
    /// 接收器
    JLAuraDeviceAdapterTypeReceiver = 0x03,
};



NS_ASSUME_NONNULL_BEGIN

/// 设备类型
@interface JLAuraDeviceType : NSObject

/// 设备类型
@property (nonatomic, assign) JLAuraDeviceMainType type;

/// 子类型
@property (nonatomic, assign) uint8_t subType;

/// 耳机类型, 当设备类型的大类型为耳机类型时适用
@property (nonatomic, assign) JLAuraDeviceEarphoneType earphoneType;

/// 音箱类型, 当设备类型的大类型为音箱类型时适用
@property (nonatomic, assign) JLAuraDeviceSpeakerType speakerType;

/// 适配器类型, 当设备类型的大类型为适配器时适用
@property (nonatomic, assign) JLAuraDeviceAdapterType adapterType;

/// 获取设备类型
/// - Parameter data: 数据
+ (JLAuraDeviceType *)beModel:(NSData *)data;

/// 获取设备类型
/// - Parameter mdType: 设备类型
+ (JLAuraDeviceType *)beModelWith:(uint16_t)mdType;

/// 设备类型数字化
- (uint16_t)beUint16;



@end

NS_ASSUME_NONNULL_END
