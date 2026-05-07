//
//  JLAudioConverter.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2025/11/28.
//  Copyright © 2025 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///  JL 音频格式转换工具
@interface JLAudioConverter : NSObject

/// 单声道的mp3文件 转 UMP3
/// @param mp3Path mp3文件路径
/// @param ump3Path UMP3文件路径
/// @param result 转换结果回调
/// 支持的采样率码率表：sr=xx的时候， 支持 后面 br列表里面的选项
/// sr=8k,12k:    br: 8k,16k,24k,32k,40k,48k,56k,64k
/// sr=16k,24k:  br: 8k,16k,24k,32k,40k,48k,56k,64k,80k,96k, 112k, 128k, 144k, 160k
/// sr=32k:      br:  32k,  40k,  48k,  56k,  64k,80k,96k,112k, 128k, 160k, 192k, 224k, 256k, 320k
+(void)convertMP3ToUmp3:(NSString *)mp3Path ump3Path:(NSString *)ump3Path Result:(void (^)(BOOL success))result;

/// 同步转换mp3文件为UMP3格式
/// @param mp3Path mp3文件路径
/// @param ump3Path UMP3文件路径
+(void)convertMP3ToUmp3Sync:(NSString *)mp3Path ump3Path:(NSString *)ump3Path;
@end

NS_ASSUME_NONNULL_END
