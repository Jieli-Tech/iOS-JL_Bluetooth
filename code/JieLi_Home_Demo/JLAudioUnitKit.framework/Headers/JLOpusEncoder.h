//
//  JLOpusEncoder.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2024/11/14.
//  Copyright © 2024 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLAudioUnitKit/JLOpusFormat.h>

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

/// Opus 编码
@interface JLOpusEncoder : NSObject

/// 音频格式
@property (nonatomic, strong) JLOpusFormat *opusFormat;

/// 代理
@property (nonatomic, weak) id<JLOpusEncoderDelegate> delegate;

-(instancetype)init NS_UNAVAILABLE;

/// 初始化
/// - Parameters:
///   - format: 音频格式
///   - delegate: 代理
-(instancetype)initFormat:(JLOpusFormat *)format delegate:(id<JLOpusEncoderDelegate>)delegate;

/// PCM 数据
/// - Parameter data: PCM 数据
-(void)opusEncodeData:(NSData *)data;

/// PCM 文件转换成 Opus 文件
/// - Parameters:
///   - pcmPath: PCM 文件存放路径
///   - outPut: 文件输出路径
///   - result: 结果回调
-(void)opusEncodeFile:(NSString *)pcmPath outPut:(NSString *_Nullable)outPut Resoult:(JLOpusEncoderConvertBlock _Nullable)result;

/// 释放
-(void)opusOnRelease;

@end

NS_ASSUME_NONNULL_END
