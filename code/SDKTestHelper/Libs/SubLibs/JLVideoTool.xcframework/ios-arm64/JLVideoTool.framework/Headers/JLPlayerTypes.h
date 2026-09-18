//
//  JLPlayerTypes.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 播放器模块通用类型定义，包含 H.264 格式、流格式、调试浮层样式和日志级别枚举
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - H.264 数据格式

/**
 H.264 裸流数据封装格式

 - JLH264FormatAnnexB: AnnexB 格式，使用 Start Code (0x00000001 / 0x000001) 分隔 NAL 单元
 - JLH264FormatAVCC: AVCC 格式，使用 4 字节大端长度前缀分隔 NAL 单元
 */
typedef NS_ENUM(NSInteger, JLH264Format) {
    JLH264FormatAnnexB,
    JLH264FormatAVCC,
};

#pragma mark - 流数据格式

/**
 裸流数据格式枚举

 - JLStreamFormatH264AnnexB: H.264 AnnexB 格式
 - JLStreamFormatH264AVCC: H.264 AVCC 格式
 - JLStreamFormatJPEG: JPEG 图片格式
 - JLStreamFormatPCM: PCM 音频格式
 */
typedef NS_ENUM(NSInteger, JLStreamFormat) {
    JLStreamFormatH264AnnexB,
    JLStreamFormatH264AVCC,
    JLStreamFormatJPEG,
    JLStreamFormatPCM,
};

#pragma mark - 调试浮层样式

/**
 调试浮层显示样式

 - JLDebugOverlayStyleMinimal: 简洁样式，仅显示关键指标
 - JLDebugOverlayStyleDetailed: 详细样式，显示完整统计信息
 - JLDebugOverlayStyleGraph: 图表样式，显示性能曲线（预留）
 */
typedef NS_ENUM(NSInteger, JLDebugOverlayStyle) {
    JLDebugOverlayStyleMinimal,
    JLDebugOverlayStyleDetailed,
    JLDebugOverlayStyleGraph,
};

#pragma mark - 日志级别

/**
 调试日志级别

 - JLLogLevelVerbose: 详细日志，包括内部状态变化
 - JLLogLevelDebug: 调试日志，如帧处理详情
 - JLLogLevelInfo: 信息日志，如状态变化
 - JLLogLevelWarning: 警告日志，如丢帧、同步偏移
 - JLLogLevelError: 错误日志，如解码失败
 - JLLogLevelOff: 关闭日志输出
 */
typedef NS_ENUM(NSInteger, JLLogLevel) {
    JLLogLevelVerbose,
    JLLogLevelDebug,
    JLLogLevelInfo,
    JLLogLevelWarning,
    JLLogLevelError,
    JLLogLevelOff,
};

NS_ASSUME_NONNULL_END
