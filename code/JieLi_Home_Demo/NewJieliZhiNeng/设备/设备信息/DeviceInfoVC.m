//
//  DeviceInfoVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DeviceInfoVC.h"
#import "NormalSettingView.h"
#import "HeadSetControlView.h"
#import "JLUI_Effect.h"
#import "JL_RunSDK.h"
#import "DeviceInfoTools.h"
#import "HeadphoneFunVC.h"
#import "UpgradeVC.h"
#import "ReNameView.h"
#import "MofifyNameAlert.h"
#import "SqliteManager.h"
#import "NoNetView.h"
#import "ElasticHandler.h"
#import "JLUI_Cache.h"
#import "AppStatusManager.h"
#import "NetworkPlayer.h"
#import "FlashDeviceVC.h"
#import "DenoiseVC.h"
#import "JLCacheBox.h"
#import "HeadSetControlView2.h"
#import "DhaFittingVC.h"
#import "HeadSetANC.h"
#import "MultiLinksViewController.h"
#import "ColorScreenSetVC.h"
#import "SqliteManager.h"


@interface DeviceInfoVC ()<HeadSetControlDelegate,NormalSettingDelegate,ReNameViewDelegate,MofifyNameAlertDelegate,HeadsetDenoisePtl>{
    
    HeadSetControlView *headSetView;
    NaviView *naviView;
    HeadSetANC *headSetAncView;
    NormalSettingView *settingView;
    NormalSettingView *dhaFittingView;
    NormalSettingView *multiLinksView;
    NormalSettingView *colorScreenBoxView;
    SwitchSettingView *weatherPushView;
    NormalSettingView *updateView;
    UIButton *deleteBtn;
    ReNameView *rnameView;
    MofifyNameAlert *mofifyNameAlert;
    UIScrollView *scrollView;
    
    NSMutableArray *sortTouchArray;
    NSMutableArray *doubleTouchArray;
    NSMutableArray *upgradeArray;
    NSDictionary *deviceDic;
    NormalSettingObject *nameObject; //蓝牙设备名字
    NoNetView *noNetView;
    
    JL_RunSDK   *bleSDK;
    NSString    *bleName;
    NSString    *bleUUID;
    JL_DeviceType  bleType;
    BOOL        isLoadImage;
    int         protrocolVersion;
    BOOL        isKeySetting;
    
}
@property(nonatomic,strong)NSMutableArray<NormalSettingObject *> *settingArray;

@end

@implementation DeviceInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingArray = [NSMutableArray new];
    sortTouchArray = [NSMutableArray new];
    doubleTouchArray = [NSMutableArray new];
    upgradeArray = [NSMutableArray new];
    naviView = [[NaviView alloc] init];
    [self addNote];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestData];
}

-(void)requestData{
    bleSDK = [JL_RunSDK sharedMe];
    
    bleName = bleSDK.mBleEntityM.mItem;
    bleType = bleSDK.mBleEntityM.mType;
    bleUUID = bleSDK.mBleEntityM.mUUID;
    protrocolVersion = bleSDK.mBleEntityM.mProtocolType;
    
    [self initWithData];
    [self requestDeviceImage];
    
    //    if (self.headsetDict == nil) {
    kJLLog(JLLOG_DEBUG,@"---> 获取耳机信息... Info VC");
    
    __weak typeof(self) wSelf = self;
    [bleSDK.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetGetAdvFlag:0x3F
                                                              Result:^(NSDictionary * _Nullable dict) {
        kJLLog(JLLOG_DEBUG,@"headsetDict:%@",dict);
        if (dict[@"KEY_SETTING"]){
            self.headsetDict = dict;
            [wSelf initWithData];
            [wSelf requestDeviceImage];
        }
    }];
    
    [bleSDK.mBleEntityM.mCmdManager.mTwsManager addObserver:self forKeyPath:@"headSetInfoDict" options:NSKeyValueObservingOptionNew context:nil];
    [bleSDK.mBleEntityM.mCmdManager.mTwsManager addObserver:self forKeyPath:@"dragWithMore" options:NSKeyValueObservingOptionNew context:nil];
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    @try {
        [bleSDK.mBleEntityM.mCmdManager.mTwsManager removeObserver:self forKeyPath:@"headSetInfoDict"];
        [bleSDK.mBleEntityM.mCmdManager.mTwsManager removeObserver:self forKeyPath:@"dragWithMore"];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"headSetInfoDict"]){
        if ([change objectForKey:@"new"]) {
            self.headsetDict = bleSDK.mBleEntityM.mCmdManager.mTwsManager.headSetInfoDict;
            [self initWithData];
            [self requestDeviceImage];
            nameObject.detailStr = bleSDK.mBleEntityM.mCmdManager.mTwsManager.edrName;
        }
    }
    if([keyPath isEqualToString:@"dragWithMore"]){
        [self initWithUI];
    }
}

-(void)requestDeviceImage{
    
    if (self->deviceDic == nil) {
        
        NSString *uid = bleSDK.mBleEntityM.mUID;
        NSString *pid = bleSDK.mBleEntityM.mPID;
        
        if (uid.length == 0) uid = @"0000";
        if (pid.length == 0) pid = @"0000";
        
        NSNumber *vidNumber = [NSNumber numberWithLong:strtoul(uid.UTF8String, 0, 16)];
        NSString *vidStr = [vidNumber stringValue];
        
        NSNumber *pidNumber = [NSNumber numberWithLong:strtoul(pid.UTF8String, 0, 16)];
        NSString *pidStr = [pidNumber stringValue];
        
        
        NSArray *itemArr = @[@"PRODUCT_MESSAGE"];
        isLoadImage = YES;
        __weak typeof(self) wSelf = self;
        
        [bleSDK.mBleEntityM.mCmdManager cmdRequestDeviceImageVid:vidStr Pid:pidStr
                                                       ItemArray:itemArr Result:^(NSMutableDictionary * _Nullable dict) {
            if (dict) {
                NSData *data = dict[@"PRODUCT_MESSAGE"][@"IMG"];
                
                NSDictionary *totalDict = [DFTools jsonWithData:data];
                NSDictionary *myDic = totalDict[@"device"];
                kJLLog(JLLOG_DEBUG,@"服务器 ----->%@",myDic);
                self->deviceDic = myDic;
                if(self->deviceDic == nil){
                    [wSelf localDeviceJson];
                }else{
                    [[JLCacheBox cacheUuid:self->bleSDK.mBleUUID] setLedDic:myDic];
                    [self setTitleArray:myDic];
                }
            }else{
                [wSelf localDeviceJson];
            }
            self->isLoadImage = NO;
        }];
    }
}


-(void)setHeadsetDict:(NSDictionary *)headsetDict{
    _headsetDict = headsetDict;
}


-(void)localDeviceJson{
    
    NSString *path;
    JLModel_Device *devModel = [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager outputDeviceModel];
    switch (devModel.sdkType) {
        case JL_SDKTypeAI:
            [self normalDeviceJson];
            break;
        case JL_SDKTypeST:
            [self normalDeviceJson];
            break;
        case JL_SDKType693xTWS:{
            path = [JL_Tools find:@"ac693x_headset_json.txt"];
            if ([[JL_RunSDK sharedMe] mBleEntityM].mProtocolType == PTLVersion) {
                path = [JL_Tools find:@"ac693x_headset_neck_json.txt"];
            }
        }break;
        case JL_SDKType695xSDK:{
            path = [JL_Tools find:@"ac695x_soundbox_json.txt"];
        }break;
        case JL_SDKType697xTWS:
            path = [JL_Tools find:@"ac697x_headset_json.txt"];
            break;
        case JL_SDKType696xSB:
            path = [JL_Tools find:@"ac696x_soundbox_json.txt"];
            break;
        case JL_SDKType696xTWS:
            path = [JL_Tools find:@"ac696x_soundbox_tws_json.txt"];
            break;
        case JL_SDKType695xSC:
            path = [JL_Tools find:@"ac695x_soundbox_json.txt"];
            break;
        case JL_SDKType695xWATCH:
            [self normalDeviceJson];
            break;
        case JL_SDKType701xWATCH:
            [self normalDeviceJson];
            break;
        case JL_SDKTypeManifestEarphone:
            path = [JL_Tools find:@"manifest_headset_json.txt"];
            break;
        case JL_SDKTypeManifestSoundbox:
            path = [JL_Tools find:@"manifest_soundbox_json.txt"];
            break;
        case JL_SDKTypeChargingCase:
            path = [JL_Tools find:@"ac697x_headset_json.txt"];
            break;
        case JL_SDKType707nWATCH:
            path = [JL_Tools find:@"ac696x_soundbox_tws_json.txt"];
            break;
        case JL_SDKTypeUnknown:
            [self normalDeviceJson];
            break;
    }
    
    NSData *localData = [NSData dataWithContentsOfFile:path];
    if (localData.length == 0) {
        kJLLog(JLLOG_DEBUG,@"加载本地json描述失败，请查看是否存在对应json！！！！");
        return;
    }
    NSDictionary *totalDict_1 = [DFTools jsonWithData:localData];
    deviceDic = totalDict_1[@"device"];
    
    [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setLedDic:deviceDic];
    [self setTitleArray:deviceDic];
}

-(void)normalDeviceJson{
    NSString *path;
    if (bleType == JL_DeviceTypeSoundBox) {
        path = [JL_Tools find:@"ac696x_soundbox_json.txt"];
        
    }else if (bleType == JL_DeviceTypeTWS) {
        path = [JL_Tools find:@"ac693x_headset_json.txt"];
    }else if (bleType == JL_DeviceTypeSoundCard) {
        path = [JL_Tools find:@"ac695x_soundbox_json.txt"];
        
    }else{
        path = [JL_Tools find:@"ac696x_soundbox_json.txt"];
    }
    NSData *localData = [NSData dataWithContentsOfFile:path];
    NSDictionary *totalDict_1 = [DFTools jsonWithData:localData];
    deviceDic = totalDict_1[@"device"];
    [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setLedDic:deviceDic];
    [self setTitleArray:deviceDic];
}


-(void)setTitleArray:(NSDictionary *)dict{
    if(dict[@"key_settings"]!=nil){
        isKeySetting = YES;
    }else{
        isKeySetting = NO;
    }
    [headSetView setFuncDict:dict];
    
}


-(void)initWithData{
    
    [self.settingArray removeAllObjects];
    
    [self localDeviceJson];
    
    if (self.headsetDict[@"KEY_SETTING"]) {
        //设备耳机的状态
        [sortTouchArray removeAllObjects];
        NSArray *keyArray = self.headsetDict[@"KEY_SETTING"];
        NSDictionary *oneClickLeftDic = keyArray[0];
        int leftKey = [oneClickLeftDic[@"KEY_FUNCTION"] intValue];
        DeviceInfoUsage *leftKeyUsage = [[DeviceInfoUsage alloc] init];
        leftKeyUsage.type = [DeviceInfoTools oneClickEarkeyFunc:leftKey];
        leftKeyUsage.title = kJL_TXT("left");
        leftKeyUsage.value = leftKey;
        leftKeyUsage.funcType = 0;
        leftKeyUsage.directionType = 0;
        [sortTouchArray addObject:leftKeyUsage];
        
        NSDictionary *oneClickRightDic = keyArray[1];
        int rightKey = [oneClickRightDic[@"KEY_FUNCTION"] intValue];
        DeviceInfoUsage *rightKeyUsage = [[DeviceInfoUsage alloc] init];
        rightKeyUsage.type = [DeviceInfoTools oneClickEarkeyFunc:rightKey];
        rightKeyUsage.title = kJL_TXT("right");
        rightKeyUsage.value = rightKey;
        rightKeyUsage.funcType = 0;
        rightKeyUsage.directionType = 1;
        [sortTouchArray addObject:rightKeyUsage];
        
        [doubleTouchArray removeAllObjects];
        NSDictionary *twoClickLeftDic = keyArray[2];
        int twoLeftKey = [twoClickLeftDic[@"KEY_FUNCTION"] intValue];
        DeviceInfoUsage *twoLeftKeyUsage = [[DeviceInfoUsage alloc] init];
        twoLeftKeyUsage.type = [DeviceInfoTools oneClickEarkeyFunc:twoLeftKey];
        twoLeftKeyUsage.title = kJL_TXT("left");
        twoLeftKeyUsage.value = twoLeftKey;
        twoLeftKeyUsage.funcType = 1;
        twoLeftKeyUsage.directionType = 0;
        [doubleTouchArray addObject:twoLeftKeyUsage];
        
        NSDictionary *twoClickrightDic = keyArray[3];
        int twoRightKey = [twoClickrightDic[@"KEY_FUNCTION"] intValue];
        DeviceInfoUsage *twoRightKeyUsage = [[DeviceInfoUsage alloc] init];
        twoRightKeyUsage.type = [DeviceInfoTools oneClickEarkeyFunc:twoRightKey];
        twoRightKeyUsage.title = kJL_TXT("right");
        twoRightKeyUsage.value = twoRightKey;
        twoRightKeyUsage.funcType = 1;
        twoRightKeyUsage.directionType = 1;
        [doubleTouchArray addObject:twoRightKeyUsage];
    }
    
    if (bleType == JL_DeviceTypeTWS) {
        nameObject = [[NormalSettingObject alloc] init];
        nameObject.img = [UIImage imageNamed:@"Theme.bundle/mes_icon_name"];
        nameObject.funcStr = kJL_TXT("named");
        nameObject.funType = -1;
        if (bleSDK.mBleEntityM.mType == JL_AdvTypeTWS) {
            nameObject.detailStr = bleSDK.mBleEntityM.mCmdManager.mTwsManager.edrName;
        }else{
            nameObject.detailStr = bleSDK.mBleEntityM.mItem;
        }
        [self.settingArray addObject:nameObject];
    }

    if (_headsetDict[@"WORK_MODE"]) {
        NormalSettingObject *workModel = [[NormalSettingObject alloc] init];
        workModel.img = [UIImage imageNamed:@"Theme.bundle/mes_icon_mode"];
        workModel.funcStr = kJL_TXT("work_mode");
        workModel.funType = 2;
        
        //        kJLLog(JLLOG_DEBUG,@"WORK_MODE:%@",_headsetDict[@"WORK_MODE"]);
        
        if ([_headsetDict[@"WORK_MODE"] intValue] == 1) {
            workModel.detailStr = kJL_TXT("normal_model");
        }else if ([_headsetDict[@"WORK_MODE"] intValue] == 2) {
            workModel.detailStr = kJL_TXT("game_model");
        }
        if (deviceDic) {
            workModel.detailStr = [DeviceInfoTools mic_channel:[_headsetDict[@"WORK_MODE"] intValue] withKey:@"work_mode" basicDict:deviceDic];
        }
        [self.settingArray addObject:workModel];
    }
    
    if (_headsetDict[@"MIC_MODE"]) {
        NormalSettingObject *mic = [[NormalSettingObject alloc] init];
        mic.img = [UIImage imageNamed:@"Theme.bundle/mes_icon_mic"];
        mic.funcStr = kJL_TXT("mic_channel");
        mic.funType = 3;
        kJLLog(JLLOG_DEBUG,@"MIC_MODE:%@",_headsetDict[@"MIC_MODE"]);
        if ([_headsetDict[@"MIC_MODE"] intValue] == 1) {
            mic.detailStr = kJL_TXT("auto_exchange");
            if (deviceDic) {
                mic.detailStr = [DeviceInfoTools mic_channel:1 withKey:@"mic_channel" basicDict:deviceDic];
            }
        }else if ([_headsetDict[@"MIC_MODE"] intValue] == 2){
            if (bleType == JL_DeviceTypeSoundBox) {
                mic.detailStr = kJL_TXT("alway_main_box");
                if (deviceDic) {
                    mic.detailStr = [DeviceInfoTools mic_channel:2 withKey:@"mic_channel" basicDict:deviceDic];
                }
            }
            if (bleType == JL_DeviceTypeTWS) {
                mic.detailStr = kJL_TXT("always_on_left");
                kJLLog(JLLOG_DEBUG,@"mic.detailStr:%@",mic.detailStr);
            }
            if (deviceDic) {
                mic.detailStr = [DeviceInfoTools mic_channel:2 withKey:@"mic_channel" basicDict:deviceDic];
            }
        }else if ([_headsetDict[@"MIC_MODE"] intValue] == 3){
            if (bleType == JL_DeviceTypeSoundBox) {
                mic.detailStr = kJL_TXT("alway_second_box");
            }
            if (bleType == JL_DeviceTypeTWS) {
                mic.detailStr = kJL_TXT("always_on_right");
            }
            
            if (deviceDic) {
                mic.detailStr = [DeviceInfoTools mic_channel:3 withKey:@"mic_channel" basicDict:deviceDic];
            }
        }
        [self.settingArray addObject:mic];
    }
    if (_headsetDict[@"LED_SETTING"]) {
        NormalSettingObject *flash = [[NormalSettingObject alloc] init];
        flash.img = [UIImage imageNamed:@"Theme.bundle/mes_icon_light"];
        flash.funcStr = kJL_TXT("led_settings");
        flash.funType = 10;
        [self.settingArray addObject:flash];
    }

    [upgradeArray removeAllObjects];
    if (deviceDic) {
        if ([deviceDic[@"has_ota"] intValue] == 1) {
            NormalSettingObject *obj = [NormalSettingObject new];
            obj.img = [UIImage imageNamed:@"Theme.bundle/icon_upgrade"];
            obj.funcStr = kJL_TXT("firmware_update");
            [upgradeArray addObject:obj];
        }
    }
    
    naviView.title = bleName;
    [self initWithUI];
}

-(void)initWithUI{
    JL_SDKType deviceType = [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager getDeviceModel].sdkType;
    if(noNetView == nil){
        noNetView = [[NoNetView alloc] initByFrame:CGRectMake(0,kJL_HeightNavBar, [UIScreen mainScreen].bounds.size.width, 40)];
        [self.view addSubview:noNetView];
    }
    if(noNetView){
        noNetView.hidden = YES;
    }
    [naviView.leftBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:naviView];
    
    [naviView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@kJL_HeightNavBar);
    }];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width-24.0;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (scrollView == nil) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(12, kJL_HeightNavBar+10, width, height-kJL_HeightNavBar-10)];
        [self.view addSubview:scrollView];
    }
    scrollView.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    /*--- 网络监测 ---*/
    AFNetworkReachabilityManager *net = [AFNetworkReachabilityManager sharedManager];
    [self actionNetStatus:net.networkReachabilityStatus];
    
    [net setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [self actionNetStatus:status];
    }];
    
    CGFloat eHeight = 0;
    CGFloat interval = 0;
    CGFloat rowHight = 55.0;
    CGFloat addHight = 15;
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    
    //MARK: - ANC降噪UI
    if(deviceModel.ancType == JL_AncTypeYES){
        if (headSetAncView) {
            headSetAncView.frame = CGRectMake(0, interval, width, 141);
        }else{
            headSetAncView = [[HeadSetANC alloc] initWithFrame:CGRectMake(0, 0, width, 141)];
            headSetAncView.delegate = self;
            [scrollView addSubview:headSetAncView];
        }
        [headSetAncView createData];
        interval+=addHight+141;
    }
    //MARK: - DHA助听器UI

    if (bleType == JL_DeviceTypeTWS && deviceModel.isSupportDhaFitting) {
        if(dhaFittingView){
            dhaFittingView.frame = CGRectMake(0, interval, width, 60);
            interval+=(60+addHight);
        }else{
            
            [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
            
            dhaFittingView = [[NormalSettingView alloc] initWithFrame:CGRectMake(0, interval, width, rowHight)];
            dhaFittingView.delegate = self;
            dhaFittingView.tag = 2;
            NSMutableArray *dhaFittingArray = [NSMutableArray new];
            NormalSettingObject *obj = [NormalSettingObject new];
            obj.img = [UIImage imageNamed:@"Theme.bundle/icon_earphone_60"];
            obj.funcStr = kJL_TXT("hearing_aid_fitting");
            [dhaFittingArray addObject:obj];
            
            [JLUI_Effect addShadowOnView:dhaFittingView];
            [dhaFittingView config:dhaFittingArray];
            dhaFittingView.layer.masksToBounds = YES;
            [scrollView addSubview:dhaFittingView];
            interval+=(rowHight+addHight);
        }
    }
    
    //MARK: - 双设备连接UI
    if (bleType == JL_DeviceTypeTWS && bleSDK.mBleEntityM.mCmdManager.mTwsManager.supports.isSupportDragWithMore){
        
        NSMutableArray *multiArray = [NSMutableArray new];
        NormalSettingObject *obj = [NormalSettingObject new];
        obj.img = [UIImage imageNamed:@"Theme.bundle/function_icon_connection"];
        obj.funcStr = kJL_TXT("dual_device_connection");
        obj.detailStr = bleSDK.mBleEntityM.mCmdManager.mTwsManager.dragWithMore ? kJL_TXT("on"):kJL_TXT("off");
        [multiArray addObject:obj];
        
        if (multiLinksView){
            multiLinksView.frame = CGRectMake(0, interval, width, 60);
            [multiLinksView config:multiArray];
            interval+=(60+addHight);
        }else{
            multiLinksView = [[NormalSettingView alloc] initWithFrame:CGRectMake(0, interval, width, rowHight)];
            multiLinksView.delegate = self;
            multiLinksView.tag = 3;

            [JLUI_Effect addShadowOnView:dhaFittingView];
            [multiLinksView config:multiArray];
            multiLinksView.layer.masksToBounds = YES;
            [scrollView addSubview:multiLinksView];
            interval+=(rowHight+addHight);
        }
    }
    
    //MARK: - 按钮设置UI
    if (self.headsetDict[@"KEY_SETTING"] && isKeySetting == YES) {
        
        if (protrocolVersion == PTLVersion) {
            eHeight = 45 + rowHight*sortTouchArray.count;
        }else{
            eHeight = 45*2 + rowHight*sortTouchArray.count + rowHight*doubleTouchArray.count;
        }
        if (headSetView) {
            headSetView.frame = CGRectMake(0, interval, width, eHeight);
        }else{
            if (protrocolVersion == PTLVersion) {
                
                headSetView = [[HeadSetControlView2 alloc] initWithFrame:CGRectMake(0, interval, width, eHeight)];
            }else{
                
                headSetView = [[HeadSetControlView alloc] initWithFrame:CGRectMake(0, interval, width, eHeight)];
            }
            headSetView.delegate = self;
            [JLUI_Effect addShadowOnView:headSetView];
            headSetView.layer.masksToBounds = YES;
            
            if (bleType == JL_DeviceTypeTWS) {
                [scrollView addSubview:headSetView];
            }
            
            if (bleType == JL_DeviceTypeChargingBin
                && [[JL_RunSDK sharedMe] isBr35ChargeBin]) {
                [scrollView addSubview:headSetView];
            }
        }
        [headSetView initWithDataWithSort:sortTouchArray withDouble:doubleTouchArray];
        
        interval+=addHight;
    }
    
    //MARK: - 设置内容UI
    if (self.settingArray.count > 0) {
        CGFloat sHeight = 0;
        sHeight = rowHight*self.settingArray.count;
        if (settingView) {
            
            if (bleType == JL_DeviceTypeSoundBox || bleType == JL_DeviceTypeSoundCard || bleType == JL_DeviceTypeChargingBin) {
                settingView.frame = CGRectMake(0, 0, width, sHeight);
            }
            if (bleType == JL_DeviceTypeTWS) {
                settingView.frame = CGRectMake(0, eHeight+interval, width, sHeight);
            }
        }else{
            if (bleType == JL_DeviceTypeSoundBox || bleType == JL_DeviceTypeSoundCard || bleType == JL_DeviceTypeChargingBin) {
                settingView = [[NormalSettingView alloc] initWithFrame:CGRectMake(0, 0, width, sHeight)];
            }
            if (bleType == JL_DeviceTypeTWS) {
                settingView = [[NormalSettingView alloc] initWithFrame:CGRectMake(0, eHeight+interval, width, sHeight)];
            }
            if (settingView) {
                [JLUI_Effect addShadowOnView:settingView];
                settingView.delegate = self;
                settingView.tag = 0;
                settingView.layer.masksToBounds = YES;
                [scrollView addSubview:settingView];
            }
        }
        if (settingView) {
            [settingView config:self.settingArray];
            interval+=addHight;
            eHeight+=sHeight;
        }
    }
   
    
    //MARK: - 智能保护盒设置
    if(deviceType == JL_SDKTypeChargingCase){
        NSMutableArray *colorArray = [NSMutableArray new];
        NormalSettingObject *obj = [NormalSettingObject new];
        obj.img = [UIImage imageNamed:@"Theme.bundle/function_icon_bay"];
        obj.funcStr = kJL_TXT("Charging Case Setting");
        [colorArray addObject:obj];
        if (colorScreenBoxView){
            colorScreenBoxView.frame = CGRectMake(0, eHeight+interval, width, rowHight);
            [colorScreenBoxView config:colorArray];
            interval+=(rowHight+addHight);
        }else{
            colorScreenBoxView = [[NormalSettingView alloc] initWithFrame:CGRectMake(0, eHeight+interval, width, rowHight)];
            colorScreenBoxView.delegate = self;
            colorScreenBoxView.tag = 4;
            [JLUI_Effect addShadowOnView:colorScreenBoxView];
            [colorScreenBoxView config:colorArray];
            colorScreenBoxView.layer.masksToBounds = YES;
            [scrollView addSubview:colorScreenBoxView];
            interval+=(rowHight+addHight);
        }
    }
    
    //MARK: -天气推送内容
    if (deviceType == JL_SDKTypeChargingCase) {
        if (weatherPushView) {
            weatherPushView.frame = CGRectMake(0, eHeight+interval, width, rowHight);
        }else{
            weatherPushView = [[SwitchSettingView alloc] init];
            [weatherPushView config:kJL_TXT("Weather push") :@"function_icon_bay" :[SettingDefault getWeatherPush]];
            weatherPushView.frame = CGRectMake(0, eHeight+interval, width, rowHight);
            [JLUI_Effect addShadowOnView:weatherPushView];
            weatherPushView.layer.masksToBounds = YES;
            [scrollView addSubview:weatherPushView];
            weatherPushView.switchBlock = ^(BOOL value) {
                [SettingDefault setWeatherPush:value];
            };
        }
        interval+=addHight;
        eHeight+=rowHight;
    }
    
    //MARK: - 更新固件
    if (upgradeArray.count>0) {
        if (updateView) {
            updateView.frame = CGRectMake(0, eHeight+interval, width, rowHight);
        }else{
            updateView = [[NormalSettingView alloc] initWithFrame:CGRectMake(0, eHeight+interval, width, rowHight)];
            updateView.delegate = self;
            updateView.tag = 1;
            [JLUI_Effect addShadowOnView:updateView];
            updateView.layer.masksToBounds = YES;
            [updateView config:upgradeArray];
            [scrollView addSubview:updateView];
        }
        interval+=addHight;
        eHeight+=rowHight;
    }
    

    //MARK: - 断连按钮UI
    if (deleteBtn) {
        if (bleType == JL_DeviceTypeSoundBox || bleType == JL_DeviceTypeSoundCard) {
            deleteBtn.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height-185, width, rowHight);
        }
        if (bleType == JL_DeviceTypeTWS || bleType == JL_DeviceTypeChargingBin) {
            deleteBtn.frame = CGRectMake(0, eHeight+interval, width, rowHight);
        }
    }else{
        
        if (bleType == JL_DeviceTypeSoundBox || bleType == JL_DeviceTypeSoundCard) {
            deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height-185, width, rowHight)];
        }
        if (bleType == JL_DeviceTypeTWS || bleType == JL_DeviceTypeChargingBin) {
            deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, eHeight+interval, width, rowHight)];
        }
        deleteBtn.titleLabel.font = FontMedium(18.0);
        [deleteBtn setTitleColor:[UIColor colorWithRed:225.0/255.0 green:88.0/255.0 blue:88.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        deleteBtn.layer.shadowColor = [UIColor colorWithRed:205/255.0 green:230/255.0 blue:251/255.0 alpha:0.2].CGColor;
        deleteBtn.layer.shadowOffset = CGSizeMake(0,1);
        deleteBtn.layer.shadowOpacity = 1;
        deleteBtn.layer.shadowRadius = 8;
        deleteBtn.layer.borderWidth = 0.5;
        deleteBtn.layer.borderColor = [UIColor colorWithRed:237/255.0 green:125/255.0 blue:125/255.0 alpha:1.0].CGColor;
        deleteBtn.layer.cornerRadius = 4;
        [deleteBtn setTitle:kJL_TXT("disconnect_device") forState:UIControlStateNormal];
        [deleteBtn setBackgroundColor:[UIColor whiteColor]];
        [deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:deleteBtn];
    }
    
    interval+=addHight;
    eHeight+=rowHight;
    
    if((bleType == JL_DeviceTypeTWS || bleType == JL_DeviceTypeChargingBin) && deviceModel.ancType == JL_AncTypeYES){
        scrollView.contentSize = CGSizeMake(width, 120+eHeight+interval);
    }else{
        scrollView.contentSize = CGSizeMake(width, eHeight+interval);
    }
    scrollView.showsVerticalScrollIndicator = NO;
    
    scrollView.layer.cornerRadius = 13;
    scrollView.layer.shadowRadius = 5;
    scrollView.layer.shadowOpacity= 1;
    scrollView.layer.shadowOffset = CGSizeMake(0, 2);
    scrollView.layer.shadowColor  = kDF_RGBA(205, 230, 251, 0.2).CGColor;
}

-(void)deleteBtnAction{
    
    JL_EntityM *entity = bleSDK.mBleEntityM;
    kJLLog(JLLOG_DEBUG,@"---> 用户主动断开设备：%@",entity.mItem);
    [entity logProperties];
    [[ElasticHandler sharedInstance] addToBackList:entity];
    [bleSDK.mBleMultiple disconnectEntity:entity Result:^(JL_EntityM_Status status) {
        if (status == JL_EntityM_StatusDisconnectOk) {
            [self.navigationController popViewControllerAnimated:true];
        }
    }];
}



- (void)backBtnAction{
    [self.navigationController popViewControllerAnimated:true];
}



#pragma mark - 网络监测
-(void)actionNetStatus:(AFNetworkReachabilityStatus)status{
    CGFloat width = [UIScreen mainScreen].bounds.size.width-24.0;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    if (status == AFNetworkReachabilityStatusNotReachable) {
        //kJLLog(JLLOG_DEBUG,@"---> AFNetworkReachabilityStatusNotReachable");
        if(noNetView){
            noNetView.hidden = NO;
        }
        if([UIScreen mainScreen].bounds.size.width == 320.0){
            scrollView.frame = CGRectMake(12, noNetView.frame.origin.y
                                          +noNetView.frame.size.height+5, width, height-kJL_HeightNavBar-10);
        }else{
            scrollView.frame = CGRectMake(12, kJL_HeightNavBar+noNetView.frame.size.height+5, width, height-kJL_HeightNavBar-40);
        }
    }
    if (status == AFNetworkReachabilityStatusUnknown) {
        //kJLLog(JLLOG_DEBUG,@"---> AFNetworkReachabilityStatusUnknown");
        if(noNetView){
            noNetView.hidden = NO;
        }
        if([UIScreen mainScreen].bounds.size.width == 320.0){
            scrollView.frame = CGRectMake(12, noNetView.frame.origin.y
                                          +noNetView.frame.size.height+5, width, height-kJL_HeightNavBar-10);
        }else{
            scrollView.frame = CGRectMake(12, kJL_HeightNavBar+noNetView.frame.size.height+5, width, height-kJL_HeightNavBar-40);
        }
    }
    if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        //kJLLog(JLLOG_DEBUG,@"---> AFNetworkReachabilityStatusReachableViaWWAN");
        if(noNetView){
            noNetView.hidden = YES;
        }
        if([UIScreen mainScreen].bounds.size.width == 320.0){
            scrollView.frame =CGRectMake(12, 74+10, width, height-kJL_HeightNavBar-10);
        }else{
            scrollView.frame =CGRectMake(12, kJL_HeightNavBar+10, width, height-kJL_HeightNavBar-10);
        }
    }
    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        //kJLLog(JLLOG_DEBUG,@"---> AFNetworkReachabilityStatusReachableViaWiFi");
        if(noNetView){
            noNetView.hidden = YES;
        }
        if([UIScreen mainScreen].bounds.size.width == 320.0){
            scrollView.frame =CGRectMake(12, 74+10, width, height-kJL_HeightNavBar-10);
        }else{
            scrollView.frame =CGRectMake(12, kJL_HeightNavBar+10, width, height-kJL_HeightNavBar-10);
        }
    }
}


-(void)noteSetHeadsetErr:(NSNotification*)note{
    NSDictionary *dict = note.object;
    NSString *uuid = dict[kJL_MANAGER_KEY_UUID];
    JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
    
    if (type == JLUuidTypeInUse) {
        //0x00：成功
        //0x01：游戏模式导致设置失效
        //0x02：蓝牙名字长度超出限制
        //0x03：非蓝牙模式设置闪灯失败
        NSString *txt = kJL_TXT("settings_failed");
        int num = [dict[kJL_MANAGER_KEY_OBJECT] intValue];
        if (num == 0x00) txt = kJL_TXT("setting_success");
        if (num == 0x01) txt = kJL_TXT("setting_failed_in_game");
        if (num == 0x02) txt = kJL_TXT("setting_failed_long_name");
        if (num == 0x03) txt = kJL_TXT("setting_failed_not_in_ble");
        UIWindow *win = [DFUITools getWindow];
        if(num!=0x00) [DFUITools showText:txt onView:win delay:1.0];
    }
}

-(void)dealloc{
    //kJLLog(JLLOG_DEBUG,@"dealloc removeNote");
    [self removeNote];
}


-(void)removeNote{
    [JL_Tools remove:kJL_MANAGER_HEADSET_SET_ERR Own:self];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)addNote{
    [JL_Tools add:kJL_MANAGER_HEADSET_SET_ERR Action:@selector(noteSetHeadsetErr:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kJL_BLE_M_OFF Action:@selector(noteDeviceClose:) Own:self];
    
}


-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline){
        
        /*--- 正在OTA不退出界面 ---*/
        NSString *otaUuid = [[JLUI_Cache sharedInstance] otaUUID];
        if (otaUuid.length > 0) return;
        
        [self.navigationController popViewControllerAnimated:true];
    }
}

-(void)noteDeviceClose:(NSNotification *)note{
    [self.navigationController popViewControllerAnimated:true];
}




#pragma mark <- HeadSet Delegate ->

-(void)headSetControlDidTouch:(DeviceInfoUsage *)usage{
    NSDictionary *keysettings = deviceDic[@"key_settings"];
    HeadphoneFunVC *vc = [[HeadphoneFunVC alloc] init];
    vc.funType = usage.funcType;
    vc.headsetDict = _headsetDict;
    vc.directionType = usage.directionType;
    vc.key_function = keysettings[@"key_function"];
    vc.oneClickkeyFunc = usage.value;
    vc.titleStr = usage.titleStr;
    vc.tapNameStr = usage.tapNameStr;
    vc.modalPresentationStyle = 0;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark <- SettingView Deleagate ->
#pragma mark <- upgradeView delegate ->
-(void)noremalSetting:(NormalSettingView *)view Selected:(NormalSettingObject *)object{
    if ([view isEqual:settingView]) {
        JLModel_Device *deviceModel = [JL_RunSDK sharedMe].mBleEntityM.mCmdManager.outputDeviceModel;
        if(object.funType == -1){
            if (deviceModel.sdkType == JL_SDKType693xTWS ||
                deviceModel.sdkType == JL_SDKType695xSDK ||
                deviceModel.sdkType == JL_SDKType696xTWS ||
                deviceModel.sdkType == JL_SDKType697xTWS ||
                deviceModel.sdkType == JL_SDKType696xSB ||
                deviceModel.sdkType == JL_SDKTypeManifestEarphone ||
                deviceModel.sdkType == JL_SDKTypeManifestSoundbox){
                rnameView = [[ReNameView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
                rnameView.delegate = self;
                rnameView.type = 0;
                rnameView.nameTxfd.text = bleName;
                [self.view addSubview:rnameView];
            }
        }
        if (deviceDic == nil) {
            [self localDeviceJson];
            kJLLog(JLLOG_DEBUG,@"-----> noremalSetting localDeviceJson");
        }
        if (isLoadImage == YES) {
            kJLLog(JLLOG_DEBUG,@"-----> Loading Device Message...");
        }
        if (object.funType == 3) {
            HeadphoneFunVC *vc = [[HeadphoneFunVC alloc] init];
            vc.funType = object.funType;;
            vc.micMode = [self.headsetDict[@"MIC_MODE"] intValue];
            vc.mic_channel = deviceDic[@"mic_channel"];
            vc.workMode = [self.headsetDict[@"WORK_MODE"] intValue];
            vc.modalPresentationStyle = 0;
            [self presentViewController:vc animated:YES completion:nil];
        }
        if (object.funType == 2) {
            
            HeadphoneFunVC *vc = [[HeadphoneFunVC alloc] init];
            vc.funType = 2;
            vc.workMode = [_headsetDict[@"WORK_MODE"] intValue];
            vc.work_mode = deviceDic[@"work_mode"];
            vc.modalPresentationStyle = 0;
            [self presentViewController:vc animated:YES completion:nil];
        }
        
        if (object.funType == 10) {
            //FlashSettingVC *vc = [[FlashSettingVC alloc] init];
            //vc.modalPresentationStyle = 0;
            //[self presentViewController:vc animated:YES completion:nil];
            
            FlashDeviceVC *vc = [[FlashDeviceVC alloc] init];
            vc.modalPresentationStyle = 0;
            vc.jsonDict = [NSDictionary dictionaryWithDictionary:deviceDic];
            vc.infoDict = [NSDictionary dictionaryWithDictionary:self.headsetDict];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    if ([view isEqual:updateView]) {
        
        
        UpgradeVC *vc = [[UpgradeVC alloc] init];
        vc.otaEntity  = bleSDK.mBleEntityM;
        vc.rootNumber = 2;
        vc.modalPresentationStyle = 0;
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    if([view isEqual:dhaFittingView]){
#if(DHAUITest == 0)
        [JLDhaFitting auxiGetInfo:^(DhaFittingInfo * _Nonnull info, NSArray<NSNumber *> * _Nonnull gains) {
            if (info) {
                if (info.ch_num != 0) {
                    DhaFittingVC *vc = [[DhaFittingVC alloc] init];
                    [self.navigationController pushViewController:vc animated:true];
                }else{
                    Dialog()
                    //位置
                        .wToastPositionSet(DialogToastBottom)
                        .wTypeSet(DialogTypeToast)
                        .wMessageSet(kJL_TXT("msg_read_file_err_reading"))
                    //调整宽度
                        .wMainOffsetXSet(30)
                        .wStart();
                }
            }else{
                Dialog()
                //位置
                    .wToastPositionSet(DialogToastBottom)
                    .wTypeSet(DialogTypeToast)
                    .wMessageSet(kJL_TXT("msg_read_file_err_reading"))
                //调整宽度
                    .wMainOffsetXSet(30)
                    .wStart();
            }
        } Manager:[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager];
#elif (DHAUITest == 1)
        DhaFittingVC *vc = [[DhaFittingVC alloc] init];
        [self.navigationController pushViewController:vc animated:true];
#endif
        
    }
    
    if([view isEqual:multiLinksView]){
        MultiLinksViewController *vc = [[MultiLinksViewController alloc] init];
        [self.navigationController pushViewController:vc animated:true];
    }
    
    if([view isEqual:colorScreenBoxView]){
        __weak typeof(self) weakSelf = self;
        ColorScreenSetVC *vc = [[ColorScreenSetVC alloc] init];
        [vc initDataAction:^(BOOL status) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.navigationController pushViewController:vc animated:true];
        }];
    }
    
    
}

#pragma mark <- renameDelegate ->
-(void)didSelectBtnAction:(UIButton *)btn WithText:(NSString *)text{
    [rnameView removeFromSuperview];
    rnameView = nil;
    
    nameObject.detailStr = text;
    
    NSData *data =[text dataUsingEncoding:NSUTF8StringEncoding];
    [bleSDK.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetEdrName:data];
    
    mofifyNameAlert = [[MofifyNameAlert alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    mofifyNameAlert.funType = 0;
    [mofifyNameAlert updateAlertInfo];
    mofifyNameAlert.delegate = self;
    [self.view addSubview:mofifyNameAlert];
}

-(void)didSelectLeftAction:(UIButton *)btn WithText:(NSString *)text{
    
}

-(void)didSelectRightAction:(UIButton *)btn WithText:(NSString *)text{
    
}

#pragma mark <- MofifyNameAlertDelegate ->
-(void)didSelectBtnAction:(UIButton *)btn{
    [mofifyNameAlert removeFromSuperview];
    mofifyNameAlert = nil;
    
    [[DFAudioPlayer sharedMe] didPause];
    [[NetworkPlayer sharedMe] didStop];
    
    /*--- 更新数据库 ---*/
    DeviceObjc *objc = [[DeviceObjc alloc] init];
    objc.name = nameObject.detailStr;
    objc.type = (int)bleSDK.mBleEntityM.mType;
    objc.uuid = bleSDK.mBleUUID;
    objc.mProtocolType = bleSDK.mBleEntityM.mProtocolType;
    [[SqliteManager sharedInstance] updateDeviceByObjc:objc];
    
    /*--- 暂停广播包回连操作 ---*/
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
    
    /*--- 跟新SDK本地设备列表 ---*/
    [bleSDK.mBleMultiple updateHistoryRename:objc.name withUuid:objc.uuid];
    [[JLUI_Cache sharedInstance] setRenameUUID:objc.uuid];
    
    kJLLog(JLLOG_DEBUG,@"重启设备（改名）");
    [bleSDK.mBleEntityM.mCmdManager.mOTAManager cmdRebootForceDevice];
}

//MARK: - 通透降噪更多

-(void)headSetDenoiseMore:(JLModel_ANC *)deviceModelAnc{
    if(deviceModelAnc.mAncMode == JL_AncMode_Normal){
        [DFUITools showText:kJL_TXT("normal_model_cannot_entry") onView:self.view delay:1.0];
        return;
    }
    DenoiseVC *vc = [[DenoiseVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.model_ANC = deviceModelAnc;
    kJLLog(JLLOG_DEBUG,@"DenoiseVC:left:%d,right:%d",deviceModelAnc.mAncCurrent_L,deviceModelAnc.mAncCurrent_R);
    [self presentViewController:vc animated:YES completion:nil];
}


@end
