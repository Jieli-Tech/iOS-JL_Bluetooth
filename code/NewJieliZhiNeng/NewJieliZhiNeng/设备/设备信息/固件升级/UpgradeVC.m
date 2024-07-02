//
//  UpgradeVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "UpgradeVC.h"
#import "JL_RunSDK.h"
#import "UpgradeCell.h"
#import "UpgradeTipsView.h"
#import "TransportView.h"
#import "FinishTipsView.h"
#import "DeviceInfoTools.h"
#import "UTipsView.h"
#import "SqliteManager.h"
#import "AppStatusManager.h"
#import "JLUI_Cache.h"
#import "NetworkPlayer.h"

#ifdef DEBUG

#define LT 0

#else

#define LT 0

#endif



@interface UpgradeVC ()<UpgradeCellDelegate,UITableViewDelegate,UITableViewDataSource,DFHttpDelegate,UTipViewDelegate>{
    NSArray *itemArray;

    UpgradeTipsView *upgradeView;
    TransportView *transportView;
    FinishTipsView *finishView;
    UTipsView *tipsView;
    
    
    NSString *newVersion;
    BOOL shouldUp;
    NSString *downloadUrl;
    NSString *savePath;
    NSFileManager *fmgr;
    DFHttp *httpMgr;
    BOOL isDownload;
    float pRate;
    BOOL exitToRoot;
    BOOL ischeck;
    BOOL isChecking;
    BOOL isUpdateing;
    
    JL_RunSDK   *bleSDK;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headHight;
@property (weak, nonatomic) IBOutlet UITableView *upgradeTable;

@property (nonatomic,strong)NSString * otaBleAddr;

@end

@implementation UpgradeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
    
    [self initWithData];
    [self initWithUI];
}
-(void)viewWillAppear:(BOOL)animated{
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];
}

-(void)addNote{
    [JL_Tools add:UIApplicationDidEnterBackgroundNotification Action:@selector(noteEnterBackground:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_SHOW_OTA Action:@selector(notiEntityOta:) Own:self];
}

-(void)removeNote{
    [JL_Tools remove:UIApplicationDidEnterBackgroundNotification Own:self];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
    [JL_Tools remove:kUI_JL_DEVICE_SHOW_OTA Own:self];
}

-(void)initWithData{
    bleSDK = [JL_RunSDK sharedMe];
    [[JLUI_Cache sharedInstance] setOtaUUID:self.otaEntity.mUUID];
    
    itemArray = @[kJL_TXT("firmware_current_version"),kJL_TXT("firmware_update")];
    savePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    savePath = [savePath stringByAppendingPathComponent:@"update.ufw"];
    fmgr = [NSFileManager defaultManager];
    
    shouldUp = NO;
    isDownload = NO;
    pRate = 0.0;
    exitToRoot = NO;
    isChecking = NO;
    
}

-(void)checkVersion{

#if (LT==0)

//    //有新版本
//    self->shouldUp = YES;
//    self->downloadUrl = [JL_Tools find:@"update_yx_hp_123.ufw"];
//    savePath = [JL_Tools find:@"update_yx_hp_123.ufw"];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self->upgradeView initWithNews:@"1.0.0.0" tips:@"升级测试"];
//        [self.view addSubview:self->upgradeView];
//    });
//    [self.upgradeTable reloadData];
//    return;
    
    JLModel_Device *model = [self.otaEntity.mCmdManager outputDeviceModel];
    if (model.md5Type == YES) {
        /*---- OTA升级使用MD5校验 ----*/
        
        [self.otaEntity.mCmdManager cmdGetMD5_Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
            if (status == JL_CMDStatusSuccess) {
                NSData *data_md5 = data;
                NSString *str_md5 = [[NSString alloc] initWithData:data_md5 encoding:NSUTF8StringEncoding];
                NSLog(@"MD5 ----> %@",str_md5);
                //NSString* test = @"eb5eaa7e89664adc2c840230fc494656";
                [self.otaEntity.mCmdManager.mOTAManager cmdGetOtaFileKey:model.authKey Code:model.proCode hash:str_md5
                                      Result:^(JL_OTAUrlResult result,
                                               NSString * _Nullable version,
                                               NSString * _Nullable url,
                                               NSString * _Nullable explain) {
                    [self updateWithOTAResult:result Version:version Url:url Explain:explain];
                }];
            }else{
                [DFUITools showText_1:kJL_TXT("md5_verify_error") onView:self.view delay:1.0];
                self->isChecking = NO;
                [self.upgradeTable reloadData];
            }
        }];
        
            
    }else{
        /*--- 传统OTA升级 ---*/
        NSString *authKey = @"";
        NSString *proCode = @"";
        if ([model.authKey isEqualToString:@""] || [model.proCode isEqualToString:@""] ) {
            if(self.otaEntity.mUUID.length>0){
                DeviceModel *m1 = [[SqliteManager sharedInstance] checkoutDeviceModelBy:self.otaEntity.mUUID];
                authKey = m1.authKey;
                proCode = m1.proCode;
            }
        }else{
            authKey = model.authKey;
            proCode = model.proCode;
        }
        [self.otaEntity.mCmdManager.mOTAManager cmdGetOtaFileKey:authKey Code:proCode
                              Result:^(JL_OTAUrlResult result,
                                       NSString * _Nullable version,
                                       NSString * _Nullable url,
                                       NSString * _Nullable explain) {
            [self updateWithOTAResult:result Version:version Url:url Explain:explain];
        }];
    }
#else
    JLModel_Device *model = [self.otaEntity.mCmdManager outputDeviceModel];
    NSString *authKey = @"";
    NSString *proCode = @"";
    if ([model.authKey isEqualToString:@""] || [model.proCode isEqualToString:@""] ) {

        DeviceModel *m1 = [[SqliteManager sharedInstance] checkoutDeviceModelBy:self.otaEntity.mUUID];
        authKey = m1.authKey;
        proCode = m1.proCode;
    }else{
        authKey = model.authKey;
        proCode = model.proCode;
    }
    //有新版本
    shouldUp = YES;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"update.ufw"];
    savePath = path;
   
    [upgradeView initWithNews:@"Max" tips:@"无限制升级"];
    [self.view addSubview:upgradeView];
   
    
#endif
    
}

-(void)updateWithOTAResult:(JL_OTAUrlResult)result
                   Version:(NSString*)version
                       Url:(NSString*)url
                   Explain:(NSString*)explain{
    if(result == JL_OTAUrlResultDownloadFail){
        [DFUITools showText_1:kJL_TXT("network_exception") onView:self.view delay:1.0];
        self->isChecking = NO;
        self->pRate = 0;
        [self->fmgr removeItemAtPath:savePath error:nil];
        [self->_upgradeTable reloadData];
        return;
    }
    
    if (result == JL_OTAUrlResultFail) {
        [DFUITools showText_1:kJL_TXT("network_err_tips") onView:self.view delay:1.0];
        self->isChecking = NO;
        [self->_upgradeTable reloadData];
        return;
    }
    
    
    self->newVersion = version;
    NSLog(@"---> 服务器 Version:%@",version);
    
    JLModel_Device *model = [self.otaEntity.mCmdManager outputDeviceModel];
    NSString *currentFireCode = model.versionFirmware;
    NSLog(@"---> 固件 Version:%@",currentFireCode);
    
    /**版本校对*/
    if([DeviceInfoTools shouldUpdate:version local:currentFireCode]){
#if (LT==0)
        [fmgr removeItemAtPath:self->savePath error:nil];
#else
        
#endif
        //有新版本
        self->shouldUp = YES;
        self->downloadUrl = url;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->upgradeView initWithNews:version tips:explain];
            [self.view addSubview:self->upgradeView];
        });
    }else{
        self->shouldUp = NO;
        [DFUITools showText_1:kJL_TXT("no_new_version") onView:self.view delay:1.0];
    }
    self->isChecking = NO;
    [self->_upgradeTable reloadData];
}

-(void)initWithUI{
    self.headHight.constant = kJL_HeightNavBar;
    self.titleLab.text = kJL_TXT("firmware_update");
    _upgradeTable.rowHeight = 55.0;
    _upgradeTable.delegate = self;
    _upgradeTable.dataSource = self;
    _upgradeTable.backgroundColor = [UIColor clearColor];
    [_upgradeTable setSeparatorColor:[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1]];
    [_upgradeTable registerNib:[UINib nibWithNibName:@"UpgradeCell" bundle:nil] forCellReuseIdentifier:@"UpgradeCell"];
    _upgradeTable.tableFooterView = [UIView new];
    _upgradeTable.allowsSelection = YES;
    _upgradeTable.scrollEnabled = NO;

    upgradeView = [[UpgradeTipsView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    transportView = [[TransportView alloc] init];
    transportView.alpha = 0.0;
    
    finishView = [[FinishTipsView alloc] init];
    finishView.alpha = 0.0;

    tipsView = [[UTipsView alloc] init];
    tipsView.delegate = self;
    tipsView.alpha = 0.0;
    
    [JL_Tools delay:0.1 Task:^{
        [self.view addSubview:self->transportView];
        [self.view addSubview:self->finishView];
        [self.view addSubview:self->tipsView];
    }];

    [finishView okBlock:^{
        self->shouldUp = NO;
        [self->_upgradeTable reloadData];
        self->exitToRoot = YES;
        
        #if (LT==0)
            [self->fmgr removeItemAtPath:self->savePath error:nil];
        #else
        #endif
        
        if (self.rootNumber == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if (self.rootNumber == 2) {
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
}

- (IBAction)backBtnAction:(id)sender {
    [httpMgr cancelTask];
    [self dismissViewControllerAnimated:YES completion:nil];

#if (LT==0)
    [fmgr removeItemAtPath:self->savePath error:nil];
#else
    
#endif
}

#pragma mark <- tableview Delegat ->
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return itemArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UpgradeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpgradeCell" forIndexPath:indexPath];
    cell.nameLab.text = itemArray[indexPath.row];
    cell.index = indexPath.row;
    cell.delegate = self;
    if (indexPath.row == 1) {
        
        [cell.progress setProgress:pRate];
        cell.presentLab.text = [NSString stringWithFormat:@"%.0f%%",pRate*100];
        
        if (isDownload) {
            cell.progress.hidden = NO;
            cell.presentLab.hidden = NO;
            cell.downloadBtn.hidden = YES;
        }else{
            cell.progress.hidden = YES;
            cell.presentLab.hidden = YES;
            cell.downloadBtn.hidden = NO;
        }
        if (shouldUp) {
            if (!isDownload) {
                cell.downloadBtn.hidden = NO;
            }
            [cell.downloadBtn setTitle:kJL_TXT("upgrade_tips") forState:UIControlStateNormal];
            cell.lastVersionLab.hidden = YES;
            cell.checkBtn.hidden = YES;
        }
        if ([fmgr fileExistsAtPath:savePath]) {
            cell.lastVersionLab.hidden = YES;
            [cell.downloadBtn setTitle:kJL_TXT("upgrade_tips") forState:UIControlStateNormal];
        }else{
            if (shouldUp == NO) {
                cell.lastVersionLab.hidden = YES;
                cell.progress.hidden = YES;
                cell.downloadBtn.hidden = YES;
                cell.presentLab.hidden = YES;
                cell.downloadBtn.hidden = YES;
                cell.checkBtn.hidden = NO;
            }
        }

        if (isChecking) {
            [cell.checkingView startAnimating];
            cell.checkingView.hidden = NO;
        }else{
            cell.checkingView.hidden = YES;
            [cell.checkingView stopAnimating];
        }
      
    }else if(indexPath.row == 0){
        cell.checkingView.hidden = YES;
        cell.progress.hidden = YES;
        cell.downloadBtn.hidden = YES;
        cell.presentLab.hidden = YES;
        cell.lastVersionLab.hidden = NO;
        cell.checkBtn.hidden = YES;
        
        JLModel_Device *model = [self.otaEntity.mCmdManager outputDeviceModel];
        if (model.versionFirmware == nil ||
            [model.versionFirmware isEqual:@""]) {
            cell.lastVersionLab.text = @"";
        }else{
            cell.lastVersionLab.text = [NSString stringWithFormat:@"v%@",model.versionFirmware];
        }
    }
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark <- cell delegate ->
-(void)upgradeCellDidTouch:(NSInteger)index{
//    [self upgradeAction];
//    return;
    
    /*--- 关闭网络电台 ---*/
    [[NetworkPlayer sharedMe] didStop];
    [DFAudioPlayer didAllPause];
    [self pauseLineinAndMusic];
    if (index == 1) {
        if ([fmgr fileExistsAtPath:savePath]) {
            //已经存在，就开始固件升级
            [self upgradeAction];
        }else{
            //还没下载，那就去下载
            [self startDownload];
        }
    }
}

-(void)checkUpdateCellDidTouch{
    isChecking = YES;
    [self checkVersion];
    [self.upgradeTable reloadData];
}


#pragma mark <- HTTP文件下载 ->
-(void)startDownload{
    isDownload = YES;
#if (LT==0)
    NSDictionary *dict = @{@"URL":downloadUrl?:@"",@"PATH":savePath?:@""};
    [fmgr removeItemAtPath:savePath error:nil];
    [self.upgradeTable reloadData];
    httpMgr = nil;
    httpMgr = [[DFHttp alloc] init];
    httpMgr.delegate = self;
    [httpMgr down:dict];
#else
    pRate = 1.0;
    isDownload = NO;
    [self.upgradeTable reloadData];
    //已经存在，就开始固件升级
    [self upgradeAction];
    pRate = 0;
#endif
    
}

-(void)http:(DFHttp *)http didFail:(NSError *)error{
    isDownload = NO;
#if (LT==0)
    [fmgr removeItemAtPath:self->savePath error:nil];
#else
    
#endif
    [self.upgradeTable reloadData];
    [DFUITools showText:kJL_TXT("network_exception") onView:self.view delay:2.0];
    pRate = 0;
}
-(void)http:(DFHttp *)http progress:(float)rate{
    pRate = rate;
    [self.upgradeTable reloadData];
}
-(void)http:(DFHttp *)http didSuccess:(NSString *)path{
    isDownload = NO;
    [self.upgradeTable reloadData];
    //已经存在，就开始固件升级
    [self upgradeAction];
    pRate = 0;
}


#pragma mark -【开始固件进行升级】
/// 开始升级
-(void)upgradeAction{
    
    [self.otaEntity setGameMode:NO MTU:0 Delay:0];

    NSData *data = [NSData dataWithContentsOfFile:savePath];
    if(data.length >0){
        [transportView update:0.0 Text:kJL_TXT("upgrade_progress_update")];
        transportView.alpha = 1.0;
        tipsView.alpha = 0.0;
        tipsView.index = -1;
        [self otaTimeCheck];//增加超时检测
                
        isUpdateing = YES;
        NSLog(@"----> OTA Upgrade Action..");
        
        __weak typeof(self) weakSelf = self;
        [self.otaEntity.mCmdManager.mOTAManager cmdOTAData:data Result:^(JL_OTAResult result, float progress) {
            if (result == JL_OTAResultSuccess) {
                [self->transportView update:1.0 Text:nil];
                self->transportView.alpha = 0.0;
                
                [[JLUI_Cache sharedInstance] setOtaUUID:nil];
                
                [weakSelf upgradeFinish];
            }
            if (result == JL_OTAResultFail) {
                [weakSelf failedWithAction:kJL_TXT("upgrade_failed")];
            }
            if (result == JL_OTAResultDataIsNull) {
                [weakSelf failedWithAction:kJL_TXT("ota_upgrade_data_nil")];
            }
            if (result == JL_OTAResultCommandFail) {
                [weakSelf failedWithAction:kJL_TXT("ota_upgrade_cmd_failed")];
            }
            if (result == JL_OTAResultSeekFail) {
                [weakSelf failedWithAction:kJL_TXT("ota_upgrade_offset_failed")];
            }
            if (result == JL_OTAResultInfoFail) {
                [weakSelf failedWithAction:kJL_TXT("ota_upgrade_info_failed")];
            }
            if (result == JL_OTAResultLowPower) {
                [weakSelf failedWithAction:kJL_TXT("ota_upgrade_battery_failed")];
            }
            if (result == JL_OTAResultEnterFail) {
                [weakSelf failedWithAction:kJL_TXT("ota_upgrade_cannot_failed")];
            }
            if (result == JL_OTAResultUnknown) {
                [weakSelf failedWithAction:kJL_TXT("ota_upgrade_unknow_failed")];
            }
            if (result == JL_OTAResultFailSameVersion) {
                [weakSelf failedWithAction:kJL_TXT("is_same_version")];
            }
            if (result == JL_OTAResultFailTWSDisconnect) {
                [weakSelf failedWithAction:kJL_TXT("tws_isnot_connected")];
            }
            if (result == JL_OTAResultFailNotInBin) {
                [weakSelf failedWithAction:kJL_TXT("tws_isnot_online")];
            }
            
            if (result == JL_OTAResultPreparing ||
                result == JL_OTAResultUpgrading)
            {
                if (result == JL_OTAResultUpgrading) [self->transportView update:progress Text:kJL_TXT("upgrade_progress_update")];
                if (result == JL_OTAResultPreparing) [self->transportView update:progress Text:@"检验文件"];
                [self otaTimeCheck];//增加超时检测
            }
            
            if (result == JL_OTAResultPrepared) {
                [self otaTimeCheck];//增加超时检测
            }
            if (result == JL_OTAResultReconnect ) {
                [self otaTimeCheck];//增加超时检测
                
                NSLog(@"---> OTA正在回连设备... %@",self.otaEntity.mItem);
                [self->bleSDK.mBleMultiple connectEntity:self.otaEntity Result:^(JL_EntityM_Status status) {
                    if (status != JL_EntityM_StatusPaired) {
                        [weakSelf failedWithAction:kJL_TXT("ota_timeout")];
                    }
                }];
            }
            if (result == JL_OTAResultReconnectWithMacAddr) {
                [self otaTimeCheck];//增加超时检测
                JLModel_Device *model = [self.otaEntity.mCmdManager outputDeviceModel];
                NSLog(@"---> OTA正在回连设备2... %@",model.bleAddr);
                self.otaBleAddr = model.bleAddr;
                [self->bleSDK.mBleMultiple connectEntityForMac:model.bleAddr Result:^(JL_EntityM_Status status) {
                    if (status != JL_EntityM_StatusPaired) {
                        [weakSelf failedWithAction:kJL_TXT("ota_timeout")];
                    }
                }];
            }
            if (result == JL_OTAResultReboot) {
                [self.otaEntity.mCmdManager.mOTAManager cmdRebootForceDevice];
//                [[[JL_RunSDK sharedMe] mBleMultiple] disconnectEntity:self.otaEntity Result:^(JL_EntityM_Status status) {
//                    
//                }];
            }
            
        }];
    }
}

-(void)notiEntityOta:(NSNotification *)note{
    self.otaEntity = note.object;
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeSomethingConnected) {
        NSString *otaUuid = [[JLUI_Cache sharedInstance] otaUUID];
        if (otaUuid.length >0) {
            JLUuidType uuidType = [JL_RunSDK getStatusUUID:otaUuid];
            if (uuidType == JLUuidTypeNeedOTA) {
                //重连后继续升级
                NSLog(@"---> OTA成功回连设备:%@",self.otaEntity.mItem);
                [self upgradeAction];
                return;
            }
            
            if (self.otaBleAddr) {
                //重连后继续升级
                NSLog(@"---> OTA成功回连设备2:%@",self.otaEntity.mItem);
                [self upgradeAction];
                self.otaBleAddr = nil;
                return;
            }
        }
        
    }
    if (type == JLDeviceChangeTypeConnectedOffline) {
        NSString *otaUuid = [[JLUI_Cache sharedInstance] otaUUID];
        if (otaUuid.length >0) {
            JLUuidType uuidType = [JL_RunSDK getStatusUUID:otaUuid];
            if (uuidType == JLUuidTypeDisconnected && isUpdateing == NO) {
                if (self.rootNumber == 1) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                if (self.rootNumber == 2) {
                    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }
    }
    if (type == JLDeviceChangeTypeInUseOffline) {
        if (isUpdateing == NO) {
            if (self.rootNumber == 1) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            if (self.rootNumber == 2) {
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    if (type == JLDeviceChangeTypeBleOFF) {
        [self failedWithAction:kJL_TXT("请勿关闭蓝牙，升级失败！")];
        [self otaTimeClose];
    }
}


#pragma <- 退到后台 ->
-(void)noteEnterBackground:(NSNotification*)note{
    
    if (isUpdateing) {
        //命令退出OTA
        [self.otaEntity.mCmdManager.mOTAManager cmdOTACancelResult:nil];
        
        [JL_Tools delay:1.0 Task:^{
            [[JLUI_Cache sharedInstance] setOtaUUID:nil];
            
            NSLog(@"---> OTA 用户异常操作，断开BLE.");
            [self->bleSDK.mBleMultiple disconnectEntity:self.otaEntity Result:^(JL_EntityM_Status status) {
                if (status == JL_EntityM_StatusDisconnectOk) {
                    [JL_Tools mainTask:^{
                        [DFUITools showText:kJL_TXT("device_is_disconected") onView:self.view delay:1.0];
                    }];
                }
            }];
        }];
        [self failedWithAction:kJL_TXT("user_op_error_failed")];
        [self otaTimeClose];
    }
}



-(void)failedWithAction:(NSString*)txt{
#if (LT==0)
    [fmgr removeItemAtPath:self->savePath error:nil];
#else
    
#endif
    [transportView update:0.0 Text:nil];
    transportView.alpha = 0.0;
    
    tipsView.tipsLab.text = txt;
    tipsView.alpha = 1.0;
    
    finishView.alpha = 0.0;
    
    [self otaTimeClose];//关闭超时检测
}

-(void)upgradeFinish{
#if (LT==0)
    [fmgr removeItemAtPath:self->savePath error:nil];
#else
    
#endif
    isUpdateing = NO;
    transportView.alpha = 0.0;
    tipsView.alpha = 0.0;
    finishView.alpha = 1.0;
    
    [self otaTimeClose];//关闭超时检测
}


static NSTimer  *otaTimer = nil;
static int      otaTimeout= 0;
-(void)otaTimeCheck{
    otaTimeout = 0;
    if (otaTimer == nil) {
        otaTimer = [JL_Tools timingStart:@selector(otaTimeAdd)
                                  target:self Time:1.0];
    }
}

-(void)otaTimeClose{
    [JL_Tools timingStop:otaTimer];
    otaTimeout = 0;
    otaTimer = nil;
}

-(void)otaTimeAdd{
    otaTimeout++;
    if (otaTimeout == 17) {
        [self otaTimeClose];
        [self failedWithAction:kJL_TXT("ota_timeout")];
        NSLog(@"OTA ---> 超时了！！！");
        
#if (LT==0)
        [fmgr removeItemAtPath:self->savePath error:nil];
#else
#endif
    }
}



#pragma mark <- tips delegate ->
-(void)UtipsOkWithIndex:(NSInteger)index{
    tipsView.alpha = 0.0;
    
    isUpdateing = NO;
    [self.upgradeTable reloadData];
    
    if (index == -1) {
        if (self.rootNumber == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if (self.rootNumber == 2) {
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)pauseLineinAndMusic{
    JLModel_Device *model = [self.otaEntity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        [self.otaEntity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                                        Command:JL_FCmdMusicPP
                                         Extend:JL_MusicStatusPause
                                         Result:nil];
    }
    if(model.currentFunc == JL_FunctionCodeLINEIN){
        [self.otaEntity.mCmdManager cmdFunction:JL_FunctionCodeLINEIN
                                        Command:0x03
                                         Extend:JL_LineInStatusPause
                                         Result:nil];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [[JLUI_Cache sharedInstance] setOtaUUID:nil];
    
    [self->transportView update:0.0 Text:nil];
    [self->transportView removeFromSuperview];
    self->transportView = nil;
    
    [self->tipsView removeFromSuperview];
    self->tipsView = nil;
    
    [self->finishView removeFromSuperview];
    self->finishView = nil;
    
    [self removeNote];
}

@end
