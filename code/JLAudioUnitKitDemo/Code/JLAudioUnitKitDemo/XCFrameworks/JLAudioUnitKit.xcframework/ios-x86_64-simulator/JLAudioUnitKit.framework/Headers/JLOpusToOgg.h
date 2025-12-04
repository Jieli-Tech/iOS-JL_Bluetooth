//
//  JLOpusToOgg.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2025/5/16.
//  Copyright © 2025 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JLOpusToOggConvertBlock)(NSData *_Nullable oggData, BOOL isLast, NSError *_Nullable error);

/// 将Opus数据转换为Ogg数据
@interface JLOpusToOgg : NSObject

/// 转码内容的回调
@property(nonatomic,strong)JLOpusToOggConvertBlock _Nullable convertBlock;

/// 帧长
/// - Parameter frameLen: 帧长
/// 默认值 40
- (instancetype)initWithFrameLength:(uint32_t)frameLen;

/// 开始流
-(void)startStream;

/// 添加Opus数据
/// - Parameter opusData: 符合杰理的无头裸 opus 数据
- (void)appendOpusData:(NSData *)opusData;

/// 关闭流
- (void)closeStream;


/// 将Opus数据转换为Ogg数据
/// opus 必须为 16000
/// opus 必须是 单声道
/// - Parameters:
///   - opusData: 符合杰理的无头裸 opus 数据
///   - frameLen: 帧长 公版默认帧长是 40
///   - duration: 转换后的时长
///   - error: 错误
+ (NSData *_Nullable)convertOpusDataToOgg:(NSData *)opusData
                                 frameLen:(uint32_t)frameLen
                                 duration:(double *)duration
                                    error:(NSError *__autoreleasing _Nullable *)error ;

/// 将Opus文件转换为Ogg文件
/// 符合杰理的无头裸 opus 文件
/// opus 必须为 16000
/// opus 必须是 单声道
/// - Parameters:
///   - opusFilePath: opus文件路径
///   - oggFilePath: ogg文件路径
///   - frameLen: 帧长 公版默认帧长是 40
///   - duration: 转换后的时长
+(void)convertOpusFileToOgg:(NSString *)opusFilePath
                oggFilePath:(NSString *)oggFilePath
                   frameLen:(uint32_t)frameLen
                   duration:(double *)duration;


@end

NS_ASSUME_NONNULL_END
