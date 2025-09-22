//
//  HeadSetStatusView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "HeadSetStatusView.h"
#import "DeviceInfoTools.h"
#import "JLUI_Cache.h"

@interface HeadSetStatusView(){
    UIImageView *centerImgv;
    UILabel *powerLab;
    UIImageView *batteryImgv;
}

@end

@implementation HeadSetStatusView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        centerImgv = [[UIImageView alloc] init];
        centerImgv.contentMode = UIViewContentModeCenter;
        [self addSubview:centerImgv];
        self.type = HeadSetType_L;
        powerLab = [[UILabel alloc] init];
        powerLab.font = [UIFont systemFontOfSize:13];
        powerLab.adjustsFontSizeToFitWidth = YES;
        powerLab.textColor = [UIColor blackColor];
        powerLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:powerLab];
        batteryImgv = [[UIImageView alloc] init];
        batteryImgv.contentMode = UIViewContentModeCenter;
        [self addSubview:batteryImgv];
        
    }
    return self;
}




-(void)configUuid:(NSString*)uuid{
    
    NSString *powerStr = [NSString stringWithFormat:@"%@%%",self.powerDict[@"power"]];
    powerLab.text = powerStr;
    batteryImgv.image = [DeviceInfoTools powerTypeWithDict:self.powerDict];
    
    CGFloat half = self.frame.size.width/2;
    CGRect centerRect;
    CGRect labRect;
    CGRect batteryRect;
    
    switch (_type) {
        case HeadSetType_L:{
            centerRect = CGRectMake(half, 0, half, self.frame.size.height-20.0);
            labRect = CGRectMake(0, self.frame.size.height-20.0, 35.0, 20.0);
            batteryRect = CGRectMake(35.0, self.frame.size.height-20.0, 20.0, 20.0);
            //NSData *leftData = [[JLUI_Cache sharedInstance] leftData];
            NSData *leftData = [self getEarphoneImageUUID:uuid Name:@"LEFT_DEVICE_CONNECTED"];
            if(leftData == nil){
                centerImgv.image = [UIImage imageNamed:@"Theme.bundle/product_img_earphone_02"];
            }else{
                centerImgv.image = [self OriginImage:[UIImage imageWithData:leftData] scaleToSize:CGSizeMake(95/2, 190/2)];
            }
        }break;
        case HeadSetType_R:{
            labRect = CGRectMake(20, self.frame.size.height-20.0, 35.0, 20.0);
            batteryRect = CGRectMake(0.0, self.frame.size.height-20.0, 20.0, 20.0);
            centerRect = CGRectMake(0, 0, half, self.frame.size.height-20.0);
            //NSData *rightData = [[JLUI_Cache sharedInstance] rightData];
            NSData *rightData = [self getEarphoneImageUUID:uuid Name:@"RIGHT_DEVICE_CONNECTED"];
            if(rightData == nil){
                centerImgv.image = [UIImage imageNamed:@"Theme.bundle/product_img_earphone_01"];
            }else{
                centerImgv.image = [self OriginImage:[UIImage imageWithData:rightData] scaleToSize:CGSizeMake(95/2, 190/2)];
            }
        }break;
        case HeadSetType_C:{
            centerRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20.0);
            labRect = CGRectMake(20, self.frame.size.height-20.0, 35.0, 20.0);
            batteryRect = CGRectMake(0.0, self.frame.size.height-20.0, 20.0, 20.0);
            //NSData *chargingBinData = [[JLUI_Cache sharedInstance] chargingBinData];
            NSData *chargingBinData = [self getEarphoneImageUUID:uuid Name:@"CHARGING_BIN_IDLE"];

            if(chargingBinData == nil){
                centerImgv.image = [UIImage imageNamed:@"Theme.bundle/product_img_chargingbin"];
            }else{
                centerImgv.image = [self OriginImage:[UIImage imageWithData:chargingBinData] scaleToSize:CGSizeMake(95, 95)];
            }
        }break;
        case HeadSetType_BOX:{
            centerRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20.0);
            labRect = CGRectMake(20, self.frame.size.height-20.0, 35.0, 20.0);
            batteryRect = CGRectMake(0.0, self.frame.size.height-20.0, 20.0, 20.0);

            NSData *soundBoxData = [self getEarphoneImageUUID:uuid Name:@"PRODUCT_LOGO"];

            if(soundBoxData == nil){
                centerImgv.image = [UIImage imageNamed:@"Theme.bundle/product_img_speaker"];
            }else{
                centerImgv.image = [self OriginImage:[UIImage imageWithData:soundBoxData] scaleToSize:CGSizeMake(95, 95)];
            }
        }break;
        case HeadSetType_SHENGKA:{
            centerRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20.0);
            labRect = CGRectMake(20, self.frame.size.height-20.0, 35.0, 20.0);
            batteryRect = CGRectMake(0.0, self.frame.size.height-20.0, 20.0, 20.0);

            NSData *soundBoxData = [self getEarphoneImageUUID:uuid Name:@"PRODUCT_LOGO"];

            if(soundBoxData == nil){
                centerImgv.image = [UIImage imageNamed:@"Theme.bundle/img_mic"];
            }else{
                centerImgv.image = [self OriginImage:[UIImage imageWithData:soundBoxData] scaleToSize:CGSizeMake(95, 95)];
            }
        }break;
        default:
            break;
    }
    centerImgv.frame = centerRect;
    powerLab.frame = labRect;
    batteryImgv.frame = batteryRect;
}


-(NSData *)getEarphoneImageUUID:(NSString*)uuid Name:(NSString*)name{
    NSString *imageName = [NSString stringWithFormat:@"%@_%@",name,uuid];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory
                             MiddlePath:@"" File:imageName];
    NSData *data = nil;
    if (path) {
        data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    }
    return data;
}


-(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;   //返回的就是已经改变的图片
}

@end
