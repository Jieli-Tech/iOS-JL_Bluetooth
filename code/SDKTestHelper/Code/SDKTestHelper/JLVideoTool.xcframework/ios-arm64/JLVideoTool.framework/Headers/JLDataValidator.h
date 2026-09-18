//
//  JLDataValidator.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 数据验证器，验证输入裸流数据（H.264 / JPEG / PCM）的格式合法性和完整性，
//           支持自动格式检测和元数据提取
//

#import <Foundation/Foundation.h>
#import <JLVideoTool/JLPlayerTypes.h>

NS_ASSUME_NONNULL_BEGIN

/**
 数据验证结果

 @discussion
 封装验证结果，包括是否通过、错误信息、检测到的格式和元数据。
 用于在数据进入解码器前进行合法性检查。
 */
@interface JLValidationResult : NSObject

/// 是否验证通过
@property (nonatomic, assign, readonly) BOOL isValid;

/// 验证失败原因（验证通过时为 nil）
@property (nonatomic, copy, readonly, nullable) NSString *errorMessage;

/// 检测到的数据格式（验证通过时有效）
@property (nonatomic, assign, readonly) JLStreamFormat detectedFormat;

/// 数据元信息（如分辨率、采样率等），验证通过时可能非空
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, id> *metadata;

@end

/**
 数据验证器

 @discussion
 验证输入裸流数据的格式合法性和完整性。
 支持三种数据类型:
 - H.264: 检测 AnnexB / AVCC 格式，验证 NAL 单元完整性
 - JPEG: 检测 SOI (0xFFD8) / EOI (0xFFD9) 标记
 - PCM: 验证数据长度与采样参数的一致性

 还支持自动格式检测（detectFormat:），无需提前知道数据类型。
 */
@interface JLDataValidator : NSObject

/**
 验证 H.264 数据

 @param data 待验证的 H.264 裸流数据
 @param expectedFormat 期望的封装格式，传 JLStreamFormatH264AnnexB 或 JLStreamFormatH264AVCC
 @return 验证结果
 @discussion 检查数据非空、长度 > 0，并根据格式类型验证 start code 或长度前缀
 */
- (JLValidationResult *)validateH264Data:(NSData *)data
                          expectedFormat:(JLStreamFormat)expectedFormat;

/**
 验证 JPEG 数据

 @param data 待验证的 JPEG 编码数据
 @return 验证结果
 @discussion 检查 SOI 标记 (0xFF 0xD8)、EOI 标记 (0xFF 0xD9) 和数据长度
 */
- (JLValidationResult *)validateJPEGData:(NSData *)data;

/**
 验证 PCM 数据

 @param data 待验证的 PCM 原始数据
 @param sampleRate 采样率（Hz）
 @param channels 声道数
 @param bitsPerSample 位深（bit）
 @return 验证结果
 @discussion 验证数据长度与采样参数的数学一致性：dataLength 应为 (channels * bitsPerSample / 8) 的整数倍
 */
- (JLValidationResult *)validatePCMData:(NSData *)data
                             sampleRate:(int32_t)sampleRate
                               channels:(int32_t)channels
                          bitsPerSample:(int32_t)bitsPerSample;

/**
 自动检测数据格式

 @param data 待检测的数据
 @return 检测到的格式
 @discussion 按优先级检测：先检查 JPEG 标记 (0xFFD8)，再检查 H.264 NAL 特征（start code / 长度前缀），
             均不匹配则返回 JLStreamFormatPCM（最后手段）
 */
- (JLStreamFormat)detectFormat:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
