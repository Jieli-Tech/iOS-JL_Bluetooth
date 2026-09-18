//
//  JLSpeexUnit.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2024/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JLSpeexDecoder;

@protocol JLSpeexDelegate <NSObject>

/// Speex 数据解码
/// - Parameters:
///   - decoder: 解码器
///   - data: PCM 数据
///   - error: 错误信息
- (void)speexDecoder:(JLSpeexDecoder *)decoder Data:(NSData* _Nullable)data error:(NSError* _Nullable)error;

@end

typedef void(^JLSpeexConvertBlock)(NSString *_Nullable pcmPath,NSError *_Nullable error);

/// Speex 数据解码
@interface JLSpeexDecoder : NSObject

-(instancetype)init NS_UNAVAILABLE;

/// 初始化
/// - Parameter delegate: 委托
-(instancetype)initWithDelegate:(id<JLSpeexDelegate>)delegate;

/// 委托
@property (nonatomic, weak) id<JLSpeexDelegate> delegate;

/// 输入 Speex 数据
/// - Parameter data: Speex 数据
-(void)speexInputData:(NSData*)data;

/// 将 Speex 转换为 PCM
/// - Parameters:
///   - filePath: Speex 路径
///   - opPath: 输出路径
///   - result: 结果回调
-(void)speexConvertToPcm:(NSString *)filePath outPutFilePath:(NSString * _Nullable)opPath Result:(JLSpeexConvertBlock)result;

/// 释放对象
-(void)speexOnRelease;

@end

NS_ASSUME_NONNULL_END
