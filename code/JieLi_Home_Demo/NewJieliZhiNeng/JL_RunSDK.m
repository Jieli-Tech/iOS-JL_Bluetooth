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
#import "SqliteManager.h"
#import "JLPreparation.h"
#import "ElasticHandler.h"

NSString *kUI_JL_SHOW_ID3               = @"UI_JL_SHOW_ID3";
NSString *kUI_JL_CARD_MUSIC_INFO        = @"UI_JL_CARD_MUSIC_INFO";
NSString *kUI_JL_LINEIN_INFO            = @"UI_JL_LINEIN_INFO";
NSString *kUI_JL_FM_INFO                = @"UI_JL_FM_INFO";

NSString *kUI_JL_DEVICE_SHOW_OTA        = @"UI_JL_DEVICE_SHOW_OTA";
NSString *kUI_JL_DEVICE_CHANGE          = @"UI_JL_DEVICE_CHANGE";
NSString *kUI_JL_DEVICE_PREPARING       = @"UI_JL_DEVICE_PREPARING";

NSString *kUI_JL_BLE_SCAN_OPEN          = @"UI_JL_BLE_SCAN_OPEN";
NSString *kUI_JL_BLE_SCAN_CLOSE         = @"UI_JL_BLE_SCAN_CLOSE";

NSString *kUI_TURN_TO_DEVICEVC          = @"UI_TURN_TO_DEVICEVC";

@interface JL_RunSDK(){
    NSTimer         *scanTimer;
    NSTimer         *preparateTimer;
    NSMutableArray  *preparationArr;
    NSMutableArray  *linkedUuidArr;
    NSArray  *localSqlArr;
}
@end

@implementation JL_RunSDK

+(instancetype)sharedMe{
    static JL_RunSDK *SDK = nil;
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
        //是否开启过滤
        self.mBleMultiple.BLE_FILTER_ENABLE = YES;
        //是否开启设备认证
        self.mBleMultiple.BLE_PAIR_ENABLE = YES;
        self.mBleMultiple.BLE_TIMEOUT = 7;
        
        /*--- 选择设备类型搜索 ---*/
        self.mBleMultiple.bleDeviceTypeArr = @[@(JL_DeviceTypeTradition),
                                               @(JL_DeviceTypeSoundBox),
                                               @(JL_DeviceTypeTWS),
                                               @(JL_DeviceTypeChargingBin),
                                               @(JL_DeviceTypeHeadset),
                                               @(JL_DeviceTypeSoundCard),
        ];
        
        /*--- 开启蓝牙【搜索】【弹窗】 ---*/
        [self noteBleScanOpen:nil];
        self.dialInfoExtentedModel = [[JLDialInfoExtentedModel alloc] init];
        self.dialInfoExtentedModel.radius = 6;
        self.dialInfoExtentedModel.shape = 0x03;
        self.publicSetMgr = [JLPublicSetting new];
        [self addNote];
        [self refreshLocalDevices];
        
        //KVO 监听已连接的 ATT 设备
        [self.mBleMultiple addObserver:self forKeyPath:@"bleAttDevices" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(JL_EntityM *)mBleEntityM{
    return _mBleEntityM;
}

-(void)refreshLocalDevices{
    __weak typeof(self) wSelf = self;
    [[SqliteManager sharedInstance] checkOutDevices:^(NSArray * _Nullable array) {
        __strong typeof(wSelf) sSelf = wSelf;
        sSelf->localSqlArr = array;
    }];
}

+(void)setActiveUUID:(NSString*)uuid{
    if ([self sharedMe].mBleEntityM.mCmdManager) {
        [[self sharedMe].mBleEntityM.mCmdManager.mChargingBinManager cmdID3_PushEnable:YES];
    }
    if ([self sharedMe].mBleUUID) [[self sharedMe] addLinkedArrayUuid:[self sharedMe].mBleUUID];
    
    [[self sharedMe] changeUUID:uuid];
    [JL_Tools post:kUI_JL_DEVICE_CHANGE Object:@(JLDeviceChangeTypeManualChange)];
}

-(void)setConfigModel:(JLDeviceConfigModel *)configModel{
    if (_configModel != configModel) {
        [self willChangeValueForKey:@"configModel"];
        _configModel = configModel;
        [self didChangeValueForKey:@"configModel"];
    }
}

+(BOOL)isConnectedEdr:(JL_EntityM *)entity{
    
    if (entity.mType != JL_DeviceTypeTWS){
        return true;
    }
    if (@available(iOS 13.0, *)) {
        if (entity.mType == JL_DeviceTypeTWS) {
            return true;
        }
    }
    NSArray *array = [JL_BLEMultiple outputEdrList];
    if ([array containsObject:entity.mEdr]){
        return true;
    }else{
        return false;
    }
}


+(JLUuidType)getStatusUUID:(NSString*)uuid{
    if ([uuid isEqual:[self sharedMe].mBleUUID]) {
        return 2;
    }
    NSMutableArray *mConnectArr = [self sharedMe].mBleMultiple.bleConnectedArr;
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
    NSArray *arr = @[kJL_TXT("bluetooth_off"),
                     kJL_TXT("bt_connect_failed"),
                     kJL_TXT("device_connecting"),
                     kJL_TXT("repeated_connection"),
                     kJL_TXT("connect_timeout"),
                     kJL_TXT("reject_by_device"),
                     kJL_TXT("paire_failed"),
                     kJL_TXT("paire_timeout"),
                     kJL_TXT("paire_ok"),
                     kJL_TXT("master-slave_switch"),
                     kJL_TXT("disconnect_success"),
                     kJL_TXT("open_bluetooth")];
    if (status+1 <= arr.count) {
        return arr[status];
    }else{
        return @"未知错误";
    }
}

+(JLModel_Device *)getDeviceModel{
    JL_ManagerM *manager = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    JLModel_Device * deviceModel = [manager outputDeviceModel];
    return deviceModel;
}

+(JL_EntityM*)getEntity:(NSString*)uuid{
    NSMutableArray *mConnectArr = [self sharedMe].mBleMultiple.bleConnectedArr;
    for (JL_EntityM *entity in mConnectArr) {
        NSString *inUnid = entity.mPeripheral.identifier.UUIDString;
        if ([uuid isEqual:inUnid]) {
            kJLLog(JLLOG_INFO,@"找到设备:%@", entity);
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
    return [self sharedMe]->linkedUuidArr;
}


#pragma mark -
-(void)changeUUID:(NSString*)uuid{
    
    NSMutableArray *mConnectArr = self.mBleMultiple.bleConnectedArr;
    for (JL_EntityM *entity in mConnectArr) {
        NSString *inUnid = entity.mPeripheral.identifier.UUIDString;
        if ([uuid isEqual:inUnid] &&
            entity.mBLE_NEED_OTA == NO &&
            entity.isCMD_PREPARED== YES)
        {
            self.mBleEntityM = entity;
            kJLLog(JLLOG_INFO,@"设备切换:%@", entity);
            self.mBleUUID = uuid;
            
            [linkedUuidArr removeObject:uuid];
            break;
        }
    }
}


-(BOOL)isBr35ChargeBin {
    if (_publicSDKInfoModel) {
        if (_publicSDKInfoModel.chipId == 0x02
            && _publicSDKInfoModel.projectId == 0x01
            && _publicSDKInfoModel.productId == 0x01) {
            return true;
        }
        return false;
    } else {
        return false;
    }
}

#pragma mark 设备被连接
-(void)noteEntityConnected:(NSNotification*)note{
    CBPeripheral *pl = [note object];
    NSString *uuid = pl.identifier.UUIDString;
    
    /*--- 已连接的设备预处理 ---*/
    JLPreparation *preparation = [JLPreparation new];
    self.mBleEntityM = preparation.mBleEntityM = [JL_RunSDK getEntity:uuid];
    preparation.mBleUUID       = uuid;
    preparation.isPreparateOK  = 0;
    [preparationArr addObject:preparation];
    
    [self startPreparation];
}

-(void)noteUuidPreparateOk:(NSNotification*)note{
    NSString *uuid = note.object;
    JL_EntityM *entity = [JL_RunSDK getEntity:uuid];
    self.mBleEntityM = entity;
    if (self.mBleUUID && entity.mBLE_NEED_OTA == NO) {
        [self addLinkedArrayUuid:self.mBleUUID];
    }
    
    [self changeUUID:uuid];
    /*--- 需要OTA升级的设备 ---*/
    if (entity.mBLE_NEED_OTA) {
        [self noteBleScanClose:nil];
        [JL_Tools post:kUI_JL_DEVICE_SHOW_OTA Object:entity];
    }
    [JL_Tools post:kUI_JL_DEVICE_CHANGE Object:@(JLDeviceChangeTypeSomethingConnected)];
    [self refreshLocalDevices];
    
}


#pragma mark 已连设备的定时处理
-(void)startPreparation{
    kJLLog(JLLOG_DEBUG,@"---> 开始预处理...");
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
            kJLLog(JLLOG_DEBUG,@"---> 开始处理: %@",pre.mBleEntityM);
            [JL_Tools post:kUI_JL_DEVICE_PREPARING Object:nil];
            [pre actionPreparation];
        }
        if (isOk == 1) {
            //kJLLog(JLLOG_DEBUG,@"---> 处理中... %@",pre.mBleEntityM.mItem);
        }
        if (isOk == 2) {
            [preparationArr removeObject:pre];
        }
    }else{
        [self stopPreparation];
        kJLLog(JLLOG_DEBUG,@"---> 停止准备工作.");
        [JL_Tools post:kUI_JL_DEVICE_CHANGE Object:@(JLDeviceChangeTypeInitOK)];
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
    NSMutableArray *mConnectArr = self.mBleMultiple.bleConnectedArr;
    self.dialInfoExtentedModel = nil;
    self.publicSDKInfoModel = nil;
    
    /*--- 断开的是【正在使用的设备】 ---*/
    if ([uuid isEqual:self.mBleUUID]) {
        /*--- 默认选择第一个 ---*/
        if (mConnectArr.count > 0) {
            if (linkedUuidArr.count > 0) {
                NSString *uuid_0 = linkedUuidArr[0];
                [self changeUUID:uuid_0];
            }
        }else{
            self.mBleUUID = nil;
            kJLLog(JLLOG_INFO, @"reset:%@",self.mBleEntityM);
            self.mBleEntityM = nil;
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
    self.mBleUUID = nil;
    self.mBleEntityM = nil;
    
    [linkedUuidArr removeAllObjects];
    [preparationArr removeAllObjects];
    
    [JL_Tools post:kUI_JL_DEVICE_CHANGE Object:@(JLDeviceChangeTypeBleOFF)];
}




#pragma mark BLE广播接收管理
-(void)noteBleScanOpen:(NSNotification*)note{
    if (scanTimer == nil) {
        scanTimer = [JL_Tools timingStart:@selector(actionBleScan) target:self Time:20.0];
    }else{
        [JL_Tools timingContinue:scanTimer];
    }
}

-(void)noteBleScanClose:(NSNotification*)note{
    [JL_Tools timingPause:scanTimer];
    [self.mBleMultiple scanStop];
    //kJLLog(JLLOG_DEBUG,@"-----> Close Scan!");
}

-(void)actionBleScan{
    kJLLog(JLLOG_DEBUG,@"-----> Start Scan by Timer 20s...");
    [self.mBleMultiple scanStart];
}

-(void)addLinkedArrayUuid:(NSString*)uuid{
    if ([linkedUuidArr containsObject:uuid]) {
        [linkedUuidArr removeObject:uuid];
    }
    if(uuid)[linkedUuidArr insertObject:uuid atIndex:0];
}

-(void)noteEdrChange:(NSNotification *)note{
    if (self.mBleEntityM == nil) return;
    for (JL_EntityM *entity in self.mBleMultiple.bleConnectedArr) {
        if(![JL_RunSDK isConnectedEdr:entity]){
            if (entity.mCmdManager.mTwsManager.supports.isSupportDragWithMore){
                
                [self.mBleMultiple disconnectEntity:entity Result:^(JL_EntityM_Status status) {
                }];
            }
        }
    }
}

-(void)reconnectDevice:(NSNotification*)note{
    JL_EntityM *entity = note.object;
    __weak typeof(self) wSelf = self;
    [[SqliteManager sharedInstance] checkOutDevices:^(NSArray * _Nullable array) {
        __strong typeof(wSelf) sSelf = wSelf;
        sSelf->localSqlArr = array;
        if (entity.mType == JL_DeviceTypeChargingBin) {
            if ([[ElasticHandler sharedInstance] isInBlackList:entity]){
                return;
            }
            for (DeviceObjc *device in sSelf->localSqlArr) {
                if ([device.edr isEqualToString:entity.mEdr]) {
                    [self.mBleMultiple connectEntity:entity Result:^(JL_EntityM_Status status) {
                    }];
                }
            }
        }
    }];
    
    
    
}


-(void)addNote{
    [JL_Tools add:kUI_JL_BLE_SCAN_OPEN Action:@selector(noteBleScanOpen:) Own:self];
    [JL_Tools add:kUI_JL_BLE_SCAN_CLOSE Action:@selector(noteBleScanClose:) Own:self];
    [JL_Tools add:kUI_JL_UUID_PREPARATE_OK Action:@selector(noteUuidPreparateOk:) Own:self];
    [JL_Tools add:kJL_BLE_M_ENTITY_CONNECTED Action:@selector(noteEntityConnected:) Own:self];
    [JL_Tools add:kJL_BLE_M_ENTITY_DISCONNECTED Action:@selector(noteEntityDisconnected:) Own:self];
    [JL_Tools add:kJL_BLE_M_OFF Action:@selector(noteBlePoweredOFF:) Own:self];
    [JL_Tools add:kJL_BLE_M_EDR_CHANGE Action:@selector(noteEdrChange:) Own:self];
    [JL_Tools add:kJL_BLE_M_FOUND_SINGLE Action:@selector(reconnectDevice:) Own:self];
}

//MARK: - 监听 ATT 设备连接变更
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"bleAttDevices"]) {
        NSArray *newArr = change[NSKeyValueChangeNewKey];
        //FIXME: 临时连接
        if (newArr.count == 0) {
            return;
        }
        CBPeripheral *cbp = newArr[0];
        [_mBleMultiple getEntityWithSearchUUID:cbp.identifier.UUIDString SearchStatus:false Result:^(JL_EntityM * _Nullable entity) {
            if (entity != nil) {
                kJLLog(JLLOG_INFO, @"ATT连接成功:%@", entity);
                [self connectEntity:entity Result:^(JL_EntityM_Status status) {
                    
                }];
            }else{
                JL_EntityM *newEntity = [self.mBleMultiple makeEntityWithUUID:cbp.identifier.UUIDString];
                kJLLog(JLLOG_INFO, @"ATT连接成功:%@", newEntity);
                [self connectEntity:newEntity Result:^(JL_EntityM_Status status) {
                    
                }];
            }
        }];
    }
}

-(void)connectEntity:(JL_EntityM*)entity Result:(JL_EntityM_STATUS_BK)result {
    [self.mBleMultiple connectEntity:entity Result:^(JL_EntityM_Status status) {
        result(status);
        if (status == JL_EntityM_StatusPaired) {
            [[SqliteManager sharedInstance] installWithDevice:entity];
        }
    }];
}

@end
