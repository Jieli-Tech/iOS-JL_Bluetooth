//
//  JLBroadcastInfoManager.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/28.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class JLBroadcastDataModel;
@class JLBroadcastInfoManager;
@class JLAuracastTransmitter;
@class JLScanDevManager;
@class JLAuracastSourceControl;

/// 广播信息协议
@protocol JLBroadcastInfoManagerProtocol <NSObject>

@optional
/// 单个广播信息对象回调
/// - Parameters:
///   - manager: JLBroadcastInfoManager
///  - model: 广播对象
-(void)jlBroadcastInfoManager:(JLBroadcastInfoManager *)manager BroadcastDataModel:(JLBroadcastDataModel *)model;

/// 多个广播信息对象回调
/// - Parameters:
///   - manager: JLBroadcastInfoManager
///   - models: 广播对象
-(void)jlBroadcastInfoManager:(JLBroadcastInfoManager *)manager BroadcastDataModelList:(NSArray <JLBroadcastDataModel *>*)models;

/// 推送的广播状态
/// - Parameters:
///   - manager: JLBroadcastInfoManager
///   - model: 广播对象
-(void)jlBroadcastInfoManager:(JLBroadcastInfoManager *)manager BroadcastState:(JLBroadcastDataModel *)model;

@end


/// 广播信息管理
@interface JLBroadcastInfoManager : NSObject

-(instancetype)init __attribute__((unavailable("init is not available, use initWithTransmitter:Protocol: instead")));

/// 若干个搜索到的对象
@property(nonatomic,strong)NSMutableArray <JLBroadcastDataModel *>* broadcastDataModels;

/// 搜索控制对象
@property(nonatomic,strong)JLScanDevManager *scanMgr;

/// 资源控制对象
@property(nonatomic,strong)JLAuracastSourceControl *controlMgr;

/// 当前播放的对象
@property(nonatomic,strong)JLBroadcastDataModel * _Nullable currentBroadcastModel;

/// 初始化
/// - Parameters:
///   - tranmitter: 发射器
///   - protocol: 协议
-(instancetype)initWithTransmitter:(JLAuracastTransmitter *)tranmitter Protocol:(id<JLBroadcastInfoManagerProtocol>)protocol;

/// 释放
- (void)onRelease;

@end

NS_ASSUME_NONNULL_END
