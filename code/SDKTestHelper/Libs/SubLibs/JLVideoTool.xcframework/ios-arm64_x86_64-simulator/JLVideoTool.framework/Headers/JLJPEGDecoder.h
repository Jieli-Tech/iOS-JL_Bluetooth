//
//  JLJPEGDecoder.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: JPEG / MJPEG 图片解码器，提供同步单帧解码和快速解码模式
//

#import <JLVideoTool/JLVideoDecoder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 JPEG / MJPEG 图片解码器

 @discussion
 继承自 JLVideoDecoder，针对 JPEG 图片解码场景优化：
 - 提供同步解码便捷方法（decodeJPEGData:），适合单张图片解码
 - 支持快速解码模式（fastDecodeMode），牺牲部分画质换取更低延迟
 - 输出像素格式为 NV12 (420YpCbCr8BiPlanarVideoRange)，与 AVSampleBufferDisplayLayer 兼容
 - 输出帧类型固定为 JLVideoFrameTypeKey

 典型用法（同步单帧）:
 @code
 JLDecoderOptions *opts = [JLDecoderOptions optionsWithType:JLDecoderTypeJPEG];
 JLJPEGDecoder *decoder = [[JLJPEGDecoder alloc] initWithOptions:opts];
 JLVideoFrame *frame = [decoder decodeJPEGData:jpegData];
 // frame.pixelBuffer 可直接用于 AVSampleBufferDisplayLayer
 @endcode
 */
@interface JLJPEGDecoder : JLVideoDecoder

/// 快速解码模式，默认 NO；开启后跳过 loop filter 和部分 IDCT 以降低延迟
@property (nonatomic, assign) BOOL fastDecodeMode;

/// 是否保留 EXIF 信息，默认 NO（当前版本预留，暂未实现完整 EXIF 解析）
@property (nonatomic, assign) BOOL preserveEXIF;

/**
 同步解码单张 JPEG 图片

 @param jpegData JPEG 编码数据
 @return 解码后的视频帧（NV12 像素格式），失败返回 nil
 @discussion 该方法阻塞当前线程直到解码完成，适合单张图片场景。
             内部自动完成编解码器初始化
 */
- (nullable JLVideoFrame *)decodeJPEGData:(NSData *)jpegData;

/**
 同步解码单张 JPEG 图片（带时间戳）

 @param jpegData JPEG 编码数据
 @param pts 显示时间戳（毫秒）
 @return 解码后的视频帧，失败返回 nil
 @discussion 时间戳会写入输出帧的 presentationTimeStamp
 */
- (nullable JLVideoFrame *)decodeJPEGData:(NSData *)jpegData
                    presentationTimeStamp:(int64_t)pts;

@end

NS_ASSUME_NONNULL_END
