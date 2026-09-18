//
//  JLPlayerDelegate.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 播放器委托协议，定义播放器状态变化、帧渲染、统计和缓冲回调
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JLPlayerCore;
@class JLVideoFrame;
@class JLAudioFrame;

NS_ASSUME_NONNULL_BEGIN

/**
 播放器委托协议

 @discussion
 所有方法均为 @optional。回调均在主线程触发。
 分为四类回调:
 - 状态回调: 就绪、开始播放、暂停、停止、错误
 - 渲染回调: 视频帧/音频帧即将渲染（可在回调中做后处理）
 - 统计回调: 周期性统计信息更新
 - 缓冲回调: 缓冲开始/结束/进度
 */
@protocol JLPlayerDelegate <NSObject>

@optional

#pragma mark - 状态回调

/// 播放器准备完成，进入就绪状态
- (void)playerDidBecomeReady:(JLPlayerCore *)player;

/// 播放器开始播放
- (void)playerDidStartPlaying:(JLPlayerCore *)player;

/// 播放器已暂停
- (void)playerDidPause:(JLPlayerCore *)player;

/// 播放器已停止
- (void)playerDidStop:(JLPlayerCore *)player;

/// 播放器发生错误
/// @param player 播放器实例
/// @param error 错误详情
- (void)player:(JLPlayerCore *)player didFailWithError:(NSError *)error;

#pragma mark - 渲染回调

/// 视频帧即将渲染
/// @param player 播放器实例
/// @param frame 待渲染的视频帧
/// @discussion 可在此回调中对帧数据做后处理（如叠加水印）
- (void)player:(JLPlayerCore *)player shouldRenderVideoFrame:(JLVideoFrame *)frame;

/// 音频帧即将渲染
/// @param player 播放器实例
/// @param frame 待播放的音频帧
- (void)player:(JLPlayerCore *)player shouldRenderAudioFrame:(JLAudioFrame *)frame;

#pragma mark - 统计回调

/// 统计信息周期更新
/// @param player 播放器实例
/// @param statistics 统计字典，包含帧数、帧率、缓存大小等
- (void)player:(JLPlayerCore *)player didUpdateStatistics:(NSDictionary *)statistics;

#pragma mark - 缓冲回调

/// 开始缓冲（视频缓存为空）
- (void)playerDidStartBuffering:(JLPlayerCore *)player;

/// 缓冲结束（视频缓存恢复）
- (void)playerDidEndBuffering:(JLPlayerCore *)player;

/// 缓冲进度更新
/// @param player 播放器实例
/// @param progress 缓冲进度（0.0 ~ 1.0）
- (void)player:(JLPlayerCore *)player bufferingProgress:(float)progress;

#pragma mark - 轨道模式回调

/// 播放轨道模式发生变化
/// @param player 播放器实例
/// @param newMode 新的轨道模式
/// @param oldMode 旧的轨道模式
/// @discussion 当调用 setTrackMode: 时会触发此回调
- (void)player:(JLPlayerCore *)player didChangeTrackMode:(JLPlayerTrackMode)newMode fromMode:(JLPlayerTrackMode)oldMode;

/// 视频轨道已暂停（切换到音频-only 模式时触发）
/// @param player 播放器实例
- (void)playerDidPauseVideoTrack:(JLPlayerCore *)player;

/// 视频轨道已恢复（从音频-only 模式切换回 Both/VideoOnly 时触发）
/// @param player 播放器实例
- (void)playerDidResumeVideoTrack:(JLPlayerCore *)player;

/// 音频轨道已暂停（切换到视频-only 模式时触发）
/// @param player 播放器实例
- (void)playerDidPauseAudioTrack:(JLPlayerCore *)player;

/// 音频轨道已恢复（从视频-only 模式切换回 Both/AudioOnly 时触发）
/// @param player 播放器实例
- (void)playerDidResumeAudioTrack:(JLPlayerCore *)player;

@end

NS_ASSUME_NONNULL_END
