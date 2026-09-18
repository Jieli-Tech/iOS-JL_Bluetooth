//
//  JLAudioFrame.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: PCM 音频帧数据封装，描述采样格式、声道、时长等元信息
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

/**
 音频采样格式枚举

 - JLPlayerAudioFormatS16: 16 位有符号整数（最常用）
 - JLPlayerAudioFormatS32: 32 位有符号整数
 - JLPlayerAudioFormatFloat: 32 位浮点数
 - JLPlayerAudioFormatDouble: 64 位浮点数
 */
typedef NS_ENUM(NSInteger, JLPlayerAudioFormat) {
    JLPlayerAudioFormatS16,
    JLPlayerAudioFormatS32,
    JLPlayerAudioFormatFloat,
    JLPlayerAudioFormatDouble,
};

/**
 PCM 音频帧数据封装

 @discussion
 封装一帧 PCM 音频数据及其元信息（采样率、声道数、格式、位深等）。
 提供样本数、时长等派生属性的自动计算。
 用于在解码器和音频渲染器之间传递音频数据。
 */
@interface JLAudioFrame : NSObject

/// PCM 原始音频数据
@property (nonatomic, strong, readonly) NSData *pcmData;

/// 显示时间戳（Presentation Time Stamp）
@property (nonatomic, assign, readonly) CMTime presentationTimeStamp;

/// 采样率（Hz），如 44100、48000
@property (nonatomic, assign, readonly) int32_t sampleRate;

/// 声道数（1=单声道，2=立体声）
@property (nonatomic, assign, readonly) int32_t channels;

/// 音频采样格式（S16 / S32 / Float / Double）
@property (nonatomic, assign, readonly) JLPlayerAudioFormat format;

/// 每采样点位深（bit），由 format 自动推导
@property (nonatomic, assign, readonly) int32_t bitsPerChannel;

/// 样本数（= PCM 数据长度 / 每帧字节数）
@property (nonatomic, assign, readonly) int32_t sampleCount;

/// 音频帧时长（毫秒），由 sampleCount 和 sampleRate 计算得出
@property (nonatomic, assign, readonly) int64_t durationMs;

/**
 使用 PCM 数据和音频参数初始化音频帧

 @param pcmData PCM 原始数据
 @param pts 显示时间戳
 @param sampleRate 采样率（Hz）
 @param channels 声道数
 @param format 采样格式
 @return 初始化后的音频帧对象
 @discussion 位深由 format 自动推导：S16=16, S32=32, Float=32, Double=64
 */
- (instancetype)initWithPCMData:(NSData *)pcmData
          presentationTimeStamp:(CMTime)pts
                     sampleRate:(int32_t)sampleRate
                       channels:(int32_t)channels
                         format:(JLPlayerAudioFormat)format;

/**
 使用 PCM 数据和完整参数初始化音频帧

 @param pcmData PCM 原始数据
 @param pts 显示时间戳
 @param sampleRate 采样率（Hz）
 @param channels 声道数
 @param format 采样格式
 @param bitsPerChannel 位深（bit），可手动指定以覆盖 format 的默认推导值
 @return 初始化后的音频帧对象
 */
- (instancetype)initWithPCMData:(NSData *)pcmData
          presentationTimeStamp:(CMTime)pts
                     sampleRate:(int32_t)sampleRate
                       channels:(int32_t)channels
                         format:(JLPlayerAudioFormat)format
                 bitsPerChannel:(int32_t)bitsPerChannel;

@end

NS_ASSUME_NONNULL_END
