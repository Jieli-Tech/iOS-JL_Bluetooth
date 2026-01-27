//
//  MapLocationRequest.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/27.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "MapLocationRequest.h"
#import "SqliteManager.h"

#import "JLUI_Cache.h"

@interface MapLocationRequest()<AMapLocationManagerDelegate,MAMapViewDelegate,AMapSearchDelegate>{
    NSTimer *locateTimer;
    NSString *addressMap;
    NSData *locateMap;
    NSData *searchGeoData;
    GeoCodeSearch gcsBlock;
}
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) AMapSearchAPI *search;
@end

@implementation MapLocationRequest

+(instancetype)shareInstanced{
    static MapLocationRequest *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = [[MapLocationRequest alloc] init];
    });
    return map;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        kJLLog(JLLOG_DEBUG,@"---> MapLocationRequest.");
        [JL_Tools add:kJL_BLE_M_ENTITY_DISCONNECTED Action:@selector(disconnectedBle:) Own:self];
        [JL_Tools add:kJL_MANAGER_HEADSET_ADV Action:@selector(noteHeadsetInfo:) Own:self];
     
        self.locationManager = [[AMapLocationManager alloc] init];
        self.locationManager.delegate = self;
        //设置期望定位精度
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        //设置不允许系统暂停定位
        [self.locationManager setPausesLocationUpdatesAutomatically:NO];
        //设置定位超时时间
        [self.locationManager setLocationTimeout:1];
//        [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
//        }];
        
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
        locateTimer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(requestLocate) userInfo:nil repeats:YES];
        [locateTimer fire];
    }
    return self;
}

#pragma mark - 电量信息
-(void)noteHeadsetInfo:(NSNotification*)note{
    [JL_Tools mainTask:^{
        NSDictionary *info = note.object;
        NSString *uuid = info[kJL_MANAGER_KEY_UUID];
        NSDictionary *dict = info[kJL_MANAGER_KEY_OBJECT];
        
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        if([dict[@"POWER_L"] intValue] != entity.mPower_L
            || [dict[@"POWER_R"] intValue] != entity.mPower_R){
            int powL = [dict[@"POWER_L"] intValue];
            int powR = [dict[@"POWER_R"] intValue];
            if(powL == 0){ //记录左耳离线的时间
                [[SqliteManager sharedInstance] updateLeftLastTime:[NSDate new] ForUUID:uuid];
            }
            if(powR == 0){ //记录右耳离线的时间
                [[SqliteManager sharedInstance] updateRightLastTime:[NSDate new] ForUUID:uuid];
            }
        }
    }];
}

-(void)requestLocate{
    [JL_Tools subTask:^{
        [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            if (error) { kJLLog(JLLOG_DEBUG,@"定位错误：%@",error); return; }
            NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
            NSNumber *lon = [NSNumber numberWithDouble:location.coordinate.longitude];
            NSDictionary *userLocation=@{@"lat":lat?:@"",@"long":lon?:@""};
            self->locateMap = [NSKeyedArchiver archivedDataWithRootObject:userLocation];
            self->addressMap = regeocode.formattedAddress;
        }];
    }];
}

-(void)disconnectedBle:(NSNotification *)note{
    /*--- 【改名断开】或者【OTA断开】都不记录位置 ---*/
    NSString *renameUUID = [[JLUI_Cache sharedInstance] renameUUID];
    NSString *otaUUID    = [[JLUI_Cache sharedInstance] otaUUID];
    if (renameUUID.length>0 || otaUUID.length>0) return;
    
    CBPeripheral *cbp = note.object;

    [self requestLocationUUid:cbp.identifier.UUIDString];
    [[SqliteManager sharedInstance] updateLastTime:[NSDate new] ForUUID:cbp.identifier.UUIDString];
}

-(void)requestLocation:(JL_EntityM *)entity{
    if (!locateMap) {
        [self requestLocationUUid:entity.mPeripheral.identifier.UUIDString];
    }else{
        [JL_Tools setUser:locateMap forKey:@"PHONE_LASTLOCATE"];
        [[SqliteManager sharedInstance] updateLocate:locateMap ForUUID:entity.mPeripheral.identifier.UUIDString];
        [[SqliteManager sharedInstance] updateLastAddress:addressMap ForUUID:entity.mPeripheral.identifier.UUIDString];
        [JL_Tools mainTask:^{
            [JL_Tools post:@"UPDATE_MAP_LIST" Object:nil];
        }];
    }
}




-(void)requestLocationUUid:(NSString *)uuid{
    if (uuid.length == 0) return;
    
    [JL_Tools subTask:^{
        [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location,
                                                                                 AMapLocationReGeocode *regeocode,
                                                                                 NSError *error)
        {
            if (error) { kJLLog(JLLOG_DEBUG,@"定位错误：%@",error); return; }
            
            NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
            NSNumber *lon = [NSNumber numberWithDouble:location.coordinate.longitude];
            NSDictionary *userLocation=@{@"lat":lat?:@"",@"long":lon?:@""};
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userLocation];
            //kJLLog(JLLOG_DEBUG,@"%s %s 定位:%@",__FILE_NAME__,__func__,userLocation);
            kJLLog(JLLOG_DEBUG,@"--->LOCATION Latitude:%@ Longitude:%@",lat,lon);
            [JL_Tools setUser:data forKey:@"PHONE_LASTLOCATE"];
            [[SqliteManager sharedInstance] updateLocate:data ForUUID:uuid];
            [[SqliteManager sharedInstance] updateLastAddress:regeocode.formattedAddress ForUUID:uuid];
            [JL_Tools mainTask:^{
                [JL_Tools post:@"UPDATE_MAP_LIST" Object:nil];
            }];
        }];
    }];
}


-(void)requestGeoCodeAddress:(NSData *)data block:(GeoCodeSearch)block{
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    double latitude = [dict[@"lat"] doubleValue];
    double longitude = [dict[@"long"] doubleValue];
    CLLocationCoordinate2D locate  = CLLocationCoordinate2DMake(latitude, longitude);
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location                    = [AMapGeoPoint locationWithLatitude:locate.latitude longitude:locate.longitude];
    regeo.requireExtension            = YES;
    searchGeoData = data;
    gcsBlock = block;
    [self.search AMapReGoecodeSearch:regeo];
}
-(NSData *)requestNowLocation{
    if (locateMap) {
        return locateMap;
    }else{
        [self requestLocate];
        return nil;
    }
}

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager
{
    [locationManager requestAlwaysAuthorization];
}
#pragma mark - AMapSearchGeocodeSearchDone
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        if (gcsBlock) {
            gcsBlock(searchGeoData,response.regeocode.formattedAddress);
        }
        
    }
}

@end
