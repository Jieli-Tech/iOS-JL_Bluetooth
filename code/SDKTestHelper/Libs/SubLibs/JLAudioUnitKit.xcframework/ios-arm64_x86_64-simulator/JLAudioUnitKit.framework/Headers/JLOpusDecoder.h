//
//  JLOpusDecoder.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2024/11/14.
//  Copyright © 2024 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLAudioUnitKit/JLOpusFormat.h>

NS_ASSUME_NONNULL_BEGIN
@class JLOpusDecoder;

/// Opus 解码代理
@protocol JLOpusDecoderDelegate <NSObject>

/// Opus 数据解码
/// - Parameters:
///   - decoder: 解码器
///   - data: pcm 数据
///   - error: 错误信息
-(void)opusDecoder:(JLOpusDecoder *)decoder Data:(NSData* _Nullable)data error:(NSError* _Nullable)error;

@optional
/// Opus 立体声数据解码
/// - Parameters:
///   - decoder: 解码器
///   - left: 左声道 pcm 数据
///   - right: 右声道 pcm 数据
///   - error: 错误信息
-(void)opusDecoderStereo:(JLOpusDecoder *)decoder Left:(NSData* _Nullable)left Right:(NSData* _Nullable)right error:(NSError* _Nullable)error;

@end

typedef void(^JLOpusDecoderConvertBlock)(NSString *_Nullable pcmPath,NSError *_Nullable error);

/// JLOpusDecoder
///
/// 负责 Opus → PCM 的解码能力，支持小文件一次性解码与大文件分包流式解码。
/// 大文件接口支持双缓冲重叠 IO/解码，并提供聚合写盘阈值以降低磁盘写入频次。
///
/// 内存预算：当 chunkBytes 传入为 0 时，将根据设备物理内存动态选择默认读取块大小；
/// 同时对用户传入过大的 chunkBytes 进行上限裁剪（动态 MAX_CHUNK_BYTES），并打印警告。
/// 在低内存设备上默认 512KB，中等内存 1MB，较高内存 2MB，桌面/高内存可达 4MB。
///
/// 日志：关键阶段包含开始/完成日志与吞吐/耗时分解，便于性能监控与问题定位。
///
/// 注意：若 hasDataHeader = YES，解码将按帧头长度进行分包；否则按固定数据长度 dataSize 解析。
/// 若 dataSize 未配置且无头信息，无法可靠分包解析，需结合业务定义。
/// Opus 解码
@interface JLOpusDecoder : NSObject

/// 数据格式参数
@property (nonatomic, strong) JLOpusFormat *opusFormat;

/// 代理委托
@property(nonatomic, weak) id<JLOpusDecoderDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

/// 初始化
/// - Parameters:
///   - format: 解码格式
///   - delegate: 代理
- (instancetype)initDecoder:(JLOpusFormat *)format delegate:(id<JLOpusDecoderDelegate>)delegate;

/// 重置解码格式
/// - Parameter format: 解码格式
-(void)resetOpusFramet:(JLOpusFormat *)format;

/// 输入 Opus 数据
/// - Parameter data: Opus 数据
-(void)opusDecoderInputData:(NSData *)data;

/// 解码文件
///  note: 该方法会一次性读取文件到内存，适用于小文件解码，而且采取的是一帧一帧的解析方式（较慢）
/// 如果需要解码大文件需要使用 opusDecodeLargeFile:output:chunkBytes:result: 方法
/// - Parameters:
///   - input: opus 文件
///   - outPut: 输出路径
///   - result: 结果回调
-(void)opusDecodeFile:(NSString *)input outPut:(NSString *_Nullable)outPut Resoult:(JLOpusDecoderConvertBlock _Nullable)result;


/// 面向大型 Opus 文件的双缓冲重叠 IO/解码接口
/// - Parameters:
///   - input: 输入 Opus 文件路径
///   - output: 输出 PCM 文件路径（为空则写入 Documents/opusLargeToPcm.pcm）
///   - chunkBytes: 流式读取块大小（字节），为 0 时按设备内存动态选择（低内存 512KB，中等 1MB，较高 2MB，高内存 4MB）；
///                 同时对传入值应用动态 MAX_CHUNK_BYTES 上限裁剪
///   - aggregateThreshold: 写盘聚合阈值（字节），为 0 时默认 262144（256KB）
///   - result: 完成回调，返回输出路径或错误
-(void)opusDecodeLargeFileEx:(NSString *)input output:(NSString *_Nullable)output chunkBytes:(NSUInteger)chunkBytes aggregateThreshold:(NSUInteger)aggregateThreshold result:(JLOpusDecoderConvertBlock _Nullable)result;

/// 释放
-(void)opusOnRelease;

@end

NS_ASSUME_NONNULL_END
