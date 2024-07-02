//
//  OpusUnit.h
//  QCY_Demo
//
//  Created by 杰理科技 on 2021/7/5.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  通知：流式编码回调Opus数据
 *  通知数据类型：NSData（Opus）
 */
extern NSString *kOPUS_ENCODE_DATA;
/**
 *  通知：流式解码回调PCM数据
 *  通知数据类型：NSData（PCM）
 */
extern NSString *kOPUS_DECODE_DATA;


@interface OpusUnit : NSObject

+ (void)opusIsLog:(BOOL)log;

#pragma mark - Opus解码

/**
 *  直接【opus文件】转换成【pcm文件】
 *  @param path_opus    opus文件路径
 *  @param path_pcm    pcm文件路径
 */
+ (int)opusDecodeOPUS:(NSString *)path_opus PCM:(NSString *)path_pcm;

/**
 *  流式解码【开启】
 */
+ (int)opusDecoderRun;

/**
 *  输入Opus的数据
 *  通知监听“kOPUS_DECODE_DATA”获得解码后数据
 *  通知数据类型：NSNotification.object => NSData（PCM格式）
 *  @param data    opus数据流（长度：1024）
 */
+ (void)opusWriteData:(NSData*)data;

/**
 *  流式解码【关闭】
 */
+ (int)opusDecoderStop;

#pragma mark - Opus编码

/**
 *  【pcm文件】转换成【opus文件】
 */
+ (int)opusEncodePCM:(NSString *)path_pcm OPUS:(NSString *)path_opus;

/**
 *  流式编码【开启】
 */
+ (int)opusEecoderRun;

/**
 *  输入pcm的数据
 *  通知监听“kOPUS_DECODE_DATA”获得解码后数据
 *  通知数据类型：NSNotification.object =>  NSData（opus格式）
 *  @param data    opus数据流（长度：1024）
 */
+ (void)pcmWriteData:(NSData*)data;

/**
 *  流式编码【关闭】
 */
+ (int)opusEncoderStop;

@end

NS_ASSUME_NONNULL_END
