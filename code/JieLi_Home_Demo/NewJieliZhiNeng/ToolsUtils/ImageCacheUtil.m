//
//  ImageCacheUtil.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2024/6/14.
//  Copyright © 2024 杰理科技. All rights reserved.
//

#import "ImageCacheUtil.h"

@implementation ImageCacheUtil

+(NSString *)imgProductLogo {
    return @"PRODUCT_LOGO";
}

+(NSString *)imgChargingBinIdle{
    return @"CHARGING_BIN_IDLE";
}

+(NSString *)imgEarphoneNoodles{
    return @"img_earphone03";
}

/// 左耳图标
+(NSString *)imgLeftEarphone {
    return @"LEFT_DEVICE_CONNECTED";
}

/// 右耳图标
+(NSString *)imgRightEarphone {
    return @"RIGHT_DEVICE_CONNECTED";
}
/// 麦克风
+(NSString *)imgMic {
    return @"img_mic";
}

/// 音箱
+(NSString *)imgSpeaker {
    return @"product_img_speaker";
}




    
+(UIImage *)getEarphoneImageUUID:(NSString*)uuid Name:(NSString*)name Default:(NSString*)def {
    NSData *imgData = [self getEarphoneImageUUID:uuid Name:name];
    if(imgData == nil){
        NSString *txt = [NSString stringWithFormat:@"Theme.bundle/%@",def];
        return [UIImage imageNamed:txt];
    }else{
        return [UIImage imageWithData:imgData];
    }
}

+(void)setImageView:(UIImageView*)imageView
         DeviceUuid:(NSString*)uuid
              Image:(NSString*)image
            Default:(NSString*)def{
    NSData *imgData = [self getEarphoneImageUUID:uuid Name:image];
    if(imgData == nil){
        NSString *txt = [NSString stringWithFormat:@"Theme.bundle/%@",def];
        imageView.image = [UIImage imageNamed:txt];
    }else{
        imageView.image = [UIImage imageWithData:imgData];
    }
}

+(NSData *)getEarphoneImageUUID:(NSString*)uuid Name:(NSString*)name{
    NSString *imageName = [NSString stringWithFormat:@"%@_%@",name,uuid];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory
                             MiddlePath:@"" File:imageName];
    NSData *data = nil;
    if (path) {
        data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    }
    return data;
}



+(NSString *)getProductImageEarphoneLeft:(JL_DeviceType)type{
    if(type == JL_DeviceTypeTWS){
        return @"product_img_earphone_02";
    }
    if(type == JL_DeviceTypeChargingBin){
        return @"chargingBin_earphone_local_middle_left";
    }
    return @"product_img_earphone_02";
}

+(NSString *)getProductImageEarphoneRight:(JL_DeviceType)type{
    if(type == JL_DeviceTypeTWS){
        return @"product_img_earphone_01";
    }
    if(type == JL_DeviceTypeChargingBin){
        return @"chargingBin_earphone_local_middle_right";
    }
    return @"product_img_earphone_01";
}

+(NSString *)getProductImageChargingBin:(JL_DeviceType)type{
    if(type == JL_DeviceTypeTWS){
        return @"product_img_chargingbin";
    }
    if(type == JL_DeviceTypeChargingBin){
        return @"chargingBin_Large";
    }
    return @"product_img_chargingbin";
}


@end
