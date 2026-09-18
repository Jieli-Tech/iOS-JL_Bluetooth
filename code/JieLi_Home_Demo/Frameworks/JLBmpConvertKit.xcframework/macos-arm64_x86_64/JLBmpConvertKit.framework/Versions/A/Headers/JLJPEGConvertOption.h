//
//  JLJPEGConvertOption.h
//  JLBmpConvertKit
//
//  Created by EzioChan on 2025/6/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLBmpConvertKit/JLJPEGConvertTypes.h>

NS_ASSUME_NONNULL_BEGIN

/// JPEG 转换配置选项
@interface JLJPEGConvertOption : NSObject

#pragma mark - 初始化

/// 使用默认配置创建选项
+ (instancetype)defaultOption;

/// 使用指定资源类型创建选项
+ (instancetype)optionWithResourceType:(JLResourceType)resourceType;

#pragma mark - 基础参数（必需）

/// 输入像素格式（默认：BGRA8888）
@property (nonatomic, assign) JLJPEGPixelFormat pixelFormat;

/// 图像宽度（像素）
@property (nonatomic, assign) uint16_t width;

/// 图像高度（像素）
@property (nonatomic, assign) uint16_t height;

#pragma mark - JPEG 编码参数

/// 分块方式（默认：32x32）
@property (nonatomic, assign) JLJPEGBlockMode blockMode;

/// YUV 采样方式（默认：420）
@property (nonatomic, assign) JLJPEGYUVSample yuvSample;

/// YUV 转换规范（默认：BT601）
@property (nonatomic, assign) JLJPEGBTMode btMode;

/// RGB 通道质量（1-100，默认：90）
@property (nonatomic, assign) uint8_t rgbQuality;

/// Alpha 通道质量（1-100，默认：90）
@property (nonatomic, assign) uint8_t alphaQuality;

/// 是否使用自定义量化表（默认：NO）
@property (nonatomic, assign) BOOL useCustomQuantTable;

/// 自定义量化表数据（可选）
@property (nonatomic, strong, nullable) NSData *quantTable;

#pragma mark - 资源输出参数

/// 目标资源类型（默认：BIN）
@property (nonatomic, assign) JLResourceType resourceType;

/// LVGL 版本（默认：LVGL8）
@property (nonatomic, assign) JLLVGLVersion lvglVersion;

/// 目标图像格式（默认：ARGB8888）
@property (nonatomic, assign) JLImageFormat imageFormat;

/// 块大小（默认：64x1）
@property (nonatomic, assign) JLBlockSize blockSize;

/// 是否交换 R/B 通道（默认：NO）
@property (nonatomic, assign) BOOL swapRB;

/// 晶圆类型（默认：ALL）
@property (nonatomic, assign) JLWaferType waferType;

/// CLUT 格式（RLE 类型必需）
@property (nonatomic, assign) JLCLUTFormat clutFormat;

/// YUV 格式（RLE 类型必需）
@property (nonatomic, assign) JLYUVFormat yuvFormat;

#pragma mark - 参数校验

/// 验证当前配置是否有效
/// @param error 错误信息输出
/// @return YES 表示配置有效
- (BOOL)validateWithError:(NSError * _Nullable * _Nullable)error;

/// 获取参数不兼容的警告列表（不修改参数）
/// @return 警告信息数组
- (NSArray<NSString *> *)validationWarnings;

/// 自动修正不兼容参数为有效值
- (void)autoCorrectParameters;

/// 获取当前配置的实际生效参数描述
- (NSString *)effectiveConfigurationDescription;

/// 生成 resconv 所需的 JSON 配置字符串
- (NSString *)generateJSONConfig;

@end

NS_ASSUME_NONNULL_END
