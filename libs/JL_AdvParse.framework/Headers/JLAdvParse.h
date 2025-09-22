//
//  JLAdvParse.h
//  JL_AdvParse
//
//  Created by EzioChan on 2023/1/31.
//  Copyright © 2023 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ADV_LEVEL) {
    ADV_DEBUG = 0,
    ADV_INFO  = 1,
    ADV_WARN  = 2,
    ADV_ERROR = 3,
};


typedef NS_ENUM(UInt8,JL_AdvType) {
    JL_AdvTypeSoundBox              = 0,     //音箱类型
    JL_AdvTypeChargingBin           = 1,     //充电仓类型
    JL_AdvTypeTWS                   = 2,     //TWS耳机类型
    JL_AdvTypeHeadset               = 3,     //普通耳机类型
    JL_AdvTypeSoundCard             = 4,     //声卡类型
    JL_AdvTypeWatch                 = 5,     //手表类型
    JL_AdvTypeTradition             = 6,     //传统设备类型
};


typedef NS_ENUM(NSInteger,JL_DeviceType) {
    JL_DeviceTypeSoundBox           = 0,     //AI音箱类型
    JL_DeviceTypeChargingBin        = 1,     //充电仓类型
    JL_DeviceTypeTWS                = 2,     //TWS耳机类型
    JL_DeviceTypeHeadset            = 3,     //普通耳机类型
    JL_DeviceTypeSoundCard          = 4,     //声卡类型
    JL_DeviceTypeWatch              = 5,     //手表类型
    JL_DeviceTypeTradition          = -1,    //传统设备类型
};


/// 广播包解析器
@interface JLAdvParse : NSObject

/// 打印当前SDK的版本
+(void)sdkVersion;

/// 解析设备广播包内容
/// @param key 过滤码(只针对传统设备生效，默认填空即可)
/// @param advertData 蓝牙广播字典
+(NSDictionary*)bluetoothAdvParse:(NSData *_Nullable)key AdvData:(NSDictionary*_Nonnull)advertData;


#pragma mark - 回连广播包信息
/**
 *  获取广播包kCBAdvDataManufacturerData里面 'JLOTA' 标识的蓝牙地址
 *  @param kCBAdvDataManufacturerData 广播包
 */
+ (NSString * _Nullable)otaBleMacAddressFromCBAdvDataManufacturerData:(NSData *)kCBAdvDataManufacturerData;

/**
 *  判断当前蓝牙地址是否等于广播包kCBAdvDataManufacturerData里面的蓝牙地址
 *  @param otaBleMacAddress ota升级中设备的蓝牙地址
 *  @param kCBAdvDataManufacturerData 广播包
 */
+ (Boolean)otaBleMacAddress:(NSString *)otaBleMacAddress isEqualToCBAdvDataManufacturerData:(NSData *)kCBAdvDataManufacturerData;

///LOG使能与等级，默认开启且debug等级。
/// @param enable LOG使能
/// @param isMore 是否打印【函数名&行号】
/// @param level   LOG等级
+(void)setLog:(BOOL)enable IsMore:(BOOL)isMore Level:(ADV_LEVEL)level;

/// 打印宏
#define kADVLog(level,fmt...) [JLAdvParse Log:level Func:__FUNCTION__ Line:__LINE__ format:fmt]
/// 打印函数
/// @param level     LOG等级
/// @param func       函数名
/// @param line       行号
/// @param format   内容
+(void)Log:(ADV_LEVEL)level
          Func:(const char* _Nullable)func
          Line:(const int)line
        format:(NSString * _Nonnull)format,...;


@end

NS_ASSUME_NONNULL_END
