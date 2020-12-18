//
//  JLPreparation.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/9/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "JLPreparation.h"
#import "JLUI_Cache.h"

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
 
    /*--- 关闭耳机信息推送 ---*/
    NSLog(@"--->(1) TURN OFF headset push.");
    [self.mBleEntityM.mCmdManager cmdHeatsetAdvEnable:NO];
    
    /*--- 同步时间戳 ----*/
    NSLog(@"--->(2) SET Device time.");
    NSDate *date = [NSDate new];
    [self.mBleEntityM.mCmdManager cmdHeatsetTimeSetting:date];

    [[JLCacheBox cacheUuid:self.mBleUUID] setIsLoadMusicInfo:NO];

    /*--- 清除设备音乐缓存 ---*/
    [self.mBleEntityM.mCmdManager cmdCleanCacheType:JL_CardTypeUSB];
    [self.mBleEntityM.mCmdManager cmdCleanCacheType:JL_CardTypeSD_0];
    [self.mBleEntityM.mCmdManager cmdCleanCacheType:JL_CardTypeSD_1];
    
    /*--- 获取设备信息 ---*/
    NSLog(@"--->(3) GET Device infomation.");
    [self.mBleEntityM.mCmdManager cmdTargetFeatureResult:^(NSArray *array) {
        JL_CMDStatus st = [array[0] intValue];
        if (st == JL_CMDStatusSuccess) {
            [wSelf startTimeout];//超时续费
            
            JLModel_Device *model = [wSelf.mBleEntityM.mCmdManager outputDeviceModel];
            
            JL_OtaStatus upSt = model.otaStatus;
            if (upSt == JL_OtaStatusForce) {
                NSLog(@"---> 进入强制升级.");
                
                [wSelf stopTimeout];
                wSelf.mBleEntityM.mBLE_NEED_OTA = YES;
                NSLog(@"-----> 处理完成:%@",wSelf.mBleEntityM.mItem);
                
                NSString *uuid = [wSelf.mBleUUID copy];
                wSelf.isPreparateOK = 2;
                [JL_Tools post:kUI_JL_UUID_PREPARATE_OK Object:uuid];
  
                return;
            }else{
                if (model.otaHeadset == JL_OtaHeadsetYES) {
                    NSLog(@"---> 进入强制升级: OTA另一只耳机.");

                    [wSelf stopTimeout];
                    wSelf.mBleEntityM.mBLE_NEED_OTA = YES;
                    NSLog(@"-----> 处理完成:%@",wSelf.mBleEntityM.mItem);

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
                NSLog(@"---> 设备定位 0");
                [[MapLocationRequest shareInstanced] requestLocation:wSelf.mBleEntityM];
            }
            /*---- 共有信息 ---*/
            NSLog(@"---> run task 1");
            [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON
                                                     Result:^(NSArray * _Nullable array) {
                [wSelf startTimeout];//超时续费
            
                NSLog(@"complete task 1");
                                    
                /*---- 蓝牙信息 ---*/
                NSLog(@"---> run task 2");
                [[JLCacheBox cacheUuid:wSelf.mBleUUID] setIsID3_FIRST:NO];
                [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeBT
                                                         Result:^(NSArray * _Nullable array) {
                    [wSelf startTimeout];//超时续费
                    
                    /*--- 开启ID3音乐信息推送 ---*/
                    NSLog(@"---->命令开启ID3信息推送.");
                    [wSelf.mBleEntityM.mCmdManager cmdID3_PushEnable:YES];
                    
                    if (wSelf.mBleEntityM.mType == 1) {//耳机需要
                        /*--- 用游戏模式的发包方式 ---*/
                        [wSelf.mBleEntityM.mCmdManager cmdGetLowDelay:^(uint16_t mtu, uint32_t delay) {
                            NSLog(@"----> In GAME MODE...【MTU：%d】【DELAY：%d】",mtu,delay);
                            int delay_time = 50;
                            if (delay > 0) delay_time = delay;
                            
                            int mtu_defult = 45;
                            if (mtu > 0) mtu_defult = mtu;

                            [wSelf.mBleEntityM setGameMode:YES MTU:mtu_defult Delay:delay_time];
                        }];
                    }
                    
                    BOOL isId3_play = [[JLCacheBox cacheUuid:wSelf.mBleUUID] isID3_PLAY];
                    if (isId3_play) {
                        NSLog(@"-----> Update ID3 Music Info.");
                        [JL_Tools post:kUI_JL_SHOW_ID3 Object:nil];
                    }else{
                        NSLog(@"-----> Update Apple Music Info.");
                    }
                    NSLog(@"complete task 2");
                    
                    if (model.currentFunc == JL_FunctionCodeMUSIC) {
                        /*---- 音乐信息 ---*/
                        NSLog(@"---> run task 3 music");
                        [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeMUSIC
                                                                 Result:^(NSArray * _Nullable array) {
                            NSLog(@"---> Preparation finished (MUSIC).");
                            [wSelf actionFinished];
                            
                            [JL_Tools post:kUI_JL_CARD_MUSIC_INFO Object:nil];
                        }];
                    }else if (model.currentFunc == JL_FunctionCodeLINEIN) {
                        /*---- Linein信息 ---*/
                        NSLog(@"---> run task 3 lineIn");
                        [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeLINEIN
                                                                 Result:^(NSArray * _Nullable array) {
                            NSLog(@"---> Preparation finished (LINEIN).");
                            [wSelf actionFinished];
                              
                            [JL_Tools post:kUI_JL_LINEIN_INFO Object:nil];
                        }];
                    }else if (model.currentFunc == JL_FunctionCodeFM) {
                        /*---- FM信息 ---*/
                        NSLog(@"---> run task 3 FM");
                        [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeFM
                                                                 Result:^(NSArray * _Nullable array) {
                            NSLog(@"---> Preparation finished (FM).");
                            [wSelf actionFinished];
                            
                            [JL_Tools post:kUI_JL_FM_INFO Object:nil];
                        }];
                    }else{
                        NSLog(@"---> Preparation finished (xxxx).");
                        [wSelf actionFinished];
                    }
                }];
            }];
        }
    }];
}


-(void)actionFinished{
    [self stopTimeout];//停止超时
    
    [[JLCacheBox cacheUuid:self.mBleUUID] setIsLoadMusicInfo:YES];
    
    NSLog(@"UI开启ID3信息。0000");
    [[JLCacheBox cacheUuid:self.mBleUUID] setIsID3_FIRST:YES];
    [[JLCacheBox cacheUuid:self.mBleUUID] setIsID3_PUSH:YES];
    
    NSLog(@"-----> 处理完成:%@",self.mBleEntityM.mItem);
    self.mBleEntityM.isCMD_PREPARED= YES;
    NSString *uuid = [self.mBleUUID copy];
    self.isPreparateOK = 2;
    [JL_Tools post:kUI_JL_UUID_PREPARATE_OK Object:uuid];
}



#pragma mark - 连接超时管理
-(void)startTimeout{
    NSLog(@"--->【%@】Preparation Timeout【Start】",self.mBleEntityM.mItem);
    timeout = 0;
    if (actionTimer) {
        [JL_Tools timingContinue:actionTimer];
    }else{
        actionTimer = [JL_Tools timingStart:@selector(timeoutAction)
                                   target:self Time:1.0];
    }
}

-(void)stopTimeout{
    NSLog(@"--->【%@】Preparation Timeout【Stop】",self.mBleEntityM.mItem);
    timeout = 0;
    [JL_Tools timingPause:actionTimer];
}

-(void)timeoutAction{
    NSLog(@"--->【%@】Preparation Timeout:%d",self.mBleEntityM.mItem,timeout);
    if (timeout == 5) {
        [self stopTimeout];

        if (preparateTimce == 2) {
            NSLog(@"-----> 处理失败，断开吧~【%@】",self.mBleEntityM.mItem);

            self.isPreparateOK = 1;
            JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
            [bleSDK.mBleMultiple disconnectEntity:self.mBleEntityM Result:^(JL_EntityM_Status status) {
                if (status == JL_EntityM_StatusDisconnectOk) {
                    self.isPreparateOK = 2;
                }
            }];
        }else{
            self.isPreparateOK = 0;
            NSLog(@"-----> 重新处理:%@",self.mBleEntityM.mItem);
        }
        preparateTimce++;
    }
    timeout++;
}

-(void)actionDismiss{
    NSLog(@"---> Preparation Action Dismiss.");
    
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
