//
//  JLJPEGConvertResult.h
//  JLBmpConvertKit
//
//  Created by EzioChan on 2025/6/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLBmpConvertKit/JLJPEGConvertTypes.h>

NS_ASSUME_NONNULL_BEGIN

/// JPEG 转换结果
@interface JLJPEGConvertResult : NSObject

/// 转换是否成功（result > 0 表示成功）
@property (nonatomic, assign) int32_t result;

/// 输出数据（编码时为 JL JPEG 数据，解码时为像素数据）
@property (nonatomic, strong, nullable) NSData *outData;

/// 图像宽度（解码时有效）
@property (nonatomic, assign) uint16_t width;

/// 图像高度（解码时有效）
@property (nonatomic, assign) uint16_t height;

/// 行跨度（解码时有效）
@property (nonatomic, assign) uint16_t stride;

/// 像素格式（解码时有效）
@property (nonatomic, assign) JLJPEGPixelFormat pixelFormat;

/// 错误信息（失败时有效）
@property (nonatomic, strong, nullable) NSError *error;

/// 输出文件路径（使用文件路径转换时有效）
@property (nonatomic, copy, nullable) NSString *outFilePath;

@end

NS_ASSUME_NONNULL_END
