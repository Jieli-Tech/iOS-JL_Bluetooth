//
//  JLJpegToH264Converter.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/06/04.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <JLVideoTool/JLJpegToH264Options.h>
#import <JLVideoTool/JLConverterStatistics.h>

NS_ASSUME_NONNULL_BEGIN

@class JLJpegToH264Converter;

#pragma mark - 代理协议

/**
 * JPEG 转 H264 转换器代理协议
 * 用于接收编码后的 H264 数据、状态变化和统计信息
 */
@protocol JLJpegToH264ConverterDelegate <NSObject>

@required

/**
 * 输出 H264 数据包回调
 * 
 * @param converter 转换器实例
 * @param h264Data H264 NALU 数据（含起始码 0x00000001）
 * @param timestamp 时间戳（与输入 JPEG 对应）
 * @param isKeyFrame 是否为关键帧（I 帧）
 * 
 * @note 此回调在工作线程调用，如需更新 UI 请切换到主线程
 */
- (void)jpegToH264Converter:(JLJpegToH264Converter *)converter
          didOutputH264Data:(NSData *)h264Data
                  timestamp:(CMTime)timestamp
                 isKeyFrame:(BOOL)isKeyFrame;

@optional

/**
 * 转换器状态变化回调
 * @param converter 转换器实例
 * @param state 新状态
 */
- (void)jpegToH264Converter:(JLJpegToH264Converter *)converter
             didChangeState:(JLConverterState)state;

/**
 * 发生错误回调
 * @param converter 转换器实例
 * @param error 错误信息
 */
- (void)jpegToH264Converter:(JLJpegToH264Converter *)converter
           didFailWithError:(NSError *)error;

/**
 * 输入队列状态变化回调（可用于流量控制）
 * @param converter 转换器实例
 * @param queueSize 当前队列大小
 * @param maxQueueSize 队列最大容量
 */
- (void)jpegToH264Converter:(JLJpegToH264Converter *)converter
     inputQueueDidChangeSize:(NSInteger)queueSize
                maxQueueSize:(NSInteger)maxQueueSize;

/**
 * 统计信息回调（每秒一次）
 * @param converter 转换器实例
 * @param statistics 统计信息
 */
- (void)jpegToH264Converter:(JLJpegToH264Converter *)converter
        didUpdateStatistics:(JLConverterStatistics *)statistics;

@end

#pragma mark - 主转换器类

/**
 * JPEG → H264 流式转换器
 * 
 * 功能特性：
 * - 支持 JPEGTurbo 解码和尺寸调整
 * - 支持双编码后端（VideoToolbox 硬件编码 / OpenH264 软件编码）
 * - 自动 I/P 帧管理（不含 B 帧）
 * - 流式处理：边输入 JPEG 边输出 H264
 * - 实时统计和状态回调
 * 
 * 使用示例：
 * @code
 * JLJpegToH264Options *options = [JLJpegToH264Options defaultOptions];
 * JLJpegToH264Converter *converter = [[JLJpegToH264Converter alloc] initWithOptions:options];
 * converter.delegate = self;
 * 
 * // 输入 JPEG 数据
 * [converter feedJpegData:jpegData timestamp:CMTimeMake(frameIndex, 30)];
 * 
 * // 结束转换
 * [converter flush];
 * [converter stop];
 * @endcode
 */
@interface JLJpegToH264Converter : NSObject

/**
 * 初始化转换器
 * @param options 配置选项
 * @return 转换器实例，失败返回 nil
 */
- (instancetype)initWithOptions:(JLJpegToH264Options *)options;

/** 代理，用于接收输出数据和状态回调 */
@property (nonatomic, weak, nullable) id<JLJpegToH264ConverterDelegate> delegate;

#pragma mark - 输入控制

/**
 * 异步输入 JPEG 数据
 * 
 * @param jpegData JPEG 原始数据
 * @param timestamp 时间戳，用于同步视频帧
 * 
 * @note 数据会被加入内部队列异步处理，不会阻塞调用线程
 * @note 如果队列已满，数据将被丢弃并触发错误回调
 */
- (void)feedJpegData:(NSData *)jpegData timestamp:(CMTime)timestamp;

/**
 * 同步输入 JPEG 数据
 * 
 * @param jpegData JPEG 原始数据
 * @param timestamp 时间戳
 * @return YES 成功入队，NO 队列已满
 * 
 * @note 此方法会立即返回入队结果，不会等待处理完成
 */
- (BOOL)feedJpegDataSync:(NSData *)jpegData timestamp:(CMTime)timestamp;

#pragma mark - 流程控制

/**
 * 刷新缓冲区
 * 强制输出编码器缓冲区中的剩余数据，等待所有数据处理完成
 */
- (void)flush;

/**
 * 停止转换
 * 立即停止接收新数据，清空队列，释放编码器资源
 */
- (void)stop;

/**
 * 重置状态
 * 重置转换器到初始状态，可重新开始新的转换任务
 */
- (void)reset;

#pragma mark - 编码器信息（只读）

/**
 * 实际使用的编码器类型
 * 可能与配置不同（如自动模式下回退到软件编码）
 */
@property (nonatomic, readonly) JLEncoderType actualEncoderType;

/**
 * 编码器回退原因
 * 如果从硬件回退到软件编码，此属性包含回退原因
 * 未发生回退时为 nil
 */
@property (nonatomic, readonly, copy, nullable) NSString *encoderFallbackReason;

/**
 * 当前是否使用硬件加速
 * YES 表示使用 VideoToolbox 硬件编码
 */
@property (nonatomic, readonly) BOOL isHardwareAccelerated;

@end

NS_ASSUME_NONNULL_END
