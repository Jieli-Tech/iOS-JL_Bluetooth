//
//  SqliteManager.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "SqliteManager.h"
#import "JL_RunSDK.h"
#import "FMDB.h"
#import "DeviceImgSql.h"

#define  DB_FILE_NAME   @"devices.sqlite"
#define  DB_DVICE_NAME  @"deviceModel.sqlite"

@interface SqliteManager(){
    
    NSString *fmdbPath;
    FMDatabase *db;
    NSDateFormatter *formatter;
    dispatch_group_t group;
    dispatch_queue_t queue;
    SqlDevices qdblock;
}

@end

@implementation SqliteManager


+(instancetype)sharedInstance{
    static SqliteManager *sm;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sm = [[SqliteManager alloc] init];
    });
    return sm;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        group = dispatch_group_create();
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        //1.获得数据库文件的路径
        NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fmdbPath=[doc stringByAppendingPathComponent:DB_FILE_NAME];
        db = [FMDatabase databaseWithPath:fmdbPath];
   
        if (![db open]) {
            kJLLog(JLLOG_DEBUG,@"数据库打开失败！");
        }
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-DD HH:mm:ss";
    }
    return self;
}


-(void)createTable{
    if ([db open]) {
        //4.创表
        BOOL result=[db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_devices (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, uuid text NOT NULL, type text NOT NULL,uid text NOT NULL,pid text NOT NULL,edr text NOT NULL ,locate blob ,lastTime TEXT,address TEXT,findDevice TEXT,locate_r blob,locate_l blob,leftLastTime TEXT,rightLastTime TEXT,protocolType text);"];
        if (result) {
            [db close];
            //kJLLog(JLLOG_DEBUG,@"tableview create OK");
            [self checkWetherShouledNewOne];
        }else{
            [db close];
            kJLLog(JLLOG_DEBUG,@"tableview create failed");
        }
        
        [db open];
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_device_model (id integer PRIMARY KEY AUTOINCREMENT,uuid text NOT NULL,authkey text NOT NULL,proCode text NOT NULL);"];
        if (result) {
            [db close];
            //kJLLog(JLLOG_DEBUG,@"tableview create OK");
        }else{
            [db close];
            kJLLog(JLLOG_DEBUG,@"tableview create failed");
        }
        //创建图片表格
        [DeviceImgSql createTableBy:db];
        
    }else{
        kJLLog(JLLOG_DEBUG,@"数据库打开失败");
    }
    
}



/// 更新某个设备的地理位置
/// @param local 地理位置
/// @param uuid uuid
-(BOOL)updateLocate:(NSData *) local ForUUID:(NSString *)uuid{
    /*
      NSNumber *lat = [NSNumber numberWithDouble:22.1235222];
       NSNumber *lon = [NSNumber numberWithDouble:11.1111111];
       NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
       NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userLocation];
       [[SqliteManager sharedInstance] updateLocate:data ForUUID:entity.mPeripheral.identifier.UUIDString];
     */
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE t_devices SET locate = ? where uuid = ? "];
        BOOL result = [db executeUpdate:sql,local,uuid];
        [db close];
        if (result) {
            //kJLLog(JLLOG_DEBUG,@"update updateLocate OK");
            return YES;
        }else{
            kJLLog(JLLOG_DEBUG,@"update  updateLocate failed");
            return NO;
        }
    }
    return NO;;
}

-(BOOL)updateLocate:(NSData *)local Type:(TWS_Locate)type ForUUID:(NSString *)uuid{
    
   if ([db open]) {
       NSString *locate = @"locate";
       if (type==TWS_RIGHT) {
           locate = @"locate_r";
       }else{
           locate = @"locate_l";
       }
       NSString *sql = [NSString stringWithFormat:@"UPDATE t_devices SET %@ = ? where uuid = ? ",locate];
       BOOL result = [db executeUpdate:sql,local,uuid];
       [db close];
       if (result) {
           //kJLLog(JLLOG_DEBUG,@"update updateLocate OK");
           return YES;
       }else{
           kJLLog(JLLOG_DEBUG,@"update  updateLocate failed");
           return NO;
       }
   }
   return NO;;
}

/// 更新左耳的最后连接时间
/// @param leftLastTime 左耳连接时间
/// @param uuid uuid
-(BOOL)updateLeftLastTime:(NSDate *)leftLastTime ForUUID:(NSString *)uuid{
    if ([db open]) {
        
        NSString *string = [formatter stringFromDate:leftLastTime];
        NSString *sql = [NSString stringWithFormat:@"UPDATE t_devices set leftLastTime = '%@' where uuid = '%@'",string,uuid];
        BOOL result = [db executeUpdate:sql];
        [db close];
        if (result) {
            //kJLLog(JLLOG_DEBUG,@"update updateLeftLastTime OK");
            return YES;
        }else{
            kJLLog(JLLOG_DEBUG,@"update  updateLeftLastTime failed");
            return NO;
        }
    }
    return NO;;
}

/// 更新右耳的最后连接时间
/// @param rightLastTime 右耳连接时间
/// @param uuid uuid
-(BOOL)updateRightLastTime:(NSDate *)rightLastTime ForUUID:(NSString *)uuid{
    if ([db open]) {
        
        NSString *string = [formatter stringFromDate:rightLastTime];
        NSString *sql = [NSString stringWithFormat:@"UPDATE t_devices set rightLastTime = '%@' where uuid = '%@'",string,uuid];
        BOOL result = [db executeUpdate:sql];
        [db close];
        if (result) {
            //kJLLog(JLLOG_DEBUG,@"update updateRightLastTime OK");
            return YES;
        }else{
            kJLLog(JLLOG_DEBUG,@"update  updateRightLastTime failed");
            return NO;
        }
    }
    return NO;;
}


/// 更新某个设备的最后连接时间
/// @param lastTime 地理位置
/// @param uuid uuid
-(BOOL)updateLastTime:(NSDate *)lastTime ForUUID:(NSString *)uuid{
    if ([db open]) {
        
        NSString *string = [formatter stringFromDate:lastTime];
        NSString *sql = [NSString stringWithFormat:@"UPDATE t_devices set lastTime = '%@' where uuid = '%@'",string,uuid];
        BOOL result = [db executeUpdate:sql];
        [db close];
        if (result) {
            //kJLLog(JLLOG_DEBUG,@"update updateLastTime OK");
            return YES;
        }else{
            kJLLog(JLLOG_DEBUG,@"update  updateLastTime failed");
            return NO;
        }
    }
    return NO;;
}

/// 更新设备的地址
/// @param addr 实际地址（非坐标）
/// @param uuid uuid
-(BOOL)updateLastAddress:(NSString *)addr ForUUID:(NSString *)uuid{
    if ([db open]) {
          NSString *sql = [NSString stringWithFormat:@"UPDATE t_devices set address = '%@' where uuid = '%@'",addr,uuid];
          BOOL result = [db executeUpdate:sql];
          [db close];
          if (result) {
              //kJLLog(JLLOG_DEBUG,@"update address OK");
              return YES;
          }else{
              kJLLog(JLLOG_DEBUG,@"update  address failed");
              return NO;
          }
      }
      return NO;
}

/// 更新某个设备是否支持设备查找功能
/// @param enable 是否支持查找设备功能
/// @param uuid uuid
-(BOOL)updateLastFindDeviceEnable:(BOOL)enable ForUUID:(NSString *)uuid{
    if ([db open]) {
        NSString *txt = @"0";
        if (enable == YES) txt = @"1";
        NSString *sql = [NSString stringWithFormat:@"UPDATE t_devices set findDevice = '%@' where uuid = '%@'",txt,uuid];
        BOOL result = [db executeUpdate:sql];
        [db close];
        if (result) {
            //kJLLog(JLLOG_DEBUG,@"update findDevice OK");
            return YES;
        }else{
            kJLLog(JLLOG_DEBUG,@"update  findDevice failed");
            return NO;
        }
    }
    return NO;
}


-(BOOL)installWithDevice:(JL_EntityM *)entity{
    
    if ([self isExit:entity]) {
        return [self updateDeviceBy:entity];
    }
    
    kJLLog(JLLOG_DEBUG,@"%s:%d name:%@,protocol:%d",__func__,entity.mType,entity.mItem,entity.mProtocolType);
    
    if ([db open]) {
        NSString *type = [NSString stringWithFormat:@"%d",(int)entity.mType];
        NSString *protocol = [NSString stringWithFormat:@"%d",entity.mProtocolType];
        BOOL result = [db executeUpdate:@"INSERT INTO t_devices (name, uuid ,type,uid,pid,edr,protocolType) VALUES (?, ? ,?,?,?,?,?);",entity.mItem,entity.mPeripheral.identifier.UUIDString,type,entity.mVID,entity.mPID,entity.mEdr,protocol];
        [db close];
        
        if (result) {
            //kJLLog(JLLOG_DEBUG,@"install OK");
            return YES;
        }else{
            kJLLog(JLLOG_DEBUG,@"install failed");
            return NO;
        }
    }else{
        kJLLog(JLLOG_DEBUG,@"db open failed");
        return NO;
    }
}
-(BOOL)installWithDeviceInfo:(DeviceObjc *)entity{
    if ([db open]) {
        NSString *type = [NSString stringWithFormat:@"%d",entity.type];
        NSString *uid = entity.uid ? entity.uid:@"null";
        NSString *pid = entity.pid ? entity.pid:@"null";
        NSString *edr = entity.edr ? entity.edr:@"null";
        NSData *locate = entity.locate ? entity.locate:nil;
        NSDate *lastTimeDate =  entity.lastTime ? entity.lastTime:nil;
        NSString *lastTime = @"null";
        NSString *findDev = @"0";
        
        if (lastTime) {
          lastTime = [formatter stringFromDate:lastTimeDate];
        }
        NSString *address = entity.address;
        BOOL result = [db executeUpdate:@"INSERT INTO t_devices (name, uuid ,type,uid,pid,edr,locate,lastTime,address,findDevice) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?,?);",entity.name,entity.uuid,type,uid,pid,edr,locate,lastTime,address,findDev];
        [db close];
        if (result) {
            //kJLLog(JLLOG_DEBUG,@"install OK");
            return YES;
        }else{
            kJLLog(JLLOG_DEBUG,@"install failed");
            return NO;
        }
    }else{
        kJLLog(JLLOG_DEBUG,@"db open failed");
        return NO;
    }
}

-(BOOL)updateDeviceBy:(JL_EntityM *)entity{
    
    kJLLog(JLLOG_DEBUG,@"%s:%d name:%@,protocol:%d",__func__,entity.mType,entity.mItem,entity.mProtocolType);
    NSString *sql = [NSString stringWithFormat:@"UPDATE t_devices set name = '%@', uuid = '%@', type = '%ld', uid = '%@' , pid = '%@' ,edr = '%@' ,protocolType = '%d' where uuid = '%@'",entity.mItem,entity.mPeripheral.identifier.UUIDString,(long)entity.mType,entity.mVID,entity.mPID,entity.mEdr,entity.mProtocolType,entity.mPeripheral.identifier.UUIDString];
      if ([db open]) {
          BOOL result = [db executeUpdate:sql];
          [db close];
          if (result) {
              //kJLLog(JLLOG_DEBUG,@"update OK");
              return YES;
          }else{
              //kJLLog(JLLOG_DEBUG,@"update failed");
              return NO;
          }
      }else{
          kJLLog(JLLOG_DEBUG,@"db open failed");
          return NO;
      }
}

-(BOOL)updateDeviceByObjc:(DeviceObjc *)entity{
    
    kJLLog(JLLOG_DEBUG,@"%s:%d name:%@,protocol:%d",__func__,entity.type,entity.name,entity.mProtocolType);
    NSString *sql = [NSString stringWithFormat:@"UPDATE t_devices set name = '%@', uuid = '%@', type = '%d' , uid = '%@' , pid = '%@' ,edr = '%@' ,protocolType = '%d' where uuid = '%@'",entity.name,entity.uuid,entity.type,entity.uid,entity.pid,entity.edr,entity.mProtocolType,entity.uuid];
      if ([db open]) {
          BOOL result = [db executeUpdate:sql];
          [db close];
          if (result) {
              kJLLog(JLLOG_DEBUG,@"update OK");
              return YES;
          }else{
              kJLLog(JLLOG_DEBUG,@"update failed");
              return NO;
          }
      }else{
          kJLLog(JLLOG_DEBUG,@"db open failed");
          return NO;
      }
}


-(NSArray <DeviceObjc *>*)checkOutAll{
    NSMutableArray *dataArray = [NSMutableArray new];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from t_devices"];
        FMResultSet *seq = [db executeQuery:sql];
        while ([seq next]) {
            DeviceObjc *objc = [[DeviceObjc alloc] init];
            objc.idInt = [seq intForColumn:@"id"];
            objc.name = [seq stringForColumn:@"name"];
            objc.uuid = [seq stringForColumn:@"uuid"];
            objc.type = [[seq stringForColumn:@"type"] intValue];
            objc.uid = [seq stringForColumn:@"uid"];
            objc.pid = [seq stringForColumn:@"pid"];
            objc.edr = [seq stringForColumn:@"edr"];
            objc.lastTime = [formatter dateFromString:[seq stringForColumn:@"lastTime"]];
            objc.locate = [seq dataForColumn:@"locate"];
            objc.address = [seq stringForColumn:@"address"];
            objc.findDevice = [seq stringForColumn:@"findDevice"];
            objc.mProtocolType = [[seq stringForColumn:@"protocolType"] intValue];
            [dataArray addObject:objc];
        }
    }else{
        kJLLog(JLLOG_DEBUG,@"db open failed");
    }
    [db close];
    return dataArray;
}

-(void)checkOutDevices:(SqlDevices)result{
    qdblock = result;
    //1.获得数据库文件的路径
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fmdbPath=[doc stringByAppendingPathComponent:DB_FILE_NAME];
    FMDatabaseQueue *queue1 = [FMDatabaseQueue databaseQueueWithPath:fmdbPath];
    dispatch_group_async(group, queue, ^{
        [queue1 inDatabase:^(FMDatabase * _Nonnull db) {
            NSMutableArray *dataArray = [NSMutableArray new];
            NSString *sql = [NSString stringWithFormat:@"select * from t_devices"];
            FMResultSet *seq = [db executeQuery:sql];
            while ([seq next]) {
                DeviceObjc *objc = [[DeviceObjc alloc] init];
                objc.idInt = [seq intForColumn:@"id"];
                objc.name = [seq stringForColumn:@"name"];
                objc.uuid = [seq stringForColumn:@"uuid"];
                objc.type = [[seq stringForColumn:@"type"] intValue];
                objc.uid = [seq stringForColumn:@"uid"];
                objc.pid = [seq stringForColumn:@"pid"];
                objc.edr = [seq stringForColumn:@"edr"];
                objc.lastTime = [self->formatter dateFromString:[seq stringForColumn:@"lastTime"]];
                objc.locate = [seq dataForColumn:@"locate"];
                objc.address = [seq stringForColumn:@"address"];
                objc.findDevice = [seq stringForColumn:@"findDevice"];
                objc.mProtocolType = [[seq stringForColumn:@"protocolType"] intValue];
                [dataArray addObject:objc];
                if (self->qdblock) {
                    self->qdblock(dataArray);
                }
            }
        }];
    });
}

-(void)deleteItemByIdInt:(int)idInt{
    
    if ([db open]) {
        NSString *sql0 = [NSString stringWithFormat:@"select * from t_devices where id = '%d'",idInt];
        FMResultSet *seq = [db executeQuery:sql0];
        NSMutableArray *dataArray = [NSMutableArray new];
        while ([seq next]) {
            DeviceObjc *objc = [[DeviceObjc alloc] init];
            objc.idInt = [seq intForColumn:@"id"];
            objc.name = [seq stringForColumn:@"name"];
            objc.uuid = [seq stringForColumn:@"uuid"];
            objc.type = [[seq stringForColumn:@"type"] intValue];
            objc.uid = [seq stringForColumn:@"uid"];
            objc.pid = [seq stringForColumn:@"pid"];
            objc.edr = [seq stringForColumn:@"edr"];
            objc.lastTime = [formatter dateFromString:[seq stringForColumn:@"lastTime"]];
            objc.locate = [seq dataForColumn:@"locate"];
            objc.address = [seq stringForColumn:@"address"];
            objc.findDevice = [seq stringForColumn:@"findDevice"];
            objc.mProtocolType = [[seq stringForColumn:@"protocolType"] intValue];
            [dataArray addObject:objc];
        }
        [db close];
        if (dataArray.count == 1) {
            DeviceObjc *objc = dataArray[0];
            [self deleteDeviceModelByUUid:objc.uuid];
        }
    }
    
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"delete from t_devices where id = '%d'",idInt];
        if ([db executeUpdate:sql]) {
            kJLLog(JLLOG_DEBUG,@"delete OK");
        }else{
            kJLLog(JLLOG_DEBUG,@"delete failed");
        }
    }else{
        kJLLog(JLLOG_DEBUG,@"db open failed");
    }
    [db close];
    
}

-(BOOL)isExit:(JL_EntityM *)entity{
    
    NSMutableArray *dataArray = [NSMutableArray new];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from t_devices where uuid = '%@'",entity.mPeripheral.identifier.UUIDString];
        FMResultSet *seq = [db executeQuery:sql];
        while ([seq next]) {
            DeviceObjc *objc = [[DeviceObjc alloc] init];
            objc.idInt = [seq intForColumn:@"id"];
            objc.name = [seq stringForColumn:@"name"];
            objc.uuid = [seq stringForColumn:@"uuid"];
            objc.type = [[seq stringForColumn:@"type"] intValue];
            objc.uid = [seq stringForColumn:@"uid"];
            objc.pid = [seq stringForColumn:@"pid"];
            objc.edr = [seq stringForColumn:@"edr"];
            objc.lastTime = [formatter dateFromString:[seq stringForColumn:@"lastTime"]];
            objc.locate = [seq dataForColumn:@"locate"];
            objc.locate_r = [seq dataForColumn:@"locate_r"];
            objc.locate_l = [seq dataForColumn:@"locate_l"];
            objc.leftLastTime = [formatter dateFromString:[seq stringForColumn:@"leftLastTime"]];
            objc.rightLastTime = [formatter dateFromString:[seq stringForColumn:@"rightLastTime"]];
            objc.address = [seq stringForColumn:@"address"];
            objc.findDevice = [seq stringForColumn:@"findDevice"];
            objc.mProtocolType = [[seq stringForColumn:@"protocolType"] intValue];
            [dataArray addObject:objc];
        }
    }else{
        kJLLog(JLLOG_DEBUG,@"db open failed");
    }
    [db close];
    if (dataArray.count > 0) {
        return YES;
    }else{
        return NO;
    }
}

-(DeviceObjc *)checkoutByUuid:(NSString *)uuid{
    DeviceObjc *objc = [[DeviceObjc alloc] init];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from t_devices where uuid = '%@'",uuid];
        FMResultSet *seq = [db executeQuery:sql];
        while ([seq next]) {
            objc.idInt = [seq intForColumn:@"id"];
            objc.name = [seq stringForColumn:@"name"];
            objc.uuid = [seq stringForColumn:@"uuid"];
            objc.type = [[seq stringForColumn:@"type"] intValue];
            objc.uid = [seq stringForColumn:@"uid"];
            objc.pid = [seq stringForColumn:@"pid"];
            objc.edr = [seq stringForColumn:@"edr"];
            objc.lastTime = [formatter dateFromString:[seq stringForColumn:@"lastTime"]];
            objc.locate = [seq dataForColumn:@"locate"];
            objc.locate_r = [seq dataForColumn:@"locate_r"];
            objc.locate_l = [seq dataForColumn:@"locate_l"];
            objc.leftLastTime = [formatter dateFromString:[seq stringForColumn:@"leftLastTime"]];
            objc.rightLastTime = [formatter dateFromString:[seq stringForColumn:@"rightLastTime"]];
            objc.address = [seq stringForColumn:@"address"];
            objc.findDevice = [seq stringForColumn:@"findDevice"];
            objc.mProtocolType = [[seq stringForColumn:@"protocolType"] intValue];
        }
    }else{
        kJLLog(JLLOG_DEBUG,@"db open failed");
    }
    [db close];
    return objc;
}

-(void)checkWetherShouledNewOne{
    [db open];
    if (![db columnExists:@"findDevice" inTableWithName:@"t_devices"]) {
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"t_devices",@"findDevice"];
        BOOL worked = [db executeUpdate:alertStr];
        if(worked){
            kJLLog(JLLOG_DEBUG,@"findDevice 插入成功");
        }else{
            kJLLog(JLLOG_DEBUG,@"findDevice 插入失败");
        }
    }
    if (![db columnExists:@"locate_r" inTableWithName:@"t_devices"]) {
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"t_devices",@"locate_r"];
        BOOL worked = [db executeUpdate:alertStr];
        if(worked){
            kJLLog(JLLOG_DEBUG,@"locate_r 插入成功");
        }else{
            kJLLog(JLLOG_DEBUG,@"locate_r 插入失败");
        }
    }
    if (![db columnExists:@"locate_l" inTableWithName:@"t_devices"]) {
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"t_devices",@"locate_l"];
        BOOL worked = [db executeUpdate:alertStr];
        if(worked){
            kJLLog(JLLOG_DEBUG,@"locate_l 插入成功");
        }else{
            kJLLog(JLLOG_DEBUG,@"locate_l 插入失败");
        }
    }
    if (![db columnExists:@"leftLastTime" inTableWithName:@"t_devices"]) {
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"t_devices",@"leftLastTime"];
        BOOL worked = [db executeUpdate:alertStr];
        if(worked){
            kJLLog(JLLOG_DEBUG,@"leftLastTime 插入成功");
        }else{
            kJLLog(JLLOG_DEBUG,@"leftLastTime 插入失败");
        }
    }
    if (![db columnExists:@"rightLastTime" inTableWithName:@"t_devices"]) {
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"t_devices",@"rightLastTime"];
        BOOL worked = [db executeUpdate:alertStr];
        if(worked){
            kJLLog(JLLOG_DEBUG,@"rightLastTime 插入成功");
        }else{
            kJLLog(JLLOG_DEBUG,@"rightLastTime 插入失败");
        }
    }
    
    if (![db columnExists:@"protocolType" inTableWithName:@"t_devices"]) {
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"t_devices",@"protocolType"];
        BOOL worked = [db executeUpdate:alertStr];
        if(worked){
            kJLLog(JLLOG_DEBUG,@"protocolType 插入成功");
        }else{
            kJLLog(JLLOG_DEBUG,@"protocolType 插入失败");
        }
    }
    
    [db close];
}


#pragma mark ///t_device_mode 设置
-(void)updateDeviceModel:(JLModel_Device *)model forUUID:(NSString *)uuid{
    if (model.authKey.length == 0 || model.proCode.length == 0) {
        return;
    }
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from t_device_model where uuid = '%@'",uuid];
        FMResultSet *seq = [db executeQuery:sql];
        NSMutableArray *array = [NSMutableArray new];
        while ([seq next]) {
            DeviceModel *m1 = [[DeviceModel alloc] init];
            m1.authKey = [seq stringForColumn:@"authkey"];
            m1.proCode = [seq stringForColumn:@"proCode"];
            m1.uuid = [seq stringForColumn:@"uuid"];
            [array addObject:m1];
        }
        if (array.count==1) {
            NSString *sql1 = [NSString stringWithFormat:@"UPDATE t_device_model set uuid = '%@',  authkey = '%@' , proCode = '%@' where uuid = '%@'",uuid,model.authKey,model.proCode,uuid];
            BOOL result = [db executeUpdate:sql1];
            if (result) {
                //kJLLog(JLLOG_DEBUG,@"authkey proCode update OK");
            }else{
                kJLLog(JLLOG_DEBUG,@"authkey proCode update Failed");
            }
        }else{
            BOOL result = [db executeUpdate:@"INSERT INTO t_device_model (uuid ,authkey,proCode) VALUES (?, ? ,?);",uuid,model.authKey,model.proCode];
            if (result) {
                kJLLog(JLLOG_DEBUG,@"authkey proCode install OK");
            }else{
                kJLLog(JLLOG_DEBUG,@"authkey proCode install Failed");
            }
        }
        
        [db close];
    }
}

-(void)deleteDeviceModelByUUid:(NSString *)uuid{
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"delete from t_device_model where uuid = '%@'",uuid];
        BOOL result = [db executeUpdate:sql];
        if (result) {
            kJLLog(JLLOG_DEBUG,@"delete t_device_model by uuid OK");
        }else{
            kJLLog(JLLOG_DEBUG,@"delete t_device_model by uuid failed");
        }
        [db close];
    }
}

-(DeviceModel *)checkoutDeviceModelBy:(NSString *)uuid{
    NSMutableArray *array = [NSMutableArray new];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from t_device_model where uuid = '%@'",uuid];
        FMResultSet *seq = [db executeQuery:sql];
        
        while ([seq next]) {
            DeviceModel *m1 = [[DeviceModel alloc] init];
            m1.authKey = [seq stringForColumn:@"authkey"];
            m1.proCode = [seq stringForColumn:@"proCode"];
            m1.uuid = [seq stringForColumn:@"uuid"];
            [array addObject:m1];
        }
        [db close];
    }
    if(array.count>0){
        return array[0];
    }
    return nil;
}

#pragma mark ///Device image
/// 插入、更新model的authKey和ProCode
/// @param model jlDeviceModel
/// @param uuid 设备UUID
-(void)updateDeviceImage:(DeviceImageModel *)model forUUID:(NSString *)uuid{
    [DeviceImgSql updateDeviceImage:model forUUID:uuid by:db];
}

/// 删除关于对应UUID的model
/// @param uuid uuid
-(void)deleteDeviceImageByUUid:(NSString *)uuid{
    [DeviceImgSql deleteDeviceImageByUUid:uuid by:db];
}

/// 获取存储的DeviceModel
/// @param uuid uuid
-(DeviceImageModel *)checkoutDeviceImageBy:(NSString *)uuid{
    return [DeviceImgSql checkoutDeviceImageBy:uuid by:db];
}


@end

@implementation DeviceObjc

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    DeviceObjc *devObjc = [[self class] allocWithZone:zone];
    devObjc.idInt = self.idInt;
    devObjc.name  = self.name;
    devObjc.uuid  = self.uuid;
    devObjc.type  = self.type;
    devObjc.uid = self.uid;
    devObjc.pid = self.pid;
    devObjc.edr = self.edr;
    devObjc.locate = self.locate;
    devObjc.locate_l = self.locate_l;
    devObjc.locate_r = self.locate_r;
    devObjc.lastTime = self.lastTime;
    devObjc.leftLastTime = self.leftLastTime;
    devObjc.rightLastTime = self.rightLastTime;
    devObjc.address = self.address;
    devObjc.findDevice= self.findDevice;
    return devObjc;
}

@end

@implementation DeviceModel

-(nonnull id)copyWithZone:(nullable NSZone *)zone{
    DeviceModel *model = [[self class] allocWithZone:zone];
    model.authKey = self.authKey;
    model.proCode = self.proCode;
    model.uuid = self.uuid;
    return model;
}
@end
