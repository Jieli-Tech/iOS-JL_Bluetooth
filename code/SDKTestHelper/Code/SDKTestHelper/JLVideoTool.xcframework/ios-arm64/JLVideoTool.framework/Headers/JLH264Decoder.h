//
//  JLH264Decoder.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: H.264 视频解码器，扩展基类以支持 SPS/PPS 注入、AnnexB / AVCC 双格式解析
//

#import <JLVideoTool/JLVideoDecoder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 H.264 视频解码器

 @discussion
 继承自 JLVideoDecoder，增加 H.264 特有的 NAL 单元解析能力：
 - 支持 AnnexB 格式（start code: 0x00000001 / 0x000001）
 - 支持 AVCC 格式（4 字节长度前缀）
 - 支持手动注入 SPS/PPS 或从流中自动提取
 - 支持 B 帧开关

 裸流解码时需注意：
 SPS/PPS 必须在 IDR 帧之前送入解码器，否则解码会失败。
 可通过 setSPS:PPS: 手动注入，或确保流数据包含参数集 NAL 单元。
 */
@interface JLH264Decoder : JLVideoDecoder

/// 是否支持 B 帧解码，默认 YES
@property (nonatomic, assign) BOOL supportsBFrames;

/**
 手动注入 SPS 和 PPS 数据（裸流解码必需）

 @param spsData SPS（Sequence Parameter Set）NAL 单元数据（不含 start code）
 @param ppsData PPS（Picture Parameter Set）NAL 单元数据（不含 start code）
 @discussion 应在 start: 之前调用。若解码过程中流数据自带 SPS/PPS 则无需手动注入
 */
- (void)setSPS:(NSData *)spsData PPS:(NSData *)ppsData;

/**
 解码 AnnexB 格式 H.264 数据

 @param data AnnexB 格式的编码数据（start code 分隔 NAL 单元）
 @param pts 显示时间戳（毫秒）
 @return YES 表示数据已入队，NO 表示解码器状态不允许
 @discussion AnnexB 使用 0x00000001 或 0x000001 作为 NAL 单元分隔符。
             内部自动切分 NAL 单元，IDR 帧前自动注入 SPS/PPS（如已配置）
 */
- (BOOL)decodeAnnexBData:(NSData *)data presentationTimeStamp:(int64_t)pts;

/**
 解码 AVCC 格式 H.264 数据

 @param data AVCC 格式的编码数据（4 字节长度前缀 + NAL 单元）
 @param pts 显示时间戳（毫秒）
 @return YES 表示数据已入队，NO 表示解码器状态不允许
 @discussion AVCC 格式常见于 MP4 容器，每个 NAL 单元前有 4 字节大端长度前缀
 */
- (BOOL)decodeAVCCData:(NSData *)data presentationTimeStamp:(int64_t)pts;

@end

NS_ASSUME_NONNULL_END
