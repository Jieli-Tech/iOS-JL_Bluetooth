//
//  JLPlayerOptions.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 播放器配置选项类，封装视频/音频参数、同步策略、缓存策略和调试开关
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <JLVideoTool/JLAudioFrame.h>

NS_ASSUME_NONNULL_BEGIN

/**
 播放模式枚举

 - JLPlayerModeStandard: 标准模式，按帧率播放并维护视频/音频缓存队列
 - JLPlayerModeInstant: 即时模式，即来即播，不做缓存和帧率控制
 */
typedef NS_ENUM(NSInteger, JLPlayerMode) {
    JLPlayerModeStandard,
    JLPlayerModeInstant,
};

/**
 播放轨道模式枚举

 - JLPlayerTrackModeBoth: 同时播放音视频（默认）
 - JLPlayerTrackModeAudioOnly: 仅播放音频
 - JLPlayerTrackModeVideoOnly: 仅播放视频
 */
typedef NS_ENUM(NSInteger, JLPlayerTrackMode) {
    JLPlayerTrackModeBoth,
    JLPlayerTrackModeAudioOnly,
    JLPlayerTrackModeVideoOnly,
};

/**
 播放器配置选项

 @discussion
 封装播放器的全部配置参数，分为以下几类：
 - 播放模式: 标准（带缓存、帧率控制）或即时（零延迟）
 - 视频参数: 分辨率、帧率、最大缓存帧数
 - 音频参数: 采样率、声道数、位深、格式、最大缓存帧数
 - 同步参数: 音视频偏移量、自动同步开关
 - 缓存策略: 最小/最大缓存时长、丢帧策略
 - 调试参数: 调试模式、统计开关、统计间隔

 支持 NSCopying 协议，使用前建议调用 isValid: 验证参数。
 */
@interface JLPlayerOptions : NSObject <NSCopying>

/// 播放模式（Standard / Instant），默认 Standard
@property (nonatomic, assign) JLPlayerMode playerMode;

/// 播放轨道模式（Both / AudioOnly / VideoOnly），默认 Both
@property (nonatomic, assign) JLPlayerTrackMode trackMode;

#pragma mark - 视频参数

/// 视频宽度（像素），0 表示自适应
@property (nonatomic, assign) int32_t videoWidth;

/// 视频高度（像素），0 表示自适应
@property (nonatomic, assign) int32_t videoHeight;

/// 视频帧率（fps），默认 30，范围 1-120
@property (nonatomic, assign) int32_t videoFrameRate;

/// 最大视频缓存帧数，默认 8，超过后根据 dropLateFrames 决定是否丢帧
@property (nonatomic, assign) int32_t videoMaxCacheFrames;

#pragma mark - 音频参数

/// 是否启用音频播放，默认 YES
@property (nonatomic, assign) BOOL enableAudio;

/// 音频采样率（Hz），默认 16000
@property (nonatomic, assign) int32_t audioSampleRate;

/// 音频采样格式，默认 S16
@property (nonatomic, assign) JLPlayerAudioFormat audioFormat;

/// 音频位深（bit），默认 16
@property (nonatomic, assign) int32_t audioBitsPerChannel;

/// 音频声道数，默认 1（单声道）
@property (nonatomic, assign) int32_t audioChannels;

/// 最大音频缓存帧数，默认 8
@property (nonatomic, assign) int32_t audioMaxCacheFrames;

#pragma mark - 同步参数

/// 音视频同步偏移量（毫秒），正数表示音频超前，默认 0
@property (nonatomic, assign) int64_t audioVideoSyncOffset;

/// 是否启用自动音视频同步，默认 YES；以音频时钟为主时钟
@property (nonatomic, assign) BOOL enableAutoSync;

#pragma mark - 缓存策略

/// 最小缓存时长（毫秒），默认 100，低于此时长触发缓冲中状态
@property (nonatomic, assign) int64_t minCacheDuration;

/// 最大缓存时长（毫秒），默认 500，超过此时长开始丢帧
@property (nonatomic, assign) int64_t maxCacheDuration;

/// 是否丢弃延迟帧，默认 YES；缓存满时丢弃最旧帧而非丢弃新帧
@property (nonatomic, assign) BOOL dropLateFrames;

#pragma mark - 调试参数

/// 是否启用调试模式，默认 NO
@property (nonatomic, assign) BOOL enableDebugMode;

/// 是否启用统计信息收集，默认 NO
@property (nonatomic, assign) BOOL enableStatistics;

/// 统计信息输出间隔（秒），默认 5
@property (nonatomic, assign) int32_t statisticsInterval;

/**
 创建带默认值的配置实例

 @return 默认配置：Standard 模式、30fps、16000Hz/S16/单声道、AV 同步启用
 */
+ (instancetype)defaultOptions;

/**
 按视频尺寸和帧率创建配置实例

 @param size 视频尺寸（像素）
 @param fps 目标帧率
 @return 新配置实例，其他参数使用默认值
 */
+ (instancetype)optionsForVideoSize:(CGSize)size frameRate:(int32_t)fps;

/**
 便捷设置音频参数

 @param sampleRate 采样率（Hz）
 @param channels 声道数
 @param bits 位深（bit），自动推导对应的 JLPlayerAudioFormat
 */
- (void)setAudioFormatWithSampleRate:(int32_t)sampleRate
                           channels:(int32_t)channels
                           bitsPerChannel:(int32_t)bits;

/**
 验证配置参数合法性

 @param error 验证失败时返回错误信息（可选）
 @return YES 有效，NO 无效
 @discussion 检查帧率范围（1-120）、采样率（<= 192000）、声道数（1-8）
 */
- (BOOL)isValid:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
