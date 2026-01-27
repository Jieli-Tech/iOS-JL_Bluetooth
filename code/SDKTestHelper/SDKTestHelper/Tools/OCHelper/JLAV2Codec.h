//
//  JLAV2Codec.h
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/10.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JLAV2CodeInfo;

/// 错误码
typedef NS_ENUM(NSUInteger, JLAV2CodecError) {
    /// 内存申请出错
    JLAV2CodecErrorMemoryAllocation = 1001,
    /// 初始化失败
    JLAV2CodecErrorInitializationFailed,
    /// 参数错误
    JLAV2CodecErrorInvalidParameter,
    /// 编/解码失败
    JLAV2CodecErrorProcessingFailed,
    /// 缓冲区满
    JLAV2CodecErrorBufferFull
};

// 配置参数类型
typedef NS_ENUM(NSUInteger, JLAV2DecodeChannelMode) {
    /// 双声道输出
    JLAV2DecodeChannelModeNormal = 0,
    /// 仅左声道
    JLAV2DecodeChannelModeLeftOnly,
    /// 仅右声道
    JLAV2DecodeChannelModeRightOnly,
    /// 立体声混合
    JLAV2DecodeChannelModeStereoMix
};

@interface JLAV2CodecConfig : NSObject
/// 淡入配置（单位：毫秒）
@property (nonatomic, assign) NSUInteger fadeInDuration;

/// 淡出配置（单位：毫秒）
@property (nonatomic, assign) NSUInteger fadeOutDuration;
/// 声道输出模式配置
@property (nonatomic, assign) JLAV2DecodeChannelMode channelMode;

/// 左声道混合系数 0.0~1.0
@property (nonatomic, assign) CGFloat leftChannelCoefficient;
/// 右声道混合系数 0.0~1.0
@property (nonatomic, assign) CGFloat rightChannelCoefficient;
/// ED帧长度（特殊帧配置）
@property (nonatomic, assign) NSUInteger edFrameLength;

@end


/// JLAV2 编解码协议
/// 通过 delegate 方式回调编解码结果
@protocol JLAV2CodecDelegate <NSObject>

@optional

/// 编码回调
/// - Parameters:
///   - data: 编码数据
///   - error: 错误信息
-(void)encodecData:(NSData* _Nullable)data error:(NSError *_Nullable)error;

/// 解码回调
/// - Parameters:
///   - data: 解码数据 PCM
///   - error: 错误信息
-(void)decodecData:(NSData* _Nullable)data error:(NSError *_Nullable)error;

@end

/// 编解码结果回调 Block
/// @param data     处理后的数据（nullable）
/// @param filePath 输出文件路径（仅在文件操作时有效）
/// @param error    错误信息（nullable）
typedef void(^JLAV2CodecBlock)(NSData* _Nullable data, NSString * filePath, NSError *_Nullable error);

/**
 * JLAV2 音频编解码器
 * 支持文件/流式两种处理方式
 */
@interface JLAV2Codec : NSObject

/// 初始化流式编解码器（需配合 encodeData:/decodeData: 使用）
/// @param delegate 回调代理
-(instancetype)initWithDelegate:(id<JLAV2CodecDelegate>)delegate;

/// 编码文件（异步）
/// @param inFilePath  输入文件路径
/// @param outFilePath 输出文件路径
/// @param option      编码配置
/// @param result      结果回调
+ (void)encodeFile:(NSString *)inFilePath outFilePath:(NSString *)outFilePath Option:(JLAV2CodeInfo *)option  Result:(JLAV2CodecBlock) result;

/// 解码文件（异步）
/// @param inFilePath  输入文件路径
/// @param outFilePath 输出文件路径
/// @param option      解码配置
/// @param config      动态配置参数（nullable）
/// @param result      结果回调
+ (void)decodeFile:(NSString *)inFilePath outFilePath:(NSString *)outFilePath Option:(JLAV2CodeInfo *)option ApplyConfig:(JLAV2CodecConfig * _Nullable)config Result:(JLAV2CodecBlock) result;

/// 初始化编码器
/// @param info 编码配置
/// @return 是否初始化成功
- (BOOL)createEncode:(JLAV2CodeInfo *)info;

/// 是否在编码中
- (BOOL)isEncoding;

/// 开始编码
/// - Parameter pcmData: 输入待编码数据（需先调用 createEncode:）
- (void)encodeData:(NSData *)pcmData;

/// 停止编码
- (void)destoryEncode;

// Decoder

/// 初始化解码器
/// - Parameter info: 解码配置
- (BOOL)createDecode:(JLAV2CodeInfo *)info;

/// 是否在解码中
- (BOOL)isDecoding;

/// 开始解码
/// - Parameter encodeData: 待解码数据
- (void)decodeData:(NSData *)encodeData;

/// 应用解码配置
/// - Parameter configa: 解码配置
- (BOOL)applyDecoderConfig:(JLAV2CodecConfig *)configa;

/// 停止解码
- (void)destoryDecode;

@end


NS_ASSUME_NONNULL_END
