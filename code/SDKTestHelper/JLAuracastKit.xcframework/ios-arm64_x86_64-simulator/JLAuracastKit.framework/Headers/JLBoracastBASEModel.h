//
//  JLBoracastBASEModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/27.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@class JLCodeSpecificConfigModel;
@class JLAuracastMetaModel;


/// 编解码器格式
typedef NS_ENUM(NSUInteger, JLCodecFormatHCIType) {
    /// μ-law log
    JLCodecFormatHCITypeuLaw = 0x00,
    /// A-law log
    JLCodecFormatHCITypeALaw = 0x01,
    /// CVSD
    JLCodecFormatHCITypeCVSD = 0x02,
    /// Transparent
    JLCodecFormatHCITypeTransparent = 0x03,
    /// Linear PCM
    JLCodecFormatHCITypeLinearPCM = 0x04,
    /// mSBC
    JLCodecFormatHCITypemSBC = 0x05,
    /// LC3
    JLCodecFormatHCITypeLC3 = 0x06,
    /// G.729A
    JLCodecFormatHCITypeG729A = 0x07,
    /// Vendor Specific
    JLCodecFormatHCITypeVendorSpecific = 0xFF
};


/// boracast codec info
/// 编解码器规格配置
@interface JLBoracastCodecInfoModel : NSObject

/// 编解码器配置个数
/// Codec Index
@property (nonatomic, assign) NSInteger numBis;

/// 编解码器ID
/// Codec ID
@property (nonatomic, assign) JLCodecFormatHCIType codecId;

/// 编解码器规格配置
/// Codec Specific Configuration
@property (nonatomic, strong) JLCodeSpecificConfigModel *codecConfigModel;

/// 节目元数据
/// Meta Data
@property (nonatomic, strong) JLAuracastMetaModel *metaModel;


/// 编解码器规格配置
/// Codec Specific Config
@property (nonatomic, strong) NSArray <JLCodeSpecificConfigModel *> *codecSpecificConfigs;




@end


/// boracast base info
/// BASE Broadcast Audio Source Endpoint
/// 基础广播音频源端点
@interface JLBoracastBASEModel : NSObject

/// Presentation Delay (μs)
/// 渲染延迟（微秒）
@property (nonatomic, assign) NSTimeInterval presentationDelay;

/// Number of Subgroups
/// 子组数
@property (nonatomic, assign) NSInteger numSubGroups;

/// Codec Info Array
/// 编解码器规格配置
@property (nonatomic, strong) NSArray<JLBoracastCodecInfoModel *> *codecInfoArray;

/// 基础数据
/// Basic Data
@property (nonatomic, strong) NSData *basicData;

- (instancetype)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
