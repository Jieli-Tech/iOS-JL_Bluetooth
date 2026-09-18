//
//  JLVideoDecoder.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 视频解码器基类，定义解码器通用接口、状态机和流式解码能力
//

#import <Foundation/Foundation.h>
#import <JLVideoTool/JLDecoderOptions.h>
#import <JLVideoTool/JLVideoDecoderDelegate.h>
#import <JLVideoTool/JLVideoFrame.h>

NS_ASSUME_NONNULL_BEGIN

/**
 解码器状态枚举

 - JLDecoderStateIdle: 空闲，尚未配置
 - JLDecoderStateInitializing: 正在初始化编解码器
 - JLDecoderStateReady: 就绪，可接收编码数据
 - JLDecoderStateDecoding: 解码中，正在处理数据
 - JLDecoderStateFlushing: 刷新中，正在排空内部缓冲区
 - JLDecoderStateStopped: 已停止，资源已释放
 - JLDecoderStateError: 错误状态，需 reset 后重新配置
 */
typedef NS_ENUM(NSInteger, JLDecoderState) {
    JLDecoderStateIdle,
    JLDecoderStateInitializing,
    JLDecoderStateReady,
    JLDecoderStateDecoding,
    JLDecoderStateFlushing,
    JLDecoderStateStopped,
    JLDecoderStateError,
};

/// 解码器错误域
extern NSString * const JLVideoDecoderErrorDomain;

/**
 解码器错误码枚举

 - JLVideoDecoderErrorInvalidOptions: 配置参数无效
 - JLVideoDecoderErrorCodecNotFound: 未找到指定编解码器
 - JLVideoDecoderErrorInitializationFailed: 编解码器初始化失败
 - JLVideoDecoderErrorDecoderNotReady: 解码器未就绪时尝试解码
 - JLVideoDecoderErrorDecodeFailed: 解码操作失败
 - JLVideoDecoderErrorHardwareAccelFailed: 硬件加速初始化/运行失败
 */
typedef NS_ENUM(NSInteger, JLVideoDecoderErrorCode) {
    JLVideoDecoderErrorInvalidOptions = -1000,
    JLVideoDecoderErrorCodecNotFound = -1001,
    JLVideoDecoderErrorInitializationFailed = -1002,
    JLVideoDecoderErrorDecoderNotReady = -1003,
    JLVideoDecoderErrorDecodeFailed = -1004,
    JLVideoDecoderErrorHardwareAccelFailed = -1005,
};

/**
 视频解码器基类

 @discussion
 基于 FFmpeg libavcodec 实现，支持 H.264 / JPEG 的软件和硬件（VideoToolbox）解码。
 提供流式输入接口（可处理不完整帧）、串行解码队列、像素缓冲池复用。
 子类可重写 setupCodec: 方法以自定义编解码器选择逻辑。

 典型使用流程:
 1. initWithOptions: → configure: → start:
 2. 循环调用 decodeData:presentationTimeStamp:
 3. 结束调用 flush → stop

 状态机: Idle → Initializing → Ready ↔ Decoding ↔ Flushing → Stopped / Error
 */
@interface JLVideoDecoder : NSObject

/// 委托对象（弱引用），接收解码器状态和帧输出回调
@property (nonatomic, weak, nullable) id<JLVideoDecoderDelegate> delegate;

/// 解码器配置选项（只读副本）
@property (nonatomic, strong, readonly) JLDecoderOptions *options;

/// 当前解码器状态
@property (nonatomic, assign, readonly) JLDecoderState state;

/// 累计成功解码帧数
@property (nonatomic, assign, readonly) int64_t decodedFrameCount;

/// 累计丢弃帧数（解码失败或输出转换失败）
@property (nonatomic, assign, readonly) int64_t droppedFrameCount;

/**
 使用配置选项初始化解码器

 @param options 解码器配置（会被 copy）
 @return 解码器实例
 */
- (instancetype)initWithOptions:(JLDecoderOptions *)options;

/**
 配置解码器（分配编解码器资源）

 @param error 配置失败时返回错误信息
 @return YES 成功，NO 失败
 @discussion 必须在 start: 之前调用。此方法会查找编解码器、分配 AVCodecContext、
             打开编解码器、初始化 parser 和像素缓冲池
 */
- (BOOL)configure:(NSError **)error;

/**
 启动解码器，进入就绪状态

 @param error 启动失败时返回错误信息
 @return YES 成功，NO 失败
 @discussion 启动后触发 decoderDidBecomeReady: 回调，此后可喂入数据
 */
- (BOOL)start:(NSError **)error;

/**
 停止解码器，释放编解码资源

 @discussion 停止后解码器进入 Stopped 状态，内部 AVCodecContext 和 parser 均被释放。
             如需重新使用需再次调用 configure: → start:
 */
- (void)stop;

/**
 喂入编码数据（流式输入）

 @param data 编码数据（H.264 NAL 单元 / JPEG 数据）
 @param pts 显示时间戳（毫秒）
 @return YES 表示数据已入队，NO 表示解码器状态不允许
 @discussion 数据在内部串行队列上异步处理，解码结果通过 delegate 回调
 */
- (BOOL)decodeData:(NSData *)data presentationTimeStamp:(int64_t)pts;

/**
 喂入编码数据（带解码时间戳）

 @param data 编码数据
 @param pts 显示时间戳（毫秒）
 @param dts 解码时间戳（毫秒）
 @return YES 表示数据已入队，NO 表示解码器状态不允许
 */
- (BOOL)decodeData:(NSData *)data
    presentationTimeStamp:(int64_t)pts
         decodeTimeStamp:(int64_t)dts;

/**
 刷新解码器

 @discussion 发送空包（EOF 信号）排空解码器内部缓冲区，获取所有剩余帧。
             完成后触发 decoderDidFlush: 回调并回到 Ready 状态。
 */
- (void)flush;

/**
 重置解码器

 @discussion 回到 Idle 状态并清零所有统计计数器。不释放编解码器资源，
             如需重新开始解码可再次调用 start:
 */
- (void)reset;

/**
 获取解码器统计信息

 @return 包含 decodedFrameCount、droppedFrameCount、state、codec 名称的字典
 */
- (NSDictionary *)statistics;

@end

NS_ASSUME_NONNULL_END
