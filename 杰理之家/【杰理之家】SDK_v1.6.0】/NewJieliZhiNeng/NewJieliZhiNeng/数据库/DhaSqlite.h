//
//  DhaSqlite.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/4.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

#define  DB_DHA_FILE   @"dha.sqlite"

#define DoubleFitter   @"double"
#define LeftFitter     @"left"
#define RightFitter    @"right"

@interface DhaFittingSql:NSObject

@property(nonatomic,assign)int autoID;

@property(nonatomic,strong)NSString *devUuid;

@property(nonatomic,strong)NSString *recordName;

@property(nonatomic,strong)NSDate *recordDate;

@property(nonatomic,strong)NSArray *recordList;

@property(nonatomic,strong)NSArray *recordFreqList;

@property(nonatomic,strong)NSString *type;

@property(nonatomic,assign)BOOL isFinish;


-(NSArray <FittingMgr *>*)beFitterMgr;

@end


typedef void(^DhaListCheck)(NSArray <DhaFittingSql *>* list);


@interface DhaSqlite : NSObject

+(instancetype)share;

-(void)checkListBy:(NSString *)uuid Number:(int)lineNumber Result:(DhaListCheck)result;

-(void)checkBy:(NSString *)uuid Number:(int)lineNumber Result:(DhaListCheck)result;

-(void)update:(DhaFittingSql *)model;

-(void)remove:(DhaFittingSql *)model;

@end

NS_ASSUME_NONNULL_END
