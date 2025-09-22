//
//  JLBroadcastBaseInfoModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/28.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 广播基础信息设备地址类型
typedef NS_ENUM(NSUInteger,JLBroadcastAdvertiserAddressType ) {
    /// 公共设备地址或公共身份地址
    JLBroadcastAdvertiserAddressTypePublic = 0x00,
    /// 随机设备地址或随机(静态)身份地址
    JLBroadcastAdvertiserAddressTypeRandom = 0x01,
};


/// 广播基础信息
@interface JLBroadcastBaseInfoModel : NSObject

/// 广播源地址类型
@property (nonatomic, assign) JLBroadcastAdvertiserAddressType advertiserAddressType;

/// 广播源地址
@property (nonatomic, strong) NSData *advertiserAddress;

/// 广播会话ID
@property (nonatomic, assign) NSInteger advertisingSID;

/// PA 间隔
@property (nonatomic, assign) NSInteger PAInterval;

- (instancetype)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
