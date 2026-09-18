//
//  JLVideoInfo.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/25.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 视频信息类 - 包含视频元数据和缩略图
@interface JLVideoInfo : NSObject

/// 视频时长（秒）
@property (nonatomic, assign, readonly) NSTimeInterval duration;

/// 视频封装格式（如：mp4, avi, mov, mkv）
@property (nonatomic, copy, readonly) NSString *containerFormat;

/// 视频编码格式（如：h264, hevc, mjpeg）
@property (nonatomic, copy, readonly) NSString *videoCodec;

/// 音频编码格式（如：aac, mp3, pcm），如果没有音频则为 nil
@property (nonatomic, copy, readonly, nullable) NSString *audioCodec;

/// 视频帧率（fps）
@property (nonatomic, assign, readonly) double fps;

/// 视频宽度（像素）
@property (nonatomic, assign, readonly) int width;

/// 视频高度（像素）
@property (nonatomic, assign, readonly) int height;

/// 视频比特率（bps）
@property (nonatomic, assign, readonly) int64_t bitrate;

/// 音频采样率（Hz），如果没有音频则为 0
@property (nonatomic, assign, readonly) int audioSampleRate;

/// 音频通道数，如果没有音频则为 0
@property (nonatomic, assign, readonly) int audioChannels;

/// 文件大小（字节）
@property (nonatomic, assign, readonly) int64_t fileSize;

/// 视频缩略图（封面图），可能为 nil
@property (nonatomic, strong, readonly, nullable) UIImage *thumbnail;

/// 初始化方法（不含缩略图）
/// @param duration 时长
/// @param containerFormat 封装格式
/// @param videoCodec 视频编码
/// @param audioCodec 音频编码
/// @param fps 帧率
/// @param width 宽度
/// @param height 高度
/// @param bitrate 比特率
/// @param audioSampleRate 音频采样率
/// @param audioChannels 音频通道数
/// @param fileSize 文件大小
- (instancetype)initWithDuration:(NSTimeInterval)duration
                 containerFormat:(NSString *)containerFormat
                      videoCodec:(NSString *)videoCodec
                      audioCodec:(nullable NSString *)audioCodec
                             fps:(double)fps
                           width:(int)width
                          height:(int)height
                         bitrate:(int64_t)bitrate
                 audioSampleRate:(int)audioSampleRate
                   audioChannels:(int)audioChannels
                        fileSize:(int64_t)fileSize;

/// 初始化方法（含缩略图）
/// @param duration 时长
/// @param containerFormat 封装格式
/// @param videoCodec 视频编码
/// @param audioCodec 音频编码
/// @param fps 帧率
/// @param width 宽度
/// @param height 高度
/// @param bitrate 比特率
/// @param audioSampleRate 音频采样率
/// @param audioChannels 音频通道数
/// @param fileSize 文件大小
/// @param thumbnail 缩略图
- (instancetype)initWithDuration:(NSTimeInterval)duration
                 containerFormat:(NSString *)containerFormat
                      videoCodec:(NSString *)videoCodec
                      audioCodec:(nullable NSString *)audioCodec
                             fps:(double)fps
                           width:(int)width
                          height:(int)height
                         bitrate:(int64_t)bitrate
                 audioSampleRate:(int)audioSampleRate
                   audioChannels:(int)audioChannels
                        fileSize:(int64_t)fileSize
                       thumbnail:(nullable UIImage *)thumbnail;

/// 获取清晰度描述（如：1080P, 720P, 480P）
- (NSString *)resolutionString;

/// 获取格式化的时长字符串（如：01:23:45）
- (NSString *)formattedDuration;

@end

NS_ASSUME_NONNULL_END
