//
//  JLAudioUnitPlayer.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2025/4/16.
//  Copyright © 2025 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JLAudioUnitPlayerType) {
    JLAudioUnitPlayerTypeFile,   // 支持 MP3/WAV/AAC 等文件格式（AVAudioPlayer）
    JLAudioUnitPlayerTypePCM      // 支持 PCM 流式播放（Audio Queue）
};

@class JLAudioUnitPlayer;

@protocol JLAudioPlayerDelegate <NSObject>
@optional
// 播放进度更新（秒）
- (void)audioPlayer:(JLAudioUnitPlayer *)player didUpdateProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;
// 播放完成
- (void)audioPlayerDidFinishPlaying:(JLAudioUnitPlayer *)player;
// 播放错误
- (void)audioPlayer:(JLAudioUnitPlayer *)player didFailWithError:(NSError *)error;
@end

@interface JLAudioUnitPlayer : NSObject

@property (nonatomic, weak) id<JLAudioPlayerDelegate> delegate;
@property (nonatomic, readonly) NSTimeInterval duration;  // 总时长（文件模式下有效）
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) BOOL isPlaying;

#pragma mark - 初始化方法

/// 文件播放初始化（MP3/WAV/AAC）
- (instancetype)initWithAudioFile:(NSString *)filePath;

/// PCM 流播放初始化（需指定格式）
- (instancetype)initWithPCMFormat:(AudioStreamBasicDescription)format;

#pragma mark - 播放控制
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)time; // 仅文件模式有效

#pragma mark - PCM 流式输入（仅 PCM 模式有效）
- (void)appendPCMData:(NSData *)pcmData;
- (void)endPCMStream; // 结束 PCM 流输入

@end

NS_ASSUME_NONNULL_END
