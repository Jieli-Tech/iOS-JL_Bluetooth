//
//  JLCodeSpecificConfigModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/27.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 音频采样率
typedef NS_ENUM(NSUInteger, JLCodecSampleFrequencyType) {
    /// 8000 Hz
    JLCodecSampleFrequencyType8000 = 0x01,
    /// 11025 Hz
    JLCodecSampleFrequencyType11025 = 0x02,
    /// 16000 Hz
    JLCodecSampleFrequencyType16000 = 0x03,
    /// 22050 Hz
    JLCodecSampleFrequencyType22050 = 0x04,
    /// 24000 Hz
    JLCodecSampleFrequencyType24000 = 0x05,
    /// 32000 Hz
    JLCodecSampleFrequencyType32000 = 0x06,
    /// 44100 Hz
    JLCodecSampleFrequencyType44100 = 0x07,
    /// 48000 Hz
    JLCodecSampleFrequencyType48000 = 0x08,
    /// 88200 Hz
    JLCodecSampleFrequencyType88200 = 0x09,
    /// 96000 Hz
    JLCodecSampleFrequencyType96000 = 0x0A,
    /// 176400 Hz
    JLCodecSampleFrequencyType176400 = 0x0B,
    /// 192000 Hz
    JLCodecSampleFrequencyType192000 = 0x0C,
    /// 384000 Hz
    JLCodecSampleFrequencyType384000 = 0x0D
};

/// 编解码器帧长
typedef NS_ENUM(NSUInteger, JLCodecFrameDurationType) {
    /// 7.5ms
    JLCodecFrameDurationType7_5ms = 0x00,
    /// 10ms
    JLCodecFrameDurationType10ms = 0x01,
};

/// 音频通道分配
typedef NS_ENUM(NSUInteger, JLCodecAudioLocationType) {
    /// Mono Audio (no specified Audio Location)
    /// 单声道
    JLCodecAudioLocationTypeMono = 0x00000000,
    /// Front Left
    /// 前左
    JLCodecAudioLocationTypeFrontLeft = 0x00000001,
    /// Front Right
    /// 前右
    JLCodecAudioLocationTypeFrontRight = 0x00000002,
    /// Front Center
    /// 前中
    JLCodecAudioLocationTypeFrontCenter = 0x00000004,
    /// Low Frequency Effects 1
    /// 低频效果1
    JLCodecAudioLocationTypeLowFrequencyEffects1 = 0x00000008,
    /// Back Left
    /// 后左
    JLCodecAudioLocationTypeBackLeft = 0x00000010,
    /// Back Right
    /// 后右
    JLCodecAudioLocationTypeBackRight = 0x00000020,
    /// Front Left of Center
    /// 前中左
    JLCodecAudioLocationTypeFrontLeftOfCenter = 0x00000040,
    /// Front Right of Center
    /// 前中右
    JLCodecAudioLocationTypeFrontRightOfCenter = 0x00000080,
    /// Back Center
    /// 后中
    JLCodecAudioLocationTypeBackCenter = 0x00000100,
    /// Low Frequency Effects 2
    /// 低频效果2
    JLCodecAudioLocationTypeLowFrequencyEffects2 = 0x00000200,
    /// Side Left
    /// 左侧
    JLCodecAudioLocationTypeSideLeft = 0x00000400,
    /// Side Right
    /// 右侧
    JLCodecAudioLocationTypeSideRight = 0x00000800,
    /// Top Front Left
    /// 顶部前左
    JLCodecAudioLocationTypeTopFrontLeft = 0x00001000,
    /// Top Front Right
    /// 顶部前右
    JLCodecAudioLocationTypeTopFrontRight = 0x00002000,
    /// Top Front Center
    /// 顶部前中
    JLCodecAudioLocationTypeTopFrontCenter = 0x00004000,
    /// Top Center
    /// 顶部中
    JLCodecAudioLocationTypeTopCenter = 0x00008000,
    /// Top Back Left
    /// 顶部后左
    JLCodecAudioLocationTypeTopBackLeft = 0x00010000,
    /// Top Back Right
    /// 顶部后右
    JLCodecAudioLocationTypeTopBackRight = 0x00020000,
    /// Top Side Left
    /// 顶部侧左
    JLCodecAudioLocationTypeTopSideLeft = 0x00040000,
    /// Top Side Right
    /// 顶部侧右
    JLCodecAudioLocationTypeTopSideRight = 0x00080000,
    /// Top Back Center
    /// 顶部后中
    JLCodecAudioLocationTypeTopBackCenter = 0x00100000,
    /// Bottom Front Center
    /// 底部前中
    JLCodecAudioLocationTypeBottomFrontCenter = 0x00200000,
    /// Bottom Front Left
    /// 底部前左
    JLCodecAudioLocationTypeBottomFrontLeft = 0x00400000,
    /// Bottom Front Right
    /// 底部前右
    JLCodecAudioLocationTypeBottomFrontRight = 0x00800000,
    /// Front Left Wide
    /// 前左宽
    JLCodecAudioLocationTypeFrontLeftWide = 0x01000000,
    /// Front Right Wide
    /// 前右宽
    JLCodecAudioLocationTypeFrontRightWide = 0x02000000,
    /// Left Surround
    /// 左侧环绕
    JLCodecAudioLocationTypeLeftSurround = 0x04000000,
    /// Right Surround
    /// 右侧环绕
    JLCodecAudioLocationTypeRightSurround = 0x08000000,
};

/// 编解码器规格配置
@interface JLCodeSpecificConfigModel : NSObject


/// BIS Index
@property(nonatomic,assign)NSInteger BISIndex;

/// 采样率
/// Sampling Frequency
@property (nonatomic, assign) JLCodecSampleFrequencyType samplingFrequency;

/// 帧长
/// Frame Duration
@property (nonatomic, assign) JLCodecFrameDurationType frameDuration;

/// 音频位置
/// Audio Location
@property (nonatomic, assign) JLCodecAudioLocationType audioLocation;

/// 每帧字节数
/// Octets Per Codec Frame
@property (nonatomic, assign) NSInteger octetsPerCodecFrame;

/// 每个SDU的编解码器帧块数
/// Codec Frame Blocks Per SDU
@property (nonatomic, assign) NSInteger codecFrameBlocksPerSDU;

/// 基础数据
@property (nonatomic, strong)NSData *baseData;

- (instancetype) initWithData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
