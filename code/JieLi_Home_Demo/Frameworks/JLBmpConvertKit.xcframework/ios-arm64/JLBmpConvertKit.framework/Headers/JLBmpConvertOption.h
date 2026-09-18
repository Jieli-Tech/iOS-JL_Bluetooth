//
//  JLBmpConvertOption.h
//  JLBmpConvertKit
//
//  Created by EzioChan on 2025/5/23.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 图像转换类型
typedef NS_ENUM(NSUInteger, JLBmpConvertType) {
    /// 695N 图像转换 RGB 转换成 695N 芯片对应的图像资源
    /// 对应原 BR23 转换算法
    JLBmpConvertType695N_RBG = 0,
    /// 701N 图像转换 RGB 转换成 701N 芯片对应的图像资源
    /// 对应原 BR28 转换的算法
    JLBmpConvertType701N_RBG = 1,
    /// 701N 图像转换 ARGB 转换成 701N 芯片对应的图像资源
    /// 对应原 BR28_ARBG 转换的算法
    JLBmpConvertType701N_ARBG = 2,
    /// 701N 图像转换 RGB 转换成 701N 芯片对应的图像资源(不打包封装）
    /// 对应原 BR28_RGB_NO_PACK 转换的算法(不打包封装)
    JLBmpConvertType701N_RBG_NO_PACK = 3,
    /// 701N 图像转换 ARGB 转换成 701N 芯片对应的图像资源(不打包封装)
    /// 对应原 BR28_ARGB_NO_PACK 转换的算法(不打包封装)
    JLBmpConvertType701N_ARGB_NO_PACK = 4,
    /// 707N 图像转换 RGB 转换成 707N 芯片对应的图像资源
    /// 对应 BR35 转换的算法
    JLBmpConvertType707N_RBG = 5,
    /// 707N 图像转换 ARGB 转换成 707N 芯片对应的图像资源
    /// 对应 BR35_ARGB 转换的算法
    JLBmpConvertType707N_ARGB = 6,
    /// 707N 图像转换 RGB 转换成 707N 芯片对应的图像资源(不打包封装)
    /// 对应 BR35_RGB_NO_PACK 转换的算法(不打包封装)
    JLBmpConvertType707N_ARGB_NO_PACK = 7,
    /// 707N 图像转换 RGB 转换成 707N 芯片对应的图像资源(不打包封装)
    /// 对应 BR35_RGB_NO_PACK 转换的算法(不打包封装)
    JLBmpConvertType707N_RBG_NO_PACK = 8,
    /// 701N 图像转换 JPEG
    /// 仅仅支持 JPEG 类型
    JLBmpConvertType701N_JPEG = 9,
    /// 380N 图像转换 （bmp/jpeg/png） 转换成 380N 芯片对应的图像资源
    JLBmpConvertType380N_IMAGE = 10
};

/// 图像像素格式
/// 707N 系列芯片支持 888/565/Auto
/// 380N 芯片支持全部格式
typedef NS_ENUM(NSUInteger, JLBmpPixelformat) {
    /// ARGB8888/RGB888 格式
    JLBmpPixelformat_888 = 0,
    /// ARGB8565/RGB565 格式
    JLBmpPixelformat_565 = 1,
    /// 自动选择最小的格式
    JLBmpPixelformat_Auto = 2,
    /// ARGB4444 格式（仅380N支持）
    JLBmpPixelformat_ARGB4444 = 3,
    /// ARGB1555 格式（仅380N支持）
    JLBmpPixelformat_ARGB1555 = 4,
    /// Alpha+Luminance 8+8 格式（仅380N支持）
    JLBmpPixelformat_AL88 = 5,
    /// Alpha+Luminance 4+4 格式（仅380N支持）
    JLBmpPixelformat_AL44 = 6,
    /// Alpha+Luminance 2+2 格式（仅380N支持）
    JLBmpPixelformat_AL22 = 7,
    /// Luminance 8位灰阶格式（仅380N支持）
    JLBmpPixelformat_L8 = 8,
    /// Luminance 4位灰阶格式（仅380N支持）
    JLBmpPixelformat_L4 = 9,
    /// Luminance 2位灰阶格式（仅380N支持）
    JLBmpPixelformat_L2 = 10,
    /// Luminance 1位二值格式（仅380N支持）
    JLBmpPixelformat_L1 = 11,
    /// Alpha 8位格式（仅380N支持）
    JLBmpPixelformat_A8 = 12,
    /// Alpha 4位格式（仅380N支持）
    JLBmpPixelformat_A4 = 13,
    /// Alpha 2位格式（仅380N支持）
    JLBmpPixelformat_A2 = 14,
    /// Alpha 1位掩码格式（仅380N支持）
    JLBmpPixelformat_A1 = 15,
};

/// 打包格式
/// 707N 系列芯片支持 None/JLUI/LVGL
/// 380N 芯片支持 None/JLUI/LVGL
typedef NS_ENUM(NSUInteger, JLBmpPacketFormat) {
    /// 不打包
    JLBmpPacketFormatNone = 0,
    /// JLUI 格式打包
    JLBmpPacketFormatJLUI = 1,
    /// LVGL 格式打包
    JLBmpPacketFormatLVGL = 2,
};

/// 压缩策略（仅380N支持）
typedef NS_ENUM(NSUInteger, JLBmpCompressStrategy) {
    /// 不压缩，原样输出
    JLBmpCompressStrategyNone = 0,
    /// 性能优先（压缩速度快）
    JLBmpCompressStrategyBestPerformance = 1,
    /// 空间优先（压缩率最高）
    JLBmpCompressStrategyBestSpaceSize = 2,
    /// 质量优先（图像质量最好）
    JLBmpCompressStrategyBestQuality = 3,
};

/// 调色板格式（仅380N支持）
typedef NS_ENUM(NSUInteger, JLBmpPaletteFormat) {
    /// ARGB8888 调色板
    JLBmpPaletteFormatARGB8888 = 0,
    /// ARGB8565 调色板
    JLBmpPaletteFormatARGB8565 = 1,
    /// RGB888 调色板
    JLBmpPaletteFormatRGB888 = 2,
    /// RGB565 调色板
    JLBmpPaletteFormatRGB565 = 3,
    /// 自动选择（默认）
    JLBmpPaletteFormatAuto = 4,
};

/// 图像转换选项
@interface JLBmpConvertOption : NSObject

#pragma mark - 基础参数（所有类型通用）

/// 图像转换类型（必需）
@property (nonatomic, assign) JLBmpConvertType convertType;

/// 是否转换成 BGRA
/// 当使用的是 JL 的 UI 框架时需要使用
/// 使用其他第三方框架时，需要根据固件端框架进行调整
/// default YES
@property (nonatomic, assign) BOOL convertToBGRA;

#pragma mark - 707N/380N 系列扩展参数

/// 图像像素格式
/// 默认为 Auto
/// 仅 707N 系列芯片和 380N 支持（其他类型设置无效）
@property (nonatomic, assign) JLBmpPixelformat pixelformat;

/// 打包格式
/// 默认为 JLUI
/// 仅 707N 系列芯片和 380N 支持（其他类型设置无效）
/// 注意：NO_PACK 类型强制为 None，设置无效
@property (nonatomic, assign) JLBmpPacketFormat packetFormat;

/// 压缩策略
/// 默认为 BestQuality
/// 仅 380N 支持（其他类型设置无效，固定使用内部算法）
@property (nonatomic, assign) JLBmpCompressStrategy compressStrategy;

/// 调色板格式
/// 默认为 Auto
/// 仅 380N 支持（其他类型设置无效）
@property (nonatomic, assign) JLBmpPaletteFormat paletteFormat;


#pragma mark - 参数校验与适配

/// 获取当前参数的有效性报告
/// 返回无效参数列表及建议值
- (NSArray<NSString *> *)validateParameters;

/// 自动修正参数为有效值
/// 根据 convertType 自动调整不兼容参数
- (void)autoCorrectParameters;

/// 获取当前配置的实际生效参数描述
- (NSString *)effectiveConfigurationDescription;

@end

NS_ASSUME_NONNULL_END
