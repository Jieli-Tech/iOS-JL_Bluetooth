//
//  MultiMediaVC.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/13.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "MultiMediaVC.h"
#import "JLUI_Cache.h"
#import "TopView.h"
#import "FunctionModel.h"
#import "FunctionsView.h"
#import "DeviceChangeView.h"
#import "DeviceChangeModel.h"
#import "JL_RunSDK.h"
#import "SqliteManager.h"

#import "ToolViewNull.h"
#import "ToolViewMusic.h"
#import "ToolViewFM.h"
#import "ToolViewLineIn.h"
#import "ToolViewFMTX.h"
#import "ToolViewNetwork.h"

#import "LocalMusicVC.h"
#import "AppSettingVC.h"
#import "DeviceInfoVC.h"
#import "ElasticHandler.h"
#import "AlarmClockVC.h"
#import "NetworkRadioVC.h"
#import "LightControlVC.h"
#import "MapListVC.h"

#import "CorePlayer.h"
#import "DeviceMusicVC.h"
#import "DMusicHandler.h"
#import "KalaokModel.h"
#import "KaraokeVC.h"
#import "ShackHandler.h"

@interface MultiMediaVC ()<ToolViewMusicDelegate,ToolViewNetworkDelegate>{
    TopView         *topView;
    FunctionsView   *functionsView;
    ToolViewNull    *toolViewNull;
    ToolViewMusic   *toolViewMusic;
    ToolViewFM      *toolViewFm;
    ToolViewFMTX    *toolViewFmtx;
    ToolViewLineIn  *toolViewLineIn;
    ToolViewNetwork *toolViewNetwork;
    
    DFTips          *loadingTp;
    NSArray         *deviceCardArray;
    NSInteger       mIndex;
    
    DeviceChangeView *devView;
    BOOL             requestNetFlag;
}
@property (assign,nonatomic) float sw;
@property (assign,nonatomic) float sh;
@property (assign,nonatomic) float sGap_h;
@property (assign,nonatomic) float sGap_t;
@end

@implementation MultiMediaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
    
    /*--- 网络监测 ---*/
    AFNetworkReachabilityManager *net = [AFNetworkReachabilityManager sharedManager];
    [net startMonitoring];
    
    __weak typeof(self) wSelf = self;
    [JL_Tools delay:0.1 Task:^{
        [wSelf updateUI];
    }];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [wSelf updateUI];
//    });
    //NSLog(@"--------------------> chooseDiffMusic");
    [toolViewMusic chooseDiffMusic];
}

-(void)viewDidAppear:(BOOL)animated{
    [topView viewFirstLoad];
}

//static BOOL isShow = NO;
-(void)updateUI{
    _sh = [DFUITools screen_2_H];
    _sw = [DFUITools screen_2_W];

    requestNetFlag = NO;
    
    /*--- 顶部栏 ---*/
    __weak typeof(self) wSelf = self;
    topView = [[TopView alloc] init];
    [topView viewFirstLoad];
    [self.view addSubview:topView];

    /*--- 切换设备 ---*/
    [topView onBLK_Device:^{
        JL_BLEMultiple *multiple = [[JL_RunSDK sharedMe] mBleMultiple];
        if (multiple.bleManagerState == CBManagerStatePoweredOff) {
            [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self.view delay:1.0];
            return;
        }
        self->devView = [[DeviceChangeView alloc] init];
        [self->devView onShow];
        [self->devView setDeviceChangeBlock:^(NSString *uuid ,NSInteger index) {
            if (index != -1) {
                JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
                if (type == JLUuidTypeInUse) {
                    DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
                    vc.modalPresentationStyle = 0;
                    [wSelf presentViewController:vc animated:YES completion:nil];
                }
                
            }
        }];

    } BLK_Setting:^{
        AppSettingVC *vc = [[AppSettingVC alloc] init];
        vc.modalPresentationStyle = 0;
        [wSelf presentViewController:vc animated:YES completion:nil];
    }];
    


    /*--- 功能图标 ---*/
    NSArray *enArr = @[@(1),@(1),@(1),@(1),@(1),
                       @(1),@(1),@(1),@(1),@(1),@(1),@(0)];
    NSArray *mDataArray = [self functionViewArray:enArr];

    CGRect rect_2 = CGRectMake(0, 240+kJL_HeightStatusBar, _sw, _sh-240-kJL_HeightStatusBar-kJL_HeightTabBar);
    functionsView = [[FunctionsView alloc] initWithFrame:rect_2];
    //NSLog(@"setFunctionsViewDataArray 3---->%lu",(unsigned long)mDataArray.count);
    [functionsView setFunctionsViewDataArray:mDataArray];
    [self.view addSubview:functionsView];

    [functionsView onFunctionViewSelectIndex:^(NSInteger index) {
        [ShackHandler sharedInstance].index = index;
        self->mIndex = index;
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
        uint8_t funcSt = deviceModel.funcOnlineStatus;
        uint8_t funcEnable = funcSt&0x01;

        if (index == 0) {

            LocalMusicVC *vc = [[LocalMusicVC alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [wSelf presentViewController:vc animated:YES completion:nil];
        }

        if (index == 1) {

            if (funcEnable == 1) {
                if (![deviceModel.cardArray containsObject:@(JL_CardTypeUSB)]) {
                    [DFUITools showText:@"USB不在线" onView:self.view delay:1.0];
                    return;
                }
            }

            //[self showToolViewWithBit:0x0002];
            DeviceMusicVC *vc0 = [[DeviceMusicVC alloc] init];
            vc0.type = 0;
            vc0.devel = deviceModel;
            vc0.modalPresentationStyle = UIModalPresentationFullScreen;
            [wSelf presentViewController:vc0 animated:YES completion:nil];

        }

        if (index == 2) {

            if (funcEnable == 1) {
                if (![deviceModel.cardArray containsObject:@(JL_CardTypeSD_0)] &&
                    ![deviceModel.cardArray containsObject:@(JL_CardTypeSD_1)]) {
                    [DFUITools showText:@"SD卡不在线" onView:self.view delay:1.0];
                    return;
                }
            }

            //[self showToolViewWithBit:0x0002];

            DeviceMusicVC *vc0 = [[DeviceMusicVC alloc] init];
            vc0.type = 1;
            vc0.devel = deviceModel;
            vc0.modalPresentationStyle = UIModalPresentationFullScreen;
            [wSelf presentViewController:vc0 animated:YES completion:nil];
        }

        if (index == 3) {
            if (deviceModel.currentFunc != JL_FunctionCodeFMTX) {
                [self changeDeviceMode:JL_FunctionCodeFMTX];
                [wSelf showToolViewWithBit:0x0008];
            }
        }
        if (index == 4) {
            if (deviceModel.currentFunc != JL_FunctionCodeFM) {
                [self changeDeviceMode:JL_FunctionCodeFM];
                [wSelf showToolViewWithBit:0x0004];
            }
        }
        if (index == 5) {
            if (funcEnable == 1) {
                if (![deviceModel.cardArray containsObject:@(JL_CardTypeLineIn)]) {
                    [DFUITools showText:@"LineIn不在线" onView:self.view delay:1.0];
                    return;
                }
            }

            JLModel_Device *model_last = [entity.mCmdManager outputDeviceModel];
            if(model_last.currentFunc !=JL_FunctionCodeLINEIN){
                JL_FunctionCode func_last = model_last.currentFunc;

                [entity.mCmdManager cmdFunction:JL_FunctionCodeCOMMON Command:JL_FunctionCodeLINEIN Extend:0x00 Result:^(NSArray *array) {
                    [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeLINEIN Result:nil];

                    [JL_Tools delay:0.5 Task:^{
                        JLModel_Device *model_now = [entity.mCmdManager outputDeviceModel];
                        if (func_last == model_now.currentFunc) {
                            [DFUITools showText_1:kJL_TXT("模式切换失败") onView:self.view delay:1.0];
                            [wSelf viewWillAppear:nil];
                        }
                    }];
                }];
            }
        }
        if (index == 6) {
            JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
            [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON Result:nil];
            
            LightControlVC *vc = [[LightControlVC alloc] init];
            vc.modalPresentationStyle = 0;
            [wSelf presentViewController:vc animated:YES completion:nil];
        }
        if (index == 7) {
            AlarmClockVC *vc = [[AlarmClockVC alloc] init];
            vc.modalPresentationStyle = 0;
            [wSelf presentViewController:vc animated:YES completion:nil];
        }
        if (index == 8) {
            [self->functionsView setFunctionsViewSelectIndex:8];
            MapListVC *vc = [[MapListVC alloc] init];
            vc.modalPresentationStyle = 0;
            [wSelf presentViewController:vc animated:YES completion:nil];
        }
        if (index == 9) {

            BOOL isEdr = [self isEdrOK];
            if (isEdr == NO) return;
            
            /*--- 网络监测 ---*/
            AFNetworkReachabilityStatus netSt = [[JLUI_Cache sharedInstance] networkStatus];
            if (netSt == AFNetworkReachabilityStatusUnknown ||
                netSt == AFNetworkReachabilityStatusNotReachable) {
                [DFUITools showText:kJL_TXT("请连接网络") onView:self.view delay:1.0];
                return;
            }

            [self->functionsView setFunctionsViewSelectIndex:9];
            //[self showToolViewWithBit:0x0020];

            NetworkRadioVC *vc = [[NetworkRadioVC alloc] init];
            vc.modalPresentationStyle = 0;
            [wSelf presentViewController:vc animated:YES completion:nil];
        }
        if (index == 10) {
            BOOL isEdr = [self isEdrOK];
            if (isEdr == NO) return;
            
            /*--- 网络监测 ---*/
            AFNetworkReachabilityStatus netSt = [[JLUI_Cache sharedInstance] networkStatus];
            if (netSt == AFNetworkReachabilityStatusUnknown ||
                netSt == AFNetworkReachabilityStatusNotReachable) {
                [DFUITools showText:kJL_TXT("请连接网络") onView:self.view delay:1.0];
                return;
            }
            
            /*--- 卡拉OK ---*/
            KaraokeVC *vc = [[KaraokeVC alloc] init];
            vc.modalPresentationStyle = 0;
            vc.requestNetFlag = self->requestNetFlag;
            [wSelf presentViewController:vc animated:YES completion:nil];
        }
        if(index == 11){
            NSLog(@"index 11");
        }
    }];
    
    /*--- 工具卡片 ---*/
    toolViewNull = [[ToolViewNull alloc] init];
    [self.view addSubview:toolViewNull];
    
    toolViewMusic = [[ToolViewMusic alloc] init];
    toolViewMusic.delegate =self;
    [self.view addSubview:toolViewMusic];
    
    toolViewFm = [[ToolViewFM alloc] init];
    toolViewFm.onVC = self;
    [self.view addSubview:toolViewFm];

    toolViewFmtx = [[ToolViewFMTX alloc] init];
    toolViewFmtx.onVC = self;
    [self.view addSubview:toolViewFmtx];
    
    toolViewLineIn = [[ToolViewLineIn alloc] init];
    [self.view addSubview:toolViewLineIn];
    
    toolViewNetwork = [[ToolViewNetwork alloc] init];
    toolViewNetwork.delegate =self;
    [self.view addSubview:toolViewNetwork];
    
    [self showToolViewWithBit:0x0001];
}
            
-(void)changeDeviceMode:(JL_FunctionCode)code{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdFunction:JL_FunctionCodeCOMMON Command:code Extend:0x00 Result:^(NSArray *array) {
        if (code == JL_FunctionCodeBT) {

            LocalMusicVC *vc = [[LocalMusicVC alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
        }
        if (code == JL_FunctionCodeFM) {
            [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeFM Result:nil];
        }
        if (code == JL_FunctionCodeFMTX) {
            [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeFMTX Result:nil];
        }
    }];
}

-(NSArray*)functionViewArray:(NSArray*)enArr{
    NSArray *nameArr  = @[kJL_TXT("本地"),kJL_TXT("U盘"),kJL_TXT("SD卡"),
                          kJL_TXT("FM发射"),kJL_TXT("FM接收"),kJL_TXT("外部音源"),
                          kJL_TXT("灯效设置"),kJL_TXT("闹钟"),kJL_TXT("查找设备"),
                          kJL_TXT("网络电台"),kJL_TXT("卡拉OK"),kJL_TXT("手表")];
    
    NSArray *imgArr_1 = @[@"Theme.bundle/mul_icon_local_nor",@"Theme.bundle/mul_icon_usb_nor",@"Theme.bundle/mul_icon_sd_nor",
                          @"Theme.bundle/mul_icon_fm_nor",@"Theme.bundle/mul_icon_fm2_nor",@"Theme.bundle/mul_icon_linein_nor",
                          @"Theme.bundle/mul_icon_light_nol",@"Theme.bundle/mul_icon_clock_nol",@"Theme.bundle/mul_icon_lacation_nol",
                          @"Theme.bundle/mul_icon_radio_nol",@"Theme.bundle/mul_icon_mic_nol",@"Theme.bundle/mul_icon_watch_nol"];
    
    NSArray *imgArr_2 = @[@"Theme.bundle/mul_icon_local_dis",@"Theme.bundle/mul_icon_usb_dis",@"Theme.bundle/mul_icon_sd_dis",
                          @"Theme.bundle/mul_icon_fm_dis",@"Theme.bundle/mul_icon_fm2_dis",@"Theme.bundle/mul_icon_linein_dis",
                          @"Theme.bundle/mul_icon_linein_dis",@"Theme.bundle/mul_icon_linein_dis",@"Theme.bundle/mul_icon_linein_dis",
                          @"Theme.bundle/mul_icon_radio_nol",@"Theme.bundle/mul_icon_mic_nol",@"Theme.bundle/mul_icon_watch_nol"];

    NSMutableArray *mDataArray = [NSMutableArray new];
    for (int i = 0; i < nameArr.count; i++) {
        FunctionModel *model = [FunctionModel new];
        model.mName = nameArr[i];
        model.mImage_1 = imgArr_1[i];
        model.mImage_2 = imgArr_2[i];
        model.isEnable = YES; //[enArr[i] boolValue];
        model.type = i;
        if ([enArr[i] boolValue] == 1) {
            [mDataArray addObject:model];
        }
    }
    return mDataArray;
}

-(void)noteCardArray:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *devel = [entity.mCmdManager outputDeviceModel];
    deviceCardArray = devel.cardArray;
    if (![deviceCardArray containsObject:@(JL_CardTypeUSB)]) {
        [entity.mCmdManager cmdCleanCacheType:JL_CardTypeUSB];
    }
    if (![deviceCardArray containsObject:@(JL_CardTypeSD_0)]) {
        [entity.mCmdManager cmdCleanCacheType:JL_CardTypeSD_0];
    }
    if (![deviceCardArray containsObject:@(JL_CardTypeSD_1)]) {
        [entity.mCmdManager cmdCleanCacheType:JL_CardTypeSD_1];
    }
    
    [self updateMultiMediaUI];
}

-(void)noteCurrentFunction:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *devel = [entity.mCmdManager outputDeviceModel];
    if (devel.currentFunc == JL_FunctionCodeBT) {
        BOOL isRegister = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
        if (isRegister == NO) {
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            //NSLog(@"--->Begin ReceivingRemoteControlEvents 0");
        }
    }else{
        NSLog(@"关闭手机所有音乐.");
        [DFAudioPlayer didAllPause];
        [[CorePlayer shareInstanced] didStop];

        
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        NSLog(@"--->END ReceivingRemoteControlEvents 1");
    }
    [self updateMultiMediaUI];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeBleOFF) {
        [self setUINoDevice];
    }
    [self updateMultiMediaUI];
    if(type == JLDeviceChangeTypeSomethingConnected){
        
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
        uint32_t fun_karaoke  = 0;
        if (deviceModel.karaokeType == JL_KaraokeTypeNO) {
            fun_karaoke = 0;
        }else{
            fun_karaoke = 1;
        }
        if(fun_karaoke==1){
            [self reloadKalaokJsonData];
        }
    }
}

#pragma mark <- 获取卡拉OK的json数据 ->
-(void)reloadKalaokJsonData{
    JL_RunSDK  *bleSDK = [JL_RunSDK sharedMe];
    NSString *uid = bleSDK.mBleEntityM.mVID;
    NSString *pid = bleSDK.mBleEntityM.mPID;
    if (uid.length == 0) uid = @"0000";
    if (pid.length == 0) pid = @"0000";
    NSNumber *vidNumber = [NSNumber numberWithLong:strtoul(uid.UTF8String, 0, 16)];
    NSString *vidStr = [vidNumber stringValue];
    
    NSNumber *pidNumber = [NSNumber numberWithLong:strtoul(pid.UTF8String, 0, 16)];
    NSString *pidStr = [pidNumber stringValue];
    
    NSArray *itemArr = @[@"PRODUCT_SOUND_CARD"];
    
    //Vid:@"2" Pid:@"95"
    [bleSDK.mBleEntityM.mCmdManager cmdRequestDeviceImageVid:vidStr Pid:pidStr
                                                   ItemArray:itemArr Result:^(NSMutableDictionary * _Nullable dict) {
        if (dict) {
            self->requestNetFlag = YES;
            
            NSData *data = dict[@"PRODUCT_SOUND_CARD"][@"IMG"];
            NSDictionary *mKalaokDic = [DFTools jsonWithData:data];
            
            JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
            [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setHasKalaokEQ:mKalaokDic[@"hasEq"]];
            
            NSMutableArray *mTempDataArray = [NSMutableArray new];
            NSArray *functionArray = mKalaokDic[@"function"];
            for (int i = 0; i < functionArray.count; i++) {
                KalaokModel *myModel = [KalaokModel new];
                NSDictionary *data = functionArray[i];
                myModel.mId = [data[@"id"] integerValue];
                myModel.zh_name = data[@"title"][@"zh"];
                myModel.en_name = data[@"title"][@"en"];
                myModel.type = data[@"type"];
                myModel.icon_url = data[@"icon_url"];
                myModel.column = [data[@"column"] integerValue];
                myModel.row = [data[@"row"] integerValue];
                myModel.paging = [data[@"paging"] boolValue];
                myModel.mList = data[@"list"];

                [mTempDataArray addObject:myModel];
            }
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:[mTempDataArray copy]];
            NSString *key = [NSString stringWithFormat:@"SHENGKA_%@",bleSDK.mBleUUID];
            
            if (arrayData) [userDefaults setObject:arrayData forKey:key];
            [userDefaults synchronize];
        }else{
            self->requestNetFlag = NO;
        }
    }];
}

-(void)setUINoDevice{
    NSArray *enArr = @[@(1),@(1),@(1),@(1),@(1),
                       @(1),@(1),@(1),@(1),@(1),@(1),@(0)];
    NSArray *mDataArray = [self functionViewArray:enArr];
    //NSLog(@"setFunctionsViewDataArray 2---->%lu",(unsigned long)mDataArray.count);
    [functionsView setFunctionsViewDataArray:mDataArray];
    [self showToolViewWithBit:0x0001];
}

-(void)updateMultiMediaUI{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    if (entity == nil) {
        [self setUINoDevice];
        return;
    }
    
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    uint32_t function  = deviceModel.function;
    uint8_t  funcSt = deviceModel.funcOnlineStatus;

    uint32_t fun_bt       = 1;//function&0x01;
    uint32_t fun_music    = function>>1&0x01;
    uint32_t fun_rtc;
    uint32_t fun_linein   = function>>3&0x01;
    uint32_t fun_fm;
    uint32_t fun_light    = function>>5&0x01;
    uint32_t fun_fmtx;
    uint32_t fun_find_dev = 1;
    uint32_t fun_net_radio= funcSt>>4&0x01;
    uint32_t fun_karaoke  = 1;
    uint32_t fun_watch    = 0;
    uint32_t fun_usb = 0;
    uint32_t fun_sd  = 0;
    
    if(entity.mType == 1){
        fun_fm = 0;
        fun_fmtx = 0;
        fun_rtc = 0;
    }else{
        fun_fm =   function>>4&0x01;
        fun_fmtx = function>>6&0x01;
        fun_rtc =  function>>2&0x01;
    }
    
    /*--- USB/SD ---*/
    if (fun_music == 1) {
        uint8_t funcSt = deviceModel.funcOnlineStatus;
        uint8_t funcEnable = funcSt&0x01;
        uint8_t funcUsb    = funcSt>>1&0x01;
        uint8_t funcSd0    = funcSt>>2&0x01;
        uint8_t funcSd1    = funcSt>>3&0x01;
        
        if (funcEnable == 1) {
            if (funcUsb == 1 ) fun_usb = 1;
            if (funcSd0 == 1 || funcSd1 == 1) fun_sd = 0;
        }else{
            if (deviceModel.cardArray.count > 0) {
                if ([deviceModel.cardArray containsObject:@(JL_CardTypeUSB)]) {
                    fun_usb = 1;
                }
                if ([deviceModel.cardArray containsObject:@(JL_CardTypeSD_0)] ||
                    [deviceModel.cardArray containsObject:@(JL_CardTypeSD_1)]) {
                    fun_sd = 1;
                }
            }
        }
    }
    
    /*--- LineIn ---*/
    if (fun_linein == 1) {
        uint8_t funcSt = deviceModel.funcOnlineStatus;
        uint8_t funcEnable = funcSt&0x01;
        uint8_t funcLineIn = funcSt>>4&0x01;
        if (funcEnable == 1) {
            fun_linein = funcLineIn;
        }else{
            if ((deviceModel.cardArray.count > 0) && ([deviceModel.cardArray containsObject:@(JL_CardTypeLineIn)])) {
                fun_linein = 1;
            }else{
                fun_linein = 0;
            }
        }
    }
    
    /*--- 查找设备 ---*/
    if (deviceModel.searchType == JL_SearchTypeNO) {
        fun_find_dev = 0;
    }else{
        fun_find_dev = 1;
    }
    
    /*--- 卡拉OK ---*/
    if (deviceModel.karaokeType == JL_KaraokeTypeNO) {
        fun_karaoke = 0;
    }else{
        fun_karaoke = 1;
    }
    
    uint32_t funNetRadio = -1;
    if(fun_net_radio == 1){ //hide
        funNetRadio = 0;
    }
    if(fun_net_radio == 0){ //show
        funNetRadio = 1;
    }
    NSArray *enArr = @[@(fun_bt),@(fun_usb),@(fun_sd),
                       @(fun_fmtx),@(fun_fm),@(fun_linein),
                       @(fun_light),@(fun_rtc),@(fun_find_dev),
                       @(funNetRadio),@(fun_karaoke),@(fun_watch)];
    
    NSArray *mDataArray = [self functionViewArray:enArr];
    //NSLog(@"setFunctionsViewDataArray 1---->%lu",(unsigned long)mDataArray.count);
    [functionsView setFunctionsViewDataArray:mDataArray];

    uint8_t fun_current = deviceModel.currentFunc;
    [self updateToolViewWithFuctionCode:fun_current];
}

-(void)updateToolViewWithFuctionCode:(uint8_t)fun_current{
    //    if (fun_current == JL_FunctionCodeBT)    [functionsView setFunctionsViewSelectIndex:0];
    //    if (fun_current == JL_FunctionCodeMUSIC) [functionsView setFunctionsViewSelectIndex:1];
    //    if (fun_current == JL_FunctionCodeRTC)   [functionsView setFunctionsViewSelectIndex:7];
    //    if (fun_current == JL_FunctionCodeFMTX)  [functionsView setFunctionsViewSelectIndex:3];
    //    if (fun_current == JL_FunctionCodeFM)    [functionsView setFunctionsViewSelectIndex:4];
    //    if (fun_current == JL_FunctionCodeLIGHT) [functionsView setFunctionsViewSelectIndex:6];
    //    if (fun_current == JL_FunctionCodeLINEIN)[functionsView setFunctionsViewSelectIndex:5];
    if (fun_current == JL_FunctionCodeBT){
        CorePlayer *cp = [CorePlayer shareInstanced];
        if (cp.status == DFNetPlayer_STATUS_PLAY
            || cp.status == DFNetPlayer_STATUS_PENDING) {
            [self showToolViewWithBit:0x0020];
        }else{
            [self showToolViewWithBit:0x0002];
        }
    }
    
    if (fun_current == JL_FunctionCodeMUSIC) {
        [self showToolViewWithBit:0x0002];
    }
    
    if (fun_current == JL_FunctionCodeFM){
        [self showToolViewWithBit:0x0004];
    }
    
    if (fun_current == JL_FunctionCodeFMTX) {
        [self showToolViewWithBit:0x0008];
    }
    
    if (fun_current == JL_FunctionCodeLINEIN) {
        [self showToolViewWithBit:0x0010];
    }
}

-(void)updateMToolViewWithFuctionCode:(uint8_t)fun_current{
    //    if (fun_current == JL_FunctionCodeBT)    [functionsView setFunctionsViewSelectIndex:0];
    //    if (fun_current == JL_FunctionCodeMUSIC) [functionsView setFunctionsViewSelectIndex:1];
    //    if (fun_current == JL_FunctionCodeRTC)   [functionsView setFunctionsViewSelectIndex:7];
    //    if (fun_current == JL_FunctionCodeFMTX)  [functionsView setFunctionsViewSelectIndex:3];
    //    if (fun_current == JL_FunctionCodeFM)    [functionsView setFunctionsViewSelectIndex:4];
    //    if (fun_current == JL_FunctionCodeLIGHT) [functionsView setFunctionsViewSelectIndex:6];
    //    if (fun_current == JL_FunctionCodeLINEIN)[functionsView setFunctionsViewSelectIndex:5];
    if (fun_current == JL_FunctionCodeBT){
        CorePlayer *cp = [CorePlayer shareInstanced];
        if (cp.status == DFNetPlayer_STATUS_PLAY || cp.status == DFNetPlayer_STATUS_STOP
            || cp.status == DFNetPlayer_STATUS_PENDING) {
            [self showToolViewWithBit:0x0020];
        }else{
            [self showToolViewWithBit:0x0002];
        }
    }
    
    if (fun_current == JL_FunctionCodeMUSIC) {
        [self showToolViewWithBit:0x0002];
    }
    
    if (fun_current == JL_FunctionCodeFM){
        [self showToolViewWithBit:0x0004];
    }
    
    if (fun_current == JL_FunctionCodeFMTX) {
        [self showToolViewWithBit:0x0008];
    }
    
    if (fun_current == JL_FunctionCodeLINEIN) {
        [self showToolViewWithBit:0x0010];
    }
}

-(void)noteFunctionAction:(NSNotification*)note{
    NSInteger index = [[note object] intValue];
    if (index == 0) {
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
        if (model.currentFunc == JL_FunctionCodeBT){
            CorePlayer *cp = [CorePlayer shareInstanced];
            if (cp.status == DFNetPlayer_STATUS_PLAY ||
                cp.status == DFNetPlayer_STATUS_PENDING) {
                [self showToolViewWithBit:0x0020];
            }else{
                [self showToolViewWithBit:0x0002];
            }
        }
    }
    if (index == 9) [self showToolViewWithBit:0x0020];
}



-(void)showToolViewWithBit:(uint16_t)bit{
    uint16_t bit_0 = (bit>>0)&0x0001;
    uint16_t bit_1 = (bit>>1)&0x0001;
    uint16_t bit_2 = (bit>>2)&0x0001;
    uint16_t bit_3 = (bit>>3)&0x0001;
    uint16_t bit_4 = (bit>>4)&0x0001;
    uint16_t bit_5 = (bit>>5)&0x0001;
    
    toolViewNull.hidden   = bit_0?NO:YES;
    toolViewMusic.hidden  = bit_1?NO:YES;
    toolViewFm.hidden     = bit_2?NO:YES;
    toolViewFmtx.hidden   = bit_3?NO:YES;
    toolViewLineIn.hidden = bit_4?NO:YES;
    toolViewNetwork.hidden= bit_5?NO:YES;
}


-(void)noteCurrentFm:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    NSDictionary *dict = note.object;
    JLFMModel *fmModel = dict[kJL_MANAGER_KEY_OBJECT];
    [toolViewFm updateFmtxUI:fmModel.fmFrequency];
}

-(void)noteFmtxPoint:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    NSDictionary *dict = note.object;
    uint16_t fmtxPoint = (uint16_t)[dict[kJL_MANAGER_KEY_OBJECT] intValue];
    [toolViewFmtx updateFmtxUI:fmtxPoint];
}

#pragma mark 进入本地音乐或者设备音乐列表
-(void)enterList:(UIButton *)btn{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeBT){
        LocalMusicVC *vc = [[LocalMusicVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        if (model.currentCard == JL_CardTypeUSB) {
            self->mIndex = 1;
        }
        if (model.currentCard == JL_CardTypeSD_0 ||
            model.currentCard == JL_CardTypeSD_1) {
            self->mIndex = 2;
        }
        DeviceMusicVC *vc0 = [[DeviceMusicVC alloc] init];
        if(self->mIndex == 1){ //USB
            vc0.type = 0;
        }
        if(self->mIndex == 2){ //SD卡
            vc0.type = 1;
        }
        vc0.devel = model;
        vc0.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc0 animated:YES completion:nil];
    }
}

#pragma mark 进入网络电台列表
-(void)enterNetVC{
    NetworkRadioVC *vc = [[NetworkRadioVC alloc] init];
    vc.modalPresentationStyle = 0;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark 网络电台播放失败
-(void)noteNetPlayerERR:(NSNotification*)note{
    [self showToolViewWithBit:0x0020];
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    uint8_t fun_current = model.currentFunc;
    [self updateMToolViewWithFuctionCode:fun_current];
}


-(void)noteNetworkStatus:(NSNotification*)note{
    AFNetworkReachabilityManager *net = note.object;
    [[JLUI_Cache sharedInstance] setNetworkStatus:net.networkReachabilityStatus];
    NSLog(@"---> Network Status: %ld",(long)net.networkReachabilityStatus);
    
}

-(void)addNote{
    //[JL_Tools add:kJL_BLE_M_OFF Action:@selector(noteBleDisconnect:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JLModel_Device observeModelProperty:@"cardArray" Action:@selector(noteCardArray:) Own:self];
    [JLModel_Device observeModelProperty:@"currentFunc" Action:@selector(noteCurrentFunction:) Own:self];
    [JLModel_Device observeModelProperty:@"currentFm" Action:@selector(noteCurrentFm:) Own:self];//当前频点
    [JLModel_Device observeModelProperty:@"fmtxPoint" Action:@selector(noteFmtxPoint:) Own:self];//当前发射点
    [JL_Tools add:@"kUI_FUNCTION_ACTION" Action:@selector(noteFunctionAction:) Own:self];
    [JL_Tools add:@"kUI_NETPLAY_ERR" Action:@selector(noteNetPlayerERR:) Own:self];
    
    [JL_Tools add:AFNetworkingReachabilityDidChangeNotification Action:@selector(noteNetworkStatus:) Own:self];
}

-(BOOL)isEdrOK{
    /*--- 判断有无连经典蓝牙 ---*/
    NSDictionary *info = [JL_BLEApple outputEdrInfo];
    NSString *addr = info[@"ADDRESS"];
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    if (![addr isEqualToString:entity.mEdr]) {
        [DFUITools showText:kJL_TXT("请连接对应的设备蓝牙") onView:self.view delay:1.0];
        return NO;
    }
    return YES;
}

@end
