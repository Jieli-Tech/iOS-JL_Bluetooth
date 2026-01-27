//
//  JpegProcessor.h
//  JLMapNaviCast
//
//  Created by EzioChan on 2025/8/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JpegProcessor : NSObject

/**
 * 缩放并压缩JPEG图片
 * @param image 原始UIImage对象
 * @param targetSize 目标尺寸（会强制拉伸到这个尺寸）
 * @param quality 压缩质量 (0.0-1.0)
 * @param maxFileSize 最大文件大小（KB），设为0表示不限制
 * @return 处理后的JPEG数据
 */
+ (NSData *)compressImage:(UIImage *)image
               targetSize:(CGSize)targetSize
                 quality:(float)quality
             maxFileSize:(NSUInteger)maxFileSize;



@end

NS_ASSUME_NONNULL_END




