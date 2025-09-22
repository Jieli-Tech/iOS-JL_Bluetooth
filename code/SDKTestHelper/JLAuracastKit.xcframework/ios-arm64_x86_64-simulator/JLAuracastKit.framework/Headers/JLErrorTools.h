//
//  JLErrorTools.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/28.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, JLAuraErrorCode) {
    /// 操作成功
    JLAuraErrorCodeSuccess = 0x0000,
    /// 操作失败
    JLAuraErrorCodeFailed = 0x0001,
    /// 参数无效
    JLAuraErrorCodeInvalid = 0x0002,
    /// 正在操作中，命令重复
    JLAuraErrorCodeRepeatOp = 0x0003,
    /// 设备繁忙
    JLAuraErrorCodeBusy = 0x0004,
    /// 内存不足
    JLAuraErrorCodeOutOfMemory = 0x0005,
    /// 未定义的命令
    JLAuraErrorCodeUndefined = 0x0006,
    /// 数据溢出
    JLAuraErrorCodeOverflow = 0x0007,
    
    /// 操作停止
    JLAuraErrorCodeOpStop = 0x0100,
    ///操作超时
    JLAuraErrorCodeTimeout = 0x0101,
    ///不允许的操作
    JLAuraErrorCodeNotAllow = 0x0102,
    ///不支持的功能
    JLAuraErrorCodeNotSupport = 0x0103,
    
    ///设备未连接
    JLAuraErrorCodeNotConnect = 0x0200,
    ///设备处于通话状态
    JLAuraErrorCodeCallStatus = 0x0201,
    ///设备处于升级状态
    JLAuraErrorCodeUpgradeStatus = 0x0202,
    
    ///数据不足
    JLAuraErrorCodeDataNotEnough = 0x0300,
    ///错误数据
    JLAuraErrorCodeDataError = 0x0301,
    /// 发送数据失败
    JLAuraErrorCodeSendError = 0x0302,
    /// 等待回复命令超时
    JLAuraErrorCodeWaitReplyTimeout = 0x0303,
    /// 丢失发送数据
    JLAuraErrorCodeLostSendData = 0x0304,
    /// 没有数据处理线程
    JLAuraErrorCodeNoDataThread = 0x0305,
    ///设备回复失败的状态
    JLAuraErrorCodeReplyStatus = 0x0306,
    ///解析数据失败
    JLAuraErrorCodeParseError = 0x0307,
    
    ///没有服务
    JLAuraErrorCodeNoService = 0x0400,
    ///缺少调节计数器
    JLAuraErrorCodeLessCounter = 0x0401,
    ///周期性广播同步失败
    JLAuraErrorCodeLessSync = 0x0402,
    ///密码错误
    JLAuraErrorCodePswError = 0x0403,
    ///周期性广播同步超时
    JLAuraErrorCodeSyncTimeout = 0x0404,
    ///周期性广播未同步
    JLAuraErrorCodeSyncNotSync = 0x0405,

    ///未知错误
    JLAuraErrorCodeUnknown = 0xFFFF
};

@interface JLErrorTools : NSObject

+(NSError *_Nullable)getError:(JLAuraErrorCode)type;

@end

NS_ASSUME_NONNULL_END
