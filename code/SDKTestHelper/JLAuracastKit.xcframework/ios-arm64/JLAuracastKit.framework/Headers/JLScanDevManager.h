//
//  JLScanDevManager.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/27.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JLAuracastTransmitter;

typedef void(^JLScanDevManagerBlock)(BOOL status,NSError *_Nullable error);


/// 扫描设备
/// 当前类是通过命令协议控制设备进行搜索附近的音源设备，区别于原有的蓝牙 BLE 搜索
@interface JLScanDevManager : NSObject

/// 搜索
/// - Parameter 
///    - transmitter: 通讯上下文
///    - block: 命令操作结果回调
- (void) onSearchStartedTransmitter:(JLAuracastTransmitter *)transmitter Block:(JLScanDevManagerBlock) block;


/// 停止搜索
/// - Parameter 
///    - transmitter: 通讯上下文
///    - block: 命令操作结果回调
- (void) onSearchStoppedTransmitter:(JLAuracastTransmitter *)transmitter Block:(JLScanDevManagerBlock) block;


/// 释放
-(void)onRelease;

@end

NS_ASSUME_NONNULL_END
