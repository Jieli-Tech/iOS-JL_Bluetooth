//
//  JLPcmToWav.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2025/4/15.
//  Copyright © 2025 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// PCM 转 WAV
@interface JLPcmToWav : NSObject

#pragma mark - 流式编码接口

/// 初始化流式编码器
/// @param outputPath 输出文件路径
/// @param sampleRate 采样率（如 16000）
/// @param numChannels 声道数（1 或 2）
/// @param bitsPerSample 位深（16）
- (instancetype)initWithOutputPath:(NSString *)outputPath
                       sampleRate:(uint32_t)sampleRate
                     numChannels:(uint16_t)numChannels
                  bitsPerSample:(uint16_t)bitsPerSample;

/// 追加 PCM 数据（需确保数据格式与初始化参数一致）
/// @param pcmData PCM 数据块
/// @param error 错误信息
- (BOOL)appendPCMData:(NSData *)pcmData error:(NSError **)error;

/// 完成编码并关闭文件（必须调用以更新 WAV 头）
/// @param error 错误信息
- (BOOL)finishWithError:(NSError **)error;

#pragma mark - 一次性编码接口（便捷方法）

/// 将 PCM 数据一次性转为 WAV 文件
/// @param pcmData PCM 数据块
/// @param outputPath 输出文件路径
/// @param sampleRate 采样率（如 16000）
/// @param numChannels 声道数（1 或 2）
/// @param bitsPerSample 位深（16）
/// @param error 错误信息
+ (BOOL)convertPCMData:(NSData *)pcmData
            toWAVFile:(NSString *)outputPath
           sampleRate:(uint32_t)sampleRate
         numChannels:(uint16_t)numChannels
      bitsPerSample:(uint16_t)bitsPerSample
              error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
