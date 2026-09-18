//
//  JLVideoDecoderDelegate.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 视频解码器委托协议，定义解码器状态变化、帧输出和错误回调
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@class JLVideoDecoder;
@class JLVideoFrame;

NS_ASSUME_NONNULL_BEGIN

/**
 视频解码器委托协议

 @discussion
 所有方法均为 @optional，调用方按需实现。
 回调均在主线程（dispatch_get_main_queue）上触发。
 解码器输出支持两种形式：JLVideoFrame 封装对象 或 原始 CVPixelBufferRef。
 */
@protocol JLVideoDecoderDelegate <NSObject>

@optional

/**
 解码器已进入就绪状态，可以开始接收数据

 @param decoder 触发回调的解码器实例
 @discussion 在 start: 成功后触发，调用方此时可开始喂入编码数据
 */
- (void)decoderDidBecomeReady:(JLVideoDecoder *)decoder;

/**
 解码器发生错误

 @param decoder 触发回调的解码器实例
 @param error 错误详情，domain 为 JLVideoDecoderErrorDomain
 */
- (void)decoder:(JLVideoDecoder *)decoder didFailWithError:(NSError *)error;

/**
 解码器输出一帧视频（JLVideoFrame 封装形式）

 @param decoder 触发回调的解码器实例
 @param frame 解码后的视频帧，包含 pixelBuffer 和时间戳
 @discussion 回调完成后 frame 中的 pixelBuffer 会被释放，如需持有请自行 retain
 */
- (void)decoder:(JLVideoDecoder *)decoder didOutputFrame:(JLVideoFrame *)frame;

/**
 解码器输出一帧视频（CVPixelBufferRef 原始形式）

 @param decoder 触发回调的解码器实例
 @param pixelBuffer 解码后的像素缓冲，调用方可直接用于渲染
 @param pts 显示时间戳
 @discussion 回调完成后 pixelBuffer 会被释放，如需持有请自行 CVPixelBufferRetain
 */
- (void)decoder:(JLVideoDecoder *)decoder didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
    presentationTimeStamp:(CMTime)pts;

/**
 解码器刷新完成

 @param decoder 触发回调的解码器实例
 @discussion 调用 flush 后，解码器会排空内部缓冲区并触发此回调
 */
- (void)decoderDidFlush:(JLVideoDecoder *)decoder;

@end

NS_ASSUME_NONNULL_END
