//
//  JLOpusEncoder.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2024/11/14.
//  Copyright © 2024 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLAudioUnitKit/JLOpusEncodeConfig.h>

NS_ASSUME_NONNULL_BEGIN
@class JLOpusEncoder;

/// Opus 编码代理
@protocol JLOpusEncoderDelegate <NSObject>

/// PCM 数据编码
/// - Parameters:
///   - encoder: 解码器
///   - data: opus 数据
///   - error: 错误信息
-(void)opusEncoder:(JLOpusEncoder *)encoder Data:(NSData* _Nullable)data error:(NSError* _Nullable)error;

@end

typedef void(^JLOpusEncoderConvertBlock)(NSString *_Nullable pcmPath,NSError *_Nullable error);

/// JLOpusEncoder
///
/// 负责 PCM → Opus 的编码能力，支持数据流/文件流两种模式，文件模式采用分包读取与聚合写盘，避免一次性加载大文件导致内存压力。
/// 大文件 Ex 接口支持双缓冲重叠 IO/编码，并提供可调聚合阈值与性能日志。
///
/// 内存预算：当 chunkBytes 传入为 0 时，将根据设备物理内存动态选择默认读取块大小；
/// 同时对用户传入过大的 chunkBytes 进行上限裁剪（动态 MAX_CHUNK_BYTES），并打印警告。
/// 在低内存设备上默认 512KB，中等内存 1MB，较高内存 2MB，桌面/高内存可达 4MB。
///
/// Opus 编码
@interface JLOpusEncoder : NSObject

/// 音频格式
@property (nonatomic, strong) JLOpusEncodeConfig *opusFormat;

/// 代理
@property (nonatomic, weak) id<JLOpusEncoderDelegate> delegate;

-(instancetype)init NS_UNAVAILABLE;

/// 初始化
/// - Parameters:
///   - config: 音频格式
///   - delegate: 代理
-(instancetype)initFormat:(JLOpusEncodeConfig *)format delegate:(id<JLOpusEncoderDelegate>)delegate;

/// PCM 数据
/// - Parameter data: PCM 数据
-(void)opusEncodeData:(NSData *)data;

/// PCM 文件转换成 Opus 文件（推荐新接口，流式读取，避免一次性加载内存）
/// - Parameters:
///   - pcmPath: PCM 文件存放路径
///   - output: 文件输出路径（可空，默认 ~/Documents/pcmToOpus.opus）
///   - result: 结果回调，回传输出路径或错误
-(void)opusEncodeFile:(NSString *)pcmPath output:(NSString *_Nullable)output result:(JLOpusEncoderConvertBlock _Nullable)result;

/// 面向大型 PCM 的流式编码接口（双缓冲重叠 IO/编码 + 可调聚合阈值）
/// - Parameters:
///   - pcmPath: PCM 文件存放路径
///   - output: 文件输出路径（可空，默认 ~/Documents/pcmToOpus.opus）
///   - chunkBytes: 流式读取块大小（字节），为 0 时按设备内存动态选择（低内存 512KB，中等 1MB，较高 2MB，高内存 4MB）；自动按帧对齐，同时应用动态 MAX_CHUNK_BYTES 上限裁剪
///   - aggregateThreshold: 写盘聚合阈值（字节），为 0 时按 256KB；当达到阈值时批量写盘
///   - result: 结果回调，回传输出路径或错误
-(void)opusEncodeFileEx:(NSString *)pcmPath output:(NSString *_Nullable)output chunkBytes:(NSUInteger)chunkBytes aggregateThreshold:(NSUInteger)aggregateThreshold result:(JLOpusEncoderConvertBlock _Nullable)result;

/// 兼容旧接口（已废弃：命名拼写问题，且旧实现一次性读入文件）
/// - Parameters:
///   - pcmPath: PCM 文件存放路径
///   - outPut: 文件输出路径
///   - result: 结果回调
-(void)opusEncodeFile:(NSString *)pcmPath outPut:(NSString *_Nullable)outPut Resoult:(JLOpusEncoderConvertBlock _Nullable)result __attribute__((deprecated("Use opusEncodeFile:output:result: instead.")));

/// 释放
-(void)opusOnRelease;

@end

NS_ASSUME_NONNULL_END
