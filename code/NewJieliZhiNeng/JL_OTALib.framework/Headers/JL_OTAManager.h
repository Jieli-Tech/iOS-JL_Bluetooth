//
//  JL_OTAManager.h
//  JL_BLEKit
//
//  Created by 杰理科技 on 2021/11/16.
//  Copyright © 2021 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OTA_LEVEL) {
    OTA_DEBUG = 0,
    OTA_INFO  = 1,
    OTA_WARN  = 2,
    OTA_ERROR = 3,
};

typedef NS_ENUM(UInt8, JL_OTAResult) {
    JL_OTAResultSuccess             = 0x00, //OTA升级成功
    JL_OTAResultFail                = 0x01, //OTA升级失败
    JL_OTAResultDataIsNull          = 0x02, //OTA升级数据为空
    JL_OTAResultCommandFail         = 0x03, //OTA指令失败
    JL_OTAResultSeekFail            = 0x04, //OTA标示偏移查找失败
    JL_OTAResultInfoFail            = 0x05, //OTA升级固件信息错误
    JL_OTAResultLowPower            = 0x06, //OTA升级设备电压低
    JL_OTAResultEnterFail           = 0x07, //未能进入OTA升级模式
    JL_OTAResultUpgrading           = 0x08, //OTA升级中
    JL_OTAResultReconnect           = 0x09, //OTA需重连设备(uuid方式)
    JL_OTAResultReboot              = 0x0a, //OTA需设备重启
    JL_OTAResultPreparing           = 0x0b, //OTA准备中
    JL_OTAResultPrepared            = 0x0f, //OTA准备完成
    JL_OTAResultFailVerification    = 0xf1, //升级数据校验失败
    JL_OTAResultFailCompletely      = 0xf2, //升级失败
    JL_OTAResultFailKey             = 0xf3, //升级数据校验失败，加密Key不对
    JL_OTAResultFailErrorFile       = 0xf4, //升级文件出错
    JL_OTAResultFailUboot           = 0xf5, //uboot不匹配
    JL_OTAResultFailLenght          = 0xf6, //升级过程长度出错
    JL_OTAResultFailFlash           = 0xf7, //升级过程flash读写失败
    JL_OTAResultFailCmdTimeout      = 0xf8, //升级过程指令超时
    JL_OTAResultFailSameVersion     = 0xf9, //相同版本
    JL_OTAResultFailTWSDisconnect   = 0xfa, //TWS耳机未连接
    JL_OTAResultFailNotInBin        = 0xfb, //耳机未在充电仓
    JL_OTAResultReconnectWithMacAddr= 0xfc, //OTA需重连设备(mac方式)
    JL_OTAResultUnknown,                    //OTA未知错误
};
typedef NS_ENUM(UInt8, JL_OTAUrlResult) {
    JL_OTAUrlResultSuccess          = 0x00, //OTA文件获取成功
    JL_OTAUrlResultFail             = 0x01, //OTA文件获取失败
    JL_OTAUrlResultDownloadFail     = 0x02, //OTA文件下载失败
};

typedef NS_ENUM(UInt8, JL_OTAReconnectType) {
    JL_OTAReconnectTypeUUID          = 0x00, //OTA升级回连使用uuid
    JL_OTAReconnectTypeMACAddr       = 0x01, //OTA升级回连使用mac地址
};

typedef NS_ENUM(UInt8, JL_OtaStatus) {
    JL_OtaStatusNormal              = 0,    //正常升级
    JL_OtaStatusForce               = 1,    //强制升级
};
typedef NS_ENUM(UInt8, JL_OtaHeadset) {
    JL_OtaHeadsetNO                 = 0,    //耳机单备份 正常升级
    JL_OtaHeadsetYES                = 1,    //耳机单备份 强制升级
};
typedef NS_ENUM(UInt8, JL_OtaWatch) {
    JL_OtaWatchNO                   = 0,    //手表资源 正常升级
    JL_OtaWatchYES                  = 1,    //手表资源 强制升级
};
typedef NS_ENUM(UInt8, JL_BootLoader) {
    JL_BootLoaderNO                 = 0,    //不需要下载Bootloader
    JL_BootLoaderYES                = 1,    //需要下载BootLoader
};
typedef NS_ENUM(UInt8, JL_Partition) {
    JL_PartitionSingle              = 0,    //固件单备份
    JL_PartitionDouble              = 1,    //固件双备份
};

typedef void(^JL_OTA_URL)(JL_OTAUrlResult result,
                          NSString* __nullable version,
                          NSString* __nullable url,
                          NSString* __nullable explain);
typedef void(^JL_OTA_RT)(JL_OTAResult result, float progress);

typedef void(^JL_OTA_RESULT)(uint8_t status, uint8_t sn, NSData* __nullable data);

@class JL_OTAManager;

/// OTA 升级管理对象回调
@protocol JL_OTAManagerDelegate <NSObject>

/// 即将被发送的数据
/// @param data 数据内容
-(void)otaDataSend:(NSData *_Nonnull)data;

@optional
/// 回调设备状态信息
/// @param manager 对象状态
-(void)otaFeatureResult:(JL_OTAManager *_Nonnull)manager;

/// 回调升级状态以及进度等
/// @param result 状态以及进度信息
/// @param progress 进度信息
-(void)otaUpgradeResult:(JL_OTAResult)result Progress:(float)progress;

/// 取消OTA升级
-(void)otaCancel;

@end

/// OTA升级管理对象
@interface JL_OTAManager : NSObject



/// 设备UUID（需要开发者填入）
@property (strong, nonatomic) NSString          *mBLE_UUID;

/// 设备名称（需要开发者填入）
@property (strong, nonatomic) NSString          *mBLE_NAME;

///是否仅仅支持BLE
@property (assign, nonatomic) BOOL              bleOnly;

///ble蓝牙地址
@property (strong, nonatomic) NSString          *bleAddr;

/// SN值
@property (assign, nonatomic) uint8_t           mCmdSN;

/// 设备版本号
@property (assign, nonatomic) uint16_t          version;

/// 设备版本信息
@property (strong, nonatomic) NSString          *versionFirmware;

/// 设备OTA状态
@property (assign, nonatomic) JL_OtaStatus      otaStatus;

/// 耳机单备份 是否需要强制升级
@property (assign, nonatomic) JL_OtaHeadset     otaHeadset;

/// 手表资源 是否需要强制升级
@property (assign, nonatomic) JL_OtaWatch       otaWatch;

/// 设备OTA时支持单/双备份
@property (assign, nonatomic) JL_Partition      otaPartition;

/// 设备是否需要下载Loader
@property (assign, nonatomic) JL_BootLoader     bootloaderType;

/// OTA升级回连方式
@property (assign, nonatomic) JL_OTAReconnectType   otaReconnectType;

/// 设备交互回调代理
@property (weak,   nonatomic) id<JL_OTAManagerDelegate> delegate;


/// 打印OTA发送的数据内容
/// - Parameter status: 开关
-(void)logSendData:(BOOL)status;

/// 当BLE连接上时告知SDK
-(void)noteEntityConnected;

/// 当BLE断开时告知SDK
-(void)noteEntityDisconnected;

/// Receive data from rcsp
/// 设备端过来的数据
/// - Parameter data: data
-(void)cmdOtaDataReceive:(NSData *)data;

/// 查询设备OTA信息
/// 所有情况下都需要执行，而且是在连上后（认证完成）第一步执行
-(void)cmdTargetFeature;

/// 查询设备系统状态
/// 当设备需要挂载外置flash才能正常升级时需要执行，其他情况则无需执行
-(void)cmdSystemFunction;

#pragma mark -文件下载
/**
 文件下载
 @param key 授权key
 @param code 授权code
 @param result 回复
 */
-(void)cmdGetOtaFileKey:(NSString*)key
                   Code:(NSString*)code
                 Result:(JL_OTA_URL __nullable)result;

/**
 OTA升级文件下载【MD5】
@param key 授权key
@param code 授权code
@param hash  MD5值
@param result 回复
*/
-(void)cmdGetOtaFileKey:(NSString*)key
                   Code:(NSString*)code
                   hash:(NSString*)hash
                 Result:(JL_OTA_URL __nullable)result;

///OTA单备份，是否正在回连
-(BOOL)cmdOtaIsRelinking;

#pragma mark ---> OTA升级
/**
 开始OTA升级
 @param data 升级数据
 @param result 升级结果
 */
-(void)cmdOTAData:(NSData*)data
           Result:(JL_OTA_RT __nullable)result;


/**
 OTA升级取消
 @param result 回复
 */
-(void)cmdOTACancelResult:(JL_OTA_RESULT __nullable)result;

///重启设备
-(void)cmdRebootDevice;

///强制重启设备
-(void)cmdRebootForceDevice;


/// 重置OTA manager
-(void)resetOTAManager;


/// 打印OTA SDK版本
+(NSString *)logSDKVersion;

///LOG使能与等级，默认开启且debug等级。
/// @param enable LOG使能
/// @param isMore 是否打印【函数名&行号】
/// @param level   LOG等级
+(void)setLog:(BOOL)enable IsMore:(BOOL)isMore Level:(OTA_LEVEL)level;

/// 打印宏
#define kOTALog(level,fmt...) [JL_OTAManager Log:level Func:__FUNCTION__ Line:__LINE__ format:fmt]
/// 打印函数
/// @param level     LOG等级
/// @param func       函数名
/// @param line       行号
/// @param format   内容
+(void)Log:(OTA_LEVEL)level
          Func:(const char* _Nullable)func
          Line:(const int)line
        format:(NSString * _Nonnull)format,...;

@end

NS_ASSUME_NONNULL_END
