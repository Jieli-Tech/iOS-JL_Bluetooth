//
//  JLPlayerView.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 播放器视图组件，提供独立的视频播放 UIView，封装解码、渲染和调试功能，
//           支持 H.264 / JPEG 视频流和 PCM 音频流的实时播放
//

#import <UIKit/UIKit.h>
#import <JLVideoTool/JLPlayerTypes.h>
#import <JLVideoTool/JLPlayerOptions.h>
#import <JLVideoTool/JLPlayerDelegate.h>
#import <JLVideoTool/JLPlayerCore.h>

@protocol JLPlayerViewDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 播放器视图组件

 @discussion
 JLPlayerView 是一个独立的 UIView 子类，封装了播放器核心、流数据路由器、
 数据验证器和调试系统，提供简洁的公共接口用于:
 - 播放控制: prepare / play / pause / resume / stop / reset
 - 数据输入: H.264 裸流、JPEG 图片、PCM 音频
 - 调试功能: 调试浮层、日志级别控制、性能报告导出

 内部自动管理解码器生命周期，通过委托协议通知上层状态变化。
 支持标准模式（带缓存、帧率控制）和即时模式（零延迟）。

 典型用法:
 @code
 // 1. 创建播放器
 JLPlayerView *playerView = [[JLPlayerView alloc] initWithFrame:self.view.bounds];
 playerView.delegate = self;
 [self.view addSubview:playerView];

 // 2. 准备播放
 [playerView prepareWithCompletion:^(BOOL success, NSError *error) {
     if (success) [playerView playWithCompletion:nil];
 }];

 // 3. 输入数据
 [playerView inputH264Data:h264Data presentationTimeStamp:pts format:JLH264FormatAnnexB];
 [playerView inputJPEGData:jpegData presentationTimeStamp:pts];
 [playerView inputPCMData:pcmData presentationTimeStamp:pts];
 @endcode
 */
@interface JLPlayerView : UIView

#pragma mark - 初始化

/**
 使用默认配置和指定 frame 初始化播放器视图

 @param frame 视图的初始 frame
 @return 播放器视图实例
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 使用指定配置和 frame 初始化播放器视图

 @param frame 视图的初始 frame
 @param options 播放器配置选项
 @return 播放器视图实例
 */
- (instancetype)initWithFrame:(CGRect)frame options:(JLPlayerOptions *)options;

#pragma mark - 播放控制

/**
 准备播放器（初始化渲染器和解码器）

 @param completion 准备完成回调，在主线程触发
 @discussion 完成后进入 Ready 状态，触发 playerViewDidBecomeReady: 回调
 */
- (void)prepareWithCompletion:(void(^_Nullable)(BOOL success, NSError *_Nullable error))completion;

/**
 开始播放

 @param completion 开始播放回调，在主线程触发
 @discussion 启动后进入 Playing 状态，触发 playerViewDidStartPlaying: 回调
 */
- (void)playWithCompletion:(void(^_Nullable)(BOOL success, NSError *_Nullable error))completion;

/// 暂停播放（进入 Paused 状态）
- (void)pause;

/// 恢复播放（从 Paused 回到 Playing 状态）
- (void)resume;

/// 停止播放（进入 Stopped 状态，释放渲染资源）
- (void)stop;

/// 重置播放器到初始状态（进入 Idle 状态，清零统计）
- (void)reset;

#pragma mark - 数据输入

/**
 输入 H.264 编码数据

 @param data H.264 裸流数据（AnnexB 或 AVCC 格式）
 @param pts 显示时间戳（毫秒）
 @param format 数据封装格式（AnnexB / AVCC）
 @return YES 表示数据已入队，NO 表示验证失败或状态不允许
 @discussion 内部自动进行数据格式验证，格式不符时返回 NO。
             SPS/PPS 可从数据中自动提取，也可通过 options 注入。
 */
- (BOOL)inputH264Data:(NSData *)data
    presentationTimeStamp:(int64_t)pts
                   format:(JLH264Format)format;

/**
 输入 JPEG 编码数据

 @param data JPEG 编码数据
 @param pts 显示时间戳（毫秒）
 @return YES 表示数据已入队，NO 表示验证失败或状态不允许
 @discussion JPEG 数据解码为单帧后直接送入渲染器显示
 */
- (BOOL)inputJPEGData:(NSData *)data
    presentationTimeStamp:(int64_t)pts;

/**
 输入 PCM 音频数据

 @param pcmData PCM 原始数据
 @param pts 显示时间戳（毫秒）
 @return YES 表示数据已入队，NO 表示验证失败或状态不允许
 @discussion PCM 数据直接加入音频播放队列，由 AudioQueue 回调消费
 */
- (BOOL)inputPCMData:(NSData *)pcmData
    presentationTimeStamp:(int64_t)pts;

#pragma mark - 配置管理

/// 当前播放器配置（只读副本）
@property (nonatomic, strong, readonly) JLPlayerOptions *options;

/**
 更新播放器配置

 @param options 新的配置选项
 @return YES 表示更新成功，NO 表示当前状态不允许修改
 @discussion 仅可在 Idle 状态调用，否则返回 NO
 */
- (BOOL)updateOptions:(JLPlayerOptions *)options;

#pragma mark - 调试功能

/// 是否启用调试模式，默认 NO；开启后统计信息和日志将开始收集
@property (nonatomic, assign) BOOL debugEnabled;

/**
 显示调试浮层

 @param style 调试浮层样式（Minimal / Detailed / Graph）
 @discussion 浮层以半透明黑色背景覆盖在视频上方，显示实时统计和日志
 */
- (void)showDebugOverlayWithStyle:(JLDebugOverlayStyle)style;

/// 隐藏调试浮层
- (void)hideDebugOverlay;

/**
 设置日志级别过滤器

 @param level 日志最低显示级别（Verbose / Debug / Info / Warning / Error / Off）
 @param categories 日志类别筛选数组（如 @[@"Video", @"Audio"]），nil 表示不过滤
 */
- (void)setLogLevel:(JLLogLevel)level forCategories:(nullable NSArray<NSString *> *)categories;

/**
 导出性能报告

 @param completion 报告导出回调，在主线程触发，参数为格式化后的报告字符串
 */
- (void)exportPerformanceReport:(void(^)(NSString *report))completion;

#pragma mark - 状态查询

/// 当前播放器状态
@property (nonatomic, assign, readonly) JLPlayerState state;

/// 是否正在播放
@property (nonatomic, assign, readonly) BOOL isPlaying;

/// 当前播放时间（秒），基于最近渲染帧的 PTS
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;

/// 缓冲进度（0.0 ~ 1.0）
@property (nonatomic, assign, readonly) float bufferingProgress;

/// 当前实际视频帧率（fps）
@property (nonatomic, assign, readonly) float currentFrameRate;

#pragma mark - 音量与控制

/// 音量（0.0 ~ 1.0），默认 1.0
@property (nonatomic, assign) float volume;

/// 播放速度（0.5 ~ 2.0），默认 1.0
@property (nonatomic, assign) float playbackRate;

#pragma mark - 横竖屏切换支持

/**
 更新渲染视图大小

 @param frame 新的视图 frame
 @discussion 在屏幕旋转时调用此方法更新播放器视图大小，视频会自动适应新的尺寸
 */
- (void)updateRenderViewFrame:(CGRect)frame;

#pragma mark - 委托

/// 播放器视图委托（弱引用）
@property (nonatomic, weak, nullable) id<JLPlayerViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
