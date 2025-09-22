//
//  JLOpusOptions.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2024/11/14.
//  Copyright © 2024 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define OPUS_JL_MAX_FRAME_SIZE 48000 * 2
#define OPUS_JL_MAX_PACKET_SIZE 1500


@interface JLOpusFormat : NSObject

/// 采样率
@property (nonatomic, assign) int sampleRate;

/// 单/双声道
@property (nonatomic, assign) int channels;

/// 帧长度 20ms 默认值
@property (nonatomic, assign) int frameDuration;

/// BitRate
@property (nonatomic, assign) int bitRate;

/// 数据帧大小
@property (nonatomic, assign, readonly) int frameSize;

/// 数据大小
@property (nonatomic, assign) int dataSize;

/// 是否包含数据头部
@property (nonatomic, assign) BOOL hasDataHeader;

-(instancetype)init NS_UNAVAILABLE;

/// 默认配置
/// sampleRate: 16000
/// channels: 1
/// frameDuration: 20
/// dataSize: 40
/// frameSize: 320
/// hasDataHeader: YES
+(JLOpusFormat*)defaultFormats;

@end

NS_ASSUME_NONNULL_END
