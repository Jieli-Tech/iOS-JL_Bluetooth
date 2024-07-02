//
//  AlarmObject.m
//  CMD_APP
//
//  Created by Ezio on 2018/2/28.
//  Copyright © 2018年 DFung. All rights reserved.
//

#import "AlarmObject.h"
#import "JL_RunSDK.h"

@implementation AlarmObject




-(instancetype) init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(AlarmObject *)alarmClockDataToObject:(NSData *)baseData{
    
    AlarmObject *object = [[AlarmObject alloc] init];
    if (baseData.length<32) {
        NSLog(@"ERROR CLOCK Data!!!");
        return object;
    }
    NSData *firstIndex = [baseData subdataWithRange:NSMakeRange(0, 1)];
    NSData *hourData = [baseData subdataWithRange:NSMakeRange(1, 1)];
    NSData *minData = [baseData subdataWithRange:NSMakeRange(2, 1)];
    NSData *repeatData = [baseData subdataWithRange:NSMakeRange(3, 1)];
    NSData *nameData = [baseData subdataWithRange:NSMakeRange(4, 24)];
    
    
    object.index = (int)[DFTools dataToInt:firstIndex];
    uint8_t hours = [DFTools dataToInt:hourData];
    object.state = hours >> 7 & 0x01;
    uint8_t hourL = hours << 1;
    uint8_t hourR = hourL >> 1;
    object.hour = hourR;
    object.min = (int)[DFTools dataToInt:minData];
    object.name = [DFTools stringGBK:nameData];
    uint8_t weekly = [DFTools dataToInt:repeatData];
    object.repeatMode = [self weekGetToArray:weekly];
    object.mode = weekly;
//    object.repeatMode = (int)[DFTools dataToInt:repeatData];
    object.reserved = [baseData subdataWithRange:NSMakeRange(28, baseData.length-28)];
    return object;

}

+(NSArray *)weekGetToArray:(uint8_t)byte{
    
    NSMutableArray *dayflagAray = [NSMutableArray array];

    for (int i = 0; i<8; i++) {
        
        uint8_t m = byte >> i & 0x01;
        int tag = (int)m;
        [dayflagAray addObject:[NSString stringWithFormat:@"%d",tag]];
    }
    
    NSArray* reversedArray = [[dayflagAray reverseObjectEnumerator] allObjects];
    NSMutableArray *tagArray = [NSMutableArray new];
    for (int i = 0; i<8; i++) {
        if ([reversedArray[i] intValue] != 0) {
            [tagArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    return tagArray;
}

+(NSString*)stringMode:(uint8_t)mode{
    
    NSMutableString *modeStr = [NSMutableString new];
    uint8_t bt_0 = mode    &0x01;
    uint8_t bt_1 = mode>>1 &0x01;
    uint8_t bt_2 = mode>>2 &0x01;
    uint8_t bt_3 = mode>>3 &0x01;
    uint8_t bt_4 = mode>>4 &0x01;
    uint8_t bt_5 = mode>>5 &0x01;
    uint8_t bt_6 = mode>>6 &0x01;
    uint8_t bt_7 = mode>>7 &0x01;
    
    if(mode == 0){
        [modeStr appendString:@" "];
        [modeStr appendString:kJL_TXT("alarm_repeat_single")];
        return modeStr;
    }
    if (bt_0 == 1) {
        [modeStr appendString:@" "];
        [modeStr appendString:kJL_TXT("alarm_repeat_every_day")];
        return modeStr;
    }
    
    if (bt_6+bt_5+bt_4+bt_3+bt_2+bt_1 == 6) {
        [modeStr appendString:@" "];
        [modeStr appendString:kJL_TXT("alarm_repeat_mon")];
        [modeStr appendString:@","];
        [modeStr appendString:kJL_TXT("alarm_repeat_tue")];
        [modeStr appendString:@","];
        [modeStr appendString:kJL_TXT("alarm_repeat_wed")];
        [modeStr appendString:@","];
        [modeStr appendString:kJL_TXT("alarm_repeat_thu")];
        [modeStr appendString:@","];
        [modeStr appendString:kJL_TXT("alarm_repeat_fri")];
        [modeStr appendString:@","];
        [modeStr appendString:kJL_TXT("alarm_repeat_sat")];
        
        return modeStr;
    }
    
    if (bt_5+bt_4+bt_3+bt_2+bt_1 == 5) {
//        [modeStr appendString:@" "];
//        [modeStr appendString:kJL_TXT("alarm_repeat_on_workday")];
        [modeStr appendString:@" "];
        [modeStr appendString:kJL_TXT("alarm_repeat_mon")];
        [modeStr appendString:@","];
        [modeStr appendString:kJL_TXT("alarm_repeat_tue")];
        [modeStr appendString:@","];
        [modeStr appendString:kJL_TXT("alarm_repeat_wed")];
        [modeStr appendString:@","];
        [modeStr appendString:kJL_TXT("alarm_repeat_thu")];
        [modeStr appendString:@","];
        [modeStr appendString:kJL_TXT("alarm_repeat_fri")];
        return modeStr;
    }
        
    if (bt_1) {[modeStr appendString:@" "];[modeStr appendString:kJL_TXT("alarm_repeat_mon")];}
    if (bt_2) {[modeStr appendString:@","];[modeStr appendString:kJL_TXT("alarm_repeat_tue")];}
    if (bt_3) {[modeStr appendString:@","];[modeStr appendString:kJL_TXT("alarm_repeat_wed")];}
    if (bt_4) {[modeStr appendString:@","];[modeStr appendString:kJL_TXT("alarm_repeat_thu")];}
    if (bt_5) {[modeStr appendString:@","];[modeStr appendString:kJL_TXT("alarm_repeat_fri")];}
    if (bt_6) {[modeStr appendString:@","];[modeStr appendString:kJL_TXT("alarm_repeat_sat")];}
    if (bt_7) {[modeStr appendString:@","];[modeStr appendString:kJL_TXT("alarm_repeat_sun")];}
    
    return modeStr;
}

+(NSArray*)stringsMode:(uint8_t)mode{
    NSMutableArray *modeArray = [NSMutableArray new];
    
    if(mode == 0){
        //单次
         return nil;
     }
    uint8_t bt_0 = mode    &0x01;
    uint8_t bt_1 = mode>>1 &0x01;
    uint8_t bt_2 = mode>>2 &0x01;
    uint8_t bt_3 = mode>>3 &0x01;
    uint8_t bt_4 = mode>>4 &0x01;
    uint8_t bt_5 = mode>>5 &0x01;
    uint8_t bt_6 = mode>>6 &0x01;
    uint8_t bt_7 = mode>>7 &0x01;
    
     if (bt_0 == 1) {
         //每天
         [modeArray addObject:kJL_TXT("alarm_repeat_mon")];
         [modeArray addObject:kJL_TXT("alarm_repeat_tue")];
         [modeArray addObject:kJL_TXT("alarm_repeat_wed")];
         [modeArray addObject:kJL_TXT("alarm_repeat_thu")];
         [modeArray addObject:kJL_TXT("alarm_repeat_fri")];
         [modeArray addObject:kJL_TXT("alarm_repeat_sat")];
         [modeArray addObject:kJL_TXT("alarm_repeat_sun")];
         return modeArray;
     }
    if (bt_5+bt_4+bt_3+bt_2+bt_1 == 5) {
        [modeArray addObject:kJL_TXT("alarm_repeat_mon")];
        [modeArray addObject:kJL_TXT("alarm_repeat_tue")];
        [modeArray addObject:kJL_TXT("alarm_repeat_wed")];
        [modeArray addObject:kJL_TXT("alarm_repeat_thu")];
        [modeArray addObject:kJL_TXT("alarm_repeat_fri")];
        return modeArray;
    }
    
    if (bt_1) {[modeArray addObject:kJL_TXT("alarm_repeat_mon")];}
    if (bt_2) {[modeArray addObject:kJL_TXT("alarm_repeat_tue")];}
    if (bt_3) {[modeArray addObject:kJL_TXT("alarm_repeat_wed")];}
    if (bt_4) {[modeArray addObject:kJL_TXT("alarm_repeat_thu")];}
    if (bt_5) {[modeArray addObject:kJL_TXT("alarm_repeat_fri")];}
    if (bt_6) {[modeArray addObject:kJL_TXT("alarm_repeat_sat")];}
    if (bt_7) {[modeArray addObject:kJL_TXT("alarm_repeat_sun")];}
    return modeArray;
}



@end
