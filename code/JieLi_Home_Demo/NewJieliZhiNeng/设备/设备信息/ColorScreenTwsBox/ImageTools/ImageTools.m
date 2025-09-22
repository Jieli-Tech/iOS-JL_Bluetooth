//
//  ImageTools.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2024/4/30.
//  Copyright © 2024 杰理科技. All rights reserved.
//

#import "ImageTools.h"

@implementation ImageTools

/// 裁剪图片方法
/// - Parameter image: 图片
/// - Returns: 裁剪后的图片
+(UIImage *)machRadius:(UIImage *)image{
    UIView *tmpView = [[UIView alloc] init];
    CGSize screenSize = CGSizeMake(320, 172);
    JLDialInfoExtentedModel *dialInfoModel = [[JL_RunSDK sharedMe] dialInfoExtentedModel];
    if([dialInfoModel size].width != 0){
        screenSize = [dialInfoModel size];
    }
    tmpView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    tmpView.backgroundColor = dialInfoModel.backgroundColor;
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    imgv.image = image;
    if ([[JL_RunSDK sharedMe] configModel].exportFunc.spDialInfoExtend){
        if (dialInfoModel.shape == 0x01){ //圆
            imgv.layer.cornerRadius = screenSize.width/2;
        }else if (dialInfoModel.shape == 0x02){ //矩形
            imgv.layer.cornerRadius = 0;
        }else if (dialInfoModel.shape == 0x03){ //圆角矩形
            imgv.layer.cornerRadius = dialInfoModel.radius/2;
        }
    }
    imgv.layer.masksToBounds = YES;
    [tmpView addSubview:imgv];
    UIGraphicsBeginImageContextWithOptions(tmpView.frame.size, NO, 2);
    [tmpView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *targetImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return targetImg;
}

@end
