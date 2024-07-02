//
//  MapViewController.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/3.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "MapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

#import <CoreLocation/CLLocationManager.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import "JLUI_Cache.h"
#import "JL_RunSDK.h"
#import "SqliteManager.h"
#import "BigVoiceTipsView.h"
#import "MapLocationRequest.h"

#import "NoNetView.h"
JL_RunSDK *bleSDK;

@interface MapViewController ()<MAMapViewDelegate,AMapSearchDelegate,AMapLocationManagerDelegate,VoiceTipsDelegate>{
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet UILabel *locationLab;
    __weak IBOutlet UILabel *lastTime;
    __weak IBOutlet UILabel *distanceLab;
    __weak IBOutlet UIButton *searchBtn;
    __weak IBOutlet UIButton *closeVoiceBtn;
    MAMapView *mapView;
    __weak IBOutlet UIButton *findMeBtn;
    __weak IBOutlet UILabel *titleLab;
    __weak IBOutlet NSLayoutConstraint *mapHeight;
    __weak IBOutlet NSLayoutConstraint *headHeight;
    __weak IBOutlet UIView *bottomView;
    
    AMapSearchAPI *search;
    MAPolyline *line;
    AMapLocationManager *locationManager;
    CLLocationCoordinate2D deviceLocation; //左右耳同时在线的经纬度
    CLLocationCoordinate2D deviceLeftLocation; //左耳在线的经纬度
    CLLocationCoordinate2D deviceRightLocation; //右耳在线的经纬度
    NSTimer *voiceTimer;
    float normalVoice;
    MPVolumeView *volumeView;
    BigVoiceTipsView *tipsView;
    NSMutableDictionary *pointDict; //左右耳同时在线
    NSMutableDictionary *pointLeftDict; //左耳在线
    NSMutableDictionary *pointRightDict; //右耳在线
    
    NoNetView *noNetView;
    __weak IBOutlet NSLayoutConstraint *manView_H;
    __weak IBOutlet NSLayoutConstraint *mapView1_H;
    
    UIView *bottomVoicesLeftView;
    UIView *bottomVoicesRightView;
    
    UILabel *leftLabel; //已连接/未连接
    UILabel *playSoundLeftLabel; //播放声音
    UIImageView *leftVolImv;
    
    UILabel *rightLabel; //已连接/未连接
    UILabel *playSoundRightLabel; //播放声音
    UIImageView *rightVolImv;
    
    int type; //0：左耳点击 1：右耳点击
    NSMutableArray *playWayArray; //播放方式的数组
    NSMutableArray *annotations;  //标记数组
    NSMutableDictionary *powerDict; //电量字典
    
    MAPointAnnotation *pointAnnotation_1;
    MAPointAnnotation *pointAnnotation_2;
    MAPointAnnotation *pointAnnotation_3;
    MAPointAnnotation *pointAnnotation_4;
    
    JL_EntityM *entity;
    BOOL soundStatus; //开启或者关闭铃声的状态
    
    JL_RunSDK *bleSDK;
    NSString *vidStr;
    NSString *pidStr;
}
@end

@implementation MapViewController

static CTCallCenter *callCenter = nil;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
    
    [self initWithUI];
    [self initBottomViews];
    [self initWithData];
    
    bleSDK = [JL_RunSDK sharedMe];
    NSString *aVid = self->bleSDK.mBleEntityM.mVID;
    NSString *aPid = self->bleSDK.mBleEntityM.mPID;

    if (aVid.length     == 0 ||
        aPid.length     == 0){
        return;}
    
    NSNumber *vidNumber = [NSNumber numberWithLong:strtoul(aVid.UTF8String, 0, 16)];
    vidStr = [vidNumber stringValue];
    
    NSNumber *pidNumber = [NSNumber numberWithLong:strtoul(aPid.UTF8String, 0, 16)];
    pidStr = [pidNumber stringValue];
    
    NSLog(@"vidStr:%@",vidStr);
    NSLog(@"pidStr:%@",pidStr);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFindStatus:) name:kJL_MANAGER_FIND_DEVICE_STATUS object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    if(self.powerDict.count > 0){
        NSDictionary *dict = self.powerDict[self.deviceUUID];
        self->entity.mPower_L = [dict[@"POWER_L"] intValue];
        self->entity.mPower_R =[dict[@"POWER_R"] intValue];
    }
    
    [self findDevice];
    [self showSoundUI];
    
    JL_TwsManager *tws = bleSDK.mBleEntityM.mCmdManager.mTwsManager;
    
    JL_FindDeviceManager *find = bleSDK.mBleEntityM.mCmdManager.mFindDeviceManager;
    
    if (tws.dragWithMore){
        [find cmdFindDeviceCheckStatus:^(JL_CMDStatus status, JLFindDeviceOperation * _Nullable model) {
            [self handleUpdate:model];
        }];
    }
}

-(void)handleFindStatus:(NSNotification *)note{
    NSDictionary *dict = note.object;
    JLFindDeviceOperation *model = dict[kJL_MANAGER_KEY_OBJECT];
    [self handleUpdate:model];
}

-(void)handleUpdate:(JLFindDeviceOperation *)model{
    if (self.deviceObjc.type == JL_DeviceTypeTWS){
        if (model){
            if(model.playWay == 3){
                type = -1;
            }
            if (model.playWay == 0){
                [playWayArray setArray:@[@(1),@(2)]];
                type = 0;
            }
            if (model.playWay == 2){
                [playWayArray setArray:@[@(2)]];
                type = 2;
            }
            if (model.playWay == 1){
                [playWayArray setArray:@[@(1)]];
                type = 1;
            }
            [self handleBottomViewUI:playWayArray];
            
            if (model.sound == 0x00){
                
                bottomVoicesRightView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                rightLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                playSoundRightLabel.hidden = NO;
                playSoundRightLabel.textColor = kColor_0000;
                rightVolImv.hidden = YES;
                
                bottomVoicesLeftView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                leftLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                playSoundLeftLabel.hidden = NO;
                playSoundLeftLabel.textColor = kColor_0000;
                leftVolImv.hidden = YES;
            }
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [voiceTimer invalidate];
    voiceTimer = nil;
}

-(void)findDevice{
    lastTime.text = [self timeFromNow:[NSDate new] Type:0];
    
    NSString *uuidNow = entity.mPeripheral.identifier.UUIDString;
    NSString *uuidSelected = self.deviceObjc.uuid;
    
    if (entity && [uuidNow isEqual:uuidSelected]) {
        locationLab.text = kJL_TXT("locating");
        [JL_Tools subTask:^{
            [self->locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                if (!error) {
                    [JL_Tools mainTask:^{
                        self->distanceLab.hidden = YES;
                        NSString *uuid = self->entity.mPeripheral.identifier.UUIDString;
                        NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
                        NSNumber *lon = [NSNumber numberWithDouble:location.coordinate.longitude];
                        NSDictionary *userLocation=@{@"lat":lat?:@"",@"long":lon?:@""};
                        
                        NSData *data;
                        if(self.deviceObjc.type == JL_DeviceTypeSoundBox || self.deviceObjc.type == JL_DeviceTypeSoundCard){
                            if(self->pointAnnotation_1 == nil){
                                self->pointAnnotation_1 = [[MAPointAnnotation alloc] init];
                            }
                            self->deviceLocation = location.coordinate;
                            self->pointAnnotation_1.coordinate = location.coordinate;
                            self->pointAnnotation_1.title = kJL_TXT("last_location_now");
                            
                            [self->pointDict setValue:userLocation forKey:uuid];
                            data = [NSKeyedArchiver archivedDataWithRootObject:userLocation];
                            [[SqliteManager sharedInstance] updateLocate:data ForUUID:uuid];
                            [[MapLocationRequest shareInstanced] requestGeoCodeAddress:data block:^(NSData * _Nonnull data, NSString * _Nonnull address) {
                                self->locationLab.text = address;
                            }];
                            
                            [self->mapView addAnnotations:@[self->pointAnnotation_1]];
                            [self->mapView setCenterCoordinate:self->pointAnnotation_1.coordinate animated:YES];
                        }
                        if(self.deviceObjc.type == JL_DeviceTypeTWS){ //耳机
                            if(self->entity.mPower_L>0 && self->entity.mPower_R>0){ //左右耳有电量，显示一对耳机的位置
                                if(self->pointAnnotation_2 == nil){
                                    self->pointAnnotation_2 = [[MAPointAnnotation alloc] init];
                                }
                                self->deviceLocation = location.coordinate;
                                self->pointAnnotation_2.coordinate = location.coordinate;
                                self->pointAnnotation_2.title = kJL_TXT("last_location_now");
                                
                                [self->pointDict setValue:userLocation forKey:uuid];
                                data = [NSKeyedArchiver archivedDataWithRootObject:userLocation];
                                [[SqliteManager sharedInstance] updateLocate:data ForUUID:uuid];
                                [[SqliteManager sharedInstance] updateLocate:data Type:(TWS_Locate)TWS_LEFT ForUUID:uuid];
                                [[SqliteManager sharedInstance] updateLocate:data Type:(TWS_Locate)TWS_RIGHT ForUUID:uuid];
                                [[MapLocationRequest shareInstanced] requestGeoCodeAddress:data block:^(NSData * _Nonnull data, NSString * _Nonnull address) {
                                    self->locationLab.text = address;
                                }];
                                
                                [self->mapView addAnnotations:@[self->pointAnnotation_2]];
                                [self->mapView setCenterCoordinate:self->pointAnnotation_2.coordinate animated:YES];
                            }
                            if(self->entity.mPower_L>0 && self->entity.mPower_R == 0){ //左耳有电量，右耳电量为0(断连)
                                [self->pointLeftDict setValue:userLocation forKey:uuid];

                                self->deviceLeftLocation = location.coordinate;
                                
                                DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                                NSDictionary *dict_r = [NSKeyedUnarchiver unarchiveObjectWithData:objc.locate_r];
                                if(dict_r == nil){
                                    dict_r = userLocation;
                                }
                                
                                NSLogEx(@"%@",dict_r);
                                [self->pointRightDict setValue:dict_r forKey:self.deviceObjc.uuid];
                                double latitude = [dict_r[@"lat"] doubleValue];
                                double longitude = [dict_r[@"long"] doubleValue];
                                self->deviceRightLocation = CLLocationCoordinate2DMake(latitude, longitude);
                                
                                CLLocationCoordinate2D coordinates[2] = {{self->deviceLeftLocation.latitude,self->deviceLeftLocation.longitude},
                                    {self->deviceRightLocation.latitude,self->deviceRightLocation.longitude}};

                                for (int i = 0; i < 2; ++i)
                                {
                                    MAPointAnnotation *mPointAnnotation = [[MAPointAnnotation alloc] init];
                                    mPointAnnotation.coordinate = coordinates[i];
                                    if(i == 0){
                                        mPointAnnotation.title      = kJL_TXT("last_location_now");
                                    }
                                    if(i == 1){
                                        DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                                        mPointAnnotation.title = [NSString stringWithFormat:@"%@%@",kJL_TXT("last_location_time"),[self timeFromNow:objc.rightLastTime Type:1]];
                                    }
                                    [self->annotations addObject:mPointAnnotation];
                                }

                                data = [NSKeyedArchiver archivedDataWithRootObject:userLocation];
                                [[SqliteManager sharedInstance] updateLocate:data Type:(TWS_Locate)TWS_LEFT ForUUID:uuid];
                                [[MapLocationRequest shareInstanced] requestGeoCodeAddress:data block:^(NSData * _Nonnull data, NSString * _Nonnull address) {
                                    self->locationLab.text = address;
                                }];

                                [self->mapView addAnnotations:self->annotations];
                                [self->mapView showAnnotations:self->annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
                            }
                            if(self->entity.mPower_R>0 && self->entity.mPower_L == 0){ //右耳有电量，左耳电量为0(断连)
                                [self->pointRightDict setValue:userLocation forKey:uuid];
                                
                                self->deviceRightLocation = location.coordinate;

                                DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                                NSDictionary *dict_l = [NSKeyedUnarchiver unarchiveObjectWithData:objc.locate_l];
                                if(dict_l == nil){
                                    dict_l = userLocation;
                                }
                                
                                NSLogEx(@"%@",dict_l);
                                [self->pointLeftDict setValue:dict_l forKey:self.deviceObjc.uuid];
                                double latitude = [dict_l[@"lat"] doubleValue];
                                double longitude = [dict_l[@"long"] doubleValue];
                                self->deviceLeftLocation = CLLocationCoordinate2DMake(latitude, longitude);
                                
                                CLLocationCoordinate2D coordinates[2] = {{self->deviceLeftLocation.latitude,self->deviceLeftLocation.longitude},
                                    {self->deviceRightLocation.latitude,self->deviceRightLocation.longitude}};

                                for (int i = 0; i < 2; ++i)
                                {
                                    MAPointAnnotation *mPointAnnotation = [[MAPointAnnotation alloc] init];
                                    mPointAnnotation.coordinate = coordinates[i];
                                    if(i == 0){
                                        DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                                        mPointAnnotation.title = [NSString stringWithFormat:@"%@%@",kJL_TXT("last_location_time"),[self timeFromNow:objc.leftLastTime Type:1]];
                                    }
                                    if(i == 1){
                                        mPointAnnotation.title = kJL_TXT("last_location_now");
                                    }
                                    [self->annotations addObject:mPointAnnotation];
                                }

                                data = [NSKeyedArchiver archivedDataWithRootObject:userLocation];

                                [[SqliteManager sharedInstance] updateLocate:data Type:(TWS_Locate)TWS_RIGHT ForUUID:uuid];
                                [[MapLocationRequest shareInstanced] requestGeoCodeAddress:data block:^(NSData * _Nonnull data, NSString * _Nonnull address) {
                                    self->locationLab.text = address;
                                }];

                                [self->mapView addAnnotations:self->annotations];
                                [self->mapView showAnnotations:self->annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
                            }
                        }
                        
                        [[SqliteManager sharedInstance] updateLastTime:[NSDate new] ForUUID:uuid];
                        if(![self->locationLab.text isEqualToString:kJL_TXT("locating")]){
                            [[SqliteManager sharedInstance] updateLastAddress:self->locationLab.text ForUUID:uuid];
                        }
                        
                    }];
                }else{
                    NSLog(@"%s %s :%@",__FILE_NAME__,__func__,error);
                }
            }];
        }];
    }else{
        titleLab.text = _deviceObjc.name;//kJL_TXT("device_positioning");
        
        if(self.deviceObjc.type == JL_DeviceTypeSoundBox || self.deviceObjc.type == JL_DeviceTypeSoundCard){
            NSMutableArray *pointsArray = [NSMutableArray new];
            if(self->pointAnnotation_3 == nil){
                self->pointAnnotation_3 = [[MAPointAnnotation alloc] init];
            }
            NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:self.deviceObjc.locate];
            NSLogEx(@"%@",dict);
            [self->pointDict setValue:dict forKey:self.deviceObjc.uuid];
            double latitude = [dict[@"lat"] doubleValue];
            double longitude = [dict[@"long"] doubleValue];
            deviceLocation = CLLocationCoordinate2DMake(latitude, longitude);
            self->pointAnnotation_3.coordinate = deviceLocation;
            self->pointAnnotation_3.title = [NSString stringWithFormat:@"%@%@",kJL_TXT("last_location_time"),[self timeFromNow:self.deviceObjc.lastTime Type:1]];
            [pointsArray addObject:self->pointAnnotation_3];
            if (pointsArray.count>0) {
                [mapView addAnnotations:pointsArray];
            }
        }
        
        if(self.deviceObjc.type == JL_DeviceTypeTWS){ //耳机
            if(self.deviceObjc.locate != nil){ //左右耳有电量，显示一对耳机的位置
                NSMutableArray *pointsArray = [NSMutableArray new];
                if(self->pointAnnotation_4 == nil){
                    self->pointAnnotation_4 = [[MAPointAnnotation alloc] init];
                }
                NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:self.deviceObjc.locate];
                NSLogEx(@"%@",dict);
                [self->pointDict setValue:dict forKey:self.deviceObjc.uuid];
                double latitude = [dict[@"lat"] doubleValue];
                double longitude = [dict[@"long"] doubleValue];
                deviceLocation = CLLocationCoordinate2DMake(latitude, longitude);
                self->pointAnnotation_4.coordinate = deviceLocation;
                self->pointAnnotation_4.title = [NSString stringWithFormat:@"%@%@",kJL_TXT("last_location_time"),[self timeFromNow:self.deviceObjc.lastTime Type:1]];
                [pointsArray addObject:self->pointAnnotation_4];
                if (pointsArray.count>0) {
                    [mapView addAnnotations:pointsArray];
                }
            }
            if(self.deviceObjc.locate_l){ //左耳有电量，右耳电量为0(断连)
                DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                
                NSDictionary *dict_l = [NSKeyedUnarchiver unarchiveObjectWithData:objc.locate_l];
                NSLogEx(@"%@",dict_l);
                [self->pointLeftDict setValue:dict_l forKey:self.deviceObjc.uuid];
                double latitude_l = [dict_l[@"lat"] doubleValue];
                double longitude_l = [dict_l[@"long"] doubleValue];
                deviceLeftLocation = CLLocationCoordinate2DMake(latitude_l, longitude_l);

                NSDictionary *dict_r = [NSKeyedUnarchiver unarchiveObjectWithData:objc.locate_r];
                NSLogEx(@"%@",dict_r);
                [self->pointRightDict setValue:dict_r forKey:self.deviceObjc.uuid];
                double latitude_r = [dict_r[@"lat"] doubleValue];
                double longitude_r = [dict_r[@"long"] doubleValue];
                deviceRightLocation = CLLocationCoordinate2DMake(latitude_r, longitude_r);
                
                CLLocationCoordinate2D coordinates[2] = {{deviceLeftLocation.latitude,deviceLeftLocation.longitude},
                    {deviceRightLocation.latitude,deviceRightLocation.longitude}};

                for (int i = 0; i < 2; ++i)
                {
                    MAPointAnnotation *mPointAnnotation = [[MAPointAnnotation alloc] init];
                    mPointAnnotation.coordinate = coordinates[i];
                    DeviceObjc *objc;
                    if(i == 0){
                        objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                        mPointAnnotation.title = [NSString stringWithFormat:@"%@%@",kJL_TXT("last_location_time"),[self timeFromNow:objc.leftLastTime Type:1]];
                    }
                    if(i == 1){
                        objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                        mPointAnnotation.title = [NSString stringWithFormat:@"%@%@",kJL_TXT("last_location_time"),[self timeFromNow:objc.rightLastTime Type:1]];
                    }
                    [self->annotations addObject:mPointAnnotation];
                }

                if(annotations.count>0){
                    [mapView addAnnotations:annotations];
                }
            }

            if(self.deviceObjc.locate_r){ //右耳有电量，左耳电量为0(断连)
                DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                
                NSDictionary *dict_l = [NSKeyedUnarchiver unarchiveObjectWithData:objc.locate_l];
                NSLogEx(@"%@",dict_l);
                [self->pointLeftDict setValue:dict_l forKey:self.deviceObjc.uuid];
                double latitude_l = [dict_l[@"lat"] doubleValue];
                double longitude_l = [dict_l[@"long"] doubleValue];
                self->deviceLeftLocation = CLLocationCoordinate2DMake(latitude_l, longitude_l);
                
                NSDictionary *dict_r = [NSKeyedUnarchiver unarchiveObjectWithData:objc.locate_r];
                NSLogEx(@"%@",dict_r);
                [self->pointRightDict setValue:dict_r forKey:self.deviceObjc.uuid];
                double latitude_r = [dict_r[@"lat"] doubleValue];
                double longitude_r = [dict_r[@"long"] doubleValue];
                deviceRightLocation = CLLocationCoordinate2DMake(latitude_r, longitude_r);

                CLLocationCoordinate2D coordinates[2] = {{self->deviceLeftLocation.latitude,self->deviceLeftLocation.longitude},
                    {self->deviceRightLocation.latitude,self->deviceRightLocation.longitude}};

                for (int i = 0; i < 2; ++i)
                {
                    MAPointAnnotation *mPointAnnotation = [[MAPointAnnotation alloc] init];
                    mPointAnnotation.coordinate = coordinates[i];
                    DeviceObjc *objc;
                    if(i == 0){
                        objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                        mPointAnnotation.title = [NSString stringWithFormat:@"%@%@",kJL_TXT("last_location_time"),[self timeFromNow:objc.leftLastTime Type:1]];
                    }
                    if(i == 1){
                        objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                        mPointAnnotation.title = [NSString stringWithFormat:@"%@%@",kJL_TXT("last_location_time"),[self timeFromNow:objc.rightLastTime Type:1]];
                    }
                    [self->annotations addObject:mPointAnnotation];
                }

                if(annotations.count>0){
                    [mapView addAnnotations:annotations];
                }
            }
        }

        locationLab.text = self.deviceObjc.address;
        
        distanceLab.hidden = NO;
        
        [JL_Tools subTask:^{
            [self->locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                [JL_Tools mainTask:^{
                    if (error == nil) {
                        
                        if(self.deviceObjc.type == JL_DeviceTypeSoundBox || self.deviceObjc.type == JL_DeviceTypeSoundCard){
                            [self->mapView setCenterCoordinate:location.coordinate animated:YES];
                        }
                        if(self.deviceObjc.type == JL_DeviceTypeTWS){ //耳机
                            if(self->entity.mPower_L>0 && self->entity.mPower_R>0){ //左右耳有电量，显示一对耳机的位置
                                [self->mapView setCenterCoordinate:location.coordinate animated:YES];
                            }
                            if(self->entity.mPower_L>0 && self->entity.mPower_R == 0){ //左耳有电量，右耳电量为0(断连)
                                [self->mapView showAnnotations:self->annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
                            }
                            if(self->entity.mPower_R>0 && self->entity.mPower_L == 0){ //右耳有电量，左耳电量为0(断连)
                                [self->mapView showAnnotations:self->annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
                            }
                        }
                        [self findMeBtnAction:nil];
                    }
                }];
                
            }];
        }];
    }
}

- (IBAction)findMeBtnAction:(id)sender {
    if(self.deviceObjc.type == JL_DeviceTypeSoundBox || self.deviceObjc.type == JL_DeviceTypeSoundCard){
        [mapView setCenterCoordinate:deviceLocation animated:YES];
        [locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            [self calcuteWithDistance:location.coordinate with:self->deviceLocation];
            [self->mapView setCenterCoordinate:location.coordinate animated:YES];
        }];
    }
    if(self.deviceObjc.type == JL_DeviceTypeTWS){ //耳机
        if(entity.mPower_L>0 && entity.mPower_R>0){ //左右耳有电量，显示一对耳机的位置
            [mapView setCenterCoordinate:deviceLocation animated:YES];
            [locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                [self calcuteWithDistance:location.coordinate with:self->deviceLocation];
                [self->mapView setCenterCoordinate:location.coordinate animated:YES];
            }];
        }
        if(entity.mPower_L>0 && entity.mPower_R == 0){ //左耳有电量，右耳电量为0(断连)
            [self->mapView showAnnotations:self->annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
            [locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                [self calcuteWithDistance:location.coordinate with:self->deviceLeftLocation];
                self->deviceLeftLocation = location.coordinate;
                CLLocationCoordinate2D coordinates[2] = {{self->deviceLeftLocation.latitude,self->deviceLeftLocation.longitude},
                    {self->deviceRightLocation.latitude,self->deviceRightLocation.longitude}};

                for (int i = 0; i < 2; ++i)
                {
                    MAPointAnnotation *mPointAnnotation = [[MAPointAnnotation alloc] init];
                    mPointAnnotation.coordinate = coordinates[i];
                    if(i == 0){
                        mPointAnnotation.title      = kJL_TXT("last_location_now");
                    }
                    if(i == 1){
                        DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                        mPointAnnotation.title = [NSString stringWithFormat:@"%@%@",kJL_TXT("last_location_time"),[self timeFromNow:objc.rightLastTime Type:1]];
                    }
                    [self->annotations addObject:mPointAnnotation];
                }
                [self->mapView showAnnotations:self->annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
            }];
        }
        if(entity.mPower_R>0 && entity.mPower_L == 0){ //右耳有电量，左耳电量为0(断连)
            [self->mapView showAnnotations:self->annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
            [locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                [self calcuteWithDistance:location.coordinate with:self->deviceRightLocation];
                self->deviceRightLocation = location.coordinate;
                CLLocationCoordinate2D coordinates[2] = {{self->deviceLeftLocation.latitude,self->deviceLeftLocation.longitude},
                    {self->deviceRightLocation.latitude,self->deviceRightLocation.longitude}};

                for (int i = 0; i < 2; ++i)
                {
                    MAPointAnnotation *mPointAnnotation = [[MAPointAnnotation alloc] init];
                    mPointAnnotation.coordinate = coordinates[i];
                    if(i == 0){
                        DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:self.deviceObjc.uuid];
                        mPointAnnotation.title = [NSString stringWithFormat:@"%@%@",kJL_TXT("last_location_time"),[self timeFromNow:objc.leftLastTime Type:1]];
                    }
                    if(i == 1){
                        mPointAnnotation.title      = kJL_TXT("last_location_now");
                    }
                    [self->annotations addObject:mPointAnnotation];
                }
                [self->mapView showAnnotations:self->annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
            }];
        }
    }
}

- (IBAction)searchDeviceBtnAction:(id)sender {
    if(self.deviceObjc.type == JL_DeviceTypeSoundBox || self.deviceObjc.type == JL_DeviceTypeSoundCard){
        [self startSearch];
    }
    if(self.deviceObjc.type == JL_DeviceTypeTWS){ //耳机
        [self.view addSubview:tipsView];
    }
}

- (IBAction)stopVoiceBtnAction:(id)sender {
    
    [self stopSearch];
    [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mFindDeviceManager cmdFindDevice:NO timeOut:60 findIphone:NO Operation:nil];
    
}

- (IBAction)leftBtnAction:(id)sender {
    [self->mapView removeAnnotations:self->annotations];
    self->annotations = nil;
    [self->locationManager stopUpdatingLocation];
    [self stopVoiceBtnAction:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)noteNetworkStatus:(NSNotification*)note{
    [self isNetwork];
}


-(void)initWithUI{
    noNetView = [[NoNetView alloc] initByFrame:CGRectMake(0,kJL_HeightNavBar, [UIScreen mainScreen].bounds.size.width, 40)];
    [self.view addSubview:noNetView];
    noNetView.hidden = YES;
    
    CLAuthorizationStatus st = [CLLocationManager authorizationStatus];
    if ([CLLocationManager locationServicesEnabled]      &&
        (st == kCLAuthorizationStatusAuthorizedWhenInUse ||
         st == kCLAuthorizationStatusNotDetermined       ||
         st == kCLAuthorizationStatusAuthorizedAlways) ) {
        
        //定位功能可用
        
    }else if (st ==kCLAuthorizationStatusDenied) {
        
        //定位不能用
        [DFUITools showText_1:kJL_TXT("no_authorized") onView:self.view delay:4];
        
    }
    
    headHeight.constant = kJL_HeightNavBar+10;
    if (kJL_IS_IPHONE_5) {
        mapHeight.constant = [UIScreen mainScreen].bounds.size.height*0.43;
    }else{
        mapHeight.constant = [UIScreen mainScreen].bounds.size.height*0.53;
    }
    if (mapView) {
        mapView = nil;
    }
    mapView = [[MAMapView alloc] initWithFrame:centerView.bounds];
    mapView.maxZoomLevel = 19;
    mapView.delegate = self;
    mapView.zoomLevel = 16.1;
    mapView.showsScale = NO;
    mapView.showsCompass = NO;
    NSData *data = [JL_Tools getUserByKey:@"PHONE_LASTLOCATE"];
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    double latitude = [dict[@"lat"] doubleValue];
    double longitude = [dict[@"long"] doubleValue];
    CLLocationCoordinate2D locate  = CLLocationCoordinate2DMake(latitude, longitude);
    
    [mapView setCenterCoordinate:locate animated:YES];
    
    
    
    [centerView addSubview:mapView];
    MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
    r.showsAccuracyRing = YES;
    r.showsHeadingIndicator = NO;
    r.fillColor = [UIColor colorWithRed:64.0/255.0 green:106.0/255.0 blue:192.0/255.0 alpha:0.2];///精度圈 填充颜色, 默认 kAccuracyCircleDefaultColor
    r.image = [UIImage imageNamed:@"Theme.bundle/search_icon_location_02"];
    [mapView updateUserLocationRepresentation:r];
    
    [searchBtn setTitle:kJL_TXT("multi_media_search_device") forState:UIControlStateNormal];
    [closeVoiceBtn setTitle:kJL_TXT("close_play") forState:UIControlStateNormal];
    
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    if ([entity.mPeripheral.identifier.UUIDString isEqualToString:self.deviceObjc.uuid])
    {
        titleLab.text = _deviceObjc.name;//[[JL_BLEUsage sharedMe] bt_Entity].mItem;
        searchBtn.backgroundColor = kColor_0000;
        [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeVoiceBtn setBackgroundColor:[UIColor whiteColor]];
        [closeVoiceBtn setTitleColor:kColor_0000 forState:UIControlStateNormal];
        [searchBtn setUserInteractionEnabled:YES];
        [closeVoiceBtn setUserInteractionEnabled:YES];
    }else{
        mapView.showsUserLocation = YES;
        mapView.userTrackingMode = MAUserTrackingModeFollow;
        
        searchBtn.backgroundColor = kDF_RGBA(212, 212, 212, 1);
        [searchBtn setTitleColor:kDF_RGBA(100, 100, 100, 1) forState:UIControlStateNormal];
        [closeVoiceBtn setBackgroundColor:[UIColor whiteColor]];
        [closeVoiceBtn setTitleColor:kDF_RGBA(141, 141, 141, 1) forState:UIControlStateNormal];
        [searchBtn setUserInteractionEnabled:NO];
        [closeVoiceBtn setUserInteractionEnabled:NO];
    }
    searchBtn.layer.cornerRadius = 21;
    searchBtn.layer.masksToBounds = YES;
    closeVoiceBtn.layer.cornerRadius = 21;
    closeVoiceBtn.layer.masksToBounds = YES;
    closeVoiceBtn.layer.borderColor = kDF_RGBA(165, 164, 165, 1).CGColor;
    closeVoiceBtn.layer.borderWidth = 0.5;
    
    volumeView = [[MPVolumeView alloc] init];
    volumeView.frame = CGRectMake(-1000, -1000, 0, 0);
    [self.view addSubview:volumeView];
    
    tipsView = [[BigVoiceTipsView alloc] init];
    tipsView.title = kJL_TXT("tips_0");
    tipsView.message = kJL_TXT("search_device_tips");
    tipsView.delegate = self;
    
}

-(void)initWithData{
    
    /*--- 网络监测 ---*/
    BOOL isOk = [self isNetwork];
    if (isOk == NO) {
        return;
    }
    
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    entity = bleSDK.mBleEntityM;
    
    pointDict = [NSMutableDictionary new];
    pointLeftDict  = [NSMutableDictionary new];
    pointRightDict = [NSMutableDictionary new];
    
    playWayArray = [NSMutableArray new];
    annotations = [NSMutableArray array];
    powerDict = [NSMutableDictionary new];
    
    search = [[AMapSearchAPI alloc] init];
    search.delegate = self;
    
    locationManager = [[AMapLocationManager alloc] init];
    locationManager.delegate = self;
    //设置不允许系统暂停定位
    [locationManager setPausesLocationUpdatesAutomatically:NO];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [locationManager setLocationTimeout:3];
    [locationManager setReGeocodeTimeout:3];
    callCenter = [[CTCallCenter alloc] init];
    callCenter.callEventHandler = ^(CTCall * call) {
        [self->voiceTimer invalidate];
        self->voiceTimer = nil;
    };
}

-(BOOL)isNetwork{
    /*--- 网络监测 ---*/
    AFNetworkReachabilityStatus netSt = [[JLUI_Cache sharedInstance] networkStatus];
    if (netSt == AFNetworkReachabilityStatusUnknown ||
        netSt == AFNetworkReachabilityStatusNotReachable) {

        manView_H.constant = 40;
        mapView1_H.constant= 40;
        noNetView.hidden = NO;
        return NO;
    }else{
        manView_H.constant = 0;
        mapView1_H.constant= 0;
        noNetView.hidden = YES;
        return YES;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [JL_Tools remove:nil Own:self];
}

-(void)noteAppForeground:(NSNotification*)note{
    [self findDevice];
}

#pragma mark - 电量信息
-(void)noteHeadsetInfo:(NSNotification*)note{
    [JL_Tools mainTask:^{
        NSDictionary *info = note.object;
        NSString *uuid = info[kJL_MANAGER_KEY_UUID];
        NSDictionary *dict = info[kJL_MANAGER_KEY_OBJECT];
        
        BOOL isLoad = [self isReloadInfoUuid:uuid Dict:dict];
        if (isLoad) {
            if([dict[@"POWER_L"] intValue] != self->entity.mPower_L
                || [dict[@"POWER_R"] intValue] != self->entity.mPower_R){
                self->entity.mPower_L = [dict[@"POWER_L"] intValue];
                self->entity.mPower_R =[dict[@"POWER_R"] intValue];

                [self->mapView removeAnnotations:self->annotations];
                self->annotations = nil;
                self->annotations = [NSMutableArray array];
                [self findDevice];

                JLUuidType uuidType = [JL_RunSDK getStatusUUID:self.deviceObjc.uuid];
                if (uuidType == JLUuidTypeDisconnected||
                    uuidType == JLUuidTypeConnected) {
                    
                    self->leftLabel.text = kJL_TXT("device_status_unconnected");
                    self->leftLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
                    self->playSoundLeftLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
                    
                    self->rightLabel.text = kJL_TXT("device_status_unconnected");
                    self->rightLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
                    self->playSoundRightLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
                    
                }else if(uuidType == JLUuidTypeInUse){
                    if(self->entity.mPower_L > 0){
                        if((self->playWayArray.count == 2 && [self->playWayArray containsObject:@(1)]
                           && [self->playWayArray containsObject:@(2)]) || (self->playWayArray.count == 1 && [self->playWayArray containsObject:@(1)])){
                            
                            self->leftLabel.text = kJL_TXT("device_status_connected");
                            
                            if(self->soundStatus == NO){ //关闭铃声
                                self->bottomVoicesLeftView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                                self->leftLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                                self->playSoundLeftLabel.hidden = NO;
                                self->playSoundLeftLabel.textColor = kColor_0000;
                                self->leftVolImv.hidden = YES;
                            }
                            if(self->soundStatus == YES){ //打开铃声
                                if(self->voiceTimer != nil){
                                    [DFAction timingContinue:self->voiceTimer];
                                }
                                self->bottomVoicesLeftView.backgroundColor = kColor_0000;
                                self->leftLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                                self->playSoundLeftLabel.hidden = YES;
                                self->leftVolImv.hidden = NO;
                            }
                        }
                        if((self->playWayArray.count == 0) ||
                           (self->playWayArray.count == 1 && [self->playWayArray containsObject:@(2)])){
                            
                            self->leftLabel.text = kJL_TXT("device_status_connected");

                            self->leftLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                            
                            self->bottomVoicesLeftView.backgroundColor = [UIColor whiteColor];

                            [self->playSoundLeftLabel removeFromSuperview];
                            self->playSoundLeftLabel = [[UILabel alloc] init];
                            self->playSoundLeftLabel.frame = CGRectMake(17.5,59.5,100,20);
                            self->playSoundLeftLabel.numberOfLines = 0;
                            [self->bottomVoicesLeftView addSubview:self->playSoundLeftLabel];
                            self->playSoundLeftLabel.hidden = NO;

                            NSMutableAttributedString *playSoundLeftStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("play_sound") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 15],NSForegroundColorAttributeName: kColor_0000}];

                            self->playSoundLeftLabel.attributedText = playSoundLeftStr;
                        }
                    }
                    if(self->entity.mPower_L == 0){
                        if(self->voiceTimer != nil){
                            [DFAction timingPause:self->voiceTimer];
                        }
                        self->leftLabel.text = kJL_TXT("device_status_unconnected");
                        self->leftLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
                        self->playSoundLeftLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
                        
                        self->bottomVoicesLeftView.backgroundColor = [UIColor whiteColor];
                        
                        //[self stopVoiceBtnAction:nil];
                        //[self->playWayArray removeObject:@(1)];
                        
                        self->playSoundLeftLabel.hidden = NO;
                        self->leftVolImv.hidden = YES;
                    }
                    if(self->entity.mPower_R >0){
                        if((self->playWayArray.count == 2 && [self->playWayArray containsObject:@(1)]
                           && [self->playWayArray containsObject:@(2)]) || (self->playWayArray.count == 1 && [self->playWayArray containsObject:@(2)])){
                            
                            self->rightLabel.text = kJL_TXT("device_status_connected");
                            
                            if(self->soundStatus == NO){ //关闭铃声
                                self->bottomVoicesRightView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                                self->rightLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                                self->playSoundRightLabel.hidden = NO;
                                self->playSoundRightLabel.textColor = kColor_0000;
                                self->rightVolImv.hidden = YES;
                            }
                            if(self->soundStatus == YES){ //打开铃声
                                if(self->voiceTimer != nil){
                                    [DFAction timingContinue:self->voiceTimer];
                                }
                                self->bottomVoicesRightView.backgroundColor = kColor_0000;
                                self->rightLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                                self->playSoundRightLabel.hidden = YES;
                                self->rightVolImv.hidden = NO;
                            }
                        }
                        
                        if((self->playWayArray.count == 0) ||
                           (self->playWayArray.count == 1 && [self->playWayArray containsObject:@(1)])){
                            
                            self->rightLabel.text = kJL_TXT("device_status_connected");

                            self->rightLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                            self->bottomVoicesRightView.backgroundColor = [UIColor whiteColor];

                            [self->playSoundRightLabel removeFromSuperview];
                            self->playSoundRightLabel = [[UILabel alloc] init];
                            self->playSoundRightLabel.frame = CGRectMake(17.5,59.5,100,20);
                            self->playSoundRightLabel.numberOfLines = 0;
                            [self->bottomVoicesRightView addSubview:self->playSoundRightLabel];
                            self->playSoundRightLabel.hidden = NO;

                            NSMutableAttributedString *playSoundRightStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("play_sound") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 15],NSForegroundColorAttributeName: kColor_0000}];

                            self->playSoundRightLabel.attributedText = playSoundRightStr;
                        }
                    }
                    if(self->entity.mPower_R == 0){
                        if(self->voiceTimer != nil){
                            [DFAction timingPause:self->voiceTimer];
                        }
                        self->rightLabel.text = kJL_TXT("device_status_unconnected");
                        self->rightLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
                        self->playSoundRightLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
                        
                        self->bottomVoicesRightView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                        
                        //[self stopVoiceBtnAction:nil];
                        //[self->playWayArray removeObject:@(2)];
                        
                        self->playSoundRightLabel.hidden = NO;
                        self->rightVolImv.hidden = YES;
                            
                    }
                }
            }
        }
    }];
}

-(BOOL)isReloadInfoUuid:(NSString*)uuid Dict:(NSDictionary*)dict{

    NSDictionary *cacheDict = powerDict[uuid];
    if (cacheDict) {
        int pw_L      = [dict[@"POWER_L"] intValue];
        int pw_R      = [dict[@"POWER_R"] intValue];
        int pw_C      = [dict[@"POWER_C"] intValue];
        int pw_en_L   = [dict[@"ISCHARGING_L"] intValue];
        int pw_en_R   = [dict[@"ISCHARGING_R"] intValue];
        int pw_en_C   = [dict[@"ISCHARGING_C"] intValue];
        
        int c_pw_L    = [cacheDict[@"POWER_L"] intValue];
        int c_pw_R    = [cacheDict[@"POWER_R"] intValue];
        int c_pw_C    = [cacheDict[@"POWER_C"] intValue];
        int c_pw_en_L = [cacheDict[@"ISCHARGING_L"] intValue];
        int c_pw_en_R = [cacheDict[@"ISCHARGING_R"] intValue];
        int c_pw_en_C = [cacheDict[@"ISCHARGING_C"] intValue];
        
        if (pw_en_L != c_pw_en_L) return YES;
        if (pw_en_R != c_pw_en_R) return YES;
        if (pw_en_C != c_pw_en_C) return YES;
        
        /*--- 左边判断 ---*/
        BOOL is_L = [self isEnable:pw_en_L Pw:pw_L C_Pw:c_pw_L];
        
        /*--- 右边判断 ---*/
        BOOL is_R = [self isEnable:pw_en_R Pw:pw_R C_Pw:c_pw_R];
        
        /*--- 充电判断 ---*/
        BOOL is_C = [self isEnable:pw_en_C Pw:pw_C C_Pw:c_pw_C];
        
        if (is_L || is_R || is_C) {
            return YES;
        }else{
            return NO;
        }

    }else{
        return YES;
    }
}

-(BOOL)isEnable:(int8)pw_en Pw:(int8)pw C_Pw:(int8)c_pw{
    if (pw_en == 0) {
        if (pw >= c_pw) {
            return NO;
        }else{
            return YES;
        }
    }else{
        if (pw <= c_pw) {
            return NO;
        }else{
            return YES;
        }
    }
}

-(void)addNote{
    [JL_Tools add:kJL_MANAGER_HEADSET_ADV Action:@selector(noteHeadsetInfo:) Own:self];
    [JL_Tools add:AFNetworkingReachabilityDidChangeNotification Action:@selector(noteNetworkStatus:) Own:self];

    [JL_Tools add:UIApplicationWillEnterForegroundNotification Action:@selector(noteAppForeground:) Own:self];
    [JL_Tools add:AVAudioSessionInterruptionNotification Action:@selector(noteInterruption:) Own:self];

    [JL_Tools add:kJL_MANAGER_FIND_DEVICE Action:@selector(cancelVoiceNote:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)noteInterruption:(NSNotification*)note{
    [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mFindDeviceManager cmdFindDevice:NO timeOut:60 findIphone:NO Operation:nil];
    [DFAction timingPause:voiceTimer];
}
-(void)cancelVoiceNote:(NSNotification *)note{
    NSDictionary *dict = note.object;
    if ([dict[@"op"] intValue] == 0) {
        [self stopSearch];
    }
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeSomethingConnected ||
        type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeBleOFF) {
        [self stopSearch];
        
    }
    
    if (type == JLDeviceChangeTypeBleOFF ||
        type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeConnectedOffline) {
        self->leftLabel.text = kJL_TXT("device_status_unconnected");
        self->leftLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
        self->playSoundLeftLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
        
        self->rightLabel.text = kJL_TXT("device_status_unconnected");
        self->rightLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
        self->playSoundRightLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
        
        [self leftBtnAction:nil];
        //[self initWithUI];
    }
}

#pragma mark 根据电量显示铃声的UI
-(void)showSoundUI{
    if(self.deviceObjc.type == JL_DeviceTypeTWS){
        JLUuidType uuidType = [JL_RunSDK getStatusUUID:self.deviceObjc.uuid];
        if (uuidType == JLUuidTypeDisconnected||
            uuidType == JLUuidTypeConnected) {
            
            self->leftLabel.text = kJL_TXT("device_status_unconnected");
            self->leftLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
            self->playSoundLeftLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
            
            self->rightLabel.text = kJL_TXT("device_status_unconnected");
            self->rightLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
            self->playSoundRightLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
            
        }else if(uuidType == JLUuidTypeInUse){
            if(entity.mPower_L > 0){
                self->leftLabel.text = kJL_TXT("device_status_connected");
                self->leftLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                self->playSoundLeftLabel.textColor = kColor_0000;
            }
            if(entity.mPower_L == 0){
                self->leftLabel.text = kJL_TXT("device_status_unconnected");
                self->leftLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
                self->playSoundLeftLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
            }
            if(entity.mPower_R >0){
                self->rightLabel.text = kJL_TXT("device_status_connected");
                self->rightLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                self->playSoundRightLabel.textColor = kColor_0000;
            }
            if(entity.mPower_R == 0){
                self->rightLabel.text = kJL_TXT("device_status_unconnected");
                self->rightLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
                self->playSoundRightLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
            }
        }
    }
}

#pragma mark 处理底部UI逻辑
-(void)handleBottomViewUI:(NSArray *) array{

    if((array.count==2  && [array containsObject:@(1)] //全部播放
        && [array containsObject:@(2)]) && self->entity.mPower_L>0 && self->entity.mPower_R>0){
        
        bottomVoicesLeftView.backgroundColor = kColor_0000;
        leftLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        playSoundLeftLabel.hidden = YES;
        leftVolImv.hidden = NO;
        
        bottomVoicesRightView.backgroundColor = kColor_0000;
        rightLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        playSoundRightLabel.hidden = YES;
        rightVolImv.hidden = NO;
        
    }
    if(type == 1 && self->entity.mPower_L>0){ //左耳播放
        if(playSoundLeftLabel.hidden == NO){
            bottomVoicesLeftView.backgroundColor = kColor_0000;
            leftLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
            playSoundLeftLabel.hidden = YES;
            leftVolImv.hidden = NO;
        }
    }
    if(type == 2 && self->entity.mPower_R>0){ //右耳播放
        if(playSoundRightLabel.hidden == NO){
            bottomVoicesRightView.backgroundColor = kColor_0000;
            rightLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
            playSoundRightLabel.hidden = YES;
            rightVolImv.hidden = NO;
        }
    }
}



#pragma mark 显示播放铃声的UI
-(void)showPlaySoundUI{
    NSSet *set = [NSSet setWithArray:playWayArray];//arr为需要去除重复的数组
    NSArray *playWayArray = [NSArray new];
    playWayArray = [set allObjects];//得到去除重复元素后的数组
    [self handleBottomViewUI:playWayArray];
}

#pragma mark ///查找设备相关
-(void)startVoice{
    AudioServicesPlaySystemSoundWithCompletion(1304, nil);
}

-(void)startSearch{
    /*--- 判断有无连经典蓝牙 ---*/
    NSDictionary *info = [JL_BLEMultiple outputEdrInfo];
    NSString *addr = info[@"ADDRESS"];
    
    //JL_Entity *entity = [[JL_BLEUsage sharedMe] bt_Entity];
    NSString *edr = self.deviceObjc.edr;
    if (![addr isEqualToString:edr]) {
        [DFUITools showText:kJL_TXT("first_connect_device") onView:self.view delay:1.0];
        return ;
    }
    
    if(self.deviceObjc.type == JL_DeviceTypeSoundBox || self.deviceObjc.type == JL_DeviceTypeSoundCard){
        [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mFindDeviceManager cmdFindDevice:YES timeOut:60 findIphone:NO Operation:nil];
    }
    
    if(self.deviceObjc.type == JL_DeviceTypeTWS){
        // 播放方式 way: 0  全部播放
        //             1  左侧播放
        //             2  右侧播放
        // 播放源 player: 0 APP端播放
        //               1 设备端播放
        // opDict：{@"way":@"0",@"player":@"0"}
        NSDictionary *dictWay;
        if(playWayArray.count==2  && [playWayArray containsObject:@(1)] //全部播放
           && [playWayArray containsObject:@(2)]){
            dictWay= @{@"way":@"0",@"player":@"0"};
        }
        if(playWayArray.count==1  && [playWayArray containsObject:@(1)]) {//左侧播放
            dictWay= @{@"way":@"1",@"player":@"0"};
        }
        if(playWayArray.count==1  && [playWayArray containsObject:@(2)]) {//右侧播放
            dictWay= @{@"way":@"2",@"player":@"0"};
        }
        
        //发送当前命令给固件
        [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mFindDeviceManager cmdFindDevice:YES timeOut:60 findIphone:NO Operation:dictWay];
        //请求当前的位置
        [self findDevice];
        [self showSoundUI];
        [self showPlaySoundUI];
    }
    
   
    
    if (voiceTimer == nil) {
        voiceTimer = [NSTimer scheduledTimerWithTimeInterval:1.8 target:self selector:@selector(startVoice) userInfo:nil repeats:YES];
    }else{
        [DFAction timingContinue:voiceTimer];
    }
    [self bigOrSmallVoice:YES];
}
-(void)stopSearch{
    [self bigOrSmallVoice:NO];
    [DFAction timingPause:voiceTimer];
}
-(void)bigOrSmallVoice:(BOOL)status{
    soundStatus = status;
    if (normalVoice == 0 || voiceTimer == nil)return;
    float k = normalVoice;
    UISlider *volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    if (status == YES) {
        normalVoice =  volumeViewSlider.value;
        k = 1.0;
    }else{
        k = normalVoice;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // change system volume, the value is between 0.0f and 1.0f
        [volumeViewSlider setValue:k animated:YES];
        // send UI control event to make the change effect right now. 立即生效
        [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
}

#pragma mark ///tipsViewDelegate
-(void)voiceDidSelectWith:(NSInteger)index{
    [tipsView removeFromSuperview];

    if (index == 1) {
        if(self.deviceObjc.type == JL_DeviceTypeTWS && tipsView.hidden == NO){

            if(type == 1){ //左耳
                if(playSoundRightLabel.hidden==NO && (playWayArray.count==1 &&[playWayArray containsObject:@(2)])){
                    [playWayArray removeObject:@(2)];
                }
                [playWayArray addObject:@(1)];
            }
            if(type == 2){ //右耳
                if(playSoundLeftLabel.hidden==NO && (playWayArray.count==1 &&[playWayArray containsObject:@(1)])){
                    [playWayArray removeObject:@(1)];
                }
                [playWayArray addObject:@(2)];
            }
        }
        [self startSearch];
    }
    
    if(index == 0){
        if(self.deviceObjc.type == JL_DeviceTypeTWS){
            if(type == 1){
                if(playSoundLeftLabel.hidden == YES){
                    bottomVoicesLeftView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                    leftLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                    playSoundLeftLabel.hidden = NO;
                    leftVolImv.hidden = YES;
                }
            }
            if(type == 2){
                if(playSoundRightLabel.hidden == YES){
                    bottomVoicesRightView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                    rightLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                    playSoundRightLabel.hidden = NO;
                    rightVolImv.hidden = YES;
                }
            }
        }
    }
}

#pragma mark ///地图相关信息

/// 逆地理位置信息
/// @param coordinate 地理坐标
-(void)calcuteWithLocation:(CLLocationCoordinate2D)coordinate{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location                    = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension            = YES;
    [search AMapReGoecodeSearch:regeo];
}

/// 计算距离
/// @param coordinate_0 设备位置坐标
/// @param coordinate_1 用户位置坐标
-(void)calcuteWithDistance:(CLLocationCoordinate2D)coordinate_0 with:(CLLocationCoordinate2D)coordinate_1{
    MAMapPoint p1 = MAMapPointForCoordinate(coordinate_0);
    MAMapPoint p2 = MAMapPointForCoordinate(coordinate_1);
    CLLocationDistance distance =  MAMetersBetweenMapPoints(p1, p2);
    float distance_1 = distance/1000;
    distanceLab.text = [NSString stringWithFormat:@"%.1f%@",distance_1,kJL_TXT("km")];
}

/// 时间设置
/// @param date 设备时间
-(NSString *)timeFromNow:(NSDate *)date Type:(int) type{
    NSDate *nowDate = [NSDate new];
    NSTimeInterval d1 = [nowDate timeIntervalSince1970];
    NSTimeInterval d2 = [date timeIntervalSince1970];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    NSString *str;
    if(type == 0){
        if ((d1-d2)>=86400) {
            str = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("昨天"),[formatter stringFromDate:date],kJL_TXT("min")];
            if ((d1-d2) >= 86400*2){
                str = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("前天"),[formatter stringFromDate:date],kJL_TXT("min")];
                if ((d1-d2) >= 86400*3){
                    str = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("两天前"),[formatter stringFromDate:date],kJL_TXT("min")];
                    if ((d1-d2) >= 86400*4){
                        formatter.dateFormat = @"yyyy-MM-DD HH:mm";
                        str = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
                    }
                }
            }
        }else{
            if([kJL_GET hasPrefix:@"zh"]){
                str = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("today"),[formatter stringFromDate:date],kJL_TXT("min")];
            }else{
                str = [NSString stringWithFormat:@"%@ %@ %@",kJL_TXT("today"),[formatter stringFromDate:date],kJL_TXT("min")];
            }
        }
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        if (bleSDK.mBleMultiple.bleManagerState == CBManagerStatePoweredOn) {
            if([kJL_GET hasPrefix:@"zh"]){
                str = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("today"),[formatter stringFromDate:nowDate],kJL_TXT("min")];
            }else{
                str = [NSString stringWithFormat:@"%@ %@ %@",kJL_TXT("today"),[formatter stringFromDate:nowDate],kJL_TXT("min")];
            }
        }
    }
    if(type == 1){
        if ((d1-d2)>=86400) {
            str = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("昨天"),[formatter stringFromDate:date],kJL_TXT("min")];
            if ((d1-d2) >= 86400*2){
                str = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("前天"),[formatter stringFromDate:date],kJL_TXT("min")];
                if ((d1-d2) >= 86400*3){
                    str = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("两天前"),[formatter stringFromDate:date],kJL_TXT("min")];
                    if ((d1-d2) >= 86400*4){
                        formatter.dateFormat = @"yyyy-MM-DD HH:mm";
                        str = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
                    }
                }
            }
        }else{
            if([kJL_GET hasPrefix:@"zh"]){
                str = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("today"),[formatter stringFromDate:date],kJL_TXT("min")];
            }else{
                str = [NSString stringWithFormat:@"%@ %@ %@",kJL_TXT("today"),[formatter stringFromDate:date],kJL_TXT("min")];
            }
        }
    }
    return str;
}

#pragma mark /// 地图Delegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"customReuseIndetifier";
        
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:reuseIndetifier];
        }
        NSNumber *lat = [NSNumber numberWithDouble:annotation.coordinate.latitude];
        NSNumber *lon = [NSNumber numberWithDouble:annotation.coordinate.longitude];
        NSDictionary *userLocation=@{@"lat":lat?:@"",@"long":lon?:@""};
        
        if(self.deviceObjc.type == JL_DeviceTypeSoundBox || self.deviceObjc.type == JL_DeviceTypeSoundCard){
            for (NSString *key in pointDict) {
                NSDictionary *dict = pointDict[key];
                if ([dict[@"lat"] isEqual:userLocation[@"lat"]] && [dict[@"long"] isEqual:userLocation[@"long"]]) {
                    DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:key];
                    if (objc.type == JL_DeviceTypeSoundBox) {//0为音箱
                        annotationView.image = [UIImage imageNamed:@"Theme.bundle/search_img_speaker"];
                    }
                }
            }
            annotationView.frame = CGRectMake(-27, -27, 54, 54);
            annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        }
        
        if(self.deviceObjc.type == JL_DeviceTypeTWS){ //耳机
            
            if (self.deviceObjc.mProtocolType == PTLVersion) {//挂脖耳机特殊处理
                for (NSString *key in pointDict) {
                    NSDictionary *dict = pointDict[key];
                    if ([dict[@"lat"] isEqual:userLocation[@"lat"]] && [dict[@"long"] isEqual:userLocation[@"long"]]) {
                        DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:key];
                        if (objc.type == JL_DeviceTypeTWS) {//1为耳机
                            annotationView.image = [UIImage imageNamed:@"Theme.bundle/search_my_earphone_03"];
                        }
                    }
                }
                annotationView.frame = CGRectMake(-27, -27, 54, 54);
                annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
                return annotationView;
            }
                
            
            if(entity.mPower_L>0 && entity.mPower_R>0){ //左右耳有电量，显示一对耳机的位置
                for (NSString *key in pointDict) {
                    NSDictionary *dict = pointDict[key];
                    if ([dict[@"lat"] isEqual:userLocation[@"lat"]] && [dict[@"long"] isEqual:userLocation[@"long"]]) {
                        DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:key];
                        if (objc.type == JL_DeviceTypeTWS) {//1为耳机
                            if([vidStr isEqualToString:@"32"] && [pidStr isEqualToString:@"158"]){
                                annotationView.image = [UIImage imageNamed:@"search_my_earphone2"];
                            }else{
                                annotationView.image = [UIImage imageNamed:@"Theme.bundle/search_my_earphone"];
                            }
                        }
                    }
                }
                annotationView.frame = CGRectMake(-27, -27, 54, 54);
                annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
            }
            
            if(entity.mPower_L>0 && entity.mPower_R == 0){ //左耳有电量，右耳电量为0(断连)
                for (NSString *key in pointLeftDict) {
                    NSDictionary *dict = pointLeftDict[key];
                    if ([dict[@"lat"] isEqual:userLocation[@"lat"]] && [dict[@"long"] isEqual:userLocation[@"long"]]) {
                        int index = (int)[annotations indexOfObject:annotation];
                        if([vidStr isEqualToString:@"32"] && [pidStr isEqualToString:@"158"]){
                            annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"searcch_my_earphone_%d",index]];
                        }else{
                            annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Theme.bundle/searcch__earphone_%d",index]];
                        }
                    }
                }
                for (NSString *key in pointRightDict) {
                    NSDictionary *dict = pointRightDict[key];
                    if ([dict[@"lat"] isEqual:userLocation[@"lat"]] && [dict[@"long"] isEqual:userLocation[@"long"]]) {
                        int index = (int)[annotations indexOfObject:annotation];
                        if([vidStr isEqualToString:@"32"] && [pidStr isEqualToString:@"158"]){
                            annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"searcch_my_earphone_%d",index]];
                        }else{
                            annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Theme.bundle/searcch__earphone_%d",index]];
                        }
                    }
                }
                annotationView.frame = CGRectMake(-27, -27, 54, 54);
                annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
            }
            
            if(entity.mPower_R>0 && entity.mPower_L == 0){ //右耳有电量，左耳电量为0(断连)
                for (NSString *key in pointLeftDict) {
                    NSDictionary *dict = pointLeftDict[key];
                    if ([dict[@"lat"] isEqual:userLocation[@"lat"]] && [dict[@"long"] isEqual:userLocation[@"long"]]) {
                        int index = (int)[annotations indexOfObject:annotation];
                        if([vidStr isEqualToString:@"32"] && [pidStr isEqualToString:@"158"]){
                            annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"searcch_my_earphone_%d",index]];
                        }else{
                            annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Theme.bundle/searcch__earphone_%d",index]];
                        }
                    }
                }
                for (NSString *key in pointRightDict) {
                    NSDictionary *dict = pointRightDict[key];
                    if ([dict[@"lat"] isEqual:userLocation[@"lat"]] && [dict[@"long"] isEqual:userLocation[@"long"]]) {
                        int index = (int)[annotations indexOfObject:annotation];
                        if([vidStr isEqualToString:@"32"] && [pidStr isEqualToString:@"158"]){
                            annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"searcch_my_earphone_%d",index]];
                        }else{
                            annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Theme.bundle/searcch__earphone_%d",index]];
                        }
                    }
                }
                annotationView.frame = CGRectMake(-27, -27, 54, 54);
                annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
            }
        }
        
        if(self.deviceObjc.type == JL_DeviceTypeSoundCard){ //声卡
            for (NSString *key in pointDict) {
                NSDictionary *dict = pointDict[key];
                if ([dict[@"lat"] isEqual:userLocation[@"lat"]] && [dict[@"long"] isEqual:userLocation[@"long"]]) {
                    DeviceObjc *objc = [[SqliteManager sharedInstance] checkoutByUuid:key];
                    if (objc.type == JL_DeviceTypeSoundCard) {
                        annotationView.image = [UIImage imageNamed:@"Theme.bundle/search_img_mic"];
                    }
                }
            }
            annotationView.frame = CGRectMake(-27, -27, 54, 54);
            annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        }
        return annotationView;
    }
    return nil;
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (updatingLocation) {
        [self calcuteWithLocation:userLocation.location.coordinate];
    }
}
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MAAnnotationView *view in views) {
        // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
        if ([view.annotation isKindOfClass:[MAUserLocation class]])
        {
            MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
            r.showsAccuracyRing = YES;
            r.showsHeadingIndicator = NO;
            r.fillColor = [UIColor colorWithRed:64.0/255.0 green:106.0/255.0 blue:192.0/255.0 alpha:0.2];///精度圈 填充颜色, 默认 kAccuracyCircleDefaultColor
            r.image = [UIImage imageNamed:@"Theme.bundle/search_icon_location_02"];
            [mapView updateUserLocationRepresentation:r];
        }
    }
    
    
}

-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    
    [locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        [self calcuteWithDistance:location.coordinate with:view.annotation.coordinate];
        [self calcuteWithLocation:location.coordinate];
    }];
    
}
-(void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager{
    [locationManager requestAlwaysAuthorization];
}


#pragma mark ///逆地理编码
-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    if (response.regeocode != nil)
    {
        //解析response获取地址描述，具体解析见 Demo
        //        AMapAddressComponent *add = response.regeocode.addressComponent;
        //        NSString *k = [response.regeocode.formattedAddress stringByReplacingOccurrencesOfString:add.province withString:@""];
        //        k = [k stringByReplacingOccurrencesOfString:add.city withString:@""];
        locationLab.text = response.regeocode.formattedAddress;
    }
    
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

//#pragma mark ///回调Location
//-(void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode{
//    if ([[JL_BLEUsage sharedMe] bt_status_connect]) {
//        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
//        pointAnnotation.coordinate = location.coordinate;
//        pointAnnotation.title = @"last_location_now";
//        [mapView addAnnotation:pointAnnotation];
//        [mapView setCenterCoordinate:pointAnnotation.coordinate animated:YES];
//    }
//}

#pragma mark 加载耳机底部查找设备的UI
-(void)initBottomViews{
    if(self.deviceObjc.type == JL_DeviceTypeSoundBox || self.deviceObjc.type == JL_DeviceTypeSoundCard ){
        searchBtn.hidden = NO;
        closeVoiceBtn.hidden = NO;
    }
    //增加挂脖耳机处理
    if (self.deviceObjc.type == JL_DeviceTypeTWS && self.deviceObjc.mProtocolType == PTLVersion ) {
        searchBtn.hidden = NO;
        closeVoiceBtn.hidden = NO;
    }
    
    if(self.deviceObjc.type == JL_DeviceTypeTWS && self.deviceObjc.mProtocolType != PTLVersion ){ //1:耳机
        searchBtn.hidden = YES;
        closeVoiceBtn.hidden = YES;
        
        bottomView.backgroundColor = [UIColor colorWithRed:248/255.0 green:250/255.0 blue:252/255.0 alpha:1.0];
        
        UIView *bottomsVociesView = [[UIView alloc] init];
        bottomsVociesView.frame = CGRectMake(24,[UIScreen mainScreen].bounds.size.height-115-28,[UIScreen mainScreen].bounds.size.width-24*2,115);
        bottomsVociesView.backgroundColor = [UIColor colorWithRed:248/255.0 green:250/255.0 blue:252/255.0 alpha:1.0];
        [self.view addSubview:bottomsVociesView];
        
        bottomVoicesLeftView = [[UIView alloc] init];
        bottomVoicesLeftView.frame = CGRectMake(0,0,([UIScreen mainScreen].bounds.size.width-24*2-17)/2,115);
        bottomVoicesLeftView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        bottomVoicesLeftView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:25/255.0 blue:58/255.0 alpha:0.15].CGColor;
        bottomVoicesLeftView.layer.shadowOffset = CGSizeMake(0,0);
        bottomVoicesLeftView.layer.shadowOpacity = 1;
        bottomVoicesLeftView.layer.shadowRadius = 30;
        bottomVoicesLeftView.layer.cornerRadius = 14;
        [bottomsVociesView addSubview:bottomVoicesLeftView];
        
        UIButton *bottomVoicesLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,([UIScreen mainScreen].bounds.size.width-24*2-17)/2,115)];
        [bottomVoicesLeftBtn addTarget:self action:@selector(leftEvent:) forControlEvents:UIControlEventTouchUpInside];
        [bottomsVociesView addSubview:bottomVoicesLeftBtn];

        bottomVoicesRightView = [[UIView alloc] init];
        bottomVoicesRightView.frame = CGRectMake(bottomVoicesLeftView.frame.origin.x+bottomVoicesLeftView.frame.size.width+17,0,([UIScreen mainScreen].bounds.size.width-24*2-17)/2,115);
        bottomVoicesRightView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        bottomVoicesRightView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:25/255.0 blue:58/255.0 alpha:0.15].CGColor;
        bottomVoicesRightView.layer.shadowOffset = CGSizeMake(0,0);
        bottomVoicesRightView.layer.shadowOpacity = 1;
        bottomVoicesRightView.layer.shadowRadius = 30;
        bottomVoicesRightView.layer.cornerRadius = 14;
        [bottomsVociesView addSubview:bottomVoicesRightView];
        
        UIButton *bottomVoicesRightBtn = [[UIButton alloc] initWithFrame:CGRectMake(bottomVoicesLeftView.frame.origin.x+bottomVoicesLeftView.frame.size.width+17,0,([UIScreen mainScreen].bounds.size.width-24*2-17)/2,115)];
        [bottomVoicesRightBtn addTarget:self action:@selector(rightEvent:) forControlEvents:UIControlEventTouchUpInside];
        [bottomsVociesView addSubview:bottomVoicesRightBtn];
        
        //左耳
        leftLabel = [[UILabel alloc] init];
        leftLabel.frame = CGRectMake(18.5,33.5,100,14);
        leftLabel.numberOfLines = 0;
        leftLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
        [bottomVoicesLeftView addSubview:leftLabel];

        NSMutableAttributedString *leftLabelStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("device_status_connected") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];

        leftLabel.attributedText = leftLabelStr;
        
        playSoundLeftLabel = [[UILabel alloc] init];
        playSoundLeftLabel.frame = CGRectMake(17.5,59.5,100,20);
        playSoundLeftLabel.numberOfLines = 0;
        [bottomVoicesLeftView addSubview:playSoundLeftLabel];
        playSoundLeftLabel.hidden = NO;

        NSMutableAttributedString *playSoundLeftStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("play_sound") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 15],NSForegroundColorAttributeName: kColor_0000}];

        playSoundLeftLabel.attributedText = playSoundLeftStr;
        
        UIImageView *leftImv = [[UIImageView alloc] init];
        leftImv.frame = CGRectMake(bottomVoicesLeftView.frame.size.width-15-45,8,46,87);
        //leftImv.image =  [UIImage imageNamed:@"Theme.bundle/img_earphone_left"];
        [self setImageView:leftImv DeviceUuid:self.deviceObjc.uuid Image:@"LEFT_DEVICE_CONNECTED" Default:@"product_img_earphone_02"];
        leftImv.contentMode = UIViewContentModeScaleToFill;
        [bottomVoicesLeftView addSubview:leftImv];
        
        leftVolImv = [[UIImageView alloc] init];
        leftVolImv.frame = CGRectMake(18,60,22,22);
        leftVolImv.image =  [UIImage imageNamed:@"Theme.bundle/icon_sound_nol"];
        leftVolImv.contentMode = UIViewContentModeScaleToFill;
        [bottomVoicesLeftView addSubview:leftVolImv];
        leftVolImv.hidden = YES;
        
        //右耳
        rightLabel = [[UILabel alloc] init];
        rightLabel.frame = CGRectMake(18.5,33.5,100,14);
        rightLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
        rightLabel.numberOfLines = 0;
        [bottomVoicesRightView addSubview:rightLabel];

        NSMutableAttributedString *rightLabelStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("device_status_connected") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];

        rightLabel.attributedText = rightLabelStr;
        
        playSoundRightLabel = [[UILabel alloc] init];
        playSoundRightLabel.frame = CGRectMake(17.5,59.5,100,20);
        playSoundRightLabel.numberOfLines = 0;
        [bottomVoicesRightView addSubview:playSoundRightLabel];
        playSoundRightLabel.hidden = NO;

        NSMutableAttributedString *playSoundRightStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("play_sound") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 15],NSForegroundColorAttributeName: kColor_0000}];

        playSoundRightLabel.attributedText = playSoundRightStr;
        
        UIImageView *rightImv = [[UIImageView alloc] init];
        rightImv.frame = CGRectMake(bottomVoicesRightView.frame.size.width-15-45,8,46,87);
        //rightImv.image =  [UIImage imageNamed:@"Theme.bundle/img_earphone_right"];
        [self setImageView:rightImv DeviceUuid:self.deviceObjc.uuid Image:@"RIGHT_DEVICE_CONNECTED" Default:@"product_img_earphone_01"];
        rightImv.contentMode = UIViewContentModeScaleToFill;
        [bottomVoicesRightView addSubview:rightImv];
        
        rightVolImv = [[UIImageView alloc] init];
        rightVolImv.frame = CGRectMake(18,60,22,22);
        rightVolImv.image =  [UIImage imageNamed:@"Theme.bundle/icon_sound_nol"];
        rightVolImv.contentMode = UIViewContentModeScaleToFill;
        [bottomVoicesRightView addSubview:rightVolImv];
        rightVolImv.hidden = YES;
    }
}


#pragma mark 处理左耳点击事件
-(void)leftEvent:(UITapGestureRecognizer *)gesture
{
    type = 1;

    BOOL isOK = [DFAction setMinExecutionGap:0.2];
    if (isOK == NO) return;
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLUuidType uuidType = [JL_RunSDK getStatusUUID:self.deviceObjc.uuid];
    if (uuidType == JLUuidTypeDisconnected
        || uuidType == JLUuidTypeConnected) {
        [DFUITools showText:kJL_TXT("left_cannot_found") onView:self.view delay:1.0];
        return;
    }else if(uuidType == JLUuidTypeInUse){
        if(entity.mPower_R > 0 && entity.mPower_L == 0){
            [self->mapView setCenterCoordinate:deviceLeftLocation animated:YES];
            
            lastTime.text = [self timeFromNow:[NSDate new] Type:0];
            
            NSNumber *lat = [NSNumber numberWithDouble:deviceLeftLocation.latitude];
            NSNumber *lon = [NSNumber numberWithDouble:deviceLeftLocation.longitude];
            NSDictionary *leftUserLocation=@{@"lat":lat?:@"",@"long":lon?:@""};
            NSData *leftdata = [NSKeyedArchiver archivedDataWithRootObject:leftUserLocation];
            [[MapLocationRequest shareInstanced] requestGeoCodeAddress:leftdata block:^(NSData * _Nonnull data, NSString * _Nonnull address) {
                self->locationLab.text = address;
            }];
            
            return;
        }
    }
   
    if(playSoundLeftLabel.hidden == NO){
        [self searchDeviceBtnAction:nil];
        return;
    }
    if(playSoundLeftLabel.hidden == YES){
        bottomVoicesLeftView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        leftLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
        playSoundLeftLabel.hidden = NO;
        playSoundLeftLabel.textColor = kColor_0000;
        leftVolImv.hidden = YES;
        
        NSDictionary *dictWay;
        if(playWayArray.count==2  && [playWayArray containsObject:@(1)] //全部播放
           && [playWayArray containsObject:@(2)] && self->entity.mPower_L>0 && self->entity.mPower_R>0){
            //左右耳同时播放，点击左耳关闭声音，就发打开右耳声音的命令
            dictWay= @{@"way":@"2",@"player":@"0"};
            [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mFindDeviceManager cmdFindDevice:YES timeOut:60 findIphone:NO Operation:dictWay];
        }
        if((playWayArray.count==1  && [playWayArray containsObject:@(1)])
           ||(playWayArray.count == 2 && self->entity.mPower_L>0 && self->entity.mPower_R==0)) {//左侧播放
            //仅左耳播放，就发关闭声音的命令
            [self stopVoiceBtnAction:nil];
        }
        //[self stopVoiceBtnAction:nil];
        [playWayArray removeObject:@(1)];
    }
}

#pragma mark 处理右耳点击事件
-(void)rightEvent:(UITapGestureRecognizer *)gesture
{
    type = 2;

    BOOL isOK = [DFAction setMinExecutionGap:0.2];
    if (isOK == NO) return;
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLUuidType uuidType = [JL_RunSDK getStatusUUID:self.deviceObjc.uuid];
    if (uuidType == JLUuidTypeDisconnected
        || uuidType == JLUuidTypeConnected) {
        [DFUITools showText:kJL_TXT("right_cannot_found") onView:self.view delay:1.0];
        return;
    }
    else if(uuidType == JLUuidTypeInUse){
        if(entity.mPower_L > 0 && entity.mPower_R == 0){
            [self->mapView setCenterCoordinate:deviceRightLocation animated:YES];
            
            lastTime.text = [self timeFromNow:[NSDate new] Type:0];
            
            NSNumber *lat = [NSNumber numberWithDouble:deviceRightLocation.latitude];
            NSNumber *lon = [NSNumber numberWithDouble:deviceRightLocation.longitude];
            NSDictionary *rightUserLocation=@{@"lat":lat?:@"",@"long":lon?:@""};
            NSData *rightdata = [NSKeyedArchiver archivedDataWithRootObject:rightUserLocation];
            [[MapLocationRequest shareInstanced] requestGeoCodeAddress:rightdata block:^(NSData * _Nonnull data, NSString * _Nonnull address) {
                self->locationLab.text = address;
            }];
            return;
        }
    }

    if(playSoundRightLabel.hidden == NO){
        [self searchDeviceBtnAction:nil];
        return;
    }
    if(playSoundRightLabel.hidden == YES){
        bottomVoicesRightView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        rightLabel.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
        playSoundRightLabel.hidden = NO;
        playSoundRightLabel.textColor = kColor_0000;
        rightVolImv.hidden = YES;
        
        NSDictionary *dictWay;
        if(playWayArray.count==2  && [playWayArray containsObject:@(1)] //全部播放
           && [playWayArray containsObject:@(2)] && self->entity.mPower_L>0 && self->entity.mPower_R>0){
            //左右耳同时播放，点击右耳关闭声音，就发打开左耳声音的命令
            dictWay= @{@"way":@"1",@"player":@"0"};
            [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mFindDeviceManager cmdFindDevice:YES timeOut:60 findIphone:NO Operation:dictWay];
        }
        if((playWayArray.count==1  && [playWayArray containsObject:@(2)])
           ||(playWayArray.count == 2 && self->entity.mPower_L==0 && self->entity.mPower_R>0)) {//右侧播放
            //仅右耳播放，就发关闭声音的命令
            [self stopVoiceBtnAction:nil];
        }
        //[self stopVoiceBtnAction:nil];
        [playWayArray removeObject:@(2)];
    }
}

-(void)setImageView:(UIImageView*)imageView
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


@end
