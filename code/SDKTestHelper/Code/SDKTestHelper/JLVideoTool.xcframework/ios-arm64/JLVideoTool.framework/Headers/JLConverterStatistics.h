//
//  JLConverterStatistics.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/06/04.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 转换器统计信息
 *
 * 记录 JPEG 转 H264 转换过程中的各项统计数据。
 * 用于性能监控、调试和优化。
 *
 * 统计项包括：
 * - 输入统计：总输入帧数、丢弃帧数、平均输入间隔
 * - 输出统计：总输出帧数、I/P 帧数量、总输出字节数
 * - 性能统计：平均处理时间、当前 FPS、当前码率
 * - 队列状态：当前队列大小、历史最大队列大小
 *
 * 使用方式：
 * @code
 * // 通过代理回调获取统计信息
 * - (void)jpegToH264Converter:(JLJpegToH264Converter *)converter
 *         didUpdateStatistics:(JLConverterStatistics *)stats {
 *     NSLog(@"FPS: %.1f, Bitrate: %.0f kbps, Queue: %ld/%ld",
 *           stats.currentFPS,
 *           stats.currentBitrate / 1000.0,
 *           (long)stats.currentQueueSize,
 *           (long)stats.maxQueueSizeReached);
 * }
 * @endcode
 */
@interface JLConverterStatistics : NSObject

#pragma mark - 输入统计

/** 总输入帧数（调用 feedJpegData 的次数） */
@property (nonatomic, assign) NSInteger totalInputFrames;

/** 丢弃帧数（队列满时丢弃的帧） */
@property (nonatomic, assign) NSInteger droppedFrames;

/** 平均输入间隔（秒），反映输入帧率稳定性 */
@property (nonatomic, assign) NSTimeInterval averageInputInterval;

#pragma mark - 输出统计

/** 总输出帧数（成功编码的帧） */
@property (nonatomic, assign) NSInteger totalOutputFrames;

/** I 帧数量（关键帧） */
@property (nonatomic, assign) NSInteger iFrameCount;

/** P 帧数量（预测帧） */
@property (nonatomic, assign) NSInteger pFrameCount;

/** 总输出字节数（编码后的 H264 数据总大小） */
@property (nonatomic, assign) NSUInteger totalOutputBytes;

#pragma mark - 性能统计

/** 平均处理时间（秒），从输入到输出的平均耗时 */
@property (nonatomic, assign) NSTimeInterval averageProcessingTime;

/** 当前 FPS（每秒输出帧数） */
@property (nonatomic, assign) NSTimeInterval currentFPS;

/** 当前码率（bps），基于最近 1 秒的数据计算 */
@property (nonatomic, assign) CGFloat currentBitrate;

#pragma mark - 队列状态

/** 当前输入队列大小 */
@property (nonatomic, assign) NSInteger currentQueueSize;

/** 历史最大队列大小（用于评估流量控制） */
@property (nonatomic, assign) NSInteger maxQueueSizeReached;

@end

NS_ASSUME_NONNULL_END
