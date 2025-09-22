//
//  JLResetDevManager.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/30.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JLAuracastTransmitter;

/// ResetDevOptionType
/// 设备执行动作
typedef NS_ENUM(NSUInteger, JLResetDevOptionType) {
    /// Shutdown
    JLResetDevOptionTypeShutdown = 0x00,
    /// Reboot
    JLResetDevOptionTypeReboot = 0x01,
    /// RestoreFactory
    JLResetDevOptionTypeRestoreFactory = 0x02
};

/// ResetDevManager
@interface JLResetDevManager : NSObject

/// 关闭/重启/恢复出厂设置
/// - Parameter option: 设备执行动作
+(void)resetDevWithOption:(JLResetDevOptionType)option Transmitter:(JLAuracastTransmitter *)transmitter;

@end

NS_ASSUME_NONNULL_END
