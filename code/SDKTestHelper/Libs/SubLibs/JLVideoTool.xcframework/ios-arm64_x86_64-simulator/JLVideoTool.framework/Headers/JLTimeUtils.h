//
//  JLTimeUtils.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 时间工具类，提供毫秒与 CMTime 互转、当前时间获取、主机时钟等通用方法
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

/**
 时间工具类

 @discussion
 提供一组类方法用于音视频开发中常见的时间转换操作：
 - 毫秒（int64_t）与 CMTime 互转
 - 获取基于 CACurrentMediaTime 的当前时间
 - 获取基于 mach_absolute_time 的主机时钟
 所有方法均为线程安全。
 */
@interface JLTimeUtils : NSObject

/**
 毫秒转 CMTime（默认 timescale=1000）

 @param ms 毫秒数
 @return CMTime 值，timescale=1000
 */
+ (CMTime)cmTimeFromMilliseconds:(int64_t)ms;

/**
 毫秒转 CMTime（自定义 timescale）

 @param ms 毫秒数
 @param timescale 时间刻度
 @return CMTime 值
 */
+ (CMTime)cmTimeFromMilliseconds:(int64_t)ms timescale:(int32_t)timescale;

/**
 CMTime 转毫秒

 @param time CMTime 值
 @return 毫秒数；若 timescale 为 0 则返回 0
 */
+ (int64_t)millisecondsFromCMTime:(CMTime)time;

/**
 获取当前时间（毫秒）

 @return 基于 CACurrentMediaTime 的当前时间（毫秒）
 @discussion 使用 Core Animation 媒体时间，与系统时钟单调同步，适合音视频同步计算
 */
+ (int64_t)currentTimeMs;

/**
 获取主机时钟时间

 @return 基于 mach_absolute_time 的主机时钟 CMTime
 @discussion 使用 mach 绝对时间，精度高，适合性能计时场景
 */
+ (CMTime)hostClockTime;

@end

NS_ASSUME_NONNULL_END
