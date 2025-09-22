//
//  JLBoracastAFModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/27.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class JLAuracastMetaModel;

/// 音频流信息
/// Public Broadcast Announcement Features
@interface JLBroadcastAFModel : NSObject

/// 音频流是否加密
@property (nonatomic,assign)BOOL audioStreamEncrypt;

/// 音频流是否存在
/// 标准音频音频流存在状态
@property (nonatomic,assign)BOOL streamExistenceStatus;

/// 高音质音频流存在状态
/// 是否支持高清音频流
@property (nonatomic,assign)BOOL hasHighQuality;

/// 节目元数据
@property (nonatomic,strong)JLAuracastMetaModel *metaModel;


-(instancetype)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
