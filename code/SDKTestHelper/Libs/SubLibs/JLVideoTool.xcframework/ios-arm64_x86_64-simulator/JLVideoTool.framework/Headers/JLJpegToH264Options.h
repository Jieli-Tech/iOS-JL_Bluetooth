//
//  JLJpegToH264Options.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/06/04.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 枚举定义

/**
 * 尺寸调整模式
 * 用于指定如何将输入 JPEG 调整为目标输出尺寸
 */
typedef NS_ENUM(NSInteger, JLResizeMode) {
    JLResizeModeScale,          ///< 缩放（可能变形）- 直接拉伸到目标尺寸
    JLResizeModeAspectFit,      ///< 适应（保持比例，可能留黑边）- 完整显示图片
    JLResizeModeAspectFill,     ///< 填充（保持比例，可能裁剪）- 填满目标区域
    JLResizeModeCropCenter,     ///< 中心裁剪 - 从中心裁剪出目标尺寸
};

/**
 * 编码预设
 * 控制编码速度与质量的平衡，仅对软件编码器（OpenH264）有效
 */
typedef NS_ENUM(NSInteger, JLEncodingPreset) {
    JLEncodingPresetUltraFast,  ///< 最快，质量最低
    JLEncodingPresetSuperFast,
    JLEncodingPresetVeryFast,
    JLEncodingPresetFaster,
    JLEncodingPresetFast,
    JLEncodingPresetMedium,     ///< 平衡（默认推荐）
    JLEncodingPresetSlow,
    JLEncodingPresetSlower,
    JLEncodingPresetVerySlow,   ///< 最慢，质量最好
};

/**
 * JPEG 解码目标格式
 * 决定 JPEGTurbo 解码后的像素格式
 */
typedef NS_ENUM(NSInteger, JLJpegDecodeFormat) {
    JLJpegDecodeFormatYUV420P,  ///< YUV 4:2:0 平面格式（推荐，H264 编码器原生支持）
    JLJpegDecodeFormatYUV422,   ///< YUV 4:2:2 格式
    JLJpegDecodeFormatRGB24,    ///< RGB 24位
    JLJpegDecodeFormatBGR24,    ///< BGR 24位
};

/**
 * 帧类型
 * H264 编码中的帧类型
 */
typedef NS_ENUM(NSInteger, JLFrameType) {
    JLFrameTypeI,               ///< I 帧（关键帧）- 完整编码，可独立解码
    JLFrameTypeP,               ///< P 帧（预测帧）- 参考前一帧编码，体积更小
};

/**
 * 转换器状态
 */
typedef NS_ENUM(NSInteger, JLConverterState) {
    JLConverterStateIdle,       ///< 空闲状态，等待输入
    JLConverterStateRunning,    ///< 运行中，正常处理数据
    JLConverterStatePaused,     ///< 暂停状态
    JLConverterStateFlushing,   ///< 刷新中，输出缓冲区剩余数据
    JLConverterStateStopped,    ///< 已停止
    JLConverterStateError,      ///< 发生错误
};

/**
 * 编码器类型
 * 用于指定使用哪种编码器实现
 */
typedef NS_ENUM(NSInteger, JLEncoderType) {
    JLEncoderTypeAuto,          ///< 自动选择（优先硬件编码，失败时回退到软件）
    JLEncoderTypeHardware,      ///< 强制使用 VideoToolbox 硬件编码
    JLEncoderTypeSoftware,      ///< 强制使用 OpenH264 软件编码
};

/**
 * H264 配置文件（硬件编码用）
 * 仅对 VideoToolbox 硬件编码器有效
 */
typedef NS_ENUM(NSInteger, JLH264Profile) {
    JLH264ProfileBaseline,      ///< Baseline Profile - 基础配置，兼容性最好
    JLH264ProfileMain,          ///< Main Profile - 主流配置
    JLH264ProfileHigh,          ///< High Profile - 高质量配置（默认）
};

#pragma mark - 配置类

/**
 * JPEG 转 H264 编码器配置选项
 * 
 * 使用示例：
 * @code
 * JLJpegToH264Options *options = [JLJpegToH264Options defaultOptions];
 * options.outputWidth = 1920;
 * options.outputHeight = 1080;
 * options.bitrate = 4000000;  // 4Mbps
 * options.encoderType = JLEncoderTypeAuto;  // 自动选择编码器
 * @endcode
 */
@interface JLJpegToH264Options : NSObject <NSCopying>

#pragma mark - 输出视频尺寸

/** 目标输出宽度（像素），默认 1920 */
@property (nonatomic, assign) NSInteger outputWidth;

/** 目标输出高度（像素），默认 1080 */
@property (nonatomic, assign) NSInteger outputHeight;

/** 尺寸调整模式，默认 JLResizeModeAspectFit */
@property (nonatomic, assign) JLResizeMode resizeMode;

#pragma mark - 编码器选择

/** 
 * 编码器类型，默认 JLEncoderTypeAuto
 * Auto 模式下会优先尝试硬件编码，失败时自动回退到软件编码
 */
@property (nonatomic, assign) JLEncoderType encoderType;

#pragma mark - 编码参数

/** 目标码率（bps），默认 4000000 (4Mbps) */
@property (nonatomic, assign) NSInteger bitrate;

/** 目标帧率（fps），默认 30 */
@property (nonatomic, assign) NSInteger frameRate;

/** I 帧间隔（帧数），默认 30，即每秒一个关键帧 */
@property (nonatomic, assign) NSInteger keyFrameInterval;

/** 
 * 编码预设，默认 JLEncodingPresetMedium
 * 仅对软件编码器（OpenH264）有效
 */
@property (nonatomic, assign) JLEncodingPreset preset;

/** 
 * 是否启用 CABAC 熵编码，默认 YES
 * 仅对软件编码器有效，可提高压缩效率
 */
@property (nonatomic, assign) BOOL enableCABAC;

#pragma mark - 硬件编码参数（VideoToolbox）

/** 
 * 是否启用实时编码模式，默认 YES
 * 实时模式可降低编码延迟，适合流媒体场景
 */
@property (nonatomic, assign) BOOL hardwareRealtimeEncoding;

/** 
 * H264 配置文件，默认 JLH264ProfileHigh
 * 仅对硬件编码器有效
 */
@property (nonatomic, assign) JLH264Profile h264Profile;

/** 
 * 是否启用硬件码率控制，默认 YES
 * 启用后使用平均码率（ABR），禁用后使用质量模式
 */
@property (nonatomic, assign) BOOL hardwareRateControlEnabled;

/** 
 * 硬件编码质量级别，范围 0.0-1.0，默认 0.75
 * 仅在 hardwareRateControlEnabled = NO 时有效
 */
@property (nonatomic, assign) CGFloat hardwareQualityLevel;

#pragma mark - 预处理参数

/** 
 * JPEG 解码目标格式，默认 JLJpegDecodeFormatYUV420P
 * 建议选择 YUV420P，与 H264 编码器原生格式一致，避免额外转换
 */
@property (nonatomic, assign) JLJpegDecodeFormat decodeFormat;

/** 
 * 是否保持原始宽高比，默认 YES
 * 启用后根据 resizeMode 自动计算实际输出尺寸
 */
@property (nonatomic, assign) BOOL keepAspectRatio;

/** 
 * 填充颜色（当 resizeMode 为 AspectFit 且需要填充时）
 * 默认 nil（使用黑色填充）
 */
@property (nonatomic, strong, nullable) UIColor *fillColor;

#pragma mark - 性能参数

/** 
 * 输入队列最大长度，默认 60
 * 超过此长度后新数据将被丢弃，防止内存无限增长
 */
@property (nonatomic, assign) NSInteger maxInputQueueSize;

/** 
 * 是否允许使用硬件加速，默认 YES
 * 仅在 encoderType = Auto 时有效
 */
@property (nonatomic, assign) BOOL enableHardwareAcceleration;

/** 
 * 工作线程数，默认 2
 * 仅对软件编码器有效，建议设置为 CPU 核心数
 */
@property (nonatomic, assign) NSInteger workerThreadCount;

#pragma mark - 工厂方法

/**
 * 默认配置
 * 1920x1080, 4Mbps, 30fps, 自动编码器选择
 */
+ (instancetype)defaultOptions;

/**
 * 高清配置 (1080p)
 * 1920x1080, 8Mbps, 30fps
 */
+ (instancetype)hdOptions;

/**
 * 标清配置 (720p)
 * 1280x720, 3Mbps, 30fps
 */
+ (instancetype)sdOptions;

/**
 * 自定义分辨率配置
 * @param width 输出宽度
 * @param height 输出高度
 * @return 配置实例
 */
+ (instancetype)optionsWithWidth:(NSInteger)width height:(NSInteger)height;

@end

NS_ASSUME_NONNULL_END
