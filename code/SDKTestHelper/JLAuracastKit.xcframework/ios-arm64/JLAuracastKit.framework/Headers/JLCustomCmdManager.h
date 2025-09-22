//
//  JLCustomCmdManager.h
//  JLAuracastKit
//
//  Created by EzioChan on 2025/3/11.
//  Copyright © 2025 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLAuracastKit/JLAuracastKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JLCustomCmdManager;

/// 自定义指令回调
@protocol JLCustomCmdDelegate <NSObject>

/// 监听设备端发送的自定义指令
/// - Parameters:
///   - manager: 自定义对象
///   - data: 自定义数据
///   - isNeedResponse: 是否需要回复
- (void)jlCustomCmdManager:(JLCustomCmdManager *)manager CmdPackageReceive:(NSData *)data isNeedResponse:(BOOL)isNeedResponse;

/// 自定义指令回复
/// - Parameters:
///   - manager: 自定义对象
///   - status: 指令状态
///   - data: 自定义数据回复
- (void)jlCustomCmdManager:(JLCustomCmdManager *)manager CmdStatus:(JLAuraErrorCode) status Data:(NSData *_Nullable) data;

@end

typedef void(^JLCustomCmdBlock)(JLAuraErrorCode result,NSData * _Nullable data);

/// 自定义指令
@interface JLCustomCmdManager : NSObject

/// 自定义指令回调代理
@property (nonatomic, weak) id<JLCustomCmdDelegate> delegate;

/// 初始化
/// - Parameters:
///   - transmitter: 传输对象
///   - delegate: 代理
-(instancetype)initWithTransmitter:(JLAuracastTransmitter *)transmitter Delegate:(id<JLCustomCmdDelegate>)delegate;

/// 自定义指令发送包
/// - Parameters:
///   - transmitter: 传输对象
///   - data: 发送数据
///   - block: 回调
-(void)customWith:(JLAuracastTransmitter *) transmitter SendData:(NSData *)data Result:(JLCustomCmdBlock _Nullable) block;

/// 自定义指令回复包，当收到设备端主动推送的自定义命令需要回复时，使用以下的方法回复
/// - Parameters:
///   - transmitter: 传输对象
///   - data: 回复数据
-(void)customWith:(JLAuracastTransmitter *)transmitter Response:(NSData *_Nullable)data;

/// 释放
-(void)onRelease;

@end

NS_ASSUME_NONNULL_END
