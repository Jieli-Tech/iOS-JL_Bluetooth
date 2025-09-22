//
//  JLBroadcastFeaturesModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2025/3/10.
//  Copyright © 2025 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 广播特性
@interface JLBroadcastFeaturesModel : NSObject

@property (nonatomic, strong)NSData *features;

/// 是否加密
@property (nonatomic, assign)BOOL isEncrypted;

+(JLBroadcastFeaturesModel *)initData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
