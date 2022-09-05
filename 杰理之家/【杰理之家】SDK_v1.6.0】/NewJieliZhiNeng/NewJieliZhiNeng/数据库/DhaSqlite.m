//
//  DhaSqlite.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/4.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DhaSqlite.h"


NSString *TABLENAME = @"DHA_FITTING";
NSString *TIMESTAMP = @"timestamp";
NSString *UUID = @"uuid";
NSString *RECORDNAME = @"recordName";
NSString *LISTDATA = @"listData";
NSString *TYPE = @"type";
NSString *ISFINISH = @"isFinish";
NSString *FREQLIST = @"freqList";

@interface DhaSqlite()

@property(nonatomic,strong)FMDatabaseQueue *fmdb;

@end


@implementation DhaSqlite

+(instancetype)share{
    static DhaSqlite *sq;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sq = [DhaSqlite new];
    });
    return sq;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
        path = [path stringByAppendingPathComponent:DB_DHA_FILE];
        self.fmdb = [FMDatabaseQueue databaseQueueWithPath:path];
        [self.fmdb inDatabase:^(FMDatabase * _Nonnull db) {
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS DHA_FITTING (ID INTEGER PRIMARY KEY AUTOINCREMENT, timestamp double,uuid TEXT,recordName TEXT, listData BLOB,freqList BLOB,type TEXT,isFinish BINARY);"];
        }];
    }
    return self;
}


-(void)checkListBy:(NSString *)uuid Number:(int)lineNumber Result:(DhaListCheck)result{
    [self.fmdb inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where uuid = '%@' order by %@ desc",TABLENAME,uuid,TIMESTAMP];
        FMResultSet *req = [db executeQuery:sql];
        NSMutableArray *resultArray = [NSMutableArray new];
        while ([req next]) {
            DhaFittingSql *model = [DhaFittingSql new];
            double t = [req doubleForColumn:TIMESTAMP];
            model.recordDate = [NSDate dateWithTimeIntervalSince1970:t];
            model.devUuid = [req stringForColumn:UUID];
            model.recordName = [req stringForColumn:RECORDNAME];
            model.autoID = [req intForColumn:@"ID"];
            NSData *archData = [req dataForColumn:LISTDATA];
            model.recordList = [NSKeyedUnarchiver unarchiveObjectWithData:archData];
            model.type = [req stringForColumn:TYPE];
            NSData *archFreqData = [req dataForColumn:FREQLIST];
            model.recordFreqList = [NSKeyedUnarchiver unarchiveObjectWithData:archFreqData];
            model.isFinish = [req boolForColumn:ISFINISH];
            int num = (int)model.recordList.count;
            if ([model.type isEqualToString:DoubleFitter]) {
                num = (int)model.recordList.count/2;
            }
            if (num == lineNumber && model.isFinish) {
                [resultArray addObject:model];
            }
        }
        result(resultArray);
    }];
}


-(void)checkBy:(NSString *)uuid Number:(int)lineNumber Result:(DhaListCheck)result{
    [self.fmdb inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where uuid = '%@' order by %@ desc",TABLENAME,uuid,TIMESTAMP];
        FMResultSet *req = [db executeQuery:sql];
        NSMutableArray *resultArray = [NSMutableArray new];
        while ([req next]) {
            DhaFittingSql *model = [DhaFittingSql new];
            double t = [req doubleForColumn:TIMESTAMP];
            model.recordDate = [NSDate dateWithTimeIntervalSince1970:t];
            model.devUuid = [req stringForColumn:UUID];
            model.recordName = [req stringForColumn:RECORDNAME];
            model.autoID = [req intForColumn:@"ID"];
            NSData *archData = [req dataForColumn:LISTDATA];
            model.recordList = [NSKeyedUnarchiver unarchiveObjectWithData:archData];
            model.type = [req stringForColumn:TYPE];
            NSData *archFreqData = [req dataForColumn:FREQLIST];
            model.recordFreqList = [NSKeyedUnarchiver unarchiveObjectWithData:archFreqData];
            model.isFinish = [req boolForColumn:ISFINISH];
            int num = (int)model.recordList.count;
            if ([model.type isEqualToString:DoubleFitter]) {
                num = (int)model.recordList.count/2;
            }
            if (num == lineNumber && !model.isFinish) {
                [resultArray addObject:model];
            }
        }
        result(resultArray);
    }];
}

-(void)update:(DhaFittingSql *)model{
    
    [self.fmdb inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSNumber *t = [NSNumber numberWithDouble:[model.recordDate timeIntervalSince1970]];
        NSNumber *isFinish = [NSNumber numberWithBool:model.isFinish];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model.recordList requiringSecureCoding:YES error:nil];
        
        NSData *freqData = [NSKeyedArchiver archivedDataWithRootObject:model.recordFreqList requiringSecureCoding:YES error:nil];
        
        NSString *checkSql = [NSString stringWithFormat:@"select * from %@ where ID = '%d'", TABLENAME, model.autoID];
        FMResultSet *req = [db executeQuery:checkSql];
        
        if ([req next]) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = ?, %@ = ? ,%@ = ? ,%@ = ?,%@ = ?,%@ = ?,%@ = ? where ID = ?",TABLENAME,TIMESTAMP,UUID,RECORDNAME,LISTDATA,FREQLIST,TYPE,ISFINISH];
            BOOL res = [db executeUpdate:sql,t,model.devUuid,model.recordName,data,freqData,model.type,isFinish,[NSNumber numberWithInt: model.autoID]];
            if (!res) {
                NSLog(@"Dha update failed");
            }
        }else{
            NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@,%@) values (?,?,?,?,?,?,?)",TABLENAME,TIMESTAMP,UUID,RECORDNAME,LISTDATA,FREQLIST,TYPE,ISFINISH];
            BOOL res = [db executeUpdate:sql,t,model.devUuid,model.recordName,data,freqData,model.type,isFinish];
            if (!res) {
                NSLog(@"Dha install failed");
            }
        }
    }];
    
}

-(void)remove:(DhaFittingSql *)model{
    [self.fmdb inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"delete  from %@ where ID = '%d' ",TABLENAME,model.autoID];
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"Dha remove failed!");
        }
    }];
}

@end


@implementation DhaFittingSql

- (instancetype)init{
    self =  [super init];
    self.autoID = -1;
    return self;
}

-(NSArray <FittingMgr *>*)beFitterMgr{
    
    if ([self.type isEqualToString:DoubleFitter]) {
        FittingMgr *fit1 = [[FittingMgr alloc] init];
        NSMutableArray *mtu = [NSMutableArray new];
        for (int i  = 0; i<self.recordList.count/2; i++) {
            NSNumber *number = self.recordList[i];
            DhaFittingData *info = [[DhaFittingData alloc] init];
            info.leftOn = true;
            info.rightOn = false;
            info.channel = DhaChannel_left;
            info.gain = [number floatValue];
            [mtu addObject:info];
            info.freq = [self.recordFreqList[i] intValue];
            if (fabs(0.0-info.gain) > 0.01) {
                fit1.fittingIndex = i;
            }
        }
        fit1.dhaList = mtu;
        
        FittingMgr *fit2 = [[FittingMgr alloc] init];
        NSMutableArray *mtu1 = [NSMutableArray new];
        for (int i  = (int)self.recordList.count/2; i<self.recordList.count; i++) {
            NSNumber *number = self.recordList[i];
            DhaFittingData *info = [[DhaFittingData alloc] init];
            info.leftOn = false;
            info.rightOn = true;
            info.channel = DhaChannel_right;
            info.gain = [number floatValue];
            [mtu1 addObject:info];
           
        }
        for (int i = 0;i<self.recordFreqList.count;i++) {
            DhaFittingData *info = mtu1[i];
            info.freq = [self.recordFreqList[i] intValue];
            if (fabs(0.0-info.gain) > 0.01) {
                fit2.fittingIndex = i;
            }
        }
        fit2.dhaList = mtu1;
        
        return @[fit1,fit2];
    }
    
    
    if ([self.type isEqualToString:LeftFitter]) {
        FittingMgr *fit1 = [[FittingMgr alloc] init];
        NSMutableArray *mtu = [NSMutableArray new];
        for (int i  = 0; i<self.recordList.count; i++) {
            NSNumber *number = self.recordList[i];
            DhaFittingData *info = [[DhaFittingData alloc] init];
            info.leftOn = true;
            info.rightOn = false;
            info.channel = DhaChannel_left;
            info.freq = [self.recordFreqList[i] intValue];
            info.gain = [number floatValue];
            [mtu addObject:info];
            
            if (fabs(0.0-info.gain) > 0.01) {
                fit1.fittingIndex = i;
            }
        }
        fit1.dhaList = mtu;
        return @[fit1];
    }
    
    if ([self.type isEqualToString:RightFitter]) {
        FittingMgr *fit1 = [[FittingMgr alloc] init];
        NSMutableArray *mtu = [NSMutableArray new];
        for (int i  = 0; i<self.recordList.count; i++) {
            NSNumber *number = self.recordList[i];
            DhaFittingData *info = [[DhaFittingData alloc] init];
            info.freq = [self.recordFreqList[i] intValue];
            info.leftOn = false;
            info.rightOn = true;
            info.channel = DhaChannel_right;
            info.gain = [number floatValue];
            info.freq = [self.recordFreqList[i] intValue];
            [mtu addObject:info];
            if (fabs(0.0-info.gain) > 0.01) {
                fit1.fittingIndex = i;
            }
        }
        fit1.dhaList = mtu;
        return @[fit1];
    }

    return @[];
   
}


@end
