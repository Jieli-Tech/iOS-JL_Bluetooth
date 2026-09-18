//
//  JLPlayerViewDelegate.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 播放器视图委托协议，定义 JLPlayerView 的状态变化、错误、缓冲和统计回调
//

#import <Foundation/Foundation.h>
#import <JLVideoTool/JLPlayerTypes.h>
#import <JLVideoTool/JLPlayerCore.h>

@class JLPlayerView;

NS_ASSUME_NONNULL_BEGIN

/**
 播放器视图委托协议

 @discussion
 所有方法均为 @optional，调用方按需实现。
 所有回调均在主线程触发。
 分为五类回调:
 - 生命周期回调: 准备完成、开始播放、暂停、停止
 - 错误回调: 播放器发生错误时触发
 - 状态回调: 播放器状态变化时触发
 - 缓冲回调: 缓冲进度更新
 - 统计回调: 周期性统计信息更新
 */
@protocol JLPlayerViewDelegate <NSObject>

@optional

#pragma mark - 生命周期回调

/// 播放器准备完成，进入就绪状态
/// @param playerView 播放器视图实例
- (void)playerViewDidBecomeReady:(JLPlayerView *)playerView;

/// 播放器开始播放
/// @param playerView 播放器视图实例
- (void)playerViewDidStartPlaying:(JLPlayerView *)playerView;

/// 播放器已暂停
/// @param playerView 播放器视图实例
- (void)playerViewDidPause:(JLPlayerView *)playerView;

/// 播放器已停止
/// @param playerView 播放器视图实例
- (void)playerViewDidStop:(JLPlayerView *)playerView;

#pragma mark - 错误回调

/// 播放器发生错误
/// @param playerView 播放器视图实例
/// @param error 错误详情
- (void)playerView:(JLPlayerView *)playerView didFailWithError:(NSError *)error;

#pragma mark - 状态回调

/// 播放器状态发生变化
/// @param playerView 播放器视图实例
/// @param newState 新状态
/// @param oldState 旧状态
- (void)playerView:(JLPlayerView *)playerView stateChanged:(JLPlayerState)newState fromState:(JLPlayerState)oldState;

#pragma mark - 缓冲回调

/// 缓冲进度更新
/// @param playerView 播放器视图实例
/// @param progress 缓冲进度（0.0 ~ 1.0）
- (void)playerView:(JLPlayerView *)playerView bufferingProgress:(float)progress;

#pragma mark - 统计回调

/// 统计信息更新
/// @param playerView 播放器视图实例
/// @param statistics 统计字典，包含帧数、帧率、缓存大小等
- (void)playerView:(JLPlayerView *)playerView didUpdateStatistics:(NSDictionary *)statistics;

@end

NS_ASSUME_NONNULL_END
