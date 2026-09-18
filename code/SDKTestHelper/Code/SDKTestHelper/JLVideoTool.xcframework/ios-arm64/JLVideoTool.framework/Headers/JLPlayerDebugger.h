//
//  JLPlayerDebugger.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 播放器调试工具，提供统计收集、调试浮层、性能报告和音视频同步调试功能
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JLPlayerCore;

NS_ASSUME_NONNULL_BEGIN

/**
 播放器统计数据封装

 @discussion
 聚合视频/音频帧统计、音视频同步偏移、系统资源使用等运行时数据。
 通过 toDictionary 方法可导出为字典用于日志或上报。
 */
@interface JLPlayerStatistics : NSObject

#pragma mark - 视频统计

/// 累计接收视频帧数
@property (nonatomic, assign, readonly) int64_t videoFramesReceived;

/// 累计渲染视频帧数
@property (nonatomic, assign, readonly) int64_t videoFramesRendered;

/// 累计丢弃视频帧数（缓存满或同步滞后导致）
@property (nonatomic, assign, readonly) int64_t videoFramesDropped;

/// 实际视频帧率（fps），= 最近统计周期内的渲染帧数 / 时间
@property (nonatomic, assign, readonly) double videoFrameRate;

/// 当前视频缓存帧数
@property (nonatomic, assign, readonly) int32_t videoCacheSize;

#pragma mark - 音频统计

/// 累计接收音频帧数
@property (nonatomic, assign, readonly) int64_t audioFramesReceived;

/// 累计播放音频帧数
@property (nonatomic, assign, readonly) int64_t audioFramesPlayed;

/// 累计丢弃音频帧数
@property (nonatomic, assign, readonly) int64_t audioFramesDropped;

/// 当前音频缓存帧数
@property (nonatomic, assign, readonly) int32_t audioCacheSize;

#pragma mark - 同步统计

/// 音视频同步偏移量（毫秒），正数=音频超前，负数=视频超前
@property (nonatomic, assign, readonly) int64_t avSyncOffset;

/// 帧间隔抖动（毫秒），反映渲染间隔的不稳定程度
@property (nonatomic, assign, readonly) double jitter;

#pragma mark - 性能统计

/// CPU 使用率（百分比）
@property (nonatomic, assign, readonly) double cpuUsage;

/// 当前进程内存占用（字节，resident_size）
@property (nonatomic, assign, readonly) int64_t memoryUsage;

/// 平均解码耗时（毫秒）
@property (nonatomic, assign, readonly) double averageDecodeTime;

/// 平均渲染耗时（毫秒）
@property (nonatomic, assign, readonly) double averageRenderTime;

/**
 导出统计字典

 @return 包含所有统计字段的 NSDictionary
 */
- (NSDictionary *)toDictionary;

@end

/**
 播放器调试工具

 @discussion
 单例模式的调试工具，可绑定到 JLPlayerCore 实例进行:
 - 统计信息定时收集和回调
 - 调试浮层（绿色半透明文字叠加层）显示实时状态
 - 音视频同步手动调试（偏移量设置/重置）
 - 性能日志输出和报告导出
 - 后门接口（测试图案注入、网络条件模拟、强制关键帧等）

 典型用法:
 @code
 JLPlayerDebugger *dbg = [JLPlayerDebugger sharedDebugger];
 [dbg attachToPlayer:player];
 [dbg showDebugOverlayInView:self.view];
 [dbg startStatisticsCollection:1.0];
 @endcode
 */
@interface JLPlayerDebugger : NSObject

/// 绑定的播放器实例（弱引用）
@property (nonatomic, weak) JLPlayerCore *player;

/// 是否显示调试浮层，默认 NO
@property (nonatomic, assign) BOOL enableDebugOverlay;

/// 获取单例实例
+ (instancetype)sharedDebugger;

/**
 绑定到指定播放器

 @param player 目标播放器实例
 */
- (void)attachToPlayer:(JLPlayerCore *)player;

/// 解除绑定
- (void)detach;

#pragma mark - 音视频同步调试

/**
 设置音视频同步偏移量

 @param offsetMs 偏移量（毫秒），正数=音频超前
 */
- (void)setAVSyncOffset:(int64_t)offsetMs;

/// 获取当前同步偏移量（毫秒）
- (int64_t)currentAVSyncOffset;

/// 重置同步偏移量为 0
- (void)resetAVSync;

#pragma mark - 统计

/// 获取当前统计快照
- (JLPlayerStatistics *)currentStatistics;

/**
 开始定时收集统计信息

 @param interval 收集间隔（秒）
 @discussion 统计结果通过 player.delegate 的 didUpdateStatistics: 回调
 */
- (void)startStatisticsCollection:(NSTimeInterval)interval;

/// 停止统计收集
- (void)stopStatisticsCollection;

#pragma mark - 性能

/**
 启用/禁用性能日志输出

 @param enable YES 启用，NO 禁用
 @discussion 启用后每次统计周期输出一条 JLLOG_DEBUG 级别日志
 */
- (void)enablePerformanceLogging:(BOOL)enable;

/**
 导出性能报告

 @param completion 完成回调，参数为格式化后的报告字符串
 @discussion 报告包含视频/音频/系统三大类统计数据
 */
- (void)exportPerformanceReport:(void(^)(NSString *report))completion;

#pragma mark - 调试浮层

/**
 在指定视图中显示调试浮层

 @param parentView 父视图，浮层会添加为 subview（左上角位置）
 @discussion 浮层为绿色等宽字体文字，半透明黑色背景
 */
- (void)showDebugOverlayInView:(UIView *)parentView;

/// 隐藏并移除调试浮层
- (void)hideDebugOverlay;

/// 手动刷新调试浮层显示内容
- (void)updateDebugOverlay;

#pragma mark - 后门接口

/**
 注入测试图案到播放器

 @param patternType 图案类型: "color_bars"（彩条）、"red"（纯红）
 @discussion 生成一帧测试图案并以视频帧方式输入播放器，用于验证渲染链路
 */
- (void)injectTestPattern:(NSString *)patternType;

/**
 模拟网络条件

 @param condition "good"（正常）或 "poor"（差），影响丢帧策略和缓存大小
 */
- (void)simulateNetworkCondition:(NSString *)condition;

/// 强制请求关键帧（I 帧），当前版本为预留接口
- (void)forceKeyFrame;

/**
 设置每帧渲染回调

 @param callback 回调 block，每帧渲染时触发，参数为帧对象
 @discussion 用于在调试时检查每帧数据，注意性能开销
 */
- (void)setRenderFrameCallback:(void(^)(id frame))callback;

@end

NS_ASSUME_NONNULL_END
