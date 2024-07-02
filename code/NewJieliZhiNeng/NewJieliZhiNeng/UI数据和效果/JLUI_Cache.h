//
//  JLUI_Cache.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <JL_BLEKit/JL_BLEKit.h>

#import "JLCacheBox.h"

NS_ASSUME_NONNULL_BEGIN



@interface JLUI_Cache : NSObject
@property(strong,nonatomic) NSString *mUuid;


@property(assign,nonatomic) BOOL            isTFType;           //判断当前是否为设备音乐
@property(nonatomic,assign) BOOL            isID3_PUSH;         //是否开启ID3推送
@property(nonatomic,assign) BOOL            isID3_FIRST;        //第一次ID3推送
@property(nonatomic,assign) BOOL            isID3_ST;           //是否处于ID3状态
@property(nonatomic,assign) BOOL            isID3_PLAY;         //是否播放ID3
@property(nonatomic,assign) BOOL            isAppOut;           //是否出于后台


@property(nonatomic,strong) NSMutableArray  *eqCacheArray;      //EQ离线数组
@property(nonatomic,strong) NSMutableArray  *eqCacheArray_1;    //EQ离线数组

@property(nonatomic,assign) uint8_t         mEqMode;            //EEQ离线模式

@property(nonatomic,strong) NSData          *leftData;          //左耳数据
@property(nonatomic,strong) NSData          *rightData;         //右耳数据
@property(nonatomic,strong) NSData          *chargingBinData;   //充电仓数据
@property(nonatomic,strong) NSData          *productData;       //产品图片数据
@property(nonatomic,assign) int             mRedFlag;           //点击标识

@property(assign,nonatomic) NSDictionary    *ledDic;            //闪灯设置
@property(nonatomic,assign) NSInteger       p_Mvol;             //最大音量
@property(nonatomic,assign) NSInteger       P_Cvol;             //当前音量

@property(nonatomic,assign) BOOL            isOtaVC;            //是否已弹出OTA界面
@property(nonatomic,assign) BOOL            isLoadMusicInfo;    //第一次刷新设备音乐
@property(nonatomic,assign) BOOL            isLoadIpodInfo;     //第一次刷新本地音乐
@property(nonatomic,assign) BOOL            callPhoneFlag;      //通话时，禁止调节主音量\高低音


@property(nonatomic,strong) NSString        *__nullable renameUUID;
@property(nonatomic,strong) NSString        *__nullable otaUUID;
@property(nonatomic,assign) BOOL            isSearchView;
@property(nonatomic,assign) AFNetworkReachabilityStatus networkStatus;
@property(assign,nonatomic) NSMutableDictionary         *mPowerDic;
@property(nonatomic,assign) BOOL            hasKalaokEQ;        //是否支持卡拉OK的话筒音效

+(id)sharedInstance;
-(instancetype)initWithUuid:(NSString*)uuid;
-(void)setEqCustomArray:(NSArray*)array;
-(void)setEqCustomArray_1:(NSArray*)array;
-(void)setAllImage:(NSDictionary *)dict WithUuid:(NSString*)uuid;


@end

NS_ASSUME_NONNULL_END
