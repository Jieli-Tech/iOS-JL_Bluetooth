//
//  DeviceImgSql.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/31.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FMDatabase;

@interface DeviceImageModel : NSObject

@property(nonatomic,strong)NSString *uuid;
@property(nonatomic,strong)UIImage *left;
@property(nonatomic,strong)UIImage *right;
@property(nonatomic,strong)UIImage *center;
@property(nonatomic,strong)UIImage *engine;
@property(nonatomic,assign)NSInteger index;


@end

@interface DeviceImgSql : NSObject

/// 创建表格
/// @param db FMDatabase
+(void)createTableBy:(FMDatabase *)db;
/// 插入、更新model的authKey和ProCode
/// @param model jlDeviceModel
/// @param uuid 设备UUID
/// @param db FMDatabase
+(void)updateDeviceImage:(DeviceImageModel *)model forUUID:(NSString *)uuid by:(FMDatabase *)db;

/// 删除关于对应UUID的model
/// @param uuid uuid
/// @param db FMDatabase
+(void)deleteDeviceImageByUUid:(NSString *)uuid by:(FMDatabase *)db;

/// 获取存储的DeviceModel
/// @param uuid uuid
/// @param db FMDatabase
+(DeviceImageModel *)checkoutDeviceImageBy:(NSString *)uuid by:(FMDatabase *)db;


@end

NS_ASSUME_NONNULL_END
