//
//  JLOpusEncodeConfig.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2025/8/27.
//  Copyright © 2025 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JLOpusEncoderBandwidth) {
    ///(4kHz bandpass)
    JLOpusEncoderBandwidthNarrowband = 1101,   // 对应 OPUS_BANDWIDTH_NARROWBAND
    /// (6kHz bandpass)
    JLOpusEncoderBandwidthMediumband = 1102,   // 对应 OPUS_BANDWIDTH_MEDIUMBAND
    /// (8kHz bandpass)
    JLOpusEncoderBandwidthWideband   = 1103,     // 对应 OPUS_BANDWIDTH_WIDEBAND
    /// (12kHz bandpass)
    JLOpusEncoderBandwidthSuperwideband = 1104,// 对应 OPUS_BANDWIDTH_SUPERWIDEBAND
    /// (20kHz bandpass)
    JLOpusEncoderBandwidthFullband   = 1105      // 对应 OPUS_BANDWIDTH_FULLBAND
};

@interface JLOpusEncodeConfig : NSObject

/// 采样率
@property (nonatomic, assign) int sampleRate;

/// 单/双声道
@property (nonatomic, assign) int channels;

/// 帧长度 20ms 默认值
@property (nonatomic, assign) int frameDuration;

/// 帧长度
@property (nonatomic, assign) int frameSize;

/// BitRate
@property (nonatomic, assign) int bitRate;

/// 可变比特率开关，默认 NO（使用 CBR）
@property (nonatomic, assign) BOOL useVBR;

/// VBR 限制模式，默认 NO
@property (nonatomic, assign) BOOL constrainedVBR;

/// 编码复杂度 0~10，默认 5
@property (nonatomic, assign) int complexity;

/// 强制输出声道数 -1: 自适应, 1: 单声道, 2: 双声道, 默认 -1
@property (nonatomic, assign) int forceChannels;

/// 是否启用 DTX（静音段不发送数据），默认 NO
@property (nonatomic, assign) BOOL useDTX;

/// 网络丢包百分比，默认 0
@property (nonatomic, assign) int packetLossPercent;

/// 最大带宽限制（OPUS_BANDWIDTH_*），默认 FULLBAND
@property (nonatomic, assign) int bandwidth;

/// PCM 输入有效位深，默认 16
@property (nonatomic, assign) int lsbDepth;

/// 专家模式下帧时长（ms），默认与 frameDuration 一致
@property (nonatomic, assign) int expertFrameDuration;

/// 是否启用数据头
/// 默认是启用的
@property (nonatomic, assign) BOOL hasDataHeader;

/// 创建默认编码配置
+ (instancetype)defaultConfig;

/// 获取默认配置
/// 杰理的无头配置
+ (instancetype)defaultJL;

@end

NS_ASSUME_NONNULL_END
