//
//  JLAuracastSourceControl.h
//  JLAuracastKit
//
//  Created by EzioChan on 2025/3/10.
//  Copyright © 2025 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLAuracastKit/JLAuracastKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JLAuracastSourceControlBlock)(JLAuraErrorCode result);

typedef void(^JLAuracastSourceControlStateBlock)(JLAuraErrorCode result,JLBroadcastDataModel * _Nullable model);

/// 音源控制
@interface JLAuracastSourceControl : NSObject

/// 音源控制
/// - Parameters:
///   - tranmistter: 通讯对象
///   - source: 资源
///   - block: 回调
-(void)onControlWith:(JLAuracastTransmitter *)tranmistter AddSource:(JLBroadcastDataModel *)source Result:(JLAuracastSourceControlBlock _Nullable) block;

/// 移除音源控制
/// - Parameters:
///   - tranmistter: 通讯对象
///   - block: 回调
-(void)onControlWithRemove:(JLAuracastTransmitter *)tranmistter Result:(JLAuracastSourceControlBlock _Nullable) block;

/// 获取音源状态
/// - Parameters:
///   - tranmistter: 通讯对象
///   - block: 回调
-(void)onControlGetState:(JLAuracastTransmitter *)tranmistter Result:(JLAuracastSourceControlStateBlock _Nullable)block;

/// 释放
-(void)onRelease;

@end

NS_ASSUME_NONNULL_END
