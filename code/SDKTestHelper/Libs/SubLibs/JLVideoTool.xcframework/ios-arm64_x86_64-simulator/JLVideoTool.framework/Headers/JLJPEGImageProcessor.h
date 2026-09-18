//
//  JLJPEGImageProcessor.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/27.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//
//  功能描述: 图像处理类
//  提供图像缩放、颜色空间转换等功能

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

/**
 图像处理器
 负责图像缩放、颜色空间转换等图像处理操作
 */
@interface JLJPEGImageProcessor : NSObject

/// 是否支持 GPU 加速
@property (nonatomic, assign, readonly) BOOL isGPUSupported;

/// GPU 是否已初始化
@property (nonatomic, assign, readonly) BOOL gpuInitialized;

/**
 初始化处理器

 @return 初始化后的处理器实例
 */
- (instancetype)init;

#pragma mark - 图像缩放

/**
 缩放 UIImage 到指定尺寸（保持宽高比）

 @param image 原始图像
 @param targetSize 目标尺寸
 @return 缩放后的图像
 */
- (nullable UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize;

/**
 使用 vImage 缩放 RGB 数据

 @param rgbBuffer 原始 RGB 数据
 @param origWidth 原始宽度
 @param origHeight 原始高度
 @param targetWidth 目标宽度
 @param targetHeight 目标高度
 @return 缩放后的 RGB 数据（调用者负责释放）
 */
- (nullable unsigned char *)scaleRGBBuffer:(unsigned char *)rgbBuffer
                                 origWidth:(int)origWidth
                                origHeight:(int)origHeight
                               targetWidth:(int)targetWidth
                              targetHeight:(int)targetHeight;

#pragma mark - GPU 处理

/**
 使用 GPU 进行颜色空间转换（RGB 到 YUV）

 @param image 输入图像
 @return 处理后的图像
 */
- (nullable UIImage *)processWithGPU:(UIImage *)image;

/**
 将 UIImage 转换为 RGB 数据

 @param image 输入图像
 @param width 输出宽度
 @param height 输出高度
 @return RGB 数据缓冲区（调用者负责释放）
 */
- (nullable unsigned char *)convertImageToRGB:(UIImage *)image
                                        width:(int *)width
                                       height:(int *)height;

#pragma mark - 尺寸计算

/**
 计算保持宽高比的缩放尺寸

 @param originalSize 原始尺寸
 @param targetSize 目标尺寸
 @return 计算后的缩放尺寸
 */
+ (CGSize)calculateScaleSize:(CGSize)originalSize targetSize:(CGSize)targetSize;

@end

NS_ASSUME_NONNULL_END
