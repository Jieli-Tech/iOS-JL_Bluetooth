//
//  JLAV2CodeInfo.h
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/10.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JLAV2CodeInfoFrameIdx32 = 0,
    JLAV2CodeInfoFrameIdx40,
    JLAV2CodeInfoFrameIdx48,
    JLAV2CodeInfoFrameIdx60,
    JLAV2CodeInfoFrameIdx64,
    JLAV2CodeInfoFrameIdx80,
    JLAV2CodeInfoFrameIdx96,
    JLAV2CodeInfoFrameIdx120,
    JLAV2CodeInfoFrameIdx128,
    JLAV2CodeInfoFrameIdx160,
    JLAV2CodeInfoFrameIdx240,
    JLAV2CodeInfoFrameIdx320,
    JLAV2CodeInfoFrameIdx400,
    JLAV2CodeInfoFrameIdx480
} JLAV2CodeInfoFrameIdx;


/// 配置参数
@interface JLAV2CodeInfo : NSObject

/// 采样率
@property (nonatomic,assign) uint32_t sampleRate;

/// 码率
@property (nonatomic,assign) uint32_t bitRate;

/// 帧长索引对应实际值
/// [32, 40, 48, 60, 64, 80, 96, 120, 128, 160, 240, 320, 400, 480]
@property (nonatomic,assign) JLAV2CodeInfoFrameIdx frameIdx;

/// 声道
@property (nonatomic,assign) uint16_t channels;

/// 是否支持bit24
@property (nonatomic,assign) BOOL isSupportBit24;


/// 默认配置
+(JLAV2CodeInfo *)defaultInfo;

@end

NS_ASSUME_NONNULL_END
