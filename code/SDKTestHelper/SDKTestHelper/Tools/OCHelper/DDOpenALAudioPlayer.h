//
//  DDOpenALAudioPlayer.h
//  WatchTest
//
//  Created by EzioChan on 2024/1/25.
//

#import <Foundation/Foundation.h>

@interface DDOpenALAudioPlayer : NSObject

+(instancetype)sharePalyer;

/**
 *  播放
 *
 *  @param pcmData    数据
 *  @param samplerate 采样率
 *  @param channels   通道
 *  @param bit        位数
 */
-(void)openAudioFromQueue:(NSData *)pcmData samplerate:(int)samplerate channels:(int)channels bit:(int)bit;

/**
 *  停止播放
 */
-(void)stopSound;

@end

