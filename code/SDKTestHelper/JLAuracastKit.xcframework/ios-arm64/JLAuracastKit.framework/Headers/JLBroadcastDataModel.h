//
//  JLBroadcastDataModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/9/28.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLBroadcastFeaturesModel;
@class JLBroadcastState;

NS_ASSUME_NONNULL_BEGIN

@interface JLBroadcastDataModel : NSObject

/// 广播名称
@property (nonatomic, strong)NSString *name;

/// 广播的 ID
@property (nonatomic, assign)NSInteger broadcastID;

/// 广播特性
@property (nonatomic, strong)JLBroadcastFeaturesModel *features;

/// 广播音频源地址
@property (nonatomic, strong)NSData *broadcastAddress;

/// 同步状态
@property (nonatomic, strong)JLBroadcastState *syncState;

/// 广播密钥
@property (nonatomic, strong)NSData *broadcastKey;

/// 基础原始数据
@property (nonatomic, strong)NSData *baseData;

-(instancetype)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
