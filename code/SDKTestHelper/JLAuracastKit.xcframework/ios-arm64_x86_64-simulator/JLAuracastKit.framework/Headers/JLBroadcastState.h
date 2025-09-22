//
//  JLBroadcastState.h
//  JLAuracastKit
//
//  Created by EzioChan on 2025/3/10.
//  Copyright © 2025 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 广播同步状态
typedef NS_ENUM(NSUInteger, JLBroadcastStateType) {
    /// 空闲
    JLBroadcastStateIdle = 0x00,
    /// 正在同步
    JLBroadcastStateSyncing = 0x01,
    /// 同步成功
    JLBroadcastStateSyncSuccess = 0x02,
};

/// 广播同步错误
typedef NS_ENUM(NSUInteger, JLBroadcastStateErrorType) {
    /// 无错误
    JLBroadcastStateErrorTypeNone = 0x00,
    /// 广播名错误
    JLBroadcastStateErrorTypeBroadcastName = 0x01,
    /// 广播地址错误
    JLBroadcastStateErrorTypeBroadcastAddress = 0x02,
    /// 广播ID错误
    JLBroadcastStateErrorTypeBroadcastID = 0x03,
    /// 广播密钥错误
    JLBroadcastStateErrorTypeBroadcastKey = 0x04,
    /// 广播同步失败
    JLBroadcastStateErrorTypeSyncFail = 0x05,
    /// 同步超时
    JLBroadcastStateErrorTypeSyncTimeout = 0x06,
    /// 同步丢失
    JLBroadcastStateErrorTypeSyncLost = 0x07
};

/// 广播同步状态
@interface JLBroadcastState : NSObject

/// 同步状态
@property (nonatomic, assign)JLBroadcastStateType state;

/// 同步错误
/// 只有同步状态为 idle 的时候才有作用
@property (nonatomic, assign)JLBroadcastStateErrorType errorType;

+(JLBroadcastState *) initData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
