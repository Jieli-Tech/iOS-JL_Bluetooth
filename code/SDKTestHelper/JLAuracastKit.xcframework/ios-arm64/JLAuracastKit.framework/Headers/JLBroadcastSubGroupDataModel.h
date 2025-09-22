//
//  JLBroadcastSubGroupDataModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/10/28.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLAuracastKit/JLAuracastMetaModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLBroadcastSubGroupDataModel : NSObject

/// BIS_Sync
@property (nonatomic, assign)uint32_t bisSync;

/// Metadata_model
@property (nonatomic, strong)JLAuracastMetaModel *metaModel;

/// 元数据
@property (nonatomic, strong)NSData *metadata;


+ (NSArray<JLBroadcastSubGroupDataModel *> *)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
