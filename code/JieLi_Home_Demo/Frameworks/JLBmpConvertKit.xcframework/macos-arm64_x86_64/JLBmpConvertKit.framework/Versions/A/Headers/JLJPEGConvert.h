//
//  JLJPEGConvert.h
//  JLBmpConvertKit
//
//  Created by EzioChan on 2025/6/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

#import <JLBmpConvertKit/JLJPEGConvertTypes.h>
#import <JLBmpConvertKit/JLJPEGConvertOption.h>
#import <JLBmpConvertKit/JLJPEGConvertResult.h>

NS_ASSUME_NONNULL_BEGIN

/// JLJPEG JPEG 编解码转换类
@interface JLJPEGConvert : NSObject

#pragma mark - JPEG 编码

/// 将像素数据编码为 JLJPEG
/// @param option 编码配置选项
/// @param pixelData 输入像素数据（格式由 option.pixelFormat 指定）
/// @return 编码结果（包含 JPEG 数据或错误信息）
+ (JLJPEGConvertResult *)encode:(JLJPEGConvertOption *)option
                      pixelData:(NSData *)pixelData;

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST
/// 将 UIImage 编码为 JPEG（iOS/macCatalyst，自动转换为 BGRA8888）
/// @param option 编码配置选项
/// @param image 输入图像
/// @return 编码结果
+ (JLJPEGConvertResult *)encode:(JLJPEGConvertOption *)option
                          image:(UIImage *)image;
#endif

#if TARGET_OS_OSX
/// 将 NSImage 编码为 JPEG（macOS，自动转换为 BGRA8888）
/// @param option 编码配置选项
/// @param image 输入图像
/// @return 编码结果
+ (JLJPEGConvertResult *)encode:(JLJPEGConvertOption *)option
                        nsImage:(NSImage *)image NS_AVAILABLE_MAC(11_0);
#endif

/// 将图像数据（PNG/JPEG/原始像素）编码为 JPEG
/// @param option 编码配置选项
/// @param imageData 图像数据（自动识别格式）
/// @return 编码结果
+ (JLJPEGConvertResult *)encodeImageData:(JLJPEGConvertOption *)option
                               imageData:(NSData *)imageData;

/// 从文件路径编码为 JPEG
/// @param option 编码配置选项
/// @param filePath 图像文件路径（支持 PNG/JPEG 等格式）
/// @return 编码结果
+ (JLJPEGConvertResult *)encodeFile:(JLJPEGConvertOption *)option
                           filePath:(NSString *)filePath;

#pragma mark - JPEG 解码

/// 将 JPEG 数据解码为像素数据
/// @param jpegData 输入 JPEG 数据
/// @param pixelFormat 目标像素格式
/// @return 解码结果（包含像素数据和图像信息）
+ (JLJPEGConvertResult *)decode:(NSData *)jpegData
                    pixelFormat:(JLJPEGPixelFormat)pixelFormat;

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST
/// 将 JPEG 数据解码为 UIImage（iOS/macCatalyst）
/// @param jpegData 输入 JPEG 数据
/// @return 解码后的 UIImage，失败返回 nil
+ (nullable UIImage *)decodeToImage:(NSData *)jpegData;
#endif

#if TARGET_OS_OSX
/// 将 JPEG 数据解码为 NSImage（macOS）
/// @param jpegData 输入 JPEG 数据
/// @return 解码后的 NSImage，失败返回 nil
+ (nullable NSImage *)decodeToNSImage:(NSData *)jpegData NS_AVAILABLE_MAC(11_0);
#endif

#pragma mark - 资源转换辅助

/// 生成用于 resconv 转换的 JSON 配置
/// @param option 转换选项
/// @return JSON 配置字符串
+ (NSString *)generateResourceConfig:(JLJPEGConvertOption *)option;

/// 验证选项配置是否可用于资源转换
/// @param option 转换选项
/// @param error 错误信息输出
/// @return YES 表示配置有效
+ (BOOL)validateForResourceConversion:(JLJPEGConvertOption *)option
                                error:(NSError * _Nullable * _Nullable)error;

#pragma mark - 格式识别

/// 识别图像数据格式
/// @param data 图像数据
/// @return 识别的格式类型
+ (JLImageInputFormat)recognizeImageFormat:(NSData *)data;

/// 检查是否为 JPEG 格式
/// @param data 图像数据
/// @return YES 表示 JPEG 格式
+ (BOOL)isJPEGData:(NSData *)data;

/// 检查是否为 PNG 格式
/// @param data 图像数据
/// @return YES 表示 PNG 格式
+ (BOOL)isPNGData:(NSData *)data;

#pragma mark - 像素格式转换

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST
/// 将 UIImage 转换为 BGRA8888 格式数据
/// @param image 输入 UIImage
/// @return BGRA8888 像素数据，失败返回 nil
+ (nullable NSData *)convertImageToBGRA8888:(UIImage *)image;
#endif

#if TARGET_OS_OSX
/// 将 NSImage 转换为 BGRA8888 格式数据（macOS）
/// @param image 输入 NSImage
/// @return BGRA8888 像素数据，失败返回 nil
+ (nullable NSData *)convertNSImageToBGRA8888:(NSImage *)image NS_AVAILABLE_MAC(11_0);
#endif

@end

NS_ASSUME_NONNULL_END
