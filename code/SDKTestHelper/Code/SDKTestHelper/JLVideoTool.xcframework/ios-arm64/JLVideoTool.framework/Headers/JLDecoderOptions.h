//
//  JLDecoderOptions.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 解码器配置选项类，封装解码器初始化所需的全部参数，支持 NSCopying
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

/**
 解码器类型枚举

 - JLDecoderTypeH264: H.264 / AVC 视频解码
 - JLDecoderTypeJPEG: JPEG / MJPEG 图片解码
 */
typedef NS_ENUM(NSInteger, JLDecoderType) {
    JLDecoderTypeH264,
    JLDecoderTypeJPEG,
};

/**
 硬件加速类型枚举

 - JLDecoderHWAccelTypeAuto: 自动选择（优先硬件，失败回退软件）
 - JLDecoderHWAccelTypeSoftware: 强制软件解码
 - JLDecoderHWAccelTypeVideoToolbox: 强制 VideoToolbox 硬件解码
 */
typedef NS_ENUM(NSInteger, JLDecoderHWAccelType) {
    JLDecoderHWAccelTypeAuto,
    JLDecoderHWAccelTypeSoftware,
    JLDecoderHWAccelTypeVideoToolbox,
};

/**
 解码器配置选项

 @discussion
 封装解码器初始化所需的全部参数，包括解码器类型、硬件加速策略、
 视频分辨率/帧率/码率、像素格式、线程数、延迟模式和缓冲帧数等。
 支持 NSCopying 协议，可安全用于多线程场景的配置拷贝。
 使用前建议调用 isValid: 验证参数合法性。
 */
@interface JLDecoderOptions : NSObject <NSCopying>

/// 解码器类型（H.264 或 JPEG），默认 H.264
@property (nonatomic, assign) JLDecoderType decoderType;

/// 硬件加速类型（Auto / Software / VideoToolbox），默认 Auto
@property (nonatomic, assign) JLDecoderHWAccelType hwAccelType;

/// 视频宽度（像素），<=0 表示由解码器自动检测
@property (nonatomic, assign) int32_t width;

/// 视频高度（像素），<=0 表示由解码器自动检测
@property (nonatomic, assign) int32_t height;

/// 帧率（fps），默认 30，用于提示解码器预分配资源
@property (nonatomic, assign) int32_t frameRate;

/// 码率（bps），0 表示不指定
@property (nonatomic, assign) int64_t bitRate;

/// 输出像素格式（OSType），默认 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange（NV12）
@property (nonatomic, assign) OSType pixelFormat;

/// 解码线程数，0 表示 FFmpeg 自动选择，>0 强制指定
@property (nonatomic, assign) int threadCount;

/// 低延迟模式，默认 NO；开启后跳过部分后处理以降低延迟
@property (nonatomic, assign) BOOL lowLatencyMode;

/// 最大缓冲帧数（1-64），默认 4，用于 CVPixelBufferPool 预分配
@property (nonatomic, assign) int maxBufferFrames;

/**
 创建带默认值的配置实例

 @return 默认配置：H.264、Auto 加速、30fps、NV12、自动线程、4 帧缓冲
 */
+ (instancetype)defaultOptions;

/**
 按指定解码器类型创建配置实例

 @param type 解码器类型（H.264 / JPEG）
 @return 新配置实例，其他参数使用默认值
 */
+ (instancetype)optionsWithType:(JLDecoderType)type;

/**
 验证配置参数合法性

 @param error 验证失败时返回错误信息（可选）
 @return YES 表示配置有效，NO 表示无效（详见 error）
 @discussion 检查 width/height >= 0，maxBufferFrames 在 1-64 范围内
 */
- (BOOL)isValid:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
