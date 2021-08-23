//
//  SqliteManager.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JL_RunSDK.h"
#import "DeviceImgSql.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^SqlDevices)(NSArray* __nullable array);
typedef enum : NSUInteger {
    TWS_LEFT,
    TWS_RIGHT
} TWS_Locate;

@interface DeviceObjc : NSObject

/// 列表中所存放的序号
@property(nonatomic,assign)int idInt;

/// 设备名字
@property(nonatomic,strong)NSString *name;

/// 设备UUID
@property(nonatomic,strong)NSString *uuid;

/// 设备类型
@property(nonatomic,assign)int type;

/// uid
@property(nonatomic,strong)NSString *uid;

/// pid
@property(nonatomic,strong)NSString *pid;

/// 经典蓝牙地址edr
@property(nonatomic,strong)NSString *edr;

/// 最后更新的地址（经纬度）
@property(nonatomic,strong)NSData *locate;

///右耳的地址（经纬度）
@property(nonatomic,strong)NSData *locate_r;

///左耳的地址 （经纬度）
@property(nonatomic,strong)NSData *locate_l;

/// 最后更新的时间
@property(nonatomic,strong)NSDate *lastTime;

/// 左耳最后更新的时间
@property(nonatomic,strong)NSDate *leftLastTime;

/// 右耳最后更新的时间
@property(nonatomic,strong)NSDate *rightLastTime;

/// 实际地址
@property(nonatomic,strong)NSString *address;

/// 是否支持查找设备
@property(nonatomic,strong)NSString *findDevice;

@end

@interface DeviceModel :NSObject

@property(nonatomic,strong)NSString *authKey;
@property(nonatomic,strong)NSString *proCode;
@property(nonatomic,strong)NSString *uuid;

@end

@interface SqliteManager : NSObject

/// 单例
+(instancetype)sharedInstance;

/// 创建表格
-(void)createTable;

/// 插入要存储的设备
/// @param entity JL_Entity
-(BOOL)installWithDevice:(JL_EntityM *)entity;

/// 更新某个设备
/// @param entity JL_Entity
-(BOOL)updateDeviceBy:(JL_EntityM *)entity;

/// 更新某个设备的地理位置
/// @param local 地理经纬度
/// @param uuid uuid
-(BOOL)updateLocate:(NSData *) local ForUUID:(NSString *)uuid;

/// 更新TWS耳机设备的地理位置
/// @param local 地理经纬度
/// @param type 左右耳类型
/// @param uuid uuid
-(BOOL)updateLocate:(NSData *)local Type:(TWS_Locate)type ForUUID:(NSString *)uuid;

/// 更新左耳的最后连接时间
/// @param leftLastTime 左耳连接时间
/// @param uuid uuid
-(BOOL)updateLeftLastTime:(NSDate *)leftLastTime ForUUID:(NSString *)uuid;

/// 更新右耳的最后连接时间
/// @param rightLastTime 右耳连接时间
/// @param uuid uuid
-(BOOL)updateRightLastTime:(NSDate *)rightLastTime ForUUID:(NSString *)uuid;

/// 更新某个设备的最后连接时间
/// @param lastTime 连接时间
/// @param uuid uuid
-(BOOL)updateLastTime:(NSDate *)lastTime ForUUID:(NSString *)uuid;

/// 更新设备的地址
/// @param addr 实际地址（非坐标）
/// @param uuid uuid
-(BOOL)updateLastAddress:(NSString *)addr ForUUID:(NSString *)uuid;

/// 更新某个设备是否支持设备查找功能
/// @param enable 是否支持查找设备功能
/// @param uuid uuid
-(BOOL)updateLastFindDeviceEnable:(BOOL)enable ForUUID:(NSString *)uuid;

/// 更新某个设备
/// @param entity DeviceObjc
-(BOOL)updateDeviceByObjc:(DeviceObjc *)entity;

/// 获取全部设备记录
-(NSArray *)checkOutAll;

/// 获取全部设备记录
/// @param result result
-(void)checkOutDevices:(SqlDevices)result;

/// 查询单个UUID的对象
/// @param uuid UUID
-(DeviceObjc *)checkoutByUuid:(NSString *)uuid;

/// 删除某个设备记录
/// @param idInt 设备记录的存放序号 DeviceObjc.idInt
-(void)deleteItemByIdInt:(int)idInt;

/// 检查是否已经存在了entity
/// @param entity JL_Entity
-(BOOL)isExit:(JL_EntityM *)entity;


#pragma mark ///JLDeviceModel

/// 插入、更新model的authKey和ProCode
/// @param model jlDeviceModel
/// @param uuid 设备UUID
-(void)updateDeviceModel:(JLModel_Device *)model forUUID:(NSString *)uuid;

/// 删除关于对应UUID的model
/// @param uuid uuid
-(void)deleteDeviceModelByUUid:(NSString *)uuid;


/// 获取存储的DeviceModel
/// @param uuid uuid
-(DeviceModel *)checkoutDeviceModelBy:(NSString *)uuid;


#pragma mark ///Device image
/// 插入、更新model的authKey和ProCode
/// @param model jlDeviceModel
/// @param uuid 设备UUID
-(void)updateDeviceImage:(DeviceImageModel *)model forUUID:(NSString *)uuid;

/// 删除关于对应UUID的model
/// @param uuid uuid
-(void)deleteDeviceImageByUUid:(NSString *)uuid;

/// 获取存储的DeviceModel
/// @param uuid uuid
-(DeviceImageModel *)checkoutDeviceImageBy:(NSString *)uuid;
@end


NS_ASSUME_NONNULL_END
