//
//  JLAudioFormatModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/10/10.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLAuracastKit/JLBroadcastSetManager.h>

NS_ASSUME_NONNULL_BEGIN

/// 音频编码详情模型
@interface JLAudioFormatModel : NSObject

/// 音频格式
@property (nonatomic, assign, readonly) JLBroadcastSetAudioFormat audioFormat;

/// 音频编码名称
@property (nonatomic, strong, readonly) NSString *name;

/// 采样率 单位：Hz
@property (nonatomic, assign, readonly) NSInteger sampleRate;

/// 最小通讯单元发送间隔 单位：µs
@property (nonatomic, assign, readonly) NSInteger SDUInterval;

/// 最大通讯单元包长度 单位：Byte
@property (nonatomic, assign, readonly) NSInteger maxSDUOctets;

/// 最大通讯单元包长度描述
@property (nonatomic, strong, readonly) NSString *maxSDUOctetsStr;

/// RTN 重试次数
@property (nonatomic, assign, readonly) NSInteger RTN;

/// 最大传输延时 单位：ms
@property (nonatomic, assign, readonly) NSInteger maxTransportLatency;

/// 演示延时 单位：µs
@property (nonatomic, assign, readonly) NSInteger presentaionDelay;

-(instancetype)init __attribute__((unavailable("init is not available, use initWithAudioFormat: instead")));

-(instancetype)initWithAudioFormat:(JLBroadcastSetAudioFormat)audioFormat;


@end

NS_ASSUME_NONNULL_END
