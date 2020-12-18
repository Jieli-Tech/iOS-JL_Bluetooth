//
//  JL_RunSDK.m
//  JL_BLE_TEST
//
//  Created by DFung on 2018/11/26.
//  Copyright © 2018 www.zh-jieli.com. All rights reserved.
//

#import "JL_RunSDK.h"
#import "JLUI_Cache.h"
#import "EQDefaultCache.h"

#import "JLPreparation.h"

NSString *kUI_JL_SHOW_ID3               = @"UI_JL_SHOW_ID3";
NSString *kUI_JL_CARD_MUSIC_INFO        = @"UI_JL_CARD_MUSIC_INFO";
NSString *kUI_JL_LINEIN_INFO            = @"UI_JL_LINEIN_INFO";
NSString *kUI_JL_FM_INFO                = @"UI_JL_FM_INFO";

NSString *kUI_JL_DEVICE_SHOW_OTA        = @"UI_JL_DEVICE_SHOW_OTA";
NSString *kUI_JL_DEVICE_CHANGE          = @"UI_JL_DEVICE_CHANGE";
NSString *kUI_JL_DEVICE_PREPARING       = @"UI_JL_DEVICE_PREPARING";

NSString *kUI_JL_BLE_SCAN_OPEN          = @"UI_JL_BLE_SCAN_OPEN";
NSString *kUI_JL_BLE_SCAN_CLOSE         = @"UI_JL_BLE_SCAN_CLOSE";

@interface JL_RunSDK(){
    NSTimer         *scanTimer;
    NSTimer         *preparateTimer;
    NSMutableArray  *preparationArr;
    NSMutableArray  *linkedUuidArr;
}
@end

@implementation JL_RunSDK

static JL_RunSDK *SDK = nil;
+(id)sharedMe{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        SDK = [[self alloc] init];
    });
    return SDK;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        preparationArr = [NSMutableArray new];
        linkedUuidArr  = [NSMutableArray new];
        
        [[EQDefaultCache sharedInstance] normalSetting];

        /*--- 初始化JL_SDK ---*/
        self.mBleMultiple = [[JL_BLEMultiple alloc] init];
        self.mBleMultiple.BLE_FILTER_ENABLE = YES;
        self.mBleMultiple.BLE_PAIR_ENABLE = YES;
        self.mBleMultiple.BLE_TIMEOUT = 7;

        /*--- 开启蓝牙【搜索】【弹窗】 ---*/
        [self noteBleScanOpen:nil];

        [self addNote];
    }
    return self;
}

+(void)setActiveUUID:(NSString*)uuid{
    if (SDK.mBleEntityM.mCmdManager) {
        [SDK.mBleEntityM.mCmdManager cmdID3_PushEnable:YES];
    }
    if (SDK.mBleUUID) [SDK addLinkedArrayUuid:SDK.mBleUUID];
    
    [SDK changeUUID:uuid];
    [JL_Tools post:kUI_JL_DEVICE_CHANGE Object:@(JLDeviceChangeTypeManualChange)];
}


+(JLUuidType)getStatusUUID:(NSString*)uuid{
    if ([uuid isEqual:SDK.mBleUUID]) {
        return 2;
    }
    NSMutableArray *mConnectArr = SDK.mBleMultiple.bleConnectedArr;
    for (JL_EntityM *entity in mConnectArr) {
        NSString *inUnid = entity.mPeripheral.identifier.UUIDString;
        if ([uuid isEqual:inUnid]) {
            if (entity.mBLE_NEED_OTA == YES) {
                return 3;
            }else if(entity.isCMD_PREPARED == NO){
                return 4;
            }else{
                return 1;
            }
        }
    }
    return 0;
}

+(NSString *)textEntityStatus:(JL_EntityM_Status)status{
    if (status<0) return @"未知错误";
    NSArray *arr = @[kJL_TXT("蓝牙未开启"),kJL_TXT("连接失败"),kJL_TXT("正在连接"),kJL_TXT("重复连接"),
                     kJL_TXT("连接超时"),kJL_TXT("被拒绝"),kJL_TXT("配对失败"),kJL_TXT("配对超时"),kJL_TXT("已配对"),
                     kJL_TXT("正在主从切换"),kJL_TXT("断开成功"),kJL_TXT("请打开蓝牙")];
    if (status+1 <= arr.count) {
        return arr[status];
    }else{
        return @"未知错误";
    }
}

+(JL_EntityM*)getEntity:(NSString*)uuid{
    NSMutableArray *mConnectArr = SDK.mBleMultiple.bleConnectedArr;
    for (JL_EntityM *entity in mConnectArr) {
        NSString *inUnid = entity.mPeripheral.identifier.UUIDString;
        if ([uuid isEqual:inUnid]) {
            return entity;
        }
    }
    return nil;
}

+(BOOL)isCurrentDeviceCmd:(NSNotification*)note{
    NSDictionary *dict = note.object;
    NSString *uuid = dict[kJL_MANAGER_KEY_UUID];
    JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
    if (type == JLUuidTypeInUse) {
        return YES;
    }
    return NO;
}

+(NSArray*)getLinkedArray{
    return SDK->linkedUuidArr;
}


#pragma mark -
-(void)changeUUID:(NSString*)uuid{
    
    NSMutableArray *mConnectArr = SDK.mBleMultiple.bleConnectedArr;
    for (JL_EntityM *entity in mConnectArr) {
        NSString *inUnid = entity.mPeripheral.identifier.UUIDString;
        if ([uuid isEqual:inUnid] &&
            entity.mBLE_NEED_OTA == NO &&
            entity.isCMD_PREPARED== YES)
        {
            SDK.mBleEntityM = entity;
            SDK.mBleUUID = uuid;
            
            [linkedUuidArr removeObject:uuid];
            break;
        }
    }
}

#pragma mark 设备被连接
-(void)noteEntityConnected:(NSNotification*)note{
    CBPeripheral *pl = [note object];
    NSString *uuid = pl.identifier.UUIDString;
    
    /*--- 已连接的设备预处理 ---*/
    JLPreparation *preparation = [JLPreparation new];
    preparation.mBleEntityM    = [JL_RunSDK getEntity:uuid];
    preparation.mBleUUID       = uuid;
    preparation.isPreparateOK  = 0;
    [preparationArr addObject:preparation];
    
    [self startPreparation];
}

-(void)noteUuidPreparateOk:(NSNotification*)note{
    NSString *uuid = note.object;
    JL_EntityM *entity = [JL_RunSDK getEntity:uuid];

    if (SDK.mBleUUID && entity.mBLE_NEED_OTA == NO) {
        [SDK addLinkedArrayUuid:SDK.mBleUUID];
    }

    [self changeUUID:uuid];
    [JL_Tools post:kUI_JL_DEVICE_CHANGE Object:@(JLDeviceChangeTypeSomethingConnected)];
    
    /*--- 需要OTA升级的设备 ---*/
    if (entity.mBLE_NEED_OTA) {
        [self noteBleScanClose:nil];
        [JL_Tools post:kUI_JL_DEVICE_SHOW_OTA Object:entity];
    }
}




#pragma mark 已连设备的定时处理
-(void)startPreparation{
    NSLog(@"---> 开始预处理...");
    if (preparateTimer) {
        [JL_Tools timingContinue:preparateTimer];
    }else{
        preparateTimer = [JL_Tools timingStart:@selector(makeSomePreparation)
                                        target:self Time:1.0];
    }
}

-(void)stopPreparation{
    [JL_Tools timingPause:preparateTimer];
}

-(void)makeSomePreparation{
    if (preparationArr.count > 0) {

        JLPreparation *pre = preparationArr[0];
        int isOk = pre.isPreparateOK;
        if (isOk == 0) {
            NSLog(@"---> 开始处理: %@",pre.mBleEntityM.mItem);
            [JL_Tools post:kUI_JL_DEVICE_PREPARING Object:nil];
            [pre actionPreparation];
        }
        if (isOk == 1) {
            //NSLog(@"---> 处理中... %@",pre.mBleEntityM.mItem);
        }
        if (isOk == 2) {
            [preparationArr removeObject:pre];
        }
    }else{
        [self stopPreparation];
        NSLog(@"---> 停止准备工作.");
    }
}

#pragma mark 设备已断开
-(void)noteEntityDisconnected:(NSNotification*)note{
    CBPeripheral *pl = note.object;
    NSString *uuid = pl.identifier.UUIDString;
    
    for (JLPreparation *preparation in preparationArr) {
        if ([uuid isEqual:preparation.mBleUUID]) {
            [preparation actionDismiss];
            break;
        }
    }
    NSMutableArray *mConnectArr = SDK.mBleMultiple.bleConnectedArr;
    
    /*--- 断开的是【正在使用的设备】 ---*/
    if ([uuid isEqual:self.mBleUUID]) {
        /*--- 默认选择第一个 ---*/
        if (mConnectArr.count > 0) {
            if (linkedUuidArr.count > 0) {
                NSString *uuid_0 = linkedUuidArr[0];
                [self changeUUID:uuid_0];
            }
        }else{
            SDK.mBleUUID = nil;
            SDK.mBleEntityM = nil;
            
            [linkedUuidArr removeAllObjects];
        }
        [JL_Tools post:kUI_JL_DEVICE_CHANGE Object:@(JLDeviceChangeTypeInUseOffline)];
    }else{
        /*--- 清除连接的记录 ---*/
        [linkedUuidArr removeObject:uuid];
        [JL_Tools post:kUI_JL_DEVICE_CHANGE Object:@(JLDeviceChangeTypeConnectedOffline)];
    }
}

#pragma mark 蓝牙中心关闭
-(void)noteBlePoweredOFF:(NSNotification*)note{
    SDK.mBleUUID = nil;
    SDK.mBleEntityM = nil;
    
    [linkedUuidArr removeAllObjects];
    [preparationArr removeAllObjects];
    
    [JL_Tools post:kUI_JL_DEVICE_CHANGE Object:@(JLDeviceChangeTypeBleOFF)];
}


#pragma mark BLE广播接收管理
-(void)noteBleScanOpen:(NSNotification*)note{
    if (scanTimer == nil) {
        scanTimer = [JL_Tools timingStart:@selector(actionBleScan) target:self Time:5.0];
    }else{
        [JL_Tools timingContinue:scanTimer];
    }
}

-(void)noteBleScanClose:(NSNotification*)note{
    [JL_Tools timingPause:scanTimer];
    [self.mBleMultiple scanStop];
    //NSLog(@"-----> Close Scan!");
}

-(void)actionBleScan{
    //NSLog(@"-----> Start Scan...");
    [self.mBleMultiple scanStart];
}

-(void)addLinkedArrayUuid:(NSString*)uuid{
    if ([linkedUuidArr containsObject:uuid]) {
        [linkedUuidArr removeObject:uuid];
    }
    if(uuid)[linkedUuidArr insertObject:uuid atIndex:0];
}


-(void)addNote{
    [JL_Tools add:kUI_JL_BLE_SCAN_OPEN Action:@selector(noteBleScanOpen:) Own:self];
    [JL_Tools add:kUI_JL_BLE_SCAN_CLOSE Action:@selector(noteBleScanClose:) Own:self];
    
    [JL_Tools add:kUI_JL_UUID_PREPARATE_OK Action:@selector(noteUuidPreparateOk:) Own:self];
    [JL_Tools add:kJL_BLE_M_ENTITY_CONNECTED Action:@selector(noteEntityConnected:) Own:self];
    [JL_Tools add:kJL_BLE_M_ENTITY_DISCONNECTED Action:@selector(noteEntityDisconnected:) Own:self];
    [JL_Tools add:kJL_BLE_M_OFF Action:@selector(noteBlePoweredOFF:) Own:self];
}

@end
