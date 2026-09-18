//
//  JLJPEGCompressor.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/27.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//
//  功能描述: TurboJPEG 压缩/解压封装类
//  提供 JPEG 编码和解码的核心功能

#import <Foundation/Foundation.h>
#import <JLVideoTool/JLJPEGEncoder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 TurboJPEG 压缩器
 封装 libjpeg-turbo 的压缩和解压功能
 */
@interface JLJPEGCompressor : NSObject

/**
 压缩 RGB 数据为 JPEG

 @param rgbBuffer RGB 数据缓冲区
 @param width 图像宽度
 @param height 图像高度
 @param options 编码选项
 @param error 错误信息输出
 @return 压缩后的 JPEG 数据
 */
- (nullable NSData *)compressRGBBuffer:(unsigned char *)rgbBuffer
                                 width:(int)width
                                height:(int)height
                               options:(JLJPEGEncodeOptions *)options
                                 error:(NSError **)error;

/**
 解压 JPEG 数据为 RGB

 @param jpegData JPEG 数据
 @param width 输出图像宽度
 @param height 输出图像高度
 @param error 错误信息输出
 @return RGB 数据缓冲区（调用者负责释放）
 */
- (nullable unsigned char *)decompressJPEGData:(NSData *)jpegData
                                         width:(int *)width
                                        height:(int *)height
                                         error:(NSError **)error;

/**
 获取 JPEG 图像信息（不解压）

 @param jpegData JPEG 数据
 @param width 输出图像宽度
 @param height 输出图像高度
 @param subsamp 输出采样格式
 @param colorspace 输出色彩空间
 @param error 错误信息输出
 @return 是否成功获取信息
 */
- (BOOL)getJPEGInfo:(NSData *)jpegData
              width:(int *)width
             height:(int *)height
           subsamp:(nullable int *)subsamp
        colorspace:(nullable int *)colorspace
              error:(NSError **)error;

/**
 计算压缩后的最大缓冲区大小

 @param width 图像宽度
 @param height 图像高度
 @param sampling 采样格式
 @return 最大缓冲区大小（字节）
 */
+ (unsigned long)maxBufferSizeForWidth:(int)width
                                height:(int)height
                              sampling:(JLJPEGSamplingFormat)sampling;

@end

NS_ASSUME_NONNULL_END
