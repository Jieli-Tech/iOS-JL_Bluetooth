//
//  ImageCacheUtil.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2024/6/14.
//  Copyright © 2024 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface ImageCacheUtil : NSObject

/// 产品图标
+(NSString *)imgProductLogo;

/// 产品充电盒图标
+(NSString *)imgChargingBinIdle;

/// 默认的挂脖耳机图标
+(NSString *)imgEarphoneNoodles;

/// 左耳图标
+(NSString *)imgLeftEarphone;

/// 右耳图标
+(NSString *)imgRightEarphone;
/// 麦克风
+(NSString *)imgMic;
/// 音箱
+(NSString *)imgSpeaker;


+(UIImage *)getEarphoneImageUUID:(NSString*)uuid Name:(NSString*)name Default:(NSString*)def;

/// 给 UI 部件赋值图片
/// - Parameters:
///   - imageView: UI 部件
///   - uuid: 设备 uuid
///   - image: 复制部件 UIIMage 名称
///   - def: 失败时默认的图片名称
+(void)setImageView:(UIImageView*)imageView
         DeviceUuid:(NSString*)uuid
              Image:(NSString*)image
            Default:(NSString*)def;

/// 左耳默认图标
/// - Parameter type: 设备类型
+(NSString *)getProductImageEarphoneLeft:(JL_DeviceType)type;

/// 右耳默认图标
/// - Parameter type: 设备类型
+(NSString *)getProductImageEarphoneRight:(JL_DeviceType)type;

/// 充电盒默认图标
/// - Parameter type: 设备类型
+(NSString *)getProductImageChargingBin:(JL_DeviceType)type;

@end

NS_ASSUME_NONNULL_END
