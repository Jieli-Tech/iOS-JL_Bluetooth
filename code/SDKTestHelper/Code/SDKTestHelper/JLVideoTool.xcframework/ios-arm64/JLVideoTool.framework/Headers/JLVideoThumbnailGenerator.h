//
//  JLVideoThumbnailGenerator.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/01/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JLVideoInfo;

@interface JLVideoThumbnailGenerator : NSObject

/// 获取视频信息（包含时长、格式、编码、fps、分辨率等）
/// @param videoPath 视频文件路径
/// @param completion 回调 (info: 视频信息, error: 错误信息)
+ (void)getVideoInfo:(NSString *)videoPath
          completion:(void(^)(JLVideoInfo * _Nullable info, NSError * _Nullable error))completion;

/// 获取视频的第一帧作为封面图
/// @param videoPath 视频文件路径
/// @param completion 回调 (image: 封面图, error: 错误信息)
+ (void)generateThumbnailFromVideo:(NSString *)videoPath
                        completion:(void(^)(UIImage * _Nullable image, NSError * _Nullable error))completion;

/// 获取视频信息和封面图（分离返回）
/// @param videoPath 视频文件路径
/// @param completion 回调 (info: 视频信息, image: 封面图, error: 错误信息)
+ (void)getVideoInfoAndThumbnail:(NSString *)videoPath
                      completion:(void(^)(JLVideoInfo * _Nullable info,
                                          UIImage * _Nullable image,
                                          NSError * _Nullable error))completion;

/// 获取视频信息和封面图（包含在 JLVideoInfo 中）
/// @param videoPath 视频文件路径
/// @param completion 回调 (info: 包含缩略图的视频信息, error: 错误信息)
+ (void)getVideoInfoWithThumbnail:(NSString *)videoPath
                       completion:(void(^)(JLVideoInfo * _Nullable info,
                                           NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
