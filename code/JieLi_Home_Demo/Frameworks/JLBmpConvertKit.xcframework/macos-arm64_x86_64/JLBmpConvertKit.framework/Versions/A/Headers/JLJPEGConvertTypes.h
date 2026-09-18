//
//  JLJPEGConvertTypes.h
//  JLBmpConvertKit
//
//  Created by EzioChan on 2025/6/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 基础枚举

/// 像素格式
typedef NS_ENUM(NSUInteger, JLJPEGPixelFormat) {
    JLJPEGPixelFormatBGRA8888,  // BGRA 排列，32位
    JLJPEGPixelFormatBGR888,    // BGR 排列，24位
    JLJPEGPixelFormatA8,        // Alpha 单通道，8位
};

/// 分块方式
typedef NS_ENUM(NSUInteger, JLJPEGBlockMode) {
    JLJPEGBlockMode32x16,       // 32x16 分块
    JLJPEGBlockMode32x32,       // 32x32 分块
};

/// YUV 采样方式
typedef NS_ENUM(NSUInteger, JLJPEGYUVSample) {
    JLJPEGYUVSample444,         // 4:4:4 采样
    JLJPEGYUVSample422,         // 4:2:2 采样
    JLJPEGYUVSample420,         // 4:2:0 采样
};

/// YUV 转换规范
typedef NS_ENUM(NSUInteger, JLJPEGBTMode) {
    JLJPEGBTModeBT709,          // BT.709 标准
    JLJPEGBTModeBT601,          // BT.601 标准
};

#pragma mark - 资源类型枚举

/// 资源类型
typedef NS_ENUM(NSUInteger, JLResourceType) {
    JLResourceTypeBIN,          // BIN 原始数据
    JLResourceTypeRLE,          // RLE 压缩
    JLResourceTypeETC2,         // ETC2 压缩纹理
};

/// LVGL 版本
typedef NS_ENUM(NSUInteger, JLLVGLVersion) {
    JLLVGLVersion8,             // LVGL 8.x
    JLLVGLVersion9,             // LVGL 9.x
};

/// 图像格式
typedef NS_ENUM(NSUInteger, JLImageFormat) {
    JLImageFormatARGB8888,      // TRUE_COLOR_ALPHA_ARGB8888
    JLImageFormatARGB8565,      // TRUE_COLOR_ALPHA_ARGB8565
    JLImageFormatRGB888,        // TRUE_COLOR_RGB888
    JLImageFormatRGB565,        // TRUE_COLOR_RGB565
    JLImageFormatIndexed1Bit,   // INDEXED_1BIT
    JLImageFormatIndexed2Bit,   // INDEXED_2BIT
    JLImageFormatIndexed4Bit,   // INDEXED_4BIT
    JLImageFormatIndexed8Bit,   // INDEXED_8BIT
    JLImageFormatAlpha1Bit,     // ALPHA_1BIT
    JLImageFormatAlpha2Bit,     // ALPHA_2BIT
    JLImageFormatAlpha4Bit,     // ALPHA_4BIT
    JLImageFormatAlpha8Bit,     // ALPHA_8BIT
};

/// 块大小
typedef NS_ENUM(NSUInteger, JLBlockSize) {
    JLBlockSize64x1,            // BLOCK_64x1
    JLBlockSize8x8,             // BLOCK_8x8
    JLBlockSize256x1,           // BLOCK_256x1
    JLBlockSize16x16,           // BLOCK_16x16
};

/// 晶圆类型
typedef NS_ENUM(NSUInteger, JLWaferType) {
    JLWaferTypeBR33,            // BR33
    JLWaferTypeWL83,            // WL83
    JLWaferTypeALL,             // ALL
};

/// CLUT 格式
typedef NS_ENUM(NSUInteger, JLCLUTFormat) {
    JLCLUTFormatARGB8888,       // ARGB8888
    JLCLUTFormatARGB8565,       // ARGB8565
    JLCLUTFormatRGB888,         // RGB888
    JLCLUTFormatRGB565,         // RGB565
};

/// YUV 格式
typedef NS_ENUM(NSUInteger, JLYUVFormat) {
    JLYUVFormatYUYV,            // YUYV
    JLYUVFormatUYVY,            // UYVY
};

#pragma mark - 图像输入格式识别

/// 输入数据格式
typedef NS_ENUM(NSUInteger, JLImageInputFormat) {
    JLImageInputFormatUnknown,      // 未知格式
    JLImageInputFormatPNG,          // PNG 格式
    JLImageInputFormatJPEG,         // JPEG 格式
    JLImageInputFormatRawPixel,     // 原始像素数据
};

#pragma mark - 错误码定义

/// JPEG 转换错误码
typedef NS_ENUM(NSInteger, JLJPEGConvertErrorCode) {
    // 参数错误 (1xx)
    JLJPEGConvertErrorInvalidParameter = 100,
    JLJPEGConvertErrorInvalidPixelFormat = 101,
    JLJPEGConvertErrorInvalidDimensions = 102,
    JLJPEGConvertErrorInvalidQuality = 103,

    // 资源类型错误 (2xx)
    JLJPEGConvertErrorInvalidResourceType = 200,
    JLJPEGConvertErrorInvalidImageFormat = 201,
    JLJPEGConvertErrorInvalidBlockSize = 202,
    JLJPEGConvertErrorMissingRequiredParam = 203,
    JLJPEGConvertErrorIncompatibleWafer = 204,

    // 编码/解码错误 (3xx)
    JLJPEGConvertErrorEncodeFailed = 300,
    JLJPEGConvertErrorDecodeFailed = 301,
    JLJPEGConvertErrorMemoryAllocation = 302,
    JLJPEGConvertErrorInvalidJPEGData = 303,

    // 系统错误 (4xx)
    JLJPEGConvertErrorFileNotFound = 400,
    JLJPEGConvertErrorFileRead = 401,
    JLJPEGConvertErrorFileWrite = 402,
};

/// JPEG 转换错误域
FOUNDATION_EXPORT NSErrorDomain const JLJPEGConvertErrorDomain;

NS_ASSUME_NONNULL_END
