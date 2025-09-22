//
//  User_Http.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/6/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface User_Http : NSObject

+(instancetype)shareInstance;

/**
 App日志上报
 */
-(void)requestUserLog:(void(^)(id result,NSError *error)) block;

/**
 固件日志上报
 */
-(void)requestDeviceLog:(NSString *)version withPid:(NSString *)pid Vid:(NSString *)vid Mac:(NSString *) mac Result:(void(^)(id result,NSError *error)) block;

/**
  用户认证登录
  code = 0;
  data =     {
    "access_token" = "token";
    "expires_in" = 86400;
    "token_type" = JWT;
  };
  msg = "\U6267\U884c\U6210\U529f";
*/
-(void)requestUserLogin:(void(^)(NSDictionary *info))result;

/**
  获取省市电台
  {
         explain = "";
         id = 1278133984025042946;
         name = "\U5317\U4eac";
         sn = 2;
         updateTime = "2020-07-01 09:11:03";
         uuid = "276d1c0e-06d1-4bbe-a5ba-888523af4dcb";
  },
  {
         explain = "";
         id = 1278133984104734722;
         name = "\U5929\U6d25";
         sn = 3;
         updateTime = "2020-07-01 09:11:03";
         uuid = "a10f4f1c-3f46-43ff-85e8-b72a3d423621";
  }
*/
-(void)requestProvincialRadio:(void(^)(NSArray *info))result;

/**
  获取省市电台播放列表
    {
        description = "";
           explain = "";
           icon = "http://cnvod.cnr.cn/audio2017/ondemand/img/1100/20190709/1562667842448.png";
           id = 1278136975117430786;
           name = "\U5317\U4eac\U65b0\U95fb\U5e7f\U64ad";
           placeId = 1278133984025042946;
           stream = "http://cnlive.cnr.cn/hls/bjxwgb.m3u8";
           updateTime = "2020-07-01 09:22:56";
           uuid = "9a808483-8c17-4ffe-9d35-bcef83c0b8ec";
       },
           {
           description = "";
           explain = "";
           icon = "http://cnvod.cnr.cn/audio2017/ondemand/img/1100/20190709/1562667945305.png";
           id = 1278136977654984706;
           name = "\U5317\U4eac\U4ea4\U901a\U5e7f\U64ad";
           placeId = 1278133984025042946;
           stream = "http://cnlive.cnr.cn/hls/bjjtgb.m3u8";
           updateTime = "2020-07-01 09:22:56";
           uuid = "76857685-9704-48f6-9299-314a38dcc0b0";
       },
*/
-(void)requestProvincialRadioList:(NSString *)areaId Result:(void(^)(NSArray *info))result;

/**
  获取国家电台
 {
     explain = "";
     id = 1278133982246658049;
     name = "\U56fd\U5bb6";
     sn = 1;
     updateTime = "2020-07-01 09:11:02";
     uuid = "b51b545c-b8cd-4a00-8d34-ab2cc1c56eb4";
 }
*/
-(void)requestNationalRadio:(void(^)(NSArray *info))result;

/**
  获取国家电台播放列表
 {
   {
       description =""
       explain = "";
       icon = "http://www.radio.cn/img/default/2014/9/18/1411025486781.jpg";
       id = 1278136529481097218;
       name = "\U4e2d\U56fd\U4e4b\U58f0";
       placeId = 1278133982246658049;
       stream = "http://ngcdn001.cnr.cn/live/zgzs/index.m3u8";
       updateTime = "2020-07-01 09:21:09";
       uuid = "00af9394-802a-4d66-86f1-e5317b2320e8";
   },
 }
*/
-(void)requestNationalRadioList:(void(^)(NSArray *info))result;

@end

NS_ASSUME_NONNULL_END
