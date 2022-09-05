//
//  DeviceInfoTools.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kJL_DEVICE_PID       @"JL_DEVICE_PID"
#define kJL_DEVICE_VID      @"JL_DEVICE_VID"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoTools : NSObject

/// 获取设备的功能
/// @param type 类型
+(NSString *)oneClickEarkeyFunc:(int)type;

/// 根据字典获取电量
/// @param dict 字典
+(UIImage *)powerTypeWithDict:(NSDictionary *)dict;

/// 根据类型获取设备对应的图标
/// @param type 类型
+(UIImage *)getDevicesImageByType:(int)type;

/// 判断版本高低
/// @param version0 服务器版本
/// @param version1 本地固件版本
/// @return BOOL 是否需要升级
+(BOOL)shouldUpdate:(NSString *)version0 local:(NSString *)version1;


/// 查找对应的描述文件字段
/// @param num value
/// @param func_key 功能标签
/// @param funcDict 功能字典
+(NSString *)mic_channel:(int)num withKey:(NSString *)func_key basicDict:(NSDictionary *)funcDict;

@end




#pragma mark <耳机列表对象>

@interface DeviceInfoUsage : NSObject
/// 左title
@property(nonatomic,strong)NSString *title;
/// 右边title（耳机当前的操作类型）
@property(nonatomic,strong)NSString *type;
/// 耳机value
@property(nonatomic,assign)int value;
/// 左右耳机
@property(nonatomic,assign)int funcType;
/// 左/右耳机操作类型
@property(nonatomic,assign)int directionType;

///title名字
@property(nonatomic,strong)NSString *titleStr;
///点击名字
@property(nonatomic,strong)NSString *tapNameStr;

@end

NS_ASSUME_NONNULL_END
