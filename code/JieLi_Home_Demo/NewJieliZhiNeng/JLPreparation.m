//
//  JLPreparation.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/9/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "JLPreparation.h"
#import "JLUI_Cache.h"
#import "JLCacheBox.h"

#import "SqliteManager.h"
#import "MapLocationRequest.h"
#import "EQDefaultCache.h"
#import "CorePlayer.h"

NSString *kUI_JL_UUID_PREPARATE_OK = @"UI_JL_UUID_PREPARATE_OK";


@interface JLPreparation(){
    int     timeout;
    NSTimer *actionTimer;
    int     preparateTimce;
}

@end

@implementation JLPreparation

- (instancetype)init
{
    self = [super init];
    if (self) {
        timeout = 0;
        preparateTimce = 0;
        self.isPreparateOK = 0;
    }
    return self;
}

-(void)actionPreparation{
    __weak typeof(self) wSelf = self;
    
    self.isPreparateOK = 1;
    [self startTimeout];
    
    /*--- 监听设备信息变化通知 ---*/
    [self.mBleEntityM.mCmdManager setPropertyUpdate:YES];
 
    /*--- 关闭耳机信息推送 ---*/
    kJLLog(JLLOG_DEBUG,@"--->(1) TURN OFF headset push.");
    [self.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetAdvEnable:NO];
    
    /*--- 同步时间戳 ----*/
    kJLLog(JLLOG_DEBUG,@"--->(2) SET Device time.");
    NSDate *date = [NSDate new];
    [self.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetTimeSetting:date];

    [[JLCacheBox cacheUuid:self.mBleUUID] setIsLoadMusicInfo:NO];

    /*--- 清除设备音乐缓存 ---*/
    [self.mBleEntityM.mCmdManager.mFileManager cmdCleanCacheType:JL_CardTypeUSB];
    [self.mBleEntityM.mCmdManager.mFileManager cmdCleanCacheType:JL_CardTypeSD_0];
    [self.mBleEntityM.mCmdManager.mFileManager cmdCleanCacheType:JL_CardTypeSD_1];
    
    /*--- 获取设备信息 ---*/
    kJLLog(JLLOG_DEBUG,@"--->(3) GET Device infomation.");
    [self.mBleEntityM.mCmdManager cmdTargetFeatureResult:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        JL_CMDStatus st = status;
        if (st == JL_CMDStatusSuccess) {
            [wSelf startTimeout];//超时续费
            
            JLModel_Device *model = [wSelf.mBleEntityM.mCmdManager outputDeviceModel];
            
            JL_OtaStatus upSt = model.otaStatus;
            if (upSt == JL_OtaStatusForce) {
                kJLLog(JLLOG_DEBUG,@"---> 进入强制升级.");
                
                [wSelf stopTimeout];
                wSelf.mBleEntityM.mBLE_NEED_OTA = YES;
                kJLLog(JLLOG_DEBUG,@"-----> 处理完成:%@",wSelf.mBleEntityM.mItem);
                
                NSString *uuid = [wSelf.mBleUUID copy];
                wSelf.isPreparateOK = 2;
                [JL_Tools post:kUI_JL_UUID_PREPARATE_OK Object:uuid];
  
                return;
            }else{
                if (model.otaHeadset == JL_OtaHeadsetYES) {
                    kJLLog(JLLOG_DEBUG,@"---> 进入强制升级: OTA另一只耳机.");

                    [wSelf stopTimeout];
                    wSelf.mBleEntityM.mBLE_NEED_OTA = YES;
                    kJLLog(JLLOG_DEBUG,@"-----> 处理完成:%@",wSelf.mBleEntityM.mItem);

                    NSString *uuid = [wSelf.mBleUUID copy];
                    wSelf.isPreparateOK = 2;
                    [JL_Tools post:kUI_JL_UUID_PREPARATE_OK Object:uuid];
  
                    return;
                }
            }
            wSelf.mBleEntityM.mBLE_NEED_OTA = NO;
            
            /*---- 存储AuthKey、ProCode、是否支持查找设备 ---*/
            [[SqliteManager sharedInstance] updateDeviceModel:model forUUID:wSelf.mBleUUID];
            [[SqliteManager sharedInstance] updateLastFindDeviceEnable:model.searchType ForUUID:wSelf.mBleUUID];

            /*--- 存设备音量 ---*/
            [[JLCacheBox cacheUuid:wSelf.mBleUUID] setP_Cvol:model.currentVol];
            [[JLCacheBox cacheUuid:wSelf.mBleUUID] setP_Mvol:model.maxVol];

            /*--- 回复本地音乐UI ---*/
            if (model.currentFunc == JL_FunctionCodeBT){
                [[JLCacheBox cacheUuid:wSelf.mBleUUID] setIsLoadIpodInfo:YES];
                [DFAudioPlayer recoveryMusicInfo];
            }
            
            if(model.searchType == 1){//在设备允许查找的时候去定位
                kJLLog(JLLOG_DEBUG,@"---> 设备定位 0");
                [[MapLocationRequest shareInstanced] requestLocation:wSelf.mBleEntityM];
            }
            /*---- 共有信息 ---*/
            kJLLog(JLLOG_DEBUG,@"---> run task 1");
            [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON
                                                     Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                [wSelf startTimeout];//超时续费
            
                kJLLog(JLLOG_DEBUG,@"complete task 1");
                                    
                /*---- 蓝牙信息 ---*/
                kJLLog(JLLOG_DEBUG,@"---> run task 2");
                [[JLCacheBox cacheUuid:wSelf.mBleUUID] setIsID3_FIRST:NO];
                [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeBT
                                                         Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data)  {
                    [wSelf startTimeout];//超时续费
                    JLModel_Device *devModel = [wSelf.mBleEntityM.mCmdManager getDeviceModel];
                    /*--- 开启ID3音乐信息推送 ---*/
                    kJLLog(JLLOG_DEBUG,@"---->命令开启ID3信息推送.");
                    [wSelf.mBleEntityM.mCmdManager.mChargingBinManager cmdID3_PushEnable:YES];
                    if(devModel.sdkType == JL_SDKTypeChargingCase){
                        [wSelf checkDeviceInfo:wSelf.mBleEntityM];
                    }
                    //if (wSelf.mBleEntityM.mType == 1) {//耳机需要
                    if (wSelf.mBleEntityM.mType == JL_DeviceTypeTWS) {//耳机需要
                        /*--- 用游戏模式的发包方式 ---*/
                        [wSelf.mBleEntityM.mCmdManager.mChargingBinManager cmdGetLowDelay:^(uint16_t mtu, uint32_t delay) {
                            kJLLog(JLLOG_DEBUG,@"----> In GAME MODE...【MTU：%d】【DELAY：%d】",mtu,delay);
                            int delay_time = 50;
                            if (delay > 0) delay_time = delay;
                            
                            int mtu_defult = 45;
                            if (mtu > 0) mtu_defult = mtu;

                            [wSelf.mBleEntityM setGameMode:YES MTU:mtu_defult Delay:delay_time];
                        }];
                    }
                    
                    BOOL isId3_play = [[JLCacheBox cacheUuid:wSelf.mBleUUID] isID3_PLAY];
                    if (isId3_play) {
                        kJLLog(JLLOG_DEBUG,@"-----> Update ID3 Music Info.");
                        [JL_Tools post:kUI_JL_SHOW_ID3 Object:nil];
                    }else{
                        kJLLog(JLLOG_DEBUG,@"-----> Update Apple Music Info.");
                    }
                    kJLLog(JLLOG_DEBUG,@"complete task 2");
                    
                    if (model.currentFunc == JL_FunctionCodeMUSIC) {
                        /*---- 音乐信息 ---*/
                        kJLLog(JLLOG_DEBUG,@"---> run task 3 music");
                        [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeMUSIC
                                                                 Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                            kJLLog(JLLOG_DEBUG,@"---> Preparation finished (MUSIC).");
                            [wSelf actionFinished];
                            [JL_Tools post:kUI_JL_CARD_MUSIC_INFO Object:nil];
                        }];
                    }else if (model.currentFunc == JL_FunctionCodeLINEIN) {
                        /*---- Linein信息 ---*/
                        kJLLog(JLLOG_DEBUG,@"---> run task 3 lineIn");
                        [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeLINEIN
                                                                 Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                            kJLLog(JLLOG_DEBUG,@"---> Preparation finished (LINEIN).");
                            [wSelf actionFinished];
                              
                            [JL_Tools post:kUI_JL_LINEIN_INFO Object:nil];
                        }];
                    }else if (model.currentFunc == JL_FunctionCodeFM) {
                        /*---- FM信息 ---*/
                        kJLLog(JLLOG_DEBUG,@"---> run task 3 FM");
                        [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeFM
                                                                 Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                            kJLLog(JLLOG_DEBUG,@"---> Preparation finished (FM).");
                            [wSelf actionFinished];
                            
                            [JL_Tools post:kUI_JL_FM_INFO Object:nil];
                        }];
                    }else if (model.currentFunc == JL_FunctionCodeSPDIF) {
                        [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeSPDIF     Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                            kJLLog(JLLOG_DEBUG,@"---> Preparation finished (SPDIF).");
                            [wSelf actionFinished];
                        }];
                    }else if (model.currentFunc == JL_FunctionCodePCServer){
                        [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodePCServer Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                            kJLLog(JLLOG_DEBUG,@"---> Preparation finished (PCServer).");
                            [wSelf actionFinished];
                        }];
                    } else{
                        kJLLog(JLLOG_DEBUG,@"---> Preparation finished (xxxx).");
                        [wSelf actionFinished];
                    }
                }];
            }];
            
            //一拖二特殊处理
            [self handleWith1t2TWSDevice];
            
            //充电仓特殊处理
            [self handleWithChargeBin];
        }
    }];
}
//MARK: - 一拖二特殊处理
-(void)handleWith1t2TWSDevice{
    JL_TwsManager *tws = self.mBleEntityM.mCmdManager.mTwsManager;
    if(!tws.supports.isSupportDragWithMore){return;}
    
    [tws cmdGetDeviceInfoListResult:^(JL_CMDStatus status, NSArray<JLTWSAddrNameInfo *> * _Nullable phoneInfos) {
        if (status == JL_CMDStatusSuccess){

            for (JLTWSAddrNameInfo *info in phoneInfos){
                [info logProperties];
            }
            
            NSData *addr = [[NSUserDefaults standardUserDefaults] valueForKey:PhoneEdrAddr];

            if (phoneInfos.count == 1){
                JLTWSAddrNameInfo *info = phoneInfos.firstObject;
                [[NSUserDefaults standardUserDefaults] setValue:info.phoneEdrAddr forKey:PhoneEdrAddr];
                [[NSUserDefaults standardUserDefaults] setValue:info.phoneName forKey:PhoneName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //绑定
                [tws cmdBindDeviceInfo:info.phoneEdrAddr phone:info.phoneName result:^(JL_CMDStatus status, NSArray<JLTWSAddrNameInfo *> * _Nullable phoneInfos) {
                    
                }];
            }
            if (phoneInfos.count == 2){
                for (JLTWSAddrNameInfo *info in phoneInfos) {
                    if (info.isBind){
                        if ([info.phoneEdrAddr isEqualToData:addr]){
                            [[NSUserDefaults standardUserDefaults] setValue:info.phoneName forKey:PhoneName];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            //绑定
                            [tws cmdBindDeviceInfo:info.phoneEdrAddr phone:info.phoneName result:^(JL_CMDStatus status, NSArray<JLTWSAddrNameInfo *> * _Nullable phoneInfos) {
                                
                            }];
                            
                        }
                    }else{
                        if ([info.phoneEdrAddr isEqualToData:addr]){
                            [[NSUserDefaults standardUserDefaults] setValue:info.phoneEdrAddr forKey:PhoneEdrAddr];
                            [[NSUserDefaults standardUserDefaults] setValue:info.phoneName forKey:PhoneName];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            //绑定
                            [tws cmdBindDeviceInfo:info.phoneEdrAddr phone:info.phoneName result:^(JL_CMDStatus status, NSArray<JLTWSAddrNameInfo *> * _Nullable phoneInfos) {
                                
                            }];
                        }
                    }
                }
            }
        }

    }];
    
}

//MARK: - 充电仓特殊处理
-(void)handleWithChargeBin {
    JLModel_Device *dev = [self.mBleEntityM.mCmdManager getDeviceModel];
    if (dev.sdkType == JL_SDKTypeChargingCase) {
        JLPublicSetting *set = [[JL_RunSDK sharedMe] publicSetMgr];
        JL_ManagerM *mgr = self.mBleEntityM.mCmdManager;
        JLTaskChain *chain = [JLTaskChain new];
        
        //同步时间
        [chain addTask:^(id  _Nonnull input, void (^ _Nonnull completion)(id _Nullable, NSError * _Nullable)) {
            NSDateFormatter *fm = [[NSDateFormatter alloc] init];
            fm.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            fm.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
            NSString *dateStr = [fm stringFromDate:[NSDate date]];
            NSArray *arr = [dateStr componentsSeparatedByString:@"-"];
            [mgr.mSystemTime cmdSetSystemYear:[arr[0] intValue] Month:[arr[1] intValue] Day:[arr[2] intValue] Hour:[arr[3] intValue] Minute:[arr[4] intValue] Second:[arr[5] intValue]];
            completion(nil, nil);
        }];
        
        //获取SDK信息
        [chain addTask:^(id  _Nonnull input, void (^ _Nonnull completion)(id _Nullable, NSError * _Nullable)) {
            [set cmdDeviceGetDeviceSDKInfo:mgr result:^(JL_CMDStatus status, JLPublicSDKInfoModel * _Nullable model) {
                if (status == JL_CMDStatusSuccess) {
                    [[JL_RunSDK sharedMe] setPublicSDKInfoModel:model];
                    completion(model, nil);
                } else {
                    completion(nil, nil);
                }
            }];
        }];
        
        //获取表盘信息
        [chain addTask:^(id  _Nonnull input, void (^ _Nonnull completion)(id _Nullable, NSError * _Nullable)) {
            JLPublicSDKInfoModel *model = input;
            if (model.productId == 0x0001 && model.chipId == 0x0002) {
                [JL_RunSDK sharedMe].dialUnitMgr = [[JLDialUnitMgr alloc] initWithManager:mgr completion:^(NSError * _Nullable err) {
                    if (err != nil) {
                        completion(nil, err);
                    } else {
                        completion([JL_RunSDK sharedMe].dialUnitMgr, nil);
                    }
                }];
            } else {
              completion(nil, nil);
            }
        }];
        
        //获取表盘的文件数据
        [chain addTask:^(id  _Nonnull input, void (^ _Nonnull completion)(id _Nullable, NSError * _Nullable)) {
            JLDialUnitMgr *manager = input;
            if (manager) {
                [manager getFileList:JL_CardTypeFLASH count:100 completion:^(NSArray<JLDialSourceModel *> * _Nullable list, NSError * _Nullable err) {
                    if (err != nil) {
                        completion(nil, err);
                    } else {
                        completion(list, nil);
                    }
                }];
            }else{
                completion(nil, nil);
            }
        }];
        
        [chain runWithInitialInput:nil completion:^(id  _Nullable result, NSError * _Nullable error) {
            if (error != nil) {
                kJLLog(JLLOG_ERROR, @"--->update Get file list error.");
            }
        }];

    }
}

//MARK: - 扩展信息检查更新
-(void)checkDeviceInfo:(JL_EntityM *)entity{
//    [[JLDeviceConfig share] deviceGetConfig:entity.mCmdManager result:^(JL_CMDStatus status, uint8_t sn, JLDeviceConfigModel * _Nullable config) {
//        [[JL_RunSDK sharedMe] setConfigModel:config];
//
//        JLDeviceExportFuncModel *model = config.exportFunc;
//        // 表盘参数扩展内容获取
//        if (model.spDialInfoExtend){
//            
//        }
//    }];
    //NOTE: 这里不需要先查询 0xD9 命令，如果是彩屏舱设备时，会直接支持
    // 表盘参数扩展内容获取
    [[JLDialInfoExtentManager share] getDialInfoExtented: entity.mCmdManager result:^(JL_CMDStatus status, JLDialInfoExtentedModel * _Nullable op) {
        if (status == JL_CMDStatusSuccess) {
            [[JL_RunSDK sharedMe] setDialInfoExtentedModel:op];
        }else{
            kJLLog(JLLOG_DEBUG,@"getDialInfoExtented fail :%d",status);
        }
    }];
}

-(void)actionFinished{
    [self stopTimeout];//停止超时
    
    [[JLCacheBox cacheUuid:self.mBleUUID] setIsLoadMusicInfo:YES];
    
    kJLLog(JLLOG_DEBUG,@"UI开启ID3信息。0000");
    [[JLCacheBox cacheUuid:self.mBleUUID] setIsID3_FIRST:YES];
    [[JLCacheBox cacheUuid:self.mBleUUID] setIsID3_PUSH:YES];
    
    kJLLog(JLLOG_DEBUG,@"-----> 处理完成:%@",self.mBleEntityM.mItem);
    self.mBleEntityM.isCMD_PREPARED= YES;
    NSString *uuid = [self.mBleUUID copy];
    self.isPreparateOK = 2;
    [JL_Tools post:kUI_JL_UUID_PREPARATE_OK Object:uuid];
}





#pragma mark - 连接超时管理
-(void)startTimeout{
    kJLLog(JLLOG_DEBUG,@"--->【%@】Preparation Timeout【Start】",self.mBleEntityM.mItem);
    timeout = 0;
    if (actionTimer) {
        [JL_Tools timingContinue:actionTimer];
    }else{
        actionTimer = [JL_Tools timingStart:@selector(timeoutAction)
                                   target:self Time:1.0];
    }
}

-(void)stopTimeout{
    kJLLog(JLLOG_DEBUG,@"--->【%@】Preparation Timeout【Stop】",self.mBleEntityM.mItem);
    timeout = 0;
    [JL_Tools timingPause:actionTimer];
}

-(void)timeoutAction{
    kJLLog(JLLOG_DEBUG,@"--->【%@】Preparation Timeout:%d",self.mBleEntityM.mItem,timeout);
    if (timeout == 5) {
        [self stopTimeout];

        if (preparateTimce == 2) {
            kJLLog(JLLOG_DEBUG,@"-----> 处理失败，断开吧~【%@】",self.mBleEntityM.mItem);

            self.isPreparateOK = 1;
            JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
            [bleSDK.mBleMultiple disconnectEntity:self.mBleEntityM Result:^(JL_EntityM_Status status) {
                if (status == JL_EntityM_StatusDisconnectOk) {
                    self.isPreparateOK = 2;
                }
            }];
        }else{
            self.isPreparateOK = 0;
            kJLLog(JLLOG_DEBUG,@"-----> 重新处理:%@",self.mBleEntityM.mItem);
        }
        preparateTimce++;
    }
    timeout++;
}

-(void)actionDismiss{
    kJLLog(JLLOG_DEBUG,@"---> Preparation Action Dismiss.");
    
    [self stopTimeout];
    [JL_Tools timingStop:actionTimer];
    actionTimer = nil;
    
    self.mBleEntityM.isCMD_PREPARED= NO;
    self.isPreparateOK = 2;
}

-(void)dealloc{
    [JL_Tools timingStop:actionTimer];
    actionTimer = nil;
}

@end
