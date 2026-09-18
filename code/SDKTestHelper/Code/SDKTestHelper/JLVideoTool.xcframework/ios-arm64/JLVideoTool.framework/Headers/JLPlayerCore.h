//
//  JLPlayerCore.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 播放器核心类，协调视频/音频渲染器、帧缓存队列和音视频同步
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JLVideoTool/JLPlayerOptions.h>
#import <JLVideoTool/JLPlayerDelegate.h>
#import <JLVideoTool/JLVideoFrame.h>
#import <JLVideoTool/JLAudioFrame.h>

NS_ASSUME_NONNULL_BEGIN

/**
 播放器状态枚举

 - JLPlayerStateIdle: 空闲，尚未准备
 - JLPlayerStatePreparing: 准备中，初始化渲染器
 - JLPlayerStateReady: 就绪，可开始播放
 - JLPlayerStatePlaying: 播放中
 - JLPlayerStatePaused: 已暂停
 - JLPlayerStateBuffering: 缓冲中，等待视频帧
 - JLPlayerStateStopped: 已停止
 - JLPlayerStateError: 错误状态
 */
typedef NS_ENUM(NSInteger, JLPlayerState) {
    JLPlayerStateIdle,
    JLPlayerStatePreparing,
    JLPlayerStateReady,
    JLPlayerStatePlaying,
    JLPlayerStatePaused,
    JLPlayerStateBuffering,
    JLPlayerStateStopped,
    JLPlayerStateError,
};

/**
 播放器核心

 @discussion
 JLPlayerCore 是播放器模块的中心类，协调以下子系统:
 - JLVideoRenderer: 视频帧渲染（基于 AVSampleBufferDisplayLayer）
 - JLAudioRenderer: PCM 音频播放（基于 AudioQueue）
 - 帧缓存队列: 管理视频/音频帧的缓冲和丢帧策略
 - 音视频同步: 以音频时钟为主时钟的自动同步

 支持两种播放模式:
 - Standard: 按目标帧率播放，维护帧缓存，丢帧策略可控
 - Instant: 即来即播，零缓存，最小延迟

 典型使用流程:
 @code
 JLPlayerOptions *opts = [JLPlayerOptions defaultOptions];
 JLPlayerCore *player = [[JLPlayerCore alloc] initWithOptions:opts];
 [player bindRenderView:self.videoView];
 [player prepare:nil];
 [player play:nil];
 // 循环喂入帧数据...
 [player inputVideoFrame:frame];
 [player inputAudioData:pcmData pts:pts];
 // ...
 [player stop];
 @endcode

 状态机: Idle → Preparing → Ready → Playing ↔ Paused / Buffering → Stopped / Error
 */
@interface JLPlayerCore : NSObject

/// 委托对象（弱引用）
@property (nonatomic, weak, nullable) id<JLPlayerDelegate> delegate;

/// 播放器配置选项（只读）
@property (nonatomic, strong, readonly) JLPlayerOptions *options;

/// 当前播放器状态
@property (nonatomic, assign, readonly) JLPlayerState state;

#pragma mark - 播放控制

/**
 使用配置选项初始化播放器

 @param options 播放器配置（会被 copy）
 @return 播放器实例
 */
- (instancetype)initWithOptions:(JLPlayerOptions *)options;

/**
 准备播放器（初始化渲染器）

 @param error 准备失败时返回错误信息
 @return YES 成功，NO 失败
 @discussion 根据配置初始化视频渲染器（如已 bindRenderView）和音频渲染器。
             完成后进入 Ready 状态并触发 playerDidBecomeReady: 回调
 */
- (BOOL)prepare:(NSError **)error;

/**
 开始播放

 @param error 启动失败时返回错误信息
 @return YES 成功，NO 失败
 @discussion 启动 CADisplayLink（Standard 模式）和 AudioQueue，
             进入 Playing 状态并触发 playerDidStartPlaying: 回调
 */
- (BOOL)play:(NSError **)error;

/// 暂停播放
- (void)pause;

/// 恢复播放
- (void)resume;

/// 停止播放并释放渲染资源
- (void)stop;

/// 重置播放器到 Idle 状态，清零所有统计
- (void)reset;

#pragma mark - 视频输入

/**
 输入视频帧到播放器

 @param frame 视频帧对象
 @return YES 成功入队，NO 失败
 @discussion Standard 模式下帧进入缓存队列，Instant 模式下立即渲染
 */
- (BOOL)inputVideoFrame:(JLVideoFrame *)frame;

/**
 输入原始视频数据到播放器

 @param data 原始像素数据（RGBA / BGRA 等）
 @param size 帧尺寸
 @param pts 显示时间戳（毫秒）
 @param pixelFormat 像素格式（OSType）
 @return YES 成功，NO 失败
 @discussion 内部将原始数据包装为 CVPixelBuffer 再创建 JLVideoFrame 入队
 */
- (BOOL)inputVideoData:(NSData *)data
                  size:(CGSize)size
                   pts:(int64_t)pts
           pixelFormat:(OSType)pixelFormat;

#pragma mark - 音频输入

/**
 输入 PCM 音频数据（使用配置中的默认音频参数）

 @param pcmData PCM 原始数据
 @param pts 显示时间戳（毫秒）
 @return YES 成功入队，NO 失败
 */
- (BOOL)inputAudioData:(NSData *)pcmData pts:(int64_t)pts;

/**
 输入 PCM 音频数据（指定音频参数）

 @param pcmData PCM 原始数据
 @param pts 显示时间戳（毫秒）
 @param sampleRate 采样率（Hz）
 @param channels 声道数
 @param format 采样格式
 @return YES 成功入队，NO 失败
 */
- (BOOL)inputAudioData:(NSData *)pcmData
                   pts:(int64_t)pts
            sampleRate:(int32_t)sampleRate
              channels:(int32_t)channels
                format:(JLPlayerAudioFormat)format;

#pragma mark - 渲染视图

/**
 绑定渲染视图（用于内部视频渲染）

 @param view 用于显示视频的 UIView
 @discussion 绑定后会自动创建 JLVideoRenderer 并开始渲染。
             在 prepare: 之前调用或在 prepare: 之后调用均可
 */
- (void)bindRenderView:(UIView *)view;

/// 解绑渲染视图并释放视频渲染器
- (void)unbindRenderView;

/// 更新渲染视图的 frame（在 layoutSubviews 中调用）
- (void)updateRenderViewFrame;

#pragma mark - 播放器信息

/// 当前播放时间（秒），基于最近渲染帧的 PTS
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;

/// 总时长（秒），由外部设置（当前版本需调用方自行管理）
@property (nonatomic, assign, readonly) NSTimeInterval duration;

/// 是否正在播放
@property (nonatomic, assign, readonly) BOOL isPlaying;

/// 缓冲进度（0.0 ~ 1.0），= 缓存帧数 / maxCacheFrames
@property (nonatomic, assign, readonly) float bufferingProgress;

#pragma mark - 控制参数

/// 音量（0.0 ~ 1.0），默认 1.0
@property (nonatomic, assign) float volume;

/// 播放速度（0.5 ~ 2.0），默认 1.0（当前版本预留，暂未影响实际播放）
@property (nonatomic, assign) float playbackRate;

#pragma mark - 轨道模式控制

/**
 动态切换播放轨道模式

 @param trackMode 新的轨道模式
 @discussion 支持在播放过程中动态切换，会暂停/恢复相应渲染器
             切换后会触发 player:didChangeTrackMode: 回调
 */
- (void)setTrackMode:(JLPlayerTrackMode)trackMode;

/// 当前播放轨道模式（只读，通过 setTrackMode: 修改）
@property (nonatomic, assign, readonly) JLPlayerTrackMode currentTrackMode;

@end

NS_ASSUME_NONNULL_END
