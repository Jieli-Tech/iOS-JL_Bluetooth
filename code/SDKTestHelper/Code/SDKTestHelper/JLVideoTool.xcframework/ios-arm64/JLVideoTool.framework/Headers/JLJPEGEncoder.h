//
//  JLJPEGEncoder.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/26.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//
//  功能描述: JPEG编码器，基于libjpeg-turbo实现
//  支持UIImage/JPEG原始数据输入，输出YCrCb色彩空间、SOF0格式、多种YUV采样模式
//  提供GPU加速图像处理方案

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 枚举定义

/**
 YUV采样格式枚举
 - JLJPEGSampling444: 4:4:4采样，无下采样，最高质量
 - JLJPEGSampling422: 4:2:2采样，水平方向2:1下采样
 - JLJPEGSampling420: 4:2:0采样，水平和垂直方向2:1下采样，最常见
 */
typedef NS_ENUM(NSInteger, JLJPEGSamplingFormat) {
    JLJPEGSampling444 = 0,
    JLJPEGSampling422 = 1,
    JLJPEGSampling420 = 2
};

/**
 JPEG编码质量级别枚举
 - JLJPEGQualityLow: 低质量，高压缩率 (~30%)
 - JLJPEGQualityMedium: 中等质量，平衡 (~60%)
 - JLJPEGQualityHigh: 高质量，低压缩率 (~85%)
 - JLJPEGQualityBest: 最佳质量，最低压缩率 (~95%)
 */
typedef NS_ENUM(NSInteger, JLJPEGQuality) {
    JLJPEGQualityLow = 30,
    JLJPEGQualityMedium = 60,
    JLJPEGQualityHigh = 85,
    JLJPEGQualityBest = 95
};

/**
 色彩空间枚举
 - JLJPEGColorSpaceYCrCb: YCrCb色彩空间（JPEG标准）
 - JLJPEGColorSpaceRGB: RGB色彩空间
 */
typedef NS_ENUM(NSInteger, JLJPEGColorSpace) {
    JLJPEGColorSpaceYCrCb = 0,
    JLJPEGColorSpaceRGB = 1
};

/**
 处理模式枚举
 - JLJPEGProcessingModeCPU: 纯CPU处理
 - JLJPEGProcessingModeGPU: GPU加速处理（Metal）
 - JLJPEGProcessingModeAuto: 自动选择（根据设备和图像大小）
 */
typedef NS_ENUM(NSInteger, JLJPEGProcessingMode) {
    JLJPEGProcessingModeCPU = 0,
    JLJPEGProcessingModeGPU = 1,
    JLJPEGProcessingModeAuto = 2
};

#pragma mark - 错误定义

/// JPEG编码器错误域
extern NSString * const JLJPEGEncoderErrorDomain;

/**
 JPEG编码器错误码枚举
 */
typedef NS_ENUM(NSInteger, JLJPEGEncoderErrorCode) {
    JLJPEGEncoderErrorInvalidInput = -2000,         // 输入参数无效
    JLJPEGEncoderErrorInvalidImage = -2001,         // 图像数据无效
    JLJPEGEncoderErrorEncodingFailed = -2002,       // 编码失败
    JLJPEGEncoderErrorMemoryAllocation = -2003,     // 内存分配失败
    JLJPEGEncoderErrorGPUInitFailed = -2004,        // GPU初始化失败
    JLJPEGEncoderErrorGPUProcessing = -2005,        // GPU处理失败
    JLJPEGEncoderErrorInvalidSampling = -2006,      // 不支持的采样格式
    JLJPEGEncoderErrorInvalidColorSpace = -2007,    // 不支持的色彩空间
    JLJPEGEncoderErrorInitializationFailed = -2008, // 初始化失败
    JLJPEGEncoderErrorDecodeFailed = -2009          // 解码失败
};

#pragma mark - 性能统计

/**
 性能统计数据模型
 用于记录和比较CPU/GPU处理性能
 */
@interface JLJPEGPerformanceMetrics : NSObject

/// 处理模式
@property (nonatomic, assign, readonly) JLJPEGProcessingMode processingMode;

/// 处理耗时（毫秒）
@property (nonatomic, assign, readonly) NSTimeInterval processingTime;

/// 图像宽度
@property (nonatomic, assign, readonly) NSInteger imageWidth;

/// 图像高度
@property (nonatomic, assign, readonly) NSInteger imageHeight;

/// 输入数据大小（字节）
@property (nonatomic, assign, readonly) NSUInteger inputDataSize;

/// 输出数据大小（字节）
@property (nonatomic, assign, readonly) NSUInteger outputDataSize;

/// 处理速度（MP/s - 百万像素每秒）
@property (nonatomic, assign, readonly) double megapixelsPerSecond;

/// 压缩比率（输出/输入）
@property (nonatomic, assign, readonly) double compressionRatio;

@end

#pragma mark - JPEG分离结果

/**
 JPEG数据分离结果
 将JPEG数据分离为头部信息和扫描数据两部分
 */
@interface JLJPEGSeparatedData : NSObject

/// JPEG头部数据（包含SOI、DQT、SOF0、DHT等标记，不包含SOS和扫描数据）
/// 大小通常为591字节（SOI到DHT DC1结束）
@property (nonatomic, strong, readonly) NSData *headerData;

/// JPEG扫描数据（从SOS标记开始到EOI结束）
@property (nonatomic, strong, readonly) NSData *scanData;

/// 原始JPEG数据总大小
@property (nonatomic, assign, readonly) NSUInteger totalSize;

/// 头部数据大小
@property (nonatomic, assign, readonly) NSUInteger headerSize;

/// 扫描数据大小
@property (nonatomic, assign, readonly) NSUInteger scanDataSize;

@end

#pragma mark - 编码选项

/**
 JPEG编码选项
 */
@interface JLJPEGEncodeOptions : NSObject

/// YUV采样格式，默认JLJPEGSampling420
@property (nonatomic, assign) JLJPEGSamplingFormat samplingFormat;

/// 编码质量（0-100），默认JLJPEGQualityMedium
@property (nonatomic, assign) NSInteger quality;

/// 色彩空间，默认JLJPEGColorSpaceYCrCb
@property (nonatomic, assign) JLJPEGColorSpace colorSpace;

/// 处理模式，默认JLJPEGProcessingModeAuto
@property (nonatomic, assign) JLJPEGProcessingMode processingMode;

/// 是否使用渐进式编码，默认NO
@property (nonatomic, assign) BOOL progressive;

/// 是否优化哈夫曼表，默认NO（设为YES会使头部不一致）
@property (nonatomic, assign) BOOL optimizeHuffman;

/// 默认选项
+ (instancetype)defaultOptions;

/// 指定采样格式创建选项
+ (instancetype)optionsWithSamplingFormat:(JLJPEGSamplingFormat)samplingFormat;

/// 指定质量和采样格式创建选项
+ (instancetype)optionsWithQuality:(JLJPEGQuality)quality
                    samplingFormat:(JLJPEGSamplingFormat)samplingFormat;

@end

#pragma mark - JPEG编码器

/**
 JPEG编码器

 @discussion
 基于libjpeg-turbo实现的高性能JPEG编码器，特点：
 - 支持UIImage和原始JPEG数据输入
 - 输出YCrCb色彩空间、SOF0格式
 - 支持444/422/420三种YUV采样格式
 - 提供GPU加速（Metal）和CPU处理两种模式
 - 支持JPEG头部分离，便于流式传输优化

 典型用法:
 @code
 // 基本编码
 JLJPEGEncoder *encoder = [[JLJPEGEncoder alloc] init];
 NSData *jpegData = [encoder encodeImage:uiImage options:[JLJPEGEncodeOptions defaultOptions] error:nil];

 // GPU加速编码
 JLJPEGEncodeOptions *options = [JLJPEGEncodeOptions defaultOptions];
 options.processingMode = JLJPEGProcessingModeGPU;
 NSData *jpegData = [encoder encodeImage:uiImage options:options error:&error];

 // 分离JPEG头部和扫描数据
 JLJPEGSeparatedData *separated = [encoder separateJPEGData:jpegData error:nil];
 NSLog(@"Header: %lu bytes, Scan: %lu bytes", separated.headerSize, separated.scanDataSize);
 @endcode
 */
@interface JLJPEGEncoder : NSObject

/// 是否支持GPU加速（设备是否支持Metal）
/// 默认为自动检测，但允许手动设置以强制使用或禁用GPU
@property (nonatomic, assign) BOOL isGPUSupported;

/// 当前处理模式（实际使用的模式）
@property (nonatomic, assign, readonly) JLJPEGProcessingMode currentProcessingMode;

/// 上次处理的性能统计
@property (nonatomic, strong, readonly, nullable) JLJPEGPerformanceMetrics *lastPerformanceMetrics;

/// 全局目标尺寸设置（作为总开关）
/// 如果设置为非 CGSizeZero，则 separateJPEGData、extractScanData、extractHeaderData 等接口
/// 在处理时会自动将图像缩放到此尺寸
@property (nonatomic, assign) CGSize globalTargetSize;

/// 标准化编码选项
/// 当 separateJPEGData、extractScanData、extractHeaderData 等接口处理JPEG数据时，
/// 如果检测到头部信息不一致，会使用此选项重新编码以统一格式
/// 如果为nil，则使用默认选项（JLJPEGEncodeOptions defaultOptions）
@property (nonatomic, strong, nullable) JLJPEGEncodeOptions *standardizationOptions;

/// 是否启用自动标准化处理
/// 默认为YES，当检测到JPEG头部格式不一致时，会自动重新编码统一格式
@property (nonatomic, assign) BOOL autoStandardizationEnabled;

/**
 初始化编码器

 @return 初始化后的编码器实例
 */
- (instancetype)init;

#pragma mark - 图像编码接口

/**
 编码UIImage为JPEG数据

 @param image 输入的UIImage对象
 @param options 编码选项
 @param error 错误信息输出
 @return 编码后的JPEG数据，失败返回nil
 */
- (nullable NSData *)encodeImage:(UIImage *)image
                         options:(JLJPEGEncodeOptions *)options
                           error:(NSError **)error;

/**
 编码UIImage为指定尺寸的JPEG数据

 @param image 输入的UIImage对象
 @param targetSize 目标输出尺寸（宽度x高度），如果 CGSizeZero 则不缩放
 @param options 编码选项
 @param error 错误信息输出
 @return 编码后的JPEG数据，失败返回nil
 @discussion 如果 targetSize 不为 CGSizeZero，则会将图片缩放到指定尺寸后编码。
             缩放使用高质量双线性插值，保持原始宽高比（如果需要）。
 */
- (nullable NSData *)encodeImage:(UIImage *)image
                      targetSize:(CGSize)targetSize
                         options:(JLJPEGEncodeOptions *)options
                           error:(NSError **)error;

/**
 编码原始图像数据为JPEG

 @param rawData 原始图像数据（RGB/RGBA格式）
 @param width 图像宽度
 @param height 图像高度
 @param bytesPerRow 每行字节数
 @param options 编码选项
 @param error 错误信息输出
 @return 编码后的JPEG数据，失败返回nil
 */
- (nullable NSData *)encodeRawData:(NSData *)rawData
                             width:(NSInteger)width
                            height:(NSInteger)height
                       bytesPerRow:(NSInteger)bytesPerRow
                           options:(JLJPEGEncodeOptions *)options
                             error:(NSError **)error;

/**
 重新编码JPEG数据（可用于转换采样格式或质量）

 @param jpegData 输入的JPEG数据
 @param options 编码选项
 @param error 错误信息输出
 @return 重新编码后的JPEG数据，失败返回nil
 */
- (nullable NSData *)reencodeJPEGData:(NSData *)jpegData
                              options:(JLJPEGEncodeOptions *)options
                                error:(NSError **)error;

#pragma mark - JPEG数据处理接口

/**
 分离JPEG数据为头部和扫描数据

 - 头部数据：从SOI到DHT DC1结束
 - 扫描数据：从SOS开始到EOI结束

 @param jpegData 输入的JPEG数据
 @param error 错误信息输出
 @return 分离后的数据结构，失败返回nil
 @discussion 如果设置了 globalTargetSize，会先将图像缩放到目标尺寸后再分离
 */
- (nullable JLJPEGSeparatedData *)separateJPEGData:(NSData *)jpegData
                                             error:(NSError **)error;

/**
 提取JPEG扫描数据（去除头部）

 @param jpegData 输入的JPEG数据
 @param error 错误信息输出
 @return 仅包含扫描数据的NSData，失败返回nil
 @discussion 如果设置了 globalTargetSize，会先将图像缩放到目标尺寸后再提取
 */
- (nullable NSData *)extractScanData:(NSData *)jpegData
                               error:(NSError **)error;

/**
 提取JPEG头部数据

 @param jpegData 输入的JPEG数据
 @param error 错误信息输出
 @return 仅包含头部数据的NSData，失败返回nil
 @discussion 如果设置了 globalTargetSize，会先将图像缩放到目标尺寸后再提取
 */
- (nullable NSData *)extractHeaderData:(NSData *)jpegData
                                 error:(NSError **)error;

/**
 合并头部和扫描数据为完整JPEG

 @param headerData 头部数据
 @param scanData 扫描数据
 @param error 错误信息输出
 @return 完整的JPEG数据，失败返回nil
 */
- (nullable NSData *)combineHeaderData:(NSData *)headerData
                              scanData:(NSData *)scanData
                                 error:(NSError **)error;

#pragma mark - 性能测试接口

/**
 对比CPU和GPU处理性能

 @param image 测试图像
 @param options 编码选项
 @param iterations 测试迭代次数
 @param completion 完成回调，返回CPU和GPU的性能统计
 */
- (void)comparePerformanceWithImage:(UIImage *)image
                            options:(JLJPEGEncodeOptions *)options
                         iterations:(NSInteger)iterations
                         completion:(void(^)(JLJPEGPerformanceMetrics *cpuMetrics,
                                            JLJPEGPerformanceMetrics *gpuMetrics,
                                            NSError *error))completion;

/**
 获取设备GPU性能等级

 @return GPU性能等级（0-10，10为最高）
 */
+ (NSInteger)gpuPerformanceLevel;

@end

NS_ASSUME_NONNULL_END
