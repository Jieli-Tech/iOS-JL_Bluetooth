//
//  JLJPEGDataSeparator.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/27.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//
//  功能描述: JPEG 数据分离器
//  提供 JPEG 头部和扫描数据的分离、合并功能

#import <Foundation/Foundation.h>
#import <JLVideoTool/JLJPEGEncoder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 JPEG 数据分离器
 负责将 JPEG 数据分离为头部和扫描数据，以及合并操作
 */
@interface JLJPEGDataSeparator : NSObject

/// 标准头部大小（字节）
@property (nonatomic, class, readonly) NSUInteger standardHeaderSize;

/**
 分离 JPEG 数据为头部和扫描数据

 @param jpegData 输入的 JPEG 数据
 @param error 错误信息输出
 @return 分离后的数据结构
 */
- (nullable JLJPEGSeparatedData *)separateJPEGData:(NSData *)jpegData
                                             error:(NSError **)error;

/**
 提取 JPEG 扫描数据（去除头部）

 @param jpegData 输入的 JPEG 数据
 @param error 错误信息输出
 @return 仅包含扫描数据的 NSData
 */
- (nullable NSData *)extractScanData:(NSData *)jpegData
                               error:(NSError **)error;

/**
 提取 JPEG 头部数据

 @param jpegData 输入的 JPEG 数据
 @param error 错误信息输出
 @return 仅包含头部数据的 NSData
 */
- (nullable NSData *)extractHeaderData:(NSData *)jpegData
                                 error:(NSError **)error;

/**
 合并头部和扫描数据为完整 JPEG

 @param headerData 头部数据
 @param scanData 扫描数据
 @param error 错误信息输出
 @return 完整的 JPEG 数据
 */
- (nullable NSData *)combineHeaderData:(NSData *)headerData
                              scanData:(NSData *)scanData
                                 error:(NSError **)error;

/**
 验证 JPEG 数据是否有效

 @param jpegData JPEG 数据
 @return 是否有效
 */
+ (BOOL)isValidJPEGData:(NSData *)jpegData;

/**
 查找 JPEG 标记位置

 @param jpegData JPEG 数据
 @param marker 标记字节（如 0xDA 表示 SOS）
 @return 标记位置，未找到返回 NSNotFound
 */
+ (NSUInteger)findMarker:(NSData *)jpegData marker:(uint8_t)marker;

@end

NS_ASSUME_NONNULL_END
