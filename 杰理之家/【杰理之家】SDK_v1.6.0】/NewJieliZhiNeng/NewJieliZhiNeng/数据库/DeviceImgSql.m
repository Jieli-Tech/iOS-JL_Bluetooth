//
//  DeviceImgSql.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/31.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DeviceImgSql.h"

@implementation DeviceImgSql


+(void)createTableBy:(FMDatabase *)db{
    
    if ([db open]) {
           //4.创表
           BOOL result=[db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_device_image (id integer PRIMARY KEY AUTOINCREMENT, left blob, right blob, center blob,engine blob,uuid text NOT NULL);"];
           if (result) {
               [db close];
               //NSLog(@"t_device_image tableview create OK");
           }else{
               [db close];
               NSLog(@"t_device_image tableview create failed");
           }
        [db close];
    }
    
}

/// 插入、更新model的authKey和ProCode
/// @param model jlDeviceModel
/// @param uuid 设备UUID
/// @param db FMDatabase
+(void)updateDeviceImage:(DeviceImageModel *)model forUUID:(NSString *)uuid by:(FMDatabase *)db{
    
     if ([db open]) {
           NSString *sql = [NSString stringWithFormat:@"select * from t_device_image where uuid = '%@'",uuid];
           FMResultSet *seq = [db executeQuery:sql];
           NSMutableArray *array = [NSMutableArray new];
           while ([seq next]) {
               DeviceImageModel *m1 = [[DeviceImageModel alloc] init];
               m1.right = [self imageFromData:[seq dataForColumn:@"right"]];
               m1.left = [self imageFromData:[seq dataForColumn:@"left"]];
               m1.center = [self imageFromData:[seq dataForColumn:@"center"]];
               m1.engine = [self imageFromData:[seq dataForColumn:@"engine"]];
               m1.index = [seq intForColumn:@"id"];
               m1.uuid = [seq stringForColumn:@"uuid"];
               [array addObject:m1];
           }
           if (array.count==1) {
               NSString *sql1 = [NSString stringWithFormat:@"UPDATE t_device_image SET left = ? ,right = ? ,center = ? ,engine = ? where uuid = ? "];
               BOOL result = [db executeUpdate:sql1,model.left,model.right,model.center,model.engine,uuid];
               if (result) {
                   //NSLog(@"device_image update OK");
               }else{
                   NSLog(@"device_image update Failed");
               }
           }else{
               BOOL result = [db executeUpdate:@"INSERT INTO t_device_image (left ,right,center,engine,uuid) VALUES (?, ? ,?);",model.left,model.right,model.center,model.engine,uuid];
               if (result) {
                   //NSLog(@"device_image install OK");
               }else{
                   NSLog(@"device_image install Failed");
               }
           }
           
           [db close];
       }
    
}

/// 删除关于对应UUID的model
/// @param uuid uuid
/// @param db FMDatabase
+(void)deleteDeviceImageByUUid:(NSString *)uuid by:(FMDatabase *)db{
    
    if ([db open]) {
          NSString *sql = [NSString stringWithFormat:@"delete from t_device_image where uuid = '%@'",uuid];
          BOOL result = [db executeUpdate:sql];
          if (result) {
              NSLog(@"delete device_image by uuid OK");
          }else{
              NSLog(@"delete device_image by uuid failed");
          }
          [db close];
      }
    
}

/// 获取存储的DeviceModel
/// @param uuid uuid
/// @param db FMDatabase
+(DeviceImageModel *)checkoutDeviceImageBy:(NSString *)uuid by:(FMDatabase *)db{
    NSMutableArray *array = [NSMutableArray new];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from t_device_image where uuid = '%@'",uuid];
        FMResultSet *seq = [db executeQuery:sql];
        while ([seq next]) {
            DeviceImageModel *m1 = [[DeviceImageModel alloc] init];
            m1.right = [self imageFromData:[seq dataForColumn:@"right"]];
            m1.left = [self imageFromData:[seq dataForColumn:@"left"]];
            m1.center = [self imageFromData:[seq dataForColumn:@"center"]];
            m1.engine = [self imageFromData:[seq dataForColumn:@"engine"]];
            m1.index = [seq intForColumn:@"id"];
            m1.uuid = [seq stringForColumn:@"uuid"];
            [array addObject:m1];
        }
        [db close];
    }
    return array[0];
}

+(UIImage *)imageFromData:(NSData *)data{
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];;
}

+(NSData *)imageToData:(UIImage*)image{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:image];
    return data;
}

@end

@implementation DeviceImageModel

-(nonnull id)copyWithZone:(nullable NSZone *)zone{
    DeviceImageModel *model = [[self class] allocWithZone:zone];
    model.left = self.left;
    model.right = self.right;
    model.center = self.center;
    model.engine = self.engine;
    model.index = self.index;
    model.uuid = self.uuid;
    return model;
}
@end
