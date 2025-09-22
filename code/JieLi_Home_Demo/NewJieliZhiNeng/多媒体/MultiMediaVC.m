//
//  MultiMediaVC.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/13.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "MultiMediaVC.h"
#import "JLUI_Cache.h"
#import "JLCacheBox.h"
#import "TopView.h"
#import "FunctionModel.h"
#import "FunctionsView.h"
#import "DeviceChangeView.h"
#import "DeviceChangeModel.h"
#import "JL_RunSDK.h"
#import "SqliteManager.h"
#import "ColorScreenSetVC.h"

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

@interface MultiMediaVC ()<ToolViewMusicDelegate,ToolViewNetworkDelegate,MediasFuncsPtl>{
    TopView         *topView;
//    FunctionsView   *functionsView;
    MediasFuncsView *functionView;
    ToolViewNull    *toolViewNull;
    ToolViewMusic   *toolViewMusic;
    ToolViewFM      *toolViewFm;
    ToolViewFMTX    *toolViewFmtx;
    ToolViewLineIn  *toolViewLineIn;
    ToolViewNetwork *toolViewNetwork;
    ToolViewPCView  *toolViewPC;
    ToolViewSpdifView *toolViewSpdif;
    
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

static void *cardCurrentCtx = &cardCurrentCtx;

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
    [toolViewMusic chooseDiffMusic];
    JL_EntityM *entity = [JL_RunSDK sharedMe].mBleEntityM;
    if (entity){
        [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON Result:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [topView viewFirstLoad];
}

//static BOOL isShow = NO;
-(void)updateUI{
    _sh = [UIScreen mainScreen].bounds.size.height;
    _sw = [UIScreen mainScreen].bounds.size.width;

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
            [DFUITools showText:kJL_TXT("bluetooth_not_enable") onView:self.view delay:1.0];
            return;
        }
        self->devView = [[DeviceChangeView alloc] init];
        [self->devView onShow];
        [self->devView setDeviceChangeBlock:^(NSString *uuid ,NSInteger index) {
            if (index != -1) {
                JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
                if (type == JLUuidTypeInUse) {
                    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
                    if (bleSDK.mBleEntityM.mType == JL_DeviceTypeTWS) {
                        [bleSDK.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetGetAdvFlag:0x3F
                                                        Result:^(NSDictionary * _Nullable dict) {
                            
                            DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
                            vc.headsetDict = dict;
                            [wSelf.navigationController pushViewController:vc animated:true];
                        }];
                    }else{
                        DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
                        [wSelf.navigationController pushViewController:vc animated:true];
                    }
                    
                }
                
            }
        }];

    } BLK_Setting:^{
        AppSettingVC *vc = [[AppSettingVC alloc] init];
        vc.modalPresentationStyle = 0;
        [wSelf presentViewController:vc animated:YES completion:nil];
    }];
    

    /*--- 工具卡片 ---*/
    toolViewNull = [[ToolViewNull alloc] init];
    [self.view addSubview:toolViewNull];
    
    functionView = [MediasFuncsView new];
    [self.view addSubview:functionView];
    functionView.delegate  = self;
    
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
    
    toolViewPC = [[ToolViewPCView alloc] init];
    [self.view addSubview:toolViewPC];
    
    toolViewSpdif = [[ToolViewSpdifView alloc] init];
    [self.view addSubview:toolViewSpdif];
    
    [toolViewSpdif mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(wSelf.view).inset(10);
        make.height.equalTo(@168);
        make.centerY.equalTo(toolViewFm.mas_centerY);
    }];
    
    [toolViewPC mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(toolViewSpdif);
    }];
    
    [functionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(wSelf.view);
        make.bottom.equalTo(wSelf.view.mas_safeAreaLayoutGuideBottom);
        make.top.equalTo(toolViewFm.mas_bottom).offset(-10);
    }];
    
    [self showToolViewWithBit:0x0001];
    
}


            
-(void)changeDeviceMode:(JL_FunctionCode)code{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdFunction:JL_FunctionCodeCOMMON Command:code Extend:0x00 Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        
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
        if (code == JL_FunctionCodeSPDIF){
            [[SpdifPcViewModel share] getSpdifStatus:entity];
            [self showToolViewWithBit:0x0080];
        }
        if (code == JL_FunctionCodePCServer) {
            [[SpdifPcViewModel share] getSpdifStatus:entity];
            [self showToolViewWithBit:0x0040];
        }
    }];
}

-(void)noteCardArray:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *devel = [entity.mCmdManager outputDeviceModel];
    deviceCardArray = devel.cardArray;
    if (![deviceCardArray containsObject:@(JL_CardTypeUSB)]) {
        [entity.mCmdManager.mFileManager cmdCleanCacheType:JL_CardTypeUSB];
    }
    if (![deviceCardArray containsObject:@(JL_CardTypeSD_0)]) {
        [entity.mCmdManager.mFileManager cmdCleanCacheType:JL_CardTypeSD_0];
    }
    if (![deviceCardArray containsObject:@(JL_CardTypeSD_1)]) {
        [entity.mCmdManager.mFileManager cmdCleanCacheType:JL_CardTypeSD_1];
    }

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
        kJLLog(JLLOG_DEBUG,@"关闭手机所有音乐.");
        [DFAudioPlayer didAllPause];
        [[CorePlayer shareInstanced] didStop];

        
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        kJLLog(JLLOG_DEBUG,@"--->END ReceivingRemoteControlEvents 1");
    }
    
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeBleOFF) {
        [self showToolViewWithBit:0x0001];
    }
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


//MARK: - 选中项目
- (void)mediasHandleFuncSelect:(MediasModel *)model{
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    
    switch (model.type) {
        case MediasFuncTypeLocalBt:{
            LocalMusicVC *vc = [[LocalMusicVC alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
        }break;
        case MediasFuncTypeUsb:{
            DeviceMusicVC *vc0 = [[DeviceMusicVC alloc] init];
            vc0.type = JL_CardTypeUSB;
            vc0.devel = deviceModel;
            vc0.modalPresentationStyle = UIModalPresentationFullScreen;
            //针对部分特殊设备，需要设置设备存储位置，因为设备使用了引脚复用
            if (deviceModel.devPinMultiplex) {
                [entity.mCmdManager.mFileManager cmdSetDeviceStorage:deviceModel.handleUSBData Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                    if (status == JL_CMDStatusSuccess) {
                        [self presentViewController:vc0 animated:YES completion:nil];
                    }else{
                        [DFUITools showText:kJL_TXT("storage_setting_failed") onView:self.view delay:2];
                    }
                }];
            }else{
                [self presentViewController:vc0 animated:YES completion:nil];
            }
        }break;
        case MediasFuncTypeSd:{
            DeviceMusicVC *vc0 = [[DeviceMusicVC alloc] init];
            vc0.type = JL_CardTypeSD_0;
            vc0.devel = deviceModel;
            vc0.modalPresentationStyle = UIModalPresentationFullScreen;
            //针对部分特殊设备，需要设置设备存储位置，因为设备使用了引脚复用
            if (deviceModel.devPinMultiplex) {
                NSData *handleData = deviceModel.handleSD_0Data;
                for (NSNumber *number in deviceModel.cardArray) {
                    if ([number intValue] == JL_CardTypeSD_0) {
                        handleData = deviceModel.handleSD_0Data;
                        break;
                    }
                    if ([number intValue] == JL_CardTypeSD_1) {
                        handleData = deviceModel.handleSD_1Data;
                        break;
                    }
                }
                [entity.mCmdManager.mFileManager cmdSetDeviceStorage:handleData Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                    if (status == JL_CMDStatusSuccess) {
                        [self presentViewController:vc0 animated:YES completion:nil];
                    }else{
                        [DFUITools showText:kJL_TXT("storage_setting_failed") onView:self.view delay:2];
                    }
                }];
            }else{
                [self presentViewController:vc0 animated:YES completion:nil];
            }
        }break;
        case MediasFuncTypeFmtx:
            if (deviceModel.currentFunc != JL_FunctionCodeFMTX) {
                [self changeDeviceMode:JL_FunctionCodeFMTX];
                [self showToolViewWithBit:0x0008];
            }
            break;
        case MediasFuncTypeFm:{
            if (deviceModel.currentFunc != JL_FunctionCodeFM) {
                [self changeDeviceMode:JL_FunctionCodeFM];
                [self showToolViewWithBit:0x0004];
            }
        }break;
        case MediasFuncTypeLinein:{
            JLModel_Device *model_last = [entity.mCmdManager outputDeviceModel];
            if(model_last.currentFunc !=JL_FunctionCodeLINEIN){
                JL_FunctionCode func_last = model_last.currentFunc;
                [entity.mCmdManager cmdFunction:JL_FunctionCodeCOMMON Command:JL_FunctionCodeLINEIN Extend:0x00 Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                    [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeLINEIN Result:nil];
                    
                    [JL_Tools delay:0.5 Task:^{
                        JLModel_Device *model_now = [entity.mCmdManager outputDeviceModel];
                        if (func_last == model_now.currentFunc) {
                            [DFUITools showText_1:kJL_TXT("msg_error_switch_mode") onView:self.view delay:1.0];
                            [self viewWillAppear:nil];
                        }
                    }];
                }];
            }
        }break;
        case MediasFuncTypeLight:{
            JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
            [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON Result:nil];
            LightControlVC *vc = [[LightControlVC alloc] init];
            vc.modalPresentationStyle = 0;
            [self presentViewController:vc animated:YES completion:nil];
        }break;
        case MediasFuncTypeRtc:{
            AlarmClockVC *vc = [[AlarmClockVC alloc] init];
            vc.modalPresentationStyle = 0;
            [self presentViewController:vc animated:YES completion:nil];
        }break;
        case MediasFuncTypeSearchDev:{
            MapListVC *vc = [[MapListVC alloc] init];
            vc.modalPresentationStyle = 0;
            [self presentViewController:vc animated:YES completion:nil];
        }break;
        case MediasFuncTypeNetwork:{
            BOOL isEdr = [self isEdrOK];
            if (isEdr == NO) return;
            /*--- 网络监测 ---*/
            AFNetworkReachabilityStatus netSt = [[JLUI_Cache sharedInstance] networkStatus];
            if (netSt == AFNetworkReachabilityStatusUnknown ||
                netSt == AFNetworkReachabilityStatusNotReachable) {
                [DFUITools showText:kJL_TXT("please_connect_network") onView:self.view delay:1.0];
                return;
            }
            NetworkRadioVC *vc = [[NetworkRadioVC alloc] init];
            vc.modalPresentationStyle = 0;
            [self presentViewController:vc animated:YES completion:nil];
        }break;
        case MediasFuncTypeSoundCard:{
            BOOL isEdr = [self isEdrOK];
            if (isEdr == NO) return;
            /*--- 网络监测 ---*/
            AFNetworkReachabilityStatus netSt = [[JLUI_Cache sharedInstance] networkStatus];
            if (netSt == AFNetworkReachabilityStatusUnknown ||
                netSt == AFNetworkReachabilityStatusNotReachable) {
                [DFUITools showText:kJL_TXT("please_connect_network") onView:self.view delay:1.0];
                return;
            }
            /*--- 卡拉OK ---*/
            KaraokeVC *vc = [[KaraokeVC alloc] init];
            vc.modalPresentationStyle = 0;
            vc.requestNetFlag = self->requestNetFlag;
            [self presentViewController:vc animated:YES completion:nil];
        }break;
        case MediasFuncTypeWatch:{
            
        }break;
        case MediasFuncTypeSpdif: {
            [self changeDeviceMode:0x05];
            break;
        }
        case MediasFuncTypePcServer: {
            [self changeDeviceMode:0x06];
            break;
        }
        case MediasFuncTypeTranslate: {
            TranslationNavVC *vc = [[TranslationNavVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case MediasFuncTypeRecord: {
            TranslationRecorderVC *vc = [TranslationRecorderVC new];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        default:
            break;
    }


}

#pragma mark <- 获取卡拉OK的json数据 ->
-(void)reloadKalaokJsonData{
    JL_RunSDK  *bleSDK = [JL_RunSDK sharedMe];
    NSString *uid = bleSDK.mBleEntityM.mUID;
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




-(void)updateToolViewWithFuctionCode{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    if(entity == nil){
        [self showToolViewWithBit:0x0001];
        return;
    }
    uint8_t fun_current = [entity.mCmdManager outputDeviceModel].currentFunc;
    BOOL isOneDragTwo = entity.mCmdManager.mTwsManager.supports.isSupportDragWithMore;
    
    if (fun_current == JL_FunctionCodeBT){
        if (!isOneDragTwo){
            CorePlayer *cp = [CorePlayer shareInstanced];
            if (cp.status == DFNetPlayer_STATUS_PLAY
                || cp.status == DFNetPlayer_STATUS_PENDING) {
                [self showToolViewWithBit:0x0020];
            }else{
                [self showToolViewWithBit:0x0002];
            }
        }else{
            [self showToolViewWithBit:0x0001];
        }
        
    }
    if (fun_current == JL_FunctionCodeMUSIC) {
        if (!isOneDragTwo){
            [self showToolViewWithBit:0x0002];
        }else{
            [self showToolViewWithBit:0x0001];
        }
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
    if (fun_current == JL_FunctionCodePCServer){
        [self showToolViewWithBit:0x0040];
    }
    if (fun_current == JL_FunctionCodeSPDIF){
        [self showToolViewWithBit:0x0080];
    }
}

-(void)updateMToolViewWithFuctionCode:(uint8_t)fun_current{
 
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    BOOL isOneDragTwo = entity.mCmdManager.mTwsManager.supports.isSupportDragWithMore;
    
    if (fun_current == JL_FunctionCodeBT){
        if (!isOneDragTwo){
            CorePlayer *cp = [CorePlayer shareInstanced];
            if (cp.status == DFNetPlayer_STATUS_PLAY
                || cp.status == DFNetPlayer_STATUS_PENDING) {
                [self showToolViewWithBit:0x0020];
            }else{
                [self showToolViewWithBit:0x0002];
            }
        }else{
            [self showToolViewWithBit:0x0001];
        }
    }
    
    if (fun_current == JL_FunctionCodeMUSIC) {
        if (!isOneDragTwo){
            [self showToolViewWithBit:0x0002];
        }else{
            [self showToolViewWithBit:0x0001];
        }
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
    
    if (fun_current == JL_FunctionCodePCServer){
        [self showToolViewWithBit:0x0040];
    }
    if (fun_current == JL_FunctionCodeSPDIF){
        [self showToolViewWithBit:0x0080];
    }
}

-(void)noteFunctionAction:(NSNotification*)note{
    NSInteger index = [[note object] intValue];
    
    if (index == 0) {
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
        BOOL isOneDragTwo = entity.mCmdManager.mTwsManager.supports.isSupportDragWithMore;
        if (model.currentFunc == JL_FunctionCodeBT){
            if (!isOneDragTwo){
                CorePlayer *cp = [CorePlayer shareInstanced];
                if (cp.status == DFNetPlayer_STATUS_PLAY
                    || cp.status == DFNetPlayer_STATUS_PENDING) {
                    [self showToolViewWithBit:0x0020];
                }else{
                    [self showToolViewWithBit:0x0002];
                }
            }else{
                [self showToolViewWithBit:0x0001];
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
    uint16_t bit_6 = (bit>>6)&0x0001;
    uint16_t bit_7 = (bit>>7)&0x0001;
    
    
    toolViewNull.hidden   = bit_0?NO:YES;
    toolViewMusic.hidden  = bit_1?NO:YES;
    toolViewFm.hidden     = bit_2?NO:YES;
    toolViewFmtx.hidden   = bit_3?NO:YES;
    toolViewLineIn.hidden = bit_4?NO:YES;
    toolViewNetwork.hidden= bit_5?NO:YES;
    toolViewPC.hidden     = bit_6?NO:YES;
    toolViewSpdif.hidden  = bit_7?NO:YES;
}


-(void)noteCurrentFm:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    NSDictionary *dict = note.object;
    JLModel_FM *fmModel = dict[kJL_MANAGER_KEY_OBJECT];
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
    kJLLog(JLLOG_DEBUG,@"---> Network Status: %ld",(long)net.networkReachabilityStatus);
    
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
    [JLModel_Device observeModelProperty:@"currentFunc" Action:@selector(updateToolViewWithFuctionCode) Own:self];
    
    [[JL_RunSDK sharedMe] addObserver:self forKeyPath:@"mBleEntityM" options:NSKeyValueObservingOptionNew context:NULL];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"mBleEntityM"]) {
        [self updateToolViewWithFuctionCode];
    }
}

-(BOOL)isEdrOK{
    /*--- 判断有无连经典蓝牙 ---*/
    NSArray *infoArray = [JL_BLEMultiple outputEdrList];
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if (![infoArray containsObject:model.btAddr]) {
        [DFUITools showText:kJL_TXT("connect_right_bluetooth") onView:self.view delay:1.0];
        return NO;
    }
    return YES;
}


@end
