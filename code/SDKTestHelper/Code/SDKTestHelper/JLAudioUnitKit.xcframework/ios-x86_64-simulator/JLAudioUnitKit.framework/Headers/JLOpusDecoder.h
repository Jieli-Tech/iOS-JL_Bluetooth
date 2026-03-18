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

@end

typedef void(^JLOpusDecoderConvertBlock)(NSString *_Nullable pcmPath,NSError *_Nullable error);

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
/// - Parameters:
///   - input: opus 文件
///   - outPut: 输出路径
///   - result: 结果回调
-(void)opusDecodeFile:(NSString *)input outPut:(NSString *_Nullable)outPut Resoult:(JLOpusDecoderConvertBlock _Nullable)result;

/// 释放
-(void)opusOnRelease;

@end

NS_ASSUME_NONNULL_END
