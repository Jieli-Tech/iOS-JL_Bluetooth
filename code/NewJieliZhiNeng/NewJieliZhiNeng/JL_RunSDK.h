//
//  JL_RunSDK.h
//  JL_BLE_TEST
//
//  Created by DFung on 2018/11/26.
//  Copyright © 2018 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>
#import "AFNetworking.h"
#import "JLUI_Effect.h"

#define MapApiKey @"0733d73d9ca8476dc29442f3d22fc4d9" //杰理之家
#define PiLinkMapApiKey @"7dc05b2a0e2fe8b2bdec91acb04d3a6c" //PiLink

/*--- 多语言 ---*/
#define kJL_GET         [LanguageCls checkLanguage]//[DFUITools systemLanguage]          //获取系统语言
#define kJL_SET(lan)    [LanguageCls setLangague:@(lan)]      //设置系统语言
//多语言转换,"Localizable"根据项目的多语言包填写。
#define kJL_TXT(key)    [LanguageCls localizableTxt:@(key)]

#pragma mark <- Tab/Navigate 高度 ->
//判断是否是ipad
#define kJL_IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//判断iPhone4系列
#define kJL_IS_IPHONE_4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPhone5系列
#define kJL_IS_IPHONE_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPhone6系列
#define kJL_IS_IPHONE_6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iphone6+系列
#define kJL_IS_IPHONE_6_PLUS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPhoneX
#define kJL_IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPHoneXr
#define kJL_IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPhoneXs
#define kJL_IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
#define kJL_IS_IPHONE_12P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1170, 2532), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPhoneXs Max
#define kJL_IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
#define kJL_IS_IPHONE_12P_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1284, 2778), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)

//iPhoneX系列
#define kJL_HeightStatusBar [UIApplication sharedApplication].delegate.window.safeAreaInsets.top
#define kJL_HeightNavBar ([UIApplication sharedApplication].delegate.window.safeAreaInsets.top+44.0)
#define kJL_HeightTabBar ([UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom+49.0)

#define PTLVersion  3

///手机蓝牙edr地址
#define PhoneEdrAddr @"phone_edr_addr"
///手机蓝牙名称
#define PhoneName @"phone_name"

NS_ASSUME_NONNULL_BEGIN

//extern NSString *kUI_JL_HIGH_LOW_VOL;
extern NSString *kUI_JL_SHOW_ID3;
extern NSString *kUI_JL_CARD_MUSIC_INFO;
extern NSString *kUI_JL_LINEIN_INFO;
extern NSString *kUI_JL_FM_INFO;

typedef NS_ENUM(UInt8, JLUuidType) {
    JLUuidTypeDisconnected              = 0,    //未连接的UUID
    JLUuidTypeConnected                 = 1,    //已连接的UUID
    JLUuidTypeInUse                     = 2,    //正在使用的UUID
    JLUuidTypeNeedOTA                   = 3,    //UUID需要OTA
    JLUuidTypePreparing                 = 4,    //正在准备的UUID
};
typedef NS_ENUM(UInt8, JLDeviceChangeType) {
    JLDeviceChangeTypeConnectedOffline  = 0,    //断开已连接的设备
    JLDeviceChangeTypeInUseOffline      = 1,    //断开正在使用的设备
    JLDeviceChangeTypeSomethingConnected= 2,    //有设备连接上
    JLDeviceChangeTypeManualChange      = 3,    //手动切换设备
    JLDeviceChangeTypeBleOFF            = 4,    //蓝牙已关闭
};
extern NSString *kUI_JL_DEVICE_CHANGE;
extern NSString *kUI_JL_DEVICE_PREPARING;
extern NSString *kUI_JL_DEVICE_SHOW_OTA;

extern NSString *kUI_JL_BLE_SCAN_OPEN;
extern NSString *kUI_JL_BLE_SCAN_CLOSE;

@interface JL_RunSDK : NSObject
@property(strong,nonatomic)JL_BLEMultiple *mBleMultiple;
@property(weak  ,nonatomic)JL_EntityM     *__nullable mBleEntityM;
@property(strong,nonatomic)NSString       *__nullable mBleUUID;

+(id)sharedMe;

/**
  使用UUID切换设备
 */
+(void)setActiveUUID:(NSString*)uuid;


/// 请求是否一连上了entity的edr
/// - Parameter entity: entity
+(BOOL)isConnectedEdr:(JL_EntityM *)entity;

/// 请求当前设备的信息
+(JLModel_Device *)getDeviceModel;

/**
 使用UUID获取已连接的Entity
*/
+(JL_EntityM*)getEntity:(NSString*)uuid;

/**
  获取当前设备状态
        0：未连接的UUID
        1：已连接的UUID
        2：正在使用的UUID
        3：UUID需要OTA
        4：正在准备的UUID
*/
+(JLUuidType)getStatusUUID:(NSString*)uuid;

/**
  获取连接状态对应中文解析
 */
+(NSString *)textEntityStatus:(JL_EntityM_Status)status;

/**
  是否为正在使用的设备发来的命令
 */
+(BOOL)isCurrentDeviceCmd:(NSNotification*)note;

/**
  已连接的UUID
 */
+(NSArray*)getLinkedArray;


@end
NS_ASSUME_NONNULL_END

