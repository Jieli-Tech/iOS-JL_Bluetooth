//
//  JLStreamRouter.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 流数据路由器，接收裸流数据后路由到对应解码器（H.264 / JPEG），
//           并将解码后的视频帧转发给 JLPlayerCore 进行渲染
//

#import <Foundation/Foundation.h>
#import <JLVideoTool/JLPlayerTypes.h>
#import <JLVideoTool/JLDecoderOptions.h>

@class JLPlayerCore;

NS_ASSUME_NONNULL_BEGIN

/**
 流数据路由器

 @discussion
 负责接收裸流数据（H.264 / JPEG），根据格式路由到对应的解码器，
 并将解码后的帧数据分发给 JLPlayerCore 进行渲染。

 内部管理解码器生命周期，实现 JLVideoDecoderDelegate 协议，
 将解码器输出的 JLVideoFrame 自动转发到绑定的 JLPlayerCore。

 典型用法:
 @code
 JLStreamRouter *router = [[JLStreamRouter alloc] initWithPlayerCore:playerCore
                                                            options:decoderOptions];
 [router configureH264WithSPS:spsData PPS:ppsData];
 [router startDecoders:nil];
 [router routeData:h264Data format:JLStreamFormatH264AnnexB pts:pts];
 @endcode
 */
@interface JLStreamRouter : NSObject

/**
 初始化路由器

 @param playerCore 播放器核心实例，用于接收解码后的视频帧
 @param options 解码器配置选项
 @return 路由器实例
 */
- (instancetype)initWithPlayerCore:(JLPlayerCore *)playerCore
                           options:(JLDecoderOptions *)options;

/**
 路由数据到对应解码器

 @param data 原始编码数据
 @param format 数据格式
 @param pts 显示时间戳（毫秒）
 @return YES 表示数据已路由，NO 表示失败
 @discussion 根据 format 自动选择解码器并喂入数据。
             H.264 AnnexB 和 AVCC 格式的数据使用不同的解码入口。
 */
- (BOOL)routeData:(NSData *)data
           format:(JLStreamFormat)format
              pts:(int64_t)pts;

/**
 配置 H.264 解码器的 SPS/PPS 参数

 @param spsData SPS（Sequence Parameter Set）NAL 单元数据（不含 start code），传 nil 表示不设置
 @param ppsData PPS（Picture Parameter Set）NAL 单元数据（不含 start code），传 nil 表示不设置
 @discussion 应在调用 startDecoders: 之前配置。SPS/PPS 会在每个 IDR 帧前自动注入。
 */
- (void)configureH264WithSPS:(nullable NSData *)spsData
                         PPS:(nullable NSData *)ppsData;

/// 启动所有解码器（进入就绪状态）
/// @param error 启动失败时返回错误信息
/// @return YES 成功，NO 失败
- (BOOL)startDecoders:(NSError *_Nullable *_Nullable)error;

/// 停止所有解码器并释放资源
- (void)stopDecoders;

/// 刷新所有解码器（排空内部缓冲区）
- (void)flushDecoders;

/// 重置所有解码器（回到空闲状态，保留配置）
- (void)resetDecoders;

@end

NS_ASSUME_NONNULL_END
