//
//  JLBmpCovert.h
//  JLBmpCovertKit
//
//  Created by EzioChan on 2024/9/9.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 图像转换类型
typedef NS_ENUM(NSUInteger, JLBmpConvertType) {
    /// 695N 图像转换 RGB 转换成 695N 芯片对应的图像资源
    /// 对应原 BR23 转换算法
    JLBmpConvertType695N_RBG = 0,
    /// 701N 图像转换 RGB 转换成 701N 芯片对应的图像资源
    /// 对应原 BR28 转换的算法
    JLBmpConvertType701N_RBG = 1,
    /// 701N 图像转换 ARGB 转换成 701N 芯片对应的图像资源
    /// 对应原 BR28_ARBG 转换的算法
    JLBmpConvertType701N_ARBG = 2,
    /// 701N 图像转换 RGB 转换成 701N 芯片对应的图像资源(不打包封装）
    /// 对应原 BR28_RGB_NO_PACK 转换的算法(不打包封装)
    JLBmpConvertType701N_RBG_NO_PACK = 3,
    /// 701N 图像转换 ARGB 转换成 701N 芯片对应的图像资源(不打包封装)
    /// 对应原 BR28_ARGB_NO_PACK 转换的算法(不打包封装)
    JLBmpConvertType701N_ARGB_NO_PACK = 4,
    /// 707N 图像转换 RGB 转换成 707N 芯片对应的图像资源
    /// 对应 BR35 转换的算法
    JLBmpConvertType707N_RBG = 5,
    /// 707N 图像转换 ARGB 转换成 707N 芯片对应的图像资源
    /// 对应 BR35_ARGB 转换的算法
    JLBmpConvertType707N_ARGB = 6,
    /// 707N 图像转换 RGB 转换成 707N 芯片对应的图像资源(不打包封装)
    /// 对应 BR35_RGB_NO_PACK 转换的算法(不打包封装)
    JLBmpConvertType707N_ARGB_NO_PACK = 7,
    /// 707N 图像转换 RGB 转换成 707N 芯片对应的图像资源(不打包封装)
    /// 对应 BR35_RGB_NO_PACK 转换的算法(不打包封装)
    JLBmpConvertType707N_RBG_NO_PACK = 8
};

typedef void(^JLBmpCovertCallBack)(NSString *inFilePath,NSString *__nullable outFilePath,NSError *__nullable error);

typedef void(^JLBmpCovertCallBack2)(NSData *__nullable outFileData,NSError *__nullable error);

/// 图像转换
@interface JLBmpConvert : NSObject

/// 图片转换
/// - Parameters:
///   - type: 转换类型
///   - inFilePath: 输入文件
///   - outFilePath: 输出文件
///   - completion: 回调
+(void)covert:(JLBmpConvertType)type
  inFilePath:(NSString *_Nonnull)inFilePath
 outFilePath:(NSString * __nullable)outFilePath
  completion:(JLBmpCovertCallBack _Nonnull)completion;

/// 图片转换
/// - Parameters:
///   - type: 转换类型
///   - inImage: 输入图片
///   - completion: 回调
+(void)covert:(JLBmpConvertType)type
  Image:(UIImage *)inImage
  completion:(JLBmpCovertCallBack2 _Nonnull)completion;


/// UIImage 转换成 BGRA
/// - Parameter image: 图片
+(NSData*)convertImageToBGRABytes:(UIImage *)image;

/// UIImage 转换成 RGBA
/// - Parameter image: 图片
+(NSData*)convertImageToRGBABytes:(UIImage *)image;


/// 图片缩放
/// - Parameters:
///   - image: 图片
///   - newSize: 缩放大小
/// - Returns: 缩放后的图片
+(NSData *)resizeImage:(UIImage*)image andResizeTo:(CGSize)newSize;

@end

NS_ASSUME_NONNULL_END
