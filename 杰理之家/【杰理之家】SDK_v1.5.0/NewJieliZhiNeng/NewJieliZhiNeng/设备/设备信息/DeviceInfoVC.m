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
#import "HeadsetDenoise.h"
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


@interface DeviceInfoVC ()<HeadSetControlDelegate,NormalSettingDelegate,ReNameViewDelegate,MofifyNameAlertDelegate,HeadsetDenoiseDelegate>{
    
    HeadSetControlView *headSetView;
    HeadsetDenoise     *headSetDenoise;
    NormalSettingView *settingView;
    NormalSettingView *updateView;
    UIButton *deleteBtn;
    ReNameView *rnameView;
    MofifyNameAlert *mofifyNameAlert;
    __weak IBOutlet UILabel *titleLab;
    UIScrollView *scrollView;
    __weak IBOutlet NSLayoutConstraint *headHeight;
    
    NSMutableArray *sortTouchArray;
    NSMutableArray *doubleTouchArray;
    NSMutableArray *upgradeArray;
    NSDictionary *deviceDic;
    NormalSettingObject *nameObject; //蓝牙设备名字
    NoNetView *noNetView;
    
    JL_RunSDK   *bleSDK;
    NSString    *bleName;
    NSString    *bleUUID;
    int         bleType;
    BOOL        isLoadImage;
}

@end

@implementation DeviceInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sortTouchArray = [NSMutableArray new];
    doubleTouchArray = [NSMutableArray new];
    upgradeArray = [NSMutableArray new];
    [self addNote];
}

-(void)viewWillAppear:(BOOL)animated{
    [self requestData];
}

-(void)requestData{
    bleSDK = [JL_RunSDK sharedMe];
    
    bleName = bleSDK.mBleEntityM.mItem;
    bleType = bleSDK.mBleEntityM.mType;
    bleUUID = bleSDK.mBleEntityM.mUUID;
    
    [self initWithData];
    [self requestDeviceImage];
    
//    if (self.headsetDict == nil) {
        NSLog(@"---> 获取耳机信息... Info VC");
    
        __weak typeof(self) wSelf = self;
        [bleSDK.mBleEntityM.mCmdManager cmdHeatsetGetAdvFlag:0x3F
                                        Result:^(NSDictionary * _Nullable dict) {
            self.headsetDict = dict;
            [wSelf initWithData];
            [wSelf requestDeviceImage];
        }];
//    }else{
//        [self initWithData];
//        [self requestDeviceImage];
//    }
}

-(void)requestDeviceImage{
    
    if (self->deviceDic == nil) {

        NSString *uid = bleSDK.mBleEntityM.mVID;
        NSString *pid = bleSDK.mBleEntityM.mPID;
        //NSString *uid = self.headsetDict[@"UID"];
        //NSString *pid = self.headsetDict[@"PID"];
         
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
                //NSLog(@"服务器 ----->%@",myDic);
                self->deviceDic = myDic;
                [[JLCacheBox cacheUuid:self->bleSDK.mBleUUID] setLedDic:myDic];
                if(self->deviceDic == nil){
                    [wSelf localDeviceJson];
                }
            }else{
                [wSelf localDeviceJson];
            }
            self->isLoadImage = NO;
        }];
     }
}



-(NSDictionary*)localDeviceJson{
    NSDictionary *myDic_1 = nil;

    if (bleType == 0) {
        NSString *path = [JL_Tools find:@"ac696x_soundbox_json.txt"];
        NSData *localData = [NSData dataWithContentsOfFile:path];
        NSDictionary *totalDict_1 = [DFTools jsonWithData:localData];
        myDic_1 = totalDict_1[@"device"];
    }else if (bleType == 1) {
        NSDictionary *dict_1 = [bleSDK.mBleEntityM.mCmdManager localDeviceImage:@"setting_json.txt"];
        NSData *data_1 = dict_1[@"PRODUCT_MESSAGE"][@"IMG"];
        NSDictionary *totalDict_1 = [DFTools jsonWithData:data_1];
        myDic_1 = totalDict_1[@"device"];
    }else if (bleType == 4) {
        NSString *path = [JL_Tools find:@"ac695x_soundbox_json.txt"];
        NSData *localData = [NSData dataWithContentsOfFile:path];
        NSDictionary *totalDict_1 = [DFTools jsonWithData:localData];
        myDic_1 = totalDict_1[@"device"];
    }else{
        NSString *path = [JL_Tools find:@"ac696x_soundbox_json.txt"];
        NSData *localData = [NSData dataWithContentsOfFile:path];
        NSDictionary *totalDict_1 = [DFTools jsonWithData:localData];
        myDic_1 = totalDict_1[@"device"];
    }
    self->deviceDic = myDic_1;
    [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setLedDic:myDic_1];
    return myDic_1;
}


-(void)initWithData{
    
    if (self.headsetDict) {
        //设备耳机的状态
        [sortTouchArray removeAllObjects];
        NSArray *keyArray = self.headsetDict[@"KEY_SETTING"];
        NSDictionary *oneClickLeftDic = keyArray[0];
        int leftKey = [oneClickLeftDic[@"KEY_FUNCTION"] intValue];
        DeviceInfoUsage *leftKeyUsage = [[DeviceInfoUsage alloc] init];
        leftKeyUsage.type = [DeviceInfoTools oneClickEarkeyFunc:leftKey];
        leftKeyUsage.title = kJL_TXT("左");
        leftKeyUsage.value = leftKey;
        leftKeyUsage.funcType = 0;
        leftKeyUsage.directionType = 0;
        [sortTouchArray addObject:leftKeyUsage];
        
        NSDictionary *oneClickRightDic = keyArray[1];
        int rightKey = [oneClickRightDic[@"KEY_FUNCTION"] intValue];
        DeviceInfoUsage *rightKeyUsage = [[DeviceInfoUsage alloc] init];
        rightKeyUsage.type = [DeviceInfoTools oneClickEarkeyFunc:rightKey];
        rightKeyUsage.title = kJL_TXT("右");
        rightKeyUsage.value = rightKey;
        rightKeyUsage.funcType = 0;
        rightKeyUsage.directionType = 1;
        [sortTouchArray addObject:rightKeyUsage];
        
        [doubleTouchArray removeAllObjects];
        NSDictionary *twoClickLeftDic = keyArray[2];
        int twoLeftKey = [twoClickLeftDic[@"KEY_FUNCTION"] intValue];
        DeviceInfoUsage *twoLeftKeyUsage = [[DeviceInfoUsage alloc] init];
        twoLeftKeyUsage.type = [DeviceInfoTools oneClickEarkeyFunc:twoLeftKey];
        twoLeftKeyUsage.title = kJL_TXT("左");
        twoLeftKeyUsage.value = twoLeftKey;
        twoLeftKeyUsage.funcType = 1;
        twoLeftKeyUsage.directionType = 0;
        [doubleTouchArray addObject:twoLeftKeyUsage];
        
        NSDictionary *twoClickrightDic = keyArray[3];
        int twoRightKey = [twoClickrightDic[@"KEY_FUNCTION"] intValue];
        DeviceInfoUsage *twoRightKeyUsage = [[DeviceInfoUsage alloc] init];
        twoRightKeyUsage.type = [DeviceInfoTools oneClickEarkeyFunc:twoRightKey];
        twoRightKeyUsage.title = kJL_TXT("右");
        twoRightKeyUsage.value = twoRightKey;
        twoRightKeyUsage.funcType = 1;
        twoRightKeyUsage.directionType = 1;
        [doubleTouchArray addObject:twoRightKeyUsage];
    }
    
    nameObject = [[NormalSettingObject alloc] init];
    nameObject.img = [UIImage imageNamed:@"Theme.bundle/mes_icon_name"];
    nameObject.funcStr = kJL_TXT("名称");
    nameObject.funType = -1;
    nameObject.detailStr = bleName;
    
    NormalSettingObject *workModel = [[NormalSettingObject alloc] init];
    workModel.img = [UIImage imageNamed:@"Theme.bundle/mes_icon_mode"];
    workModel.funcStr = kJL_TXT("工作模式");
    workModel.funType = 2;

    
    if ([_headsetDict[@"WORK_MODE"] intValue] == 1) {
        workModel.detailStr = kJL_TXT("普通模式");
    }else if ([_headsetDict[@"WORK_MODE"] intValue] == 2) {
        workModel.detailStr = kJL_TXT("游戏模式");
    }
    
    
    NormalSettingObject *mic = [[NormalSettingObject alloc] init];
    mic.img = [UIImage imageNamed:@"Theme.bundle/mes_icon_mic"];
    mic.funcStr = kJL_TXT("麦克风");
    mic.funType = 3;
    
    if ([_headsetDict[@"MIC_MODE"] intValue] == 1) {
        mic.detailStr = kJL_TXT("自动切换");
    }else if ([_headsetDict[@"MIC_MODE"] intValue] == 2){
        if (bleType == 0) {
            mic.detailStr = kJL_TXT("始终主音箱");
        }
        if (bleType == 1) {
            mic.detailStr = kJL_TXT("始终左耳");
        }
    }else if ([_headsetDict[@"MIC_MODE"] intValue] == 3){
        if (bleType == 0) {
            mic.detailStr = kJL_TXT("始终副音箱");
        }
        if (bleType == 1) {
            mic.detailStr = kJL_TXT("始终右耳");
        }
    }
    
    NormalSettingObject *flash = [[NormalSettingObject alloc] init];
    flash.img = [UIImage imageNamed:@"Theme.bundle/mes_icon_light"];
    flash.funcStr = kJL_TXT("闪灯设置");
    flash.funType = 10;
    
    if (bleType == 1) {
        self.settingArray = @[nameObject,workModel,mic,flash];
    }else if (bleType == 4) {
        self.settingArray = @[nameObject];
    }else{
        self.settingArray = @[nameObject,flash];
    }
    
    [upgradeArray removeAllObjects];
    NormalSettingObject *obj = [NormalSettingObject new];
    obj.img = [UIImage imageNamed:@"Theme.bundle/icon_upgrade"];
    obj.funcStr = kJL_TXT("固件更新");
    [upgradeArray addObject:obj];
    
    titleLab.text = bleName;
    
    [self initWithUI];
}

-(void)initWithUI{
    
    
    if(noNetView == nil){
        noNetView = [[NoNetView alloc] initByFrame:CGRectMake(0,kJL_HeightNavBar, [UIScreen mainScreen].bounds.size.width, 40)];
        [self.view addSubview:noNetView];
    }
    if(noNetView){
        noNetView.hidden = YES;
    }
    
    headHeight.constant = kJL_HeightNavBar;
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
    
    if(bleType == 1 && deviceModel.ancType == JL_AncTypeYES){
        self->headSetDenoise = [[HeadsetDenoise alloc] initWithFrame:CGRectMake(0, 0, width, 141)];
        self->headSetDenoise.delegate = self;
        [self->scrollView addSubview:self->headSetDenoise];
        self->headSetDenoise.headsetDict = self.headsetDict;
        self->headSetDenoise.currentMode = deviceModel.mAncModeCurrent.mAncMode;
        self->headSetDenoise.layer.cornerRadius = 12;
        self->headSetDenoise.layer.masksToBounds = YES;
        interval+=addHight+141;
    }

    if (self.headsetDict) {
        eHeight = 45*2 + rowHight*sortTouchArray.count + rowHight*doubleTouchArray.count;
        if (headSetView) {
            headSetView.frame = CGRectMake(0, interval, width, eHeight);
        }else{
            headSetView = [[HeadSetControlView alloc] initWithFrame:CGRectMake(0, interval, width, eHeight)];
            headSetView.delegate = self;
            [JLUI_Effect addShadowOnView:headSetView];
            headSetView.layer.masksToBounds = YES;

            if (bleType == 1) {
                [scrollView addSubview:headSetView];
            }
        }
        [headSetView initWithDataWithSort:sortTouchArray withDouble:doubleTouchArray];
        
        interval+=addHight;
    }
    CGFloat sHeight = 0;
    if (self.settingArray) {
        sHeight = rowHight*self.settingArray.count;
        if (settingView) {

            if (bleType == 0 || bleType == 4) {
                settingView.frame = CGRectMake(0, 0, width, sHeight);
            }
            if (bleType == 1) {
                settingView.frame = CGRectMake(0, eHeight+interval, width, sHeight);
            }
        }else{
            if (bleType == 0 || bleType == 4) {
                settingView = [[NormalSettingView alloc] initWithFrame:CGRectMake(0, 0, width, sHeight)];
            }
            if (bleType == 1) {
                settingView = [[NormalSettingView alloc] initWithFrame:CGRectMake(0, eHeight+interval, width, sHeight)];
            }
            [JLUI_Effect addShadowOnView:settingView];
            settingView.delegate = self;
            settingView.tag = 0;
            settingView.layer.masksToBounds = YES;
            [scrollView addSubview:settingView];
        }
        [settingView config:self.settingArray];
        interval+=addHight;
    }
    CGFloat uHeight = 0;
    if (upgradeArray.count>0) {
        uHeight = rowHight;
        if (updateView) {

            if (bleType == 0 || bleType == 4) {
                updateView.frame = CGRectMake(0, settingView.frame.origin.y+settingView.frame.size.height+10, width, uHeight);
            }
            if (bleType == 1) {
                updateView.frame = CGRectMake(0, eHeight+sHeight+interval, width, uHeight);
            }
        }else{

            if (bleType == 0 || bleType == 4) {
                updateView = [[NormalSettingView alloc] initWithFrame:CGRectMake(0, settingView.frame.origin.y+settingView.frame.size.height+10, width, uHeight)];
            }
            if (bleType == 1) {
                updateView = [[NormalSettingView alloc] initWithFrame:CGRectMake(0, eHeight+sHeight+interval, width, uHeight)];
            }
            updateView.delegate = self;
            updateView.tag = 1;
            [JLUI_Effect addShadowOnView:updateView];
            updateView.layer.masksToBounds = YES;
            [updateView config:upgradeArray];
            [scrollView addSubview:updateView];
        }
        interval+=addHight;
    }
    
    CGFloat dHeight = rowHight;
    if (deleteBtn) {

        if (bleType == 0 || bleType == 4) {
            deleteBtn.frame = CGRectMake(0,[DFUITools screen_2_H]-185, width, dHeight);
        }
        if (bleType == 1) {
            deleteBtn.frame = CGRectMake(0, eHeight+sHeight+interval+uHeight, width, dHeight);
        }
    }else{

        if (bleType == 0 || bleType == 4) {
            deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,[DFUITools screen_2_H]-185, width, dHeight)];
        }
        if (bleType == 1) {
            deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, eHeight+sHeight+interval+uHeight, width, dHeight)];
        }
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
        [deleteBtn setTitleColor:[UIColor colorWithRed:225.0/255.0 green:88.0/255.0 blue:88.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        deleteBtn.layer.shadowColor = [UIColor colorWithRed:205/255.0 green:230/255.0 blue:251/255.0 alpha:0.2].CGColor;
        deleteBtn.layer.shadowOffset = CGSizeMake(0,1);
        deleteBtn.layer.shadowOpacity = 1;
        deleteBtn.layer.shadowRadius = 8;
        deleteBtn.layer.borderWidth = 0.5;
        deleteBtn.layer.borderColor = [UIColor colorWithRed:237/255.0 green:125/255.0 blue:125/255.0 alpha:1.0].CGColor;
        deleteBtn.layer.cornerRadius = 4;
        [deleteBtn setTitle:kJL_TXT("断开连接") forState:UIControlStateNormal];
        [deleteBtn setBackgroundColor:[UIColor whiteColor]];
        [deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:deleteBtn];
    }
    
    interval+=addHight;
        
    if(bleType == 1 && deviceModel.ancType == JL_AncTypeYES){
        scrollView.contentSize = CGSizeMake(width, 120+uHeight+eHeight+sHeight+interval+dHeight);
    }else{
        scrollView.contentSize = CGSizeMake(width, uHeight+eHeight+sHeight+interval+dHeight);
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
    NSLog(@"---> 用户主动断开设备：%@",entity.mItem);
    
    [bleSDK.mBleMultiple disconnectEntity:entity Result:^(JL_EntityM_Status status) {
        if (status == JL_EntityM_StatusDisconnectOk) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}



- (IBAction)backBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 网络监测
-(void)actionNetStatus:(AFNetworkReachabilityStatus)status{
    CGFloat width = [UIScreen mainScreen].bounds.size.width-24.0;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    if (status == AFNetworkReachabilityStatusNotReachable) {
        //NSLog(@"---> AFNetworkReachabilityStatusNotReachable");
        if(noNetView){
            noNetView.hidden = NO;
        }
        if([DFUITools screen_2_W] == 320.0){
            scrollView.frame = CGRectMake(12, noNetView.frame.origin.y
                                          +noNetView.frame.size.height+5, width, height-kJL_HeightNavBar-10);
        }else{
            scrollView.frame = CGRectMake(12, kJL_HeightNavBar+noNetView.frame.size.height+5, width, height-kJL_HeightNavBar-40);
        }
    }
    if (status == AFNetworkReachabilityStatusUnknown) {
        //NSLog(@"---> AFNetworkReachabilityStatusUnknown");
        if(noNetView){
            noNetView.hidden = NO;
        }
        if([DFUITools screen_2_W] == 320.0){
            scrollView.frame = CGRectMake(12, noNetView.frame.origin.y
                                          +noNetView.frame.size.height+5, width, height-kJL_HeightNavBar-10);
        }else{
            scrollView.frame = CGRectMake(12, kJL_HeightNavBar+noNetView.frame.size.height+5, width, height-kJL_HeightNavBar-40);
        }
    }
    if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        //NSLog(@"---> AFNetworkReachabilityStatusReachableViaWWAN");
        if(noNetView){
            noNetView.hidden = YES;
        }
        if([DFUITools screen_2_W] == 320.0){
            scrollView.frame =CGRectMake(12, 74+10, width, height-kJL_HeightNavBar-10);
        }else{
            scrollView.frame =CGRectMake(12, kJL_HeightNavBar+10, width, height-kJL_HeightNavBar-10);
        }
    }
    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        //NSLog(@"---> AFNetworkReachabilityStatusReachableViaWiFi");
        if(noNetView){
            noNetView.hidden = YES;
        }
        if([DFUITools screen_2_W] == 320.0){
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
        NSString *txt = @"设置失败";
        int num = [dict[kJL_MANAGER_KEY_OBJECT] intValue];
        if (num == 0x00) txt = @"设置成功";
        if (num == 0x01) txt = @"设置失败:处于游戏模式.";
        if (num == 0x02) txt = @"设置失败:蓝牙名字过长.";
        if (num == 0x03) txt = @"设置失败:非蓝牙模式不能设置闪灯.";
        UIWindow *win = [DFUITools getWindow];
        if(num!=0x00) [DFUITools showText:txt onView:win delay:1.0];
    }
}

-(void)dealloc{
    //NSLog(@"dealloc removeNote");
    [self removeNote];
}


-(void)removeNote{
    [JL_Tools remove:kJL_MANAGER_HEADSET_SET_ERR Own:self];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)addNote{
    [JL_Tools add:kJL_MANAGER_HEADSET_SET_ERR Action:@selector(noteSetHeadsetErr:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
 
    
}


-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline){
        
        /*--- 正在OTA不退出界面 ---*/
        NSString *otaUuid = [[JLUI_Cache sharedInstance] otaUUID];
        if (otaUuid.length > 0) return;
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
    vc.modalPresentationStyle = 0;
    [self presentViewController:vc animated:YES completion:nil];

}

#pragma mark <- SettingView Deleagate ->
#pragma mark <- upgradeView delegate ->
-(void)noremalSetting:(NormalSettingView *)view Selected:(NormalSettingObject *)object{
    if ([view isEqual:settingView]) {
        
        if(object.funType == -1){
            rnameView = [[ReNameView alloc] initWithFrame:CGRectMake(0, 0, [DFUITools screen_2_W], [DFUITools screen_2_H])];
            rnameView.delegate = self;
            rnameView.type = 0;
            rnameView.nameTxfd.text = bleName;
            [self.view addSubview:rnameView];
        }
        if (deviceDic == nil) {
            [self localDeviceJson];
            NSLog(@"-----> noremalSetting localDeviceJson");
        }
        if (isLoadImage == YES) {
            NSLog(@"-----> Loading Device Message...");
        }
        if (object.funType == 3) {
            HeadphoneFunVC *vc = [[HeadphoneFunVC alloc] init];
            vc.funType = object.funType;;
            vc.micMode = [self.headsetDict[@"MIC_MODE"] intValue];
            vc.mic_channel = deviceDic[@"mic_channel"];
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
    
    
}

#pragma mark <- renameDelegate ->
-(void)didSelectBtnAction:(UIButton *)btn WithText:(NSString *)text{
    [rnameView removeFromSuperview];
    rnameView = nil;
    
    nameObject.detailStr = text;
    
    NSData *data =[text dataUsingEncoding:NSUTF8StringEncoding];
    [bleSDK.mBleEntityM.mCmdManager cmdHeatsetEdrName:data];
    
    mofifyNameAlert = [[MofifyNameAlert alloc] initWithFrame:CGRectMake(0, 0, [DFUITools screen_2_W], [DFUITools screen_2_H])];
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
    objc.type = bleSDK.mBleEntityM.mType;
    objc.uuid = bleSDK.mBleUUID;
    [[SqliteManager sharedInstance] updateDeviceByObjc:objc];
    
    /*--- 暂停广播包回连操作 ---*/
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
    
    /*--- 跟新SDK本地设备列表 ---*/
    [bleSDK.mBleMultiple updateHistoryRename:objc.name withUuid:objc.uuid];
    [[JLUI_Cache sharedInstance] setRenameUUID:objc.uuid];
    
    NSLog(@"重启设备（改名）");
    [bleSDK.mBleEntityM.mCmdManager cmdRebootForceDevice];    
}

#pragma 通透降噪更多
-(void)HeadsetDenoiseMore:(JLModel_Device *) deviceModel{
    if(deviceModel.mAncModeCurrent.mAncMode == JL_AncMode_Normal){
        [DFUITools showText:kJL_TXT("普通模式，不允许进入") onView:self.view delay:1.0];
        return;
    }
    DenoiseVC *vc = [[DenoiseVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.model_ANC = deviceModel.mAncModeCurrent;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
