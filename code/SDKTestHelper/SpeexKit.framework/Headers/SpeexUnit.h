//
//  SpeexUnit.h
//  SpeexKit
//
//  Created by zhihui liang on 2018/8/20.
//  Copyright © 2018年 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  流式解码回调PCM数据
 */
extern NSString *kSPEEX_DECODE_DATA;       //speex decode

@interface SpeexUnit : NSObject

+(void)speexIsLog:(BOOL)log;

/**
 *  直接【speex文件】转换成【pcm文件】
 */
+(int)speexDecodeSPX:(NSString *)path_spx PCM:(NSString *)path_pcm;

/**
 *  流式解码【开启】
 */
+(int)speexDecoderRun;

/**
 *  输入Speex的数据
 */
+(void)speexWriteData:(NSData*)data;

/**
 *  流式解码【关闭】
 */
+(int)speexDecoderStop;

@end
