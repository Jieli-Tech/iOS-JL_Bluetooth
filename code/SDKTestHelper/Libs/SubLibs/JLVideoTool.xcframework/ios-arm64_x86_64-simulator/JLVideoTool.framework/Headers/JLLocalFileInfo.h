//
//  JLLocalFileInfo.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/22.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLLocalFileInfo : NSObject

@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, copy, readonly) NSString *containerFormat;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) CGSize videoSize;
@property (nonatomic, assign, readonly) int32_t videoFrameRate;
@property (nonatomic, copy, readonly) NSString *videoCodecName;
@property (nonatomic, copy, readonly) NSString *audioCodecName;
@property (nonatomic, assign, readonly) int32_t audioSampleRate;
@property (nonatomic, assign, readonly) int32_t audioChannels;
@property (nonatomic, assign, readonly) BOOL hasAudio;
@property (nonatomic, assign, readonly) BOOL hasVideo;

- (instancetype)initWithFilePath:(NSString *)filePath
                 containerFormat:(NSString *)containerFormat
                        duration:(NSTimeInterval)duration
                       videoSize:(CGSize)videoSize
                  videoFrameRate:(int32_t)videoFrameRate
                  videoCodecName:(NSString *)videoCodecName
                  audioCodecName:(NSString *)audioCodecName
                 audioSampleRate:(int32_t)audioSampleRate
                  audioChannels:(int32_t)audioChannels
                         hasAudio:(BOOL)hasAudio
                         hasVideo:(BOOL)hasVideo;

@end

NS_ASSUME_NONNULL_END
