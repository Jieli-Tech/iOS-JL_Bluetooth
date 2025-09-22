//
//  JLBroadcastSetManager.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/29.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JLEncryptModel;
@class JLBroadcastSetManager;
@class JLAuracastTransmitter;

/// 配置选项
typedef NS_OPTIONS(NSUInteger, JLBroadcastSetOptionsType) {
    /// 广播名称
    JLBroadcastSetOptionsBroadcastName = 1 << 0,
    /// 音频格式
    JLBroadcastSetOptionsAudioFormat = 1 << 1,
    /// 加密
    JLBroadcastSetOptionsEncrypt = 1 << 2,
    /// 发射功率
    JLBroadcastSetOptionsPower = 1 << 3,
    /// 全获取
    JLBroadcastSetOptionsAll = 0xffffffff
};

/// 音频格式
typedef NS_ENUM(NSUInteger, JLBroadcastSetAudioFormat) {
    /// 名称： 8_1
    /// 采样率(Hz)： 8000
    /// 帧间隔（us）：7500
    /// 包长（Byte）：26
    /// 码率（kbps）：27.732
    /// 重发次数 ：2
    /// 最大传输延时(ms) ：8
    /// 演示延时(ms) ：40
    JLBroadcastSetAudioFormat8_1 = 0x01,
    /// 名称： 8_2
    /// 采样率(Hz)： 8000
    /// 帧间隔（us）：10000
    /// 包长（Byte）：30
    /// 码率（kbps）：24
    /// 重发次数：2
    /// 最大传输延时(ms)：10
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat8_2 = 0x02,
    /// 名称： 16_1_1
    /// 采样率(Hz)： 16000
    /// 帧间隔（us）：7500
    /// 包长（Byte）：30
    /// 码率（kbps）：32
    /// 重发次数：2
    /// 最大传输延时(ms)：8
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat16_1_1 = 0x03,
    /// 名称： 16_2_1
    /// 采样率(Hz)： 16000
    /// 帧间隔（us）：10000
    /// 包长（Byte）：40
    /// 码率（kbps）：48
    /// 重发次数：2
    /// 最大传输延时(ms)：10
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat16_2_1 = 0x04,
    /// 名称： 24_1_1
    /// 采样率(Hz)： 24000
    /// 帧间隔（us）：7500
    /// 包长（Byte）：45
    /// 码率（kbps）：48
    /// 重发次数：2
    /// 最大传输延时(ms)：8
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat24_1_1 = 0x05,
    /// 名称： 24_2_1
    /// 采样率(Hz)： 24000
    /// 帧间隔（us）：10000
    /// 包长（Byte）：60
    /// 码率（kbps）：48
    /// 重发次数：2
    /// 最大传输延时(ms)：10
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat24_2_1 = 0x06,
    /// 名称： 32_1_1
    /// 采样率(Hz)： 32000
    /// 帧间隔（us）：7500
    /// 包长（Byte）：60
    /// 码率（kbps）：64
    /// 重发次数：2
    /// 最大传输延时(ms)：8
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat32_1_1 = 0x07,
    /// 名称： 32_2_1
    /// 采样率(Hz)： 32000
    /// 帧间隔（us）：10000
    /// 包长（Byte）：80
    /// 码率（kbps）：64
    /// 重发次数：2
    /// 最大传输延时(ms)：10
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat32_2_1 = 0x08,
    /// 名称： 441_1_1
    /// 采样率(Hz)： 44100
    /// 帧间隔（us）：8163
    /// 包长（Byte）：97
    /// 码率（kbps）：95.06
    /// 重发次数：4
    /// 最大传输延时(ms)：24
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat441_1_1 = 0x09,
    /// 名称： 441_2_1
    /// 采样率(Hz)： 44100
    /// 帧间隔（us）：10884
    /// 包长（Byte）：130
    /// 码率（kbps）：95.55
    /// 重发次数：4
    /// 最大传输延时(ms)：31
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat441_2_1 = 0x0A,
    /// 名称： 48_1
    /// 采样率(Hz)： 48000
    /// 帧间隔（us）：7500
    /// 包长（Byte）：75
    /// 码率（kbps）：80
    /// 重发次数：4
    /// 最大传输延时(ms)：15
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat48_1 = 0x0B,
    /// 名称： 48_2
    /// 采样率(Hz)： 48000
    /// 帧间隔（us）：10000
    /// 包长（Byte）：100
    /// 码率（kbps）：80
    /// 重发次数：4
    /// 最大传输延时(ms)：20
    /// 演示延时(ms)：40
    JLBroadcastSetAudioFormat48_2 = 0x0C
    
};

typedef void(^JLBroadcastSetManagerGetBlock)(JLBroadcastSetManager *manager,NSError *_Nullable err);

typedef void(^JLBroadcastSetManagerSetBlock)(BOOL success,NSError *_Nullable err);

/// JLBroadcastSetManager协议
@protocol JLBroadcastSetManagerProtocol <NSObject>

/// 设置广播名称
/// - Parameters:
///   - manager: JLBroadcastSetManager
///   - broadcastName: 广播名称
-(void)jlBroadcastSetManager:(JLBroadcastSetManager *)manager BroadcastName:(NSString *)broadcastName;

/// 设置音频格式
/// - Parameters:
///   - manager: JLBroadcastSetManager
///   - audioFormat: 音频格式
-(void)jlBroadcastSetManager:(JLBroadcastSetManager *)manager AudioFormat:(JLBroadcastSetAudioFormat)audioFormat;

/// 设置加密
/// - Parameters:
///   - manager: JLBroadcastSetManager
///   - encryptModel: JLEncryptModel
-(void)jlBroadcastSetManager:(JLBroadcastSetManager *)manager Encrypt:(JLEncryptModel *)encryptModel;

/// 设置发射功率
/// - Parameters:
///   - manager: JLBroadcastSetManager
///   - power: 发射功率
-(void)jlBroadcastSetManager:(JLBroadcastSetManager *)manager Power:(NSInteger)power;


/// 失败回调
/// - Parameters:
///   - manager: JLBroadcastSetManager
///   - err: NSError
-(void)jlBroadcastSetManager:(JLBroadcastSetManager *)manager Failed:(NSError *)err;


/// 读取设置完成
/// - Parameter manager: JLBroadcastSetManager
-(void)jlBroadcastSetManagerDone:(JLBroadcastSetManager *)manager;


@end

/// 广播音频发射设置交互类
@interface JLBroadcastSetManager : NSObject

/// 广播名称
@property (nonatomic,strong)NSString *broadcastName;

/// 音频格式
@property (nonatomic,assign)JLBroadcastSetAudioFormat audioFormat;

/// 加密参数
@property (nonatomic,strong)JLEncryptModel *encryptModel;

/// 发射的功率
/// 1 ～ 10
@property (nonatomic,assign)NSInteger power;

-(instancetype)init __attribute__((unavailable("init is not available, use initWithTransmitter:Protocol: instead")));

/// 初始化
/// - Parameter 
///   - tranmitter: 发射器
///   - protocol: 协议
-(instancetype)initWithTransmitter:(JLAuracastTransmitter *)tranmitter protocol:(id<JLBroadcastSetManagerProtocol>)protocol;

/// 获取发射器的状态信息
/// - Parameter type: 类型
/// - Parameter block: 回调
-(void)getDevStatus:(JLBroadcastSetOptionsType)type block:(JLBroadcastSetManagerGetBlock)block;

/// 设置广播名称
/// 不支持并发请求，如果想同时设置多个，需要使用 setManagerSetToDevice
/// - Parameters:
///   - broadcastName: 广播名称
///   - block: 设置结果
-(void)setBroadcastNameToDevice:(NSString *)broadcastName block:(JLBroadcastSetManagerSetBlock)block;

/// 设置音频格式
/// 不支持并发请求，如果想同时设置多个，需要使用 setManagerSetToDevice
/// - Parameters:
///   - format: 音频格式
///   - block: 设置结果
-(void)setAudioFormatToDevice:(JLBroadcastSetAudioFormat)format block:(JLBroadcastSetManagerSetBlock)block;


/// 设置加密
/// 不支持并发请求，如果想同时设置多个，需要使用 setManagerSetToDevice
/// - Parameters:
///   - md: JLEncryptModel
///   - block: 设置结果
-(void)setEncryptModelToDevice:(JLEncryptModel *)md block:(JLBroadcastSetManagerSetBlock)block;


/// 设置发射功率
/// 不支持并发请求，如果想同时设置多个，需要使用 setManagerSetToDevice
/// - Parameters:
///   - power: 发射功率
///   - block: 设置结果
-(void)setPowerToDevice:(NSInteger)power block:(JLBroadcastSetManagerSetBlock)block;


/// 设置广播名称、音频格式、加密、发射功率
/// - Parameter block: 设置结果
-(void)setManagerSetToDevice:(JLBroadcastSetManagerSetBlock)block;

/// 释放
- (void)onRelease;


@end

NS_ASSUME_NONNULL_END
