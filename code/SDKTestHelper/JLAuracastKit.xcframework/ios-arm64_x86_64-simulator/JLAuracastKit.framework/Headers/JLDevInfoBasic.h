//
//  JLDevBasicInfo.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/23.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JLAuraDeviceType;

/// 设备基础信息
@interface JLDevInfoBasic : NSObject

/// 协议版本
@property (nonatomic, assign) NSInteger protocolVersion;

/// 测试版本
@property (nonatomic, assign) uint8_t testVersion;

/// 小版本号，修复问题或优化功能
@property (nonatomic, assign) uint8_t smallVersion;

/// 中版本号，增加功能
@property (nonatomic, assign) uint8_t middleVersion;

/// 大版本号，整体版本
@property (nonatomic, assign) uint8_t bigVersion;

/// 固件版本格式: 0.0.0_0
/// 大版本号.中版本号.小版本号_测试版本号
@property (nonatomic, strong) NSString *hardwareVersion;

/// 产品类型
@property (nonatomic, strong) JLAuraDeviceType *productType;

/// 芯片厂商ID
@property (nonatomic, assign) uint16_t vid;

/// 客户ID
@property (nonatomic, assign) uint16_t uid;

/// 产品ID
@property (nonatomic, assign) uint16_t pid;

/// 最大音量
@property (nonatomic, assign) uint8_t volumeMax;

/// 音量步进
@property (nonatomic, assign) uint8_t volumeStep;

/// 支持的工作模式掩码
@property (nonatomic, strong) NSData *workModeMask;

+(JLDevInfoBasic *)beModel:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
