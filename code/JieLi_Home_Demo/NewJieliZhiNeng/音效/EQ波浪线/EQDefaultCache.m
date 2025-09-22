//
//  EQDefaultCache.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/5.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "EQDefaultCache.h"
#import "EQAdaptor.h"
#import <UIKit/UIKit.h>

@interface EQDefaultCache(){
    EQAdaptor *ad;
    NSMutableArray *eqArray;
    NSArray *defalutA;
    NSMutableArray *shouldCal;
}
@end

@implementation EQDefaultCache

+(instancetype)sharedInstance{
    static EQDefaultCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[EQDefaultCache alloc] init];
    });
    return cache;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        eqArray = [NSMutableArray new];
        shouldCal = [NSMutableArray new];
        ad = [[EQAdaptor alloc] init];
    }
    return self;
}

-(void)normalSetting{
    
    defalutA = @[@"JL_EQModeNORMAL",@"JL_EQModeROCK",@"JL_EQModePOP",
                 @"JL_EQModeCLASSIC",@"JL_EQModeJAZZ",
                 @"JL_EQModeCOUNTRY",@"JL_EQModeCUSTOM"];
    [shouldCal removeAllObjects];
    for (NSString *item in defalutA) {
        BOOL ret = [self checkExist:item];
        if (ret) {
            
        }else{
            [shouldCal addObject:item];
        }
    }
    if (shouldCal.count>0) {
        [self shouldCalAction:shouldCal.firstObject];
    }
    
}

-(BOOL)checkExist:(NSString *)str{
    NSData *objc = [JL_Tools getUserByKey:str];
    if (objc) {
        return YES;
    }else{
        return NO;
    }
}

-(void)shouldCalAction:(NSString *)item{
    NSArray *array;
    if ([item isEqualToString:@"JL_EQModeNORMAL"]) {
        array = @[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
    }
    if ([item isEqualToString:@"JL_EQModeROCK"]) {
        array = @[@(-2),@(0),@(2),@(4),@(-2),@(-2),@(0),@(0),@(4),@(4)];
    }
    if ([item isEqualToString:@"JL_EQModePOP"]) {
        array = @[@(3),@(1),@(0),@(-2),@(-4),@(-4),@(-2),@(0),@(1),@(2)];
    }
    if ([item isEqualToString:@"JL_EQModeCLASSIC"]) {
        array = @[@(0),@(8),@(8),@(4),@(0),@(0),@(0),@(0),@(2),@(2)];
    }
    if ([item isEqualToString:@"JL_EQModeJAZZ"]) {
        array = @[@(0),@(0),@(0),@(4),@(4),@(4),@(0),@(2),@(3),@(4)];
    }
    if ([item isEqualToString:@"JL_EQModeCOUNTRY"]) {
        array = @[@(-2),@(0),@(0),@(2),@(2),@(0),@(0),@(0),@(4),@(4)];
    }
    if ([item isEqualToString:@"JL_EQModeCUSTOM"]) {
        array = @[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
    }
    [ad initWithArray:array withHight:50.0 width:[UIScreen mainScreen].bounds.size.width-120];
    [ad calculaterForOne:[array[0] intValue] withIndex:0 eqArray:array result:^(NSArray * _Nonnull pointArray) {
        [self saveToData:pointArray WithName:item];
    }];
//    [ad calculaterForOne:[array[0] intValue] withIndex:0 result:^(NSArray * _Nonnull pointArray) {
//        [self saveToData:pointArray WithName:item];
//    }];
}

-(void)saveToData:(NSArray *)points WithName:(NSString *)name{
    NSData * wData = [NSKeyedArchiver archivedDataWithRootObject:points];
    [JL_Tools setUser:wData forKey:name];
    [self normalSetting];
}

-(void)saveEq:(NSArray *)eqArray withName:(JL_EQMode )mode{
//    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
//    NSString *name = [NSString stringWithFormat:@"%@%@",[self nameByMode:mode],entity.mUUID];
    [ad initWithArray:eqArray withHight:50.0 width:[UIScreen mainScreen].bounds.size.width-120];
    __weak typeof(self) wself = self;
    [ad calculaterForOne:[eqArray[0] intValue] withIndex:0 eqArray:eqArray result:^(NSArray * _Nonnull pointArray) {
        NSData * wData = [NSKeyedArchiver archivedDataWithRootObject:pointArray];
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        NSString *name;
        if (entity) {
            name = [NSString stringWithFormat:@"%@%@",[wself nameByMode:mode],entity.mUUID];
        }else{
            name = [NSString stringWithFormat:@"%@",[wself nameByMode:mode]];
        }
        [JL_Tools setUser:wData forKey:name];
    }];
    
//    [ad calculaterForOne:[eqArray[0] intValue] withIndex:0 result:^(NSArray * _Nonnull pointArray) {
//        NSData * wData = [NSKeyedArchiver archivedDataWithRootObject:pointArray];
//        [JL_Tools setUser:wData forKey:name];
//    }];
}
/// 设置eq值
/// @param eqArray eq值
/// @param mode 类型
-(void)saveEq:(NSArray *)eqArray centerFrequency:(NSArray *)cfArray withName:(JL_EQMode )mode{
    
    if (cfArray.count>0) [ad setCfArray:cfArray];
    [self saveEq:eqArray withName:mode];
}


-(NSArray *)getPointArray:(JL_EQMode )mode{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    NSString *name = [self nameByMode:mode];
    NSString *type1 = name;
    if (entity) {
        type1 = [NSString stringWithFormat:@"%@%@",name,entity.mUUID];
    }
    NSData *data = [JL_Tools getUserByKey:type1];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return array;
}

-(void)saveCustom:(NSArray *)eq mode:(JL_EQMode)mode{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    NSString *type = [self nameByMode:mode];
    if ([type isEqualToString:@"JL_EQModeCUSTOM"]) {
        NSString *type1 = [NSString stringWithFormat:@"JL_EQModeCUSTOM_EQ%@",entity.mUUID];
        NSData * wData = [NSKeyedArchiver archivedDataWithRootObject:eq];
        [JL_Tools setUser:wData forKey:type1];
    }
}
/// 设置自定义EQ保存
/// @param eq EQ数组
/// @param mode 类型
-(void)saveCustom:(NSArray *)eq centerFrequency:(NSArray *)cfArray mode:(JL_EQMode)mode{
    [ad setCfArray:cfArray];
    [self saveCustom:eq mode:mode];
}






-(NSString *)nameByMode:(JL_EQMode )mode{
    NSString *type;
    switch (mode) {
        case JL_EQModeNORMAL:{
            type = @"JL_EQModeNORMAL";
        }break;
        case JL_EQModePOP:{
            type = @"JL_EQModePOP";
        }break;
        case JL_EQModeJAZZ:{
            type = @"JL_EQModeJAZZ";
        }break;
        case JL_EQModeROCK:{
            type = @"JL_EQModeROCK";
        }break;
        case JL_EQModeCLASSIC:{
            type = @"JL_EQModeCLASSIC";
        }break;
        case JL_EQModeCOUNTRY:{
            type = @"JL_EQModeCOUNTRY";
        }break;
        case JL_EQModeCUSTOM:{
            type = @"JL_EQModeCUSTOM";
        }break;
        default:
            type = @"unKnow";
            kJLLog(JLLOG_DEBUG,@"%s mode:%d",__func__,mode);
            break;
    }
    return type;
}


@end
