//
//  MapLocationRequest.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/27.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^GeoCodeSearch)(NSData *data,NSString *address);

@interface MapLocationRequest : NSObject

+(instancetype)shareInstanced;

-(void)requestLocation:(JL_EntityM *)entity;

/// 逆地理编码查询
/// @param data 坐标编码数据
/// @param block 逆地理坐标实际位置
-(void)requestGeoCodeAddress:(NSData *)data block:(GeoCodeSearch)block;

/// 请求手机当前的经纬度data
-(NSData *)requestNowLocation;
@end

NS_ASSUME_NONNULL_END
