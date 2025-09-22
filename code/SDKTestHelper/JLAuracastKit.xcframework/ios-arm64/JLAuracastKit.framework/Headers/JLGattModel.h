//
//  JLGattModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/26.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLGattModel : NSObject

/// UUID
@property (nonatomic, strong) NSString *uuid;
/// 名称
@property (nonatomic, strong) NSString *_Nullable name;
/// 服务 UUID
@property (nonatomic, strong) NSString *serviceUUID;
/// 特征 UUID
@property (nonatomic, strong) NSString *characteristicUUID;

+(JLGattModel *)init:(NSString *)uuid serviceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID;

+(JLGattModel *)init:(NSString *)uuid name:(NSString *)name serviceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID;
@end

NS_ASSUME_NONNULL_END
