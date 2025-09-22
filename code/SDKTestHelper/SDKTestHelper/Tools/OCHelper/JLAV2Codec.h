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


@protocol JLAV2CodecDelegate <NSObject>

@optional

-(void)encodecData:(NSData* _Nullable)data error:(NSError *_Nullable)error;

-(void)decodecData:(NSData* _Nullable)data error:(NSError *_Nullable)error;

@end

typedef void(^JLAV2CodecBlock)(NSData* _Nullable data, NSString * filePath, NSError *_Nullable error);

@interface JLAV2Codec : NSObject

-(instancetype)initWithDelegate:(id<JLAV2CodecDelegate>)delegate;

+ (void)encodeFile:(NSString *)inFilePath outFilePath:(NSString *)outFilePath Option:(JLAV2CodeInfo *)option  Result:(JLAV2CodecBlock) result;

+ (void)decodeFile:(NSString *)inFilePath outFilePath:(NSString *)outFilePath Option:(JLAV2CodeInfo *)option ApplyConfig:(JLAV2CodecConfig * _Nullable)config Result:(JLAV2CodecBlock) result;

// Encoder
- (BOOL)createEncode:(JLAV2CodeInfo *)info;
- (BOOL)isEncoding;
- (void)encodeData:(NSData *)pcmData;
- (void)destoryEncode;

// Decoder
- (BOOL)createDecode:(JLAV2CodeInfo *)info;
- (BOOL)isDecoding;
- (void)decodeData:(NSData *)encodeData;
- (BOOL)applyDecoderConfig:(JLAV2CodecConfig *)configa;
- (void)destoryDecode;

@end


NS_ASSUME_NONNULL_END
