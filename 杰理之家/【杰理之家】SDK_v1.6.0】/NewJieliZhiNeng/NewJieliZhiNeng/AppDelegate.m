//
//  AppDelegate.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/13.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AppDelegate.h"
#import "JL_RunSDK.h"

#import "MultiMediaVC.h"
#import "EQSettingVC.h"
#import "DeviceVC.h"
#import "SqliteManager.h"
#import "DeviceInfoVC.h"
#import "UpgradeVC.h"
#import "ConfirmView.h"
#import "PrivacyPolicyVC.h"
#import "UserProfileVC.h"
#import "JLUI_Cache.h"
#import "ElasticHandler.h"
#import "RTCAlertSingle.h"
#import "OpenShowView.h"
#import "PiLinkShowView.h"
#import "Alert697xView.h"
#import "FindPhoneView.h"
#import "NetworkPlayer.h"

#import "MainTabBarVC.h"
#import "sys/utsname.h"
#import "User_Http.h"
#import "MapLocationRequest.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <Bugly/Bugly.h>

@interface AppDelegate ()<ConfirmViewDelegate>{
    MainTabBarVC        *mainVC;
    Alert697xView       *alert697;
    
    ConfirmView         *cmView;
    UIViewController    *tempVC;
    
    FindPhoneView       *findView;
    NSString *versionFirmware;
    UITapGestureRecognizer *callTapGestureRecognizer; //单击事件
    UIPanGestureRecognizer *callPanGestureRecognizer; //拖拽事件
    UISwipeGestureRecognizer *callSwipeGestureRecognizer; //轻扫事件
    UIToolbar *toolbar;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*--- 记录NSLOG ---*/
    [JL_Tools openLogTextFile];
    
    /*--- 设置屏幕常亮 ---*/
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    /*--- 远程事件接收---*/
    [application beginReceivingRemoteControlEvents];
    
    /*--- 检测当前语言 ---*/
    if ([kJL_GET isEqualToString:@"en"]) {
        kJL_SET("en");
    }else if([kJL_GET isEqualToString:@"ja"]){
        kJL_SET("ja");
    }else if ([kJL_GET isEqualToString:@"zh-Hans"]){
        kJL_SET("zh-Hans");
    }else{
        kJL_SET("");
    }
    
    /*--- 初始化UI ---*/
    [self setupUI];
   
    
    if(kJL_UI_SERIES == 0){ //杰理之家
        /*--- 开启动画 ---*/
        [OpenShowView startOpenAnimation];
    }
    if(kJL_UI_SERIES == 1){ //PiLink
        /*--- 开启动画 ---*/
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        PiLinkShowView  *piLinkShowView = [[PiLinkShowView alloc] initWithFrame:rect];
        UIWindow *win = [DFUITools getWindow];
        [win addSubview:piLinkShowView];
    }
    
    /*--- 创建数据库 ---*/
    [[SqliteManager sharedInstance] createTable];

    /*--- 用户登录 && 日志 ---*/
    [User_Http shareInstance];

    /*--- 网络监测 ---*/
    AFNetworkReachabilityManager *net = [AFNetworkReachabilityManager sharedManager];
    [net startMonitoring];
    
    [NetworkPlayer sharedMe];
    
    [Bugly startWithAppId:@"12d9f973f4"];

    [self addNote];
    
    
    if (@available(iOS 15.0, *)) {
        [UITableView appearance].sectionHeaderTopPadding = 0;
    }
    
    return YES;
}

-(void)setupUI{
    self.window =[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    cmView = [[ConfirmView alloc] init];
    cmView.delegate = self;
    NSString *key = [JL_Tools getUserByKey:@"CONMIT_PROTOCOL"];
    if ([key isEqualToString:@"OK"]) {
        [self initData];
    }else{
        tempVC =[[UIViewController alloc] init];
        self.window.rootViewController = tempVC;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
        [self.window addSubview:cmView];
    }
    if (findView == nil) {
        findView = [[FindPhoneView alloc] init];
        findView.hidden = YES;
    }
}


-(void)initData{
    mainVC = [[MainTabBarVC alloc]init];
    self.window.rootViewController = mainVC;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    alert697 = [[Alert697xView alloc] init];
    [self.window addSubview:alert697];
    alert697.hidden = YES;
    
    [RTCAlertSingle sharedInstance];

    
    /*--- 运行SDK ---*/
    [JL_RunSDK sharedMe];
    
    /*--- 高德定位 ---*/
    if(kJL_UI_SERIES == 0){ //杰理之家
        [AMapServices sharedServices].apiKey = MapApiKey;
    }
    if(kJL_UI_SERIES == 1){ //PiLink
        [AMapServices sharedServices].apiKey = PiLinkMapApiKey;
    }
    [[AMapServices sharedServices] setEnableHTTPS:YES];

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"--->定位不能用.");
    }else{
        [MapLocationRequest shareInstanced];
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}



-(void)remoteControlReceivedWithEvent:(UIEvent*)event{
    if (event) {
        if (![[CorePlayer shareInstanced] wetherPlay]) {
            [DFAudioPlayer receiveRemoteEvent:event];
        }else{
            [[NetworkPlayer sharedMe] receiveRemoteEvent:event];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [application endReceivingRemoteControlEvents];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

#pragma mark 显示弹框
-(void)noteBleStatusAlert:(NSNotification*)note{
    JL_EntityM *entity = note.object;
    NSNumber *rssi = entity.mRSSI;
    int mRssi = [rssi intValue];
    
    
    /*--- 在搜索界面存在时，不弹窗。 ---*/
    BOOL isSearchView = [[JLUI_Cache sharedInstance] isSearchView];
    if (mRssi>-80 && entity.mType!= JL_DeviceTypeTradition &&
        isSearchView == NO) {
        [alert697 refresh:entity];
    }
}

#pragma mark 查看设备连接信息、查看连接状态
-(void)noteElasticViewBtn:(NSNotification *) note{
    [mainVC setSelectedIndex:2];
    [JL_Tools delay:0.5 Task:^{
        [JL_Tools post:kUI_TURN_TO_DEVICEVC Object:nil];
    }];
}

#pragma mark 处理屏幕点击、拖拽、轻扫事件
-(void)handelClick{
    UIWindow *win = [DFUITools getWindow];
    
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    
    if(model.mCallType == JL_CALLType_ON){
        if(self->callTapGestureRecognizer){
            self->callTapGestureRecognizer.enabled = YES;
        }
        if(self->callPanGestureRecognizer){
            self->callPanGestureRecognizer.enabled = YES;
        }
        if(self->callSwipeGestureRecognizer){
            self->callSwipeGestureRecognizer.enabled = YES;
        }
        [DFUITools showText:kJL_TXT("msg_call_tip") onView:win delay:1.0];
    }
    if(model.mCallType == JL_CALLType_OFF){
        if(self->callTapGestureRecognizer){
            self->callTapGestureRecognizer.enabled = NO;
            [win removeGestureRecognizer:self->callTapGestureRecognizer];
            self->callTapGestureRecognizer = nil;
        }
        if(self->callPanGestureRecognizer){
            self->callPanGestureRecognizer.enabled = NO;
            [win removeGestureRecognizer:self->callPanGestureRecognizer];
            self->callPanGestureRecognizer = nil;
        }
        if(self->callSwipeGestureRecognizer){
            self->callSwipeGestureRecognizer.enabled = NO;
            [win removeGestureRecognizer:self->callSwipeGestureRecognizer];
            self->callSwipeGestureRecognizer = nil;
        }
        if(self->toolbar){
            [self->toolbar removeFromSuperview];
        }
    }
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeSomethingConnected ||
        type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeBleOFF) {
        [JL_Tools mainTask:^{
            [self dismissCallingUI];
        }];
    }
}


#pragma mark 处理通话状态的监听
-(void)noteHanldeCallState:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    [JL_Tools mainTask:^{
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if(model.mCallType == JL_CALLType_ON){
            [self showCallingUI];
        }
        if(model.mCallType == JL_CALLType_OFF){
            [self dismissCallingUI];
        }
    }];
}

-(void)showCallingUI{
    if(self->toolbar == nil){
        UIWindow *win = [DFUITools getWindow];
        self->toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
        //样式
        self->toolbar.barStyle = UIBarStyleBlackTranslucent;
        //透明度
        self->toolbar.alpha = 0.05f;
        [win addSubview:self->toolbar];
        
        if(self->callTapGestureRecognizer == nil){
            self->callTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelClick)];
        }
        [win addGestureRecognizer:self->callTapGestureRecognizer];
        
        if(self->callPanGestureRecognizer == nil){
            self->callPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelClick)];
        }
        [win addGestureRecognizer:self->callPanGestureRecognizer];
        
        if(self->callSwipeGestureRecognizer == nil){
            self->callSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handelClick)];
        }
        [win addGestureRecognizer:self->callSwipeGestureRecognizer];
    }
}

-(void)dismissCallingUI{
    UIWindow *win = [DFUITools getWindow];

    if(self->callTapGestureRecognizer){
        self->callTapGestureRecognizer.enabled = NO;
        [win removeGestureRecognizer:self->callTapGestureRecognizer];
        self->callTapGestureRecognizer = nil;
    }
    if(self->callPanGestureRecognizer){
        self->callPanGestureRecognizer.enabled = NO;
        [win removeGestureRecognizer:self->callPanGestureRecognizer];
        self->callPanGestureRecognizer = nil;
    }
    if(self->callSwipeGestureRecognizer){
        self->callSwipeGestureRecognizer.enabled = NO;
        [win removeGestureRecognizer:self->callSwipeGestureRecognizer];
        self->callSwipeGestureRecognizer = nil;
    }
    if(self->toolbar){
        [self->toolbar removeFromSuperview];
        self->toolbar = nil;
    }
}


-(void)addNote{
    //监测固件的通话状态
    [JL_Tools add:kJL_MANAGER_CALL_STATUS Action:@selector(noteHanldeCallState:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    
    //弹窗界面按钮跳转
    [JL_Tools add:kUI_JL_ELSATICVIEW_BTN Action:@selector(noteElasticViewBtn:) Own:self];
    //监听蓝牙通知更新
    [JL_Tools add:kJL_BLE_M_FOUND_SINGLE Action:@selector(noteBleStatusAlert:) Own:self];

    
    
    //监听查找手机的通知
    [JL_Tools add:kJL_MANAGER_FIND_PHONE Action:@selector(recivedVoiceNote:) Own:self];
    
    
    //[JL_Tools add:kUI_JL_BLE_PAIRED Action:@selector(noteBlePaired:) Own:self];
    //[JL_Tools add:kUI_JL_BLE_DISCONNECTED Action:@selector(noteBleDisconnect:) Own:self];
    //[JL_Tools add:kUI_JL_BLE_OFF Action:@selector(noteBleOff:) Own:self];
}



-(void)recivedVoiceNote:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;

    NSDictionary *noteDict = [note object];
    NSDictionary *dict = noteDict[kJL_MANAGER_KEY_OBJECT];
    
    
    if ([dict[@"op"] intValue] != 1) {
        return;
    }
    if (findView.hidden == YES) {
        if ([[DFAudioPlayer sharedMe] mState] == DFAudioPlayer_PLAYING) {
            [[DFAudioPlayer sharedMe] didPause];
        }
        [[NetworkPlayer sharedMe] didStop];
        findView.hidden = NO;
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        [win addSubview:findView];
        [findView startVoice];
    }
    
}

-(void)confirmCancelBtnAction{
    exit(0);
}

-(void)confirmConfirmBtnAction{
    [self initData];
}

-(void)confirmDidSelect:(int)index{
    
    // 在这里加一个这个样式的循环
    while (tempVC.presentedViewController)
    {
        // 这里固定写法
        tempVC = tempVC.presentedViewController;
    }
    
    if(index == 0){
        UserProfileVC *vc = [[UserProfileVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [tempVC presentViewController:vc animated:YES completion:nil];
    }
    if(index == 1){
        PrivacyPolicyVC *vc = [[PrivacyPolicyVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [tempVC presentViewController:vc animated:YES completion:nil];
    }
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}


@end
