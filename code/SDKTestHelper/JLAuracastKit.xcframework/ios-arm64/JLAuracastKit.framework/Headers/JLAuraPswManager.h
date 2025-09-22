//
//  JLAuraPswManager.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/28.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JLAuracastTransmitter;

/// 登录状态
typedef NS_ENUM(NSUInteger, JLAuraPswLoginStatus) {
    /// 登录成功
    JLAuraPswLoginStatusSuccess = 0x00,
    /// 登录失败
    JLAuraPswLoginStatusFail = 0x01,
    /// 重复登录
    JLAuraPswLoginStatusRepeat = 0x02
};

typedef NS_ENUM(NSUInteger, JLAuraPswModifyStatus) {
    /// 修改成功
    JLAuraPswModifyStatusSuccess = 0x00,
    /// 旧密码错误
    JLAuraPswModifyStatusOldPswError = 0x01,
    /// 密码没有变化
    JLAuraPswModifyStatusNoChange = 0x02,
    /// 新密码长度不对
    JLAuraPswModifyStatusNewPswError = 0x03,
    /// 修改失败
    JLAuraPswModifyStatusFail = 0xFF
};

typedef void(^JLAuraPswManagerLoginBlock)(JLAuraPswLoginStatus status,NSError * _Nullable error);

typedef void(^JLAuraPswManagerModifyBlock)(JLAuraPswModifyStatus status,NSError * _Nullable error);

/// 密码管理与登录
@interface JLAuraPswManager : NSObject

/// 登录验证
/// - Parameters:
///   - password: 密码
///   - transmitter: 传输器
///   - block: 登录结果回调
-(void)loginVerifyWith:(NSString *)password Transmitter:(JLAuracastTransmitter *)transmitter block:(JLAuraPswManagerLoginBlock)block;


/// 修改密码
/// - Parameters:
///   - oldPassword: 旧密码
///   - newPassword: 新密码
///   - transmitter: 传输器
///   - block: 修改结果回调
-(void)modifyOld:(NSString *)oldPassword newPsw:(NSString *)newPassword Transmitter:(JLAuracastTransmitter *)transmitter block:(JLAuraPswManagerModifyBlock)block;


/// 释放
-(void)onRelease;

@end

NS_ASSUME_NONNULL_END
