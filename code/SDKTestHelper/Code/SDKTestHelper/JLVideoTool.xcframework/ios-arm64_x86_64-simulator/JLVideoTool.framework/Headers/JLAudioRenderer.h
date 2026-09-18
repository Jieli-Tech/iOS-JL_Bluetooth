//
//  JLAudioRenderer.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: PCM 音频渲染器，基于 AudioQueue 实现低延迟音频播放
//

#import <Foundation/Foundation.h>
#import <JLVideoTool/JLAudioFrame.h>

NS_ASSUME_NONNULL_BEGIN

/**
 PCM 音频渲染器

 @discussion
 基于 AudioQueue 实现 PCM 音频播放，支持四种采样格式:
 - S16 (16 位有符号整数)
 - S32 (32 位有符号整数)
 - Float (32 位浮点)
 - Double (64 位浮点)

 内部维护 3 个 AudioQueue Buffer 的环形队列，通过回调填充数据。
 当缓冲区数据不足时自动填充静音，避免播放中断。
 支持音量调节和暂停/恢复控制。

 典型用法:
 @code
 JLAudioRenderer *renderer = [[JLAudioRenderer alloc] initWithSampleRate:44100
                                                                channels:2
                                                                  format:JLPlayerAudioFormatS16];
 [renderer start:nil];
 [renderer enqueuePCMData:pcmData pts:kCMTimeZero];
 // ...
 [renderer stop];
 @endcode
 */
@interface JLAudioRenderer : NSObject

/// 是否正在播放
@property (nonatomic, assign, readonly) BOOL isPlaying;

/// 音量（0.0 ~ 1.0），默认 1.0
@property (nonatomic, assign) float volume;

/**
 使用音频参数初始化渲染器

 @param sampleRate 采样率（Hz），如 44100、48000
 @param channels 声道数（1=单声道，2=立体声）
 @param format 采样格式
 @return 渲染器实例
 */
- (instancetype)initWithSampleRate:(int32_t)sampleRate
                         channels:(int32_t)channels
                           format:(JLPlayerAudioFormat)format;

/**
 启动音频渲染器

 @param error 启动失败时返回错误信息
 @return YES 成功，NO 失败
 @discussion 创建 AudioQueue、分配 Buffer 并开始播放
 */
- (BOOL)start:(NSError **)error;

/// 停止并释放音频渲染资源
- (void)stop;

/// 暂停音频输出
- (void)pause;

/// 恢复音频输出
- (void)resume;

/**
 将音频帧加入播放队列

 @param frame 音频帧对象
 @return YES 成功入队，NO 失败（未启动或数据无效）
 */
- (BOOL)enqueueAudioFrame:(JLAudioFrame *)frame;

/**
 将 PCM 数据加入播放队列

 @param pcmData PCM 原始数据
 @param pts 显示时间戳
 @return YES 成功入队，NO 失败
 @discussion 数据在内部锁保护下加入待播放列表，由 AudioQueue 回调线程消费
 */
- (BOOL)enqueuePCMData:(NSData *)pcmData pts:(CMTime)pts;

/// 清空播放队列（正在播放的 Buffer 不受影响）
- (void)flush;

@end

NS_ASSUME_NONNULL_END
