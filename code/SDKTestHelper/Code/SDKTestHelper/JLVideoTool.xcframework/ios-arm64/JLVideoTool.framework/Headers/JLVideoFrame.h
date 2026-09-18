//
//  JLVideoFrame.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 视频帧数据封装，包装 CVPixelBufferRef 并提供格式转换能力
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 视频帧类型枚举

 - JLVideoFrameTypeKey: 关键帧（I 帧），可独立解码
 - JLVideoFrameTypeInter: 非关键帧（P 帧），依赖前序帧解码
 - JLVideoFrameTypeB: B 帧，依赖前后双向参考帧解码
 */
typedef NS_ENUM(NSInteger, JLVideoFrameType) {
    JLVideoFrameTypeKey,
    JLVideoFrameTypeInter,
    JLVideoFrameTypeB,
};

/**
 视频帧数据封装类

 @discussion
 封装解码后的单帧视频数据，核心持有 CVPixelBufferRef。
 支持将像素缓冲转换为 UIImage 或 RGBA NSData，方便上层展示或进一步处理。
 使用完毕后应调用 releaseFrame 或让对象 dealloc 自动释放底层资源。
 */
@interface JLVideoFrame : NSObject

/// 像素缓冲引用（CVPixelBufferRef），持有底层图像数据
@property (nonatomic, assign, readonly) CVPixelBufferRef pixelBuffer;

/// 显示时间戳（Presentation Time Stamp）
@property (nonatomic, assign, readonly) CMTime presentationTimeStamp;

/// 解码时间戳（Decode Time Stamp）
@property (nonatomic, assign, readonly) CMTime decodeTimeStamp;

/// 帧类型（关键帧 / 非关键帧 / B 帧）
@property (nonatomic, assign, readonly) JLVideoFrameType frameType;

/// 帧尺寸（像素）
@property (nonatomic, assign, readonly) CGSize size;

/// 像素格式（OSType，如 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange）
@property (nonatomic, assign, readonly) OSType pixelFormat;

/**
 使用像素缓冲和时间戳初始化视频帧

 @param pixelBuffer 像素缓冲（内部会 retain）
 @param pts 显示时间戳
 @return 初始化后的视频帧对象
 */
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
              presentationTimeStamp:(CMTime)pts;

/**
 使用完整参数初始化视频帧

 @param pixelBuffer 像素缓冲（内部会 retain）
 @param pts 显示时间戳
 @param dts 解码时间戳
 @param frameType 帧类型
 @return 初始化后的视频帧对象
 */
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
              presentationTimeStamp:(CMTime)pts
                   decodeTimeStamp:(CMTime)dts
                         frameType:(JLVideoFrameType)frameType;

/**
 将像素缓冲转换为 UIImage

 @return UIImage 对象，转换失败返回 nil
 @discussion 内部使用 CIImage + CIContext 渲染，为同步操作，注意性能开销
 */
- (nullable UIImage *)toUIImage;

/**
 将像素缓冲转换为 RGBA 格式的 NSData

 @return RGBA 像素数据（每像素 4 字节，RGBA 排列），转换失败返回 nil
 @discussion 若源格式为 BGRA 则直接做色道交换；否则通过 Core Image 做格式转换
 */
- (nullable NSData *)toRGBAData;

/**
 手动释放底层像素缓冲

 @discussion 调用后 pixelBuffer 将被置为 NULL，通常在需要提前回收内存时使用
 */
- (void)releaseFrame;

@end

NS_ASSUME_NONNULL_END
