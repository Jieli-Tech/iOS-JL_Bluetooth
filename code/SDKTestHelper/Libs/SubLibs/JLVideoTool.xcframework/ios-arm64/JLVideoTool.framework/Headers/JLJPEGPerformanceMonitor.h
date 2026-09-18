//
//  JLJPEGPerformanceMonitor.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/27.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//
//  功能描述: 性能监控器
//  提供 JPEG 编码性能统计和监控功能

#import <Foundation/Foundation.h>
#import <JLVideoTool/JLJPEGEncoder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 性能监控器
 负责记录和统计 JPEG 编码的性能数据
 */
@interface JLJPEGPerformanceMonitor : NSObject

/// 上次处理的性能统计
@property (nonatomic, strong, readonly, nullable) JLJPEGPerformanceMetrics *lastMetrics;

/// 所有性能记录
@property (nonatomic, strong, readonly) NSArray<JLJPEGPerformanceMetrics *> *allMetrics;

/// 平均处理速度（MP/s）
@property (nonatomic, assign, readonly) double averageSpeed;

/// 平均压缩比率
@property (nonatomic, assign, readonly) double averageCompressionRatio;

/**
 开始计时
 */
- (void)startTiming;

/**
 结束计时并记录性能数据

 @param mode 处理模式
 @param width 图像宽度
 @param height 图像高度
 @param inputSize 输入数据大小
 @param outputSize 输出数据大小
 @return 性能统计对象
 */
- (JLJPEGPerformanceMetrics *)stopTimingAndRecord:(JLJPEGProcessingMode)mode
                                            width:(NSInteger)width
                                           height:(NSInteger)height
                                        inputSize:(NSUInteger)inputSize
                                       outputSize:(NSUInteger)outputSize;

/**
 直接记录性能数据

 @param mode 处理模式
 @param time 处理耗时
 @param width 图像宽度
 @param height 图像高度
 @param inputSize 输入数据大小
 @param outputSize 输出数据大小
 @return 性能统计对象
 */
- (JLJPEGPerformanceMetrics *)recordMetrics:(JLJPEGProcessingMode)mode
                                       time:(NSTimeInterval)time
                                      width:(NSInteger)width
                                     height:(NSInteger)height
                                  inputSize:(NSUInteger)inputSize
                                 outputSize:(NSUInteger)outputSize;

/**
 清除所有记录
 */
- (void)clearMetrics;

/**
 生成性能报告

 @return 性能报告字符串
 */
- (NSString *)generateReport;

@end

NS_ASSUME_NONNULL_END
