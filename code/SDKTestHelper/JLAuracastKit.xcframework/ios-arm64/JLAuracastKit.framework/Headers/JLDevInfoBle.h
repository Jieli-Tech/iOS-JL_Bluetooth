//
//  JLDevInfoBle.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/23.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 设备蓝牙信息
@interface JLDevInfoBle : NSObject

/// 是否支持BLE
@property (nonatomic, assign)BOOL  isSupportBle;

/// 是否支持CTKD
/// 一键连接功能
@property (nonatomic, assign)BOOL  isSupportCTKD;

/// 是否支持LEAudio
@property (nonatomic, assign)BOOL  isSupportLEAudio;

/// 是否支持Auracast
@property (nonatomic, assign)BOOL  isSupportAuracast;

/// 是否支持BR/EDR
@property (nonatomic, assign)BOOL  isSupportBrEdr;

/// 是否支持SPP优先
@property (nonatomic, assign)BOOL  isSppPriority;

/// ble 是否已连接
@property (nonatomic, assign)BOOL  bleConnected;

/// edr 是否已连接
@property (nonatomic, assign)BOOL  edrConnected;

/// ble 地址
@property (nonatomic, strong)NSData   *bleAddrData;

/// ble 地址 字符串
@property (nonatomic, strong)NSString *bleAddr;

/// edr 地址
@property (nonatomic, strong)NSData   *edrAddrData;

/// edr 地址字符串
@property (nonatomic, strong)NSString *edrAddr;

+(JLDevInfoBle *)beModel:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
