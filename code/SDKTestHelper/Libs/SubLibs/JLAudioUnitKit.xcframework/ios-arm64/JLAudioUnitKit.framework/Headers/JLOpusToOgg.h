//
//  JLOpusToOgg.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2025/5/16.
//  Copyright © 2025 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class JLOpusToOggConfig;

typedef void(^JLOpusToOggConvertBlock)(NSData *_Nullable oggData, BOOL isLast, NSError *_Nullable error);

/// 将Opus数据转换为Ogg数据
@interface JLOpusToOgg : NSObject

/// 转码内容的回调
@property(nonatomic,strong)JLOpusToOggConvertBlock _Nullable convertBlock;

/// 当前配置（只读）
@property(nonatomic, strong, readonly) JLOpusToOggConfig *configuration;

/// 数据处理队列（可选，用于解决高频数据传输导致的性能问题）
/// 默认使用主队列（dispatch_get_main_queue()）
/// 建议在高频数据传输场景下设置为串行队列：
///   dispatch_queue_t queue = dispatch_queue_create("com.jl.opustogg", DISPATCH_QUEUE_SERIAL);
///   converter.processingQueue = queue;
@property (nonatomic, strong, nullable) dispatch_queue_t processingQueue;

#pragma mark - 初始化方法

/// 使用配置初始化（推荐）
/// - Parameter configuration: 转换配置
- (instancetype)initWithConfiguration:(JLOpusToOggConfig *)configuration;

/// 初始化帧长（旧接口，保持兼容）
/// - Parameter frameLen: 帧长
/// 默认值 40
/// 注意：此接口使用默认配置（标准 20ms 帧），仅修改 frameLength
- (instancetype)initWithFrameLength:(uint32_t)frameLen __attribute__((deprecated("Use -initWithConfiguration: instead.")));

/// 开始流
-(void)startStream;

/// 添加Opus数据
/// - Parameter opusData: 符合杰理的无头裸 opus 数据
- (void)appendOpusData:(NSData *)opusData;

/// 关闭流
- (void)closeStream;

#pragma mark - 类方法（新接口，推荐）

/// 将Opus数据转换为Ogg数据（使用配置）
/// - Parameters:
///   - opusData: 符合杰理的无头裸 opus 数据
///   - configuration: 转换配置
///   - duration: 转换后的时长（输出参数，可为 NULL）
///   - error: 错误信息（输出参数，可为 NULL）
+ (NSData *_Nullable)convertOpusDataToOgg:(NSData *)opusData
                            configuration:(JLOpusToOggConfig *)configuration
                                 duration:(double *_Nullable)duration
                                    error:(NSError *__autoreleasing _Nullable *)error;

/// 将Opus文件转换为Ogg文件（使用配置）
/// - Parameters:
///   - opusFilePath: opus文件路径
///   - oggFilePath: ogg文件路径
///   - configuration: 转换配置
///   - duration: 转换后的时长（输出参数，可为 NULL）
+ (void)convertOpusFileToOgg:(NSString *)opusFilePath
                 oggFilePath:(NSString *)oggFilePath
               configuration:(JLOpusToOggConfig *)configuration
                    duration:(double *_Nullable)duration;

#pragma mark - 类方法（旧接口，保持兼容）

/// 将Opus数据转换为Ogg数据
/// opus 必须为 16000
/// opus 必须是 单声道
/// - Parameters:
///   - opusData: 符合杰理的无头裸 opus 数据
///   - frameLen: 帧长 公版默认帧长是 40
///   - duration: 转换后的时长
///   - error: 错误
/// 注意：此接口使用默认配置（标准 20ms 帧），仅修改 frameLength
+ (NSData *_Nullable)convertOpusDataToOgg:(NSData *)opusData
                                 frameLen:(uint32_t)frameLen
                                 duration:(double *)duration
                                    error:(NSError *__autoreleasing _Nullable *)error __attribute__((deprecated("Use -convertOpusDataToOgg:configuration:duration:error: instead.")));

/// 将Opus文件转换为Ogg文件
/// 符合杰理的无头裸 opus 文件
/// opus 必须为 16000
/// opus 必须是 单声道
/// - Parameters:
///   - opusFilePath: opus文件路径
///   - oggFilePath: ogg文件路径
///   - frameLen: 帧长 公版默认帧长是 40
///   - duration: 转换后的时长
/// 注意：此接口使用默认配置（标准 20ms 帧），仅修改 frameLength
+ (void)convertOpusFileToOgg:(NSString *)opusFilePath
                 oggFilePath:(NSString *)oggFilePath
                    frameLen:(uint32_t)frameLen
                    duration:(double *)duration __attribute__((deprecated("Use -convertOpusFileToOgg:oggFilePath:configuration:duration: instead.")));


@end

NS_ASSUME_NONNULL_END
