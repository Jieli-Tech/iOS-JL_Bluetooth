//
//  DeviceInfoTools.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DeviceInfoTools.h"
#import "JL_RunSDK.h"
#import "JLUI_Cache.h"
#import "JLCacheBox.h"

@implementation DeviceInfoTools


//耳机操作类型
+(NSString *)oneClickEarkeyFunc:(int)type{
    switch (type) {
        case 0:{
            return kJL_TXT("none");
        }break;
        case 1:{
            return kJL_TXT("boot_up");
        }break;
        case 2:{
            return kJL_TXT("shut_down");
        }break;
        case 3:{
            return kJL_TXT("previous_song");
        }break;
        case 4:{
            return kJL_TXT("next_song");
        }break;
        case 5:{
            return kJL_TXT("music_pp");
        }break;
        case 6:{
            return kJL_TXT("answer_call");
        }break;
        case 7:{
            return kJL_TXT("hang_up");
        }break;
        case 8:{
            return kJL_TXT("call_back");
        }break;
        case 9:{
            return kJL_TXT("voice_inc");
        }break;
        case 10:{
            return kJL_TXT("voice_dec");
        }break;
        case 11:{
            return kJL_TXT("take_photo");
        }break;
        case 255:{
            return kJL_TXT("noise_control");
        }
            break;
        default:
            break;
    }
    return @"null";
}

+(UIImage *)powerTypeWithDict:(NSDictionary *)dict{
    int power = [dict[@"power"] intValue];
    BOOL charing = [dict[@"charing"] boolValue];
    UIImage *image;
    //电量为0到20
    if(power>0 && power<=20){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_0"];
    }
    //电量为21到35
    if(power>20 && power<=35){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_1"];
    }
    //电量为36到50
    if(power>35 && power<=50){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_2"];
    }
    //电量为51到75
    if(power>50 && power<=75){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_3"];
    }
    //电量为76到100
    if(power>75 && power<=100){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_4"];
    }
    //充电中
    if(charing == YES){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_5"];
    }
    return image;
}

+(UIImage *)getDevicesImageByType:(int)type{
    switch (type) {
        case 0:
        {
            return [UIImage imageNamed:@"Theme.bundle/product_img_speaker"];
        }
            break;
        case 1:
        {
            JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
            if([[JLCacheBox cacheUuid:bleSDK.mBleUUID] productData] == nil){
                return  [UIImage imageNamed:@"Theme.bundle/product_img_earphone"];
            }else{
                return [UIImage imageWithData:[[JLCacheBox cacheUuid:bleSDK.mBleUUID] productData]];
            }
        }
            break;
        case 4:
        {
            return [UIImage imageNamed:@"Theme.bundle/img_mic"];
        }
            break;
        default:
            break;
    }
    return nil;
    
}


+(BOOL)shouldUpdate:(NSString *)version0 local:(NSString *)version1{
    if ([version0 isEqual:@"0.0.0.0"]) {
        kJLLog(JLLOG_DEBUG,@"服务器测试升级");
        return YES;
    }
    if (version0.length==0) {
         kJLLog(JLLOG_DEBUG,@"服务器获取到的版本号为空");
         return YES;
     }
    if (version1.length==0 || [version1 isEqual:@""]) {
        kJLLog(JLLOG_DEBUG,@"本地升级信息为空：%@",version1);
        return YES;
    }
    NSArray *arr0 = [version0 componentsSeparatedByString:@"."];
    NSArray *arr1 = [version1 componentsSeparatedByString:@"."];

    uint8_t ver0_0 = (uint8_t)[arr0[0] intValue];
    uint8_t ver0_1 = (uint8_t)[arr0[1] intValue];
    uint8_t ver0_2 = (uint8_t)[arr0[2] intValue];
    uint8_t ver0_3 = (uint8_t)[arr0[3] intValue];
    
    uint8_t ver1_0 = (uint8_t)[arr1[0] intValue];
    uint8_t ver1_1 = (uint8_t)[arr1[1] intValue];
    uint8_t ver1_2 = (uint8_t)[arr1[2] intValue];
    uint8_t ver1_3 = (uint8_t)[arr1[3] intValue];
    
    short ver0_h = (ver0_0<<4) + ver0_1;
    short ver0_l = (ver0_2<<4) + ver0_3;
    
    short ver1_h = (ver1_0<<4) + ver1_1;
    short ver1_l = (ver1_2<<4) + ver1_3;
    
    short ver0_short = (ver0_h<<8)+ver0_l;
    short ver1_short = (ver1_h<<8)+ver1_l;

    //kJLLog(JLLOG_DEBUG,@"----> %d %d",ver0_short,ver1_short);
    
    if (ver0_short > ver1_short) {
        return YES;
    }else{
        return NO;
    }
//    NSString *hex0 = [version0 stringByReplacingOccurrencesOfString:@"." withString:@""];
//    NSString *hex1 = [version1 stringByReplacingOccurrencesOfString:@"." withString:@""];
//    NSData *data0 = [DFTools HexToData:hex0];
//    NSData *data1 = [DFTools HexToData:hex1];
//    NSInteger v0 = [DFTools dataToInt:data0];
//    NSInteger v1 = [DFTools dataToInt:data1];
//    if (v0>v1) {
//        return YES;
//    }else{
//        return  NO;
//    }
}


+(NSString *)mic_channel:(int)num withKey:(NSString *)func_key basicDict:(NSDictionary *)funcDict{
    NSArray *arr0 = funcDict[func_key];
    for (NSDictionary *item in arr0) {
        if ([item[@"value"] intValue] == num) {
            NSEnumerator *enumerator = [item[@"title"] keyEnumerator];
            NSString *key;
            NSString *value;
            while ((key = [enumerator nextObject])) {
                if ([kJL_GET hasPrefix:key]) {
                    value = item[@"title"][key];
                    return value;
                    break;
                }else{
                    value = item[@"title"][@"en"];
                }
                if (value == nil) {
                    value = @"unKnow";
                }
                return value;
            }
            break;
        }
    }
    return @"unKnow";
}


@end




@implementation DeviceInfoUsage



@end
