//
//  JLBroadcastReceiveStatusModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/10/28.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLAuracastKit/JLBroadcastSubGroupDataModel.h>
#import <JLAuracastKit/JLBroadcastBaseInfoModel.h>

NS_ASSUME_NONNULL_BEGIN

/// 广播接收状态
typedef NS_ENUM(NSUInteger, JLPASyncStatusType) {
    /// 不同步至PA
    JLPASyncStatusTypeNotSyncPA = 0x00,
    /// 请求SyncInfo
    JLPASyncStatusTypeRequestSyncInfo = 0x01,
    /// 已同步到PA
    JLPASyncStatusTypeSynced = 0x02,
    /// 同步到PA失败
    JLPASyncStatusTypeSyncFailed = 0x03,
    /// No PAST
    JLPASyncStatusTypeNotPAST = 0x04,
    /// 保留
    JLPASyncStatusTypeReserved = 0x05,
};

/// 广播加密状态
typedef NS_ENUM(NSUInteger, JLBroadcastBigEncryptStatusType) {
    /// 不加密
    JLBroadcastBigEncryptStatusTypeNotEncrypt = 0x00,
    /// 加密，需要Broadcast_Code
    JLBroadcastBigEncryptStatusTypeEncryptNeedBroadcastCode = 0x01,
    /// 正在解密
    JLBroadcastBigEncryptStatusTypeDecrypting = 0x02,
    /// 密码错误
    JLBroadcastBigEncryptStatusTypePasswordError = 0x03,
    /// 保留
    JLBroadcastBigEncryptStatusTypeReserved = 0x04,
};

/// 广播接收状态
@interface JLBroadcastReceiveStatusModel : NSObject

/// 数据源ID
@property (nonatomic, assign) uint8_t sourceID;

/// 数据源地址类型
@property (nonatomic, assign) JLBroadcastAdvertiserAddressType sourceAddressType;

/// 数据源地址
@property (nonatomic, strong) NSData *sourceAddress;

/// 广播会议ID
@property (nonatomic, assign) uint8_t advSID;

/// 广播ID
@property (nonatomic, assign) NSInteger broadcastID;

/// PA同步标识
@property (nonatomic, assign) JLPASyncStatusType paSyncState;

/// BIG加密状态
@property (nonatomic, assign) JLBroadcastBigEncryptStatusType bigEncryptStatus;

/// Bad_Code
/// 如果 BIG_Encryption 字段值 = 0x00、0x01 或 0x02：为空（零长度）
/// 如果 BIG_Encryption 字段值 = 0x03 (Bad_Code)，则应将 Bad_Code 设置为无法解密 BIG 的错误 16 Bytes Broadcast_Code 的值
@property (nonatomic, strong) NSData *_Nullable badCode;

/// 子组数
@property (nonatomic, assign) int numSubgroups;

/// 子组数据
@property (nonatomic, strong) NSArray<JLBroadcastSubGroupDataModel *> *subGroupData;

@property (nonatomic, strong) NSData *baseData;

- (instancetype)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
