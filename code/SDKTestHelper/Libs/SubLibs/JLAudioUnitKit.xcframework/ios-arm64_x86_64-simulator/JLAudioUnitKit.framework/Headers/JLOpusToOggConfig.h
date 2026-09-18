//
//  JLOpusToOggConfiguration.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2025/5/11.
//  Copyright © 2025 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Opus 转 Ogg 的配置类
/// 用于配置采样率、声道数、帧时长等参数
@interface JLOpusToOggConfig : NSObject <NSCopying>

#pragma mark - 基本属性

/// 采样率（默认 16000）
/// 支持值：8000, 12000, 16000, 24000, 48000
@property (nonatomic, assign) uint32_t sampleRate;

/// 声道数（默认 1，单声道）
/// 支持值：1（单声道）, 2（立体声）
@property (nonatomic, assign) uint8_t channelCount;

/// 帧时长（单位：ms）
/// Opus 支持：2.5, 5, 10, 20, 40, 60
/// 默认 20ms
@property (nonatomic, assign) uint8_t frameDurationMs;

/// 每帧字节数（压缩后的 Opus 帧大小）
/// 默认 40 bytes（对应 20ms @ 16kbps）
@property (nonatomic, assign) uint32_t frameLength;

/// 预跳过样本数（用于解码器同步）
/// 默认与每帧采样数相同
@property (nonatomic, assign) uint16_t preSkip;

#pragma mark - 计算属性

/// 每帧采样数（根据采样率和帧时长自动计算）
- (uint32_t)samplesPerFrame;

/// 输出采样率（Opus 内部使用 48kHz）
- (uint32_t)outputSampleRate;

#pragma mark - 验证方法

/// 验证配置是否有效
/// @param error 如果验证失败，返回错误信息
/// @return YES 表示配置有效，NO 表示无效
- (BOOL)validateWithError:(NSError **)error;

/// 检查配置是否与标准值有显著差异
/// @return 返回警告信息数组，如果没有警告返回空数组
- (NSArray<NSString *> *)configurationWarnings;

#pragma mark - 预设配置工厂方法

/// 标准配置（20ms, 40bytes）- 公版默认，最常用
+ (instancetype)standardConfiguration;

/// 短帧配置（10ms, 20bytes）- 低延迟场景
+ (instancetype)shortFrameConfiguration;

/// 长帧配置（40ms, 80bytes）- 高压缩率场景
+ (instancetype)longFrameConfiguration;

/// 超长帧配置（60ms, 120bytes）- 极致压缩场景
+ (instancetype)extraLongFrameConfiguration;

/// 超短帧配置（5ms, 10bytes）- 极低延迟场景
+ (instancetype)ultraShortFrameConfiguration;

/// 自定义配置（根据帧时长自动计算推荐参数）
/// @param frameDurationMs 帧时长（必须是 2.5/5/10/20/40/60 之一）
/// @return 配置对象，如果参数无效返回 nil
+ (nullable instancetype)configurationWithFrameDurationMs:(uint8_t)frameDurationMs;

/// 完整自定义配置
/// @param sampleRate 采样率
/// @param channelCount 声道数
/// @param frameDurationMs 帧时长
/// @param frameLength 每帧字节数
/// @return 配置对象
+ (instancetype)configurationWithSampleRate:(uint32_t)sampleRate
                               channelCount:(uint8_t)channelCount
                            frameDurationMs:(uint8_t)frameDurationMs
                                frameLength:(uint32_t)frameLength;

@end

NS_ASSUME_NONNULL_END
