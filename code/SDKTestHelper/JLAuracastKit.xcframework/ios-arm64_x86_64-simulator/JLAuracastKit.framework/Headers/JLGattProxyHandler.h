//
//  JLGattProxyHandler.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/23.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLGattModel;
NS_ASSUME_NONNULL_BEGIN

/// 设备的蓝牙数据代理
@protocol JLGattProxyProtocol <NSObject>


/// 要发送给设备的蓝牙数据
/// - Parameters:
///   - data: 要发送的数据
///   - model: 蓝牙模型
-(void)jlBleDataRTXHandlerSendData:(NSData *)data gattModel:(JLGattModel *)model;

@end

/// 数据接收/发送类
@interface JLGattProxyHandler : NSObject

/// 设备的 UUID
@property(nonatomic,strong,readonly) NSString *uuid;

/// 数据发送代理
@property(nonatomic,strong,readonly) id<JLGattProxyProtocol> delegate;

/// 杰理私有协议蓝牙写入句柄
@property(nonatomic,strong)JLGattModel *jlWriteGattModel;

/// 杰理私有协议蓝牙通知句柄
@property(nonatomic,strong)JLGattModel *jlNotifyGattModel;



- (instancetype)init __attribute__((unavailable("init is not available, use initWithUUID:Delegate: instead")));


/// 初始化的唯一方法
/// - Parameters:
///   - uuid: 设备的 UUID
///   - delegate: 数据发送代理
- (instancetype)initWithUUID:(NSString *)uuid Delegate:(id<JLGattProxyProtocol>)delegate;



/// 接收到的数据
/// - Parameters:
///   - model: 蓝牙模型
///   - data: 接收到的数据
- (void) onDataReceiveModel:(JLGattModel *)model Data:(NSData *)data;

/// 销毁
-(void)onDistory;

@end

NS_ASSUME_NONNULL_END
