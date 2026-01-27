//
//  SceneDelegate.m
//  NewJieliZhiNeng
//
//  Created by Ezio Chan on 2025/11/27.
//
//  Copyright © 2025 杰理科技. All rights reserved.
//
//  场景委托实现，负责在 iOS 13+ 使用 UIWindowScene 创建窗口并配置根控制器，
//  同时复用现有的确认协议与主界面初始化流程，确保生命周期与 UI 表现一致。

#import "SceneDelegate.h"
#import "MainTabBarVC.h"
#import "ConfirmView.h"
#import "NavViewController.h"
#import "Alert697xView.h"
#import "FindPhoneView.h"
#import <JL_BLEKit/JL_BLEKit.h>
#import "OpenShowView.h"
#import "UserProfileVC.h"
#import "PrivacyPolicyVC.h"
#import "PiLinkShowView.h"
#import "RTCAlertSingle.h"
#import "MapLocationRequest.h"

@interface SceneDelegate ()<ConfirmViewDelegate>
@property (nonatomic, strong) ConfirmView *cmView;
@property (nonatomic, strong) UIViewController *tempVC;
@property (nonatomic, strong) Alert697xView *alert697;
@property (nonatomic, strong) FindPhoneView *findView;
@property (nonatomic, strong)UIToolbar *toolbar;
@property (nonatomic, strong)UITapGestureRecognizer *callTapGestureRecognizer; //单击事件
@property (nonatomic, strong)UIPanGestureRecognizer *callPanGestureRecognizer; //拖拽事件
@property (nonatomic, strong)UISwipeGestureRecognizer *callSwipeGestureRecognizer; //轻扫事件
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) { return; }
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = windowScene.coordinateSpace.bounds;

    self.cmView = [[ConfirmView alloc] init];
    self.cmView.delegate = self;

    NSString *key = [JL_Tools getUserByKey:@"CONMIT_PROTOCOL"];
    if ([key isEqualToString:@"OK"]) {
        [self initData];
    } else {
        self.tempVC = [[UIViewController alloc] init];
        self.window.rootViewController = self.tempVC;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
        [self.window addSubview:self.cmView];
    }

    if (!self.findView) {
        self.findView = [[FindPhoneView alloc] init];
        self.findView.hidden = YES;
    }

    // 启动开屏动画（保持与 AppDelegate 一致）
    if (kJL_UI_SERIES == 0) {
        [OpenShowView startOpenAnimation];
    } else if (kJL_UI_SERIES == 1) {
        CGRect rect = self.window.bounds;
        PiLinkShowView *piLinkShowView = [[PiLinkShowView alloc] initWithFrame:rect];
        [self.window addSubview:piLinkShowView];
    }
    [self addNote];
}

- (void)initData {
    MainTabBarVC *mainVC = [[MainTabBarVC alloc] init];
    NavViewController *nav = [[NavViewController alloc] initWithRootViewController:mainVC];
    nav.navigationBarHidden = YES;
    self.window.rootViewController = nav;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    self.alert697 = [[Alert697xView alloc] init];
    [self.window addSubview:self.alert697];
    self.alert697.hidden = YES;
    
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
        kJLLog(JLLOG_DEBUG,@"--->定位不能用.");
    }else{
        [MapLocationRequest shareInstanced];
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [ReconnectDevice connectHistoryFirst];
}


#pragma mark - UIScene Lifecycle Forwarders (optional)
- (void)sceneDidDisconnect:(UIScene *)scene {}
- (void)sceneDidBecomeActive:(UIScene *)scene {}
- (void)sceneWillResignActive:(UIScene *)scene {}
- (void)sceneWillEnterForeground:(UIScene *)scene {}
- (void)sceneDidEnterBackground:(UIScene *)scene {}


#pragma mark - ConfirmViewDelegate
- (void)confirmCancelBtnAction {
    exit(0);
}
- (void)confirmConfirmBtnAction {
    [JL_Tools setUser:@"OK" forKey:@"CONMIT_PROTOCOL"];
    [self.cmView removeFromSuperview];
    [self initData];
}
- (void)confirmDidSelect:(int)index {
    // 在这里加一个这个样式的循环
    while (_tempVC.presentedViewController)
    {
        // 这里固定写法
        _tempVC = _tempVC.presentedViewController;
    }
    
    if(index == 0){
        UserProfileVC *vc = [[UserProfileVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [_tempVC presentViewController:vc animated:YES completion:nil];
    }
    if(index == 1){
        PrivacyPolicyVC *vc = [[PrivacyPolicyVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [_tempVC presentViewController:vc animated:YES completion:nil];
    }
}

-(void)addNote{
    //监测固件的通话状态
    [JL_Tools add:kJL_MANAGER_CALL_STATUS Action:@selector(noteHanldeCallState:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    //监听蓝牙通知更新
    [JL_Tools add:kJL_BLE_M_FOUND_SINGLE Action:@selector(noteBleStatusAlert:) Own:self];
}


#pragma mark 处理通话状态的监听
-(void)noteHanldeCallState:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    [JL_Tools mainTask:^{
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if (bleSDK.twsConfigMode.isSupportTranslate) {
            kJLLog(JLLOG_INFO, @"current device support translate mode");
            return;
        }
        if(model.mCallType == JL_CALLType_ON){
            [self showCallingUI];
        }
        if(model.mCallType == JL_CALLType_OFF){
            [self dismissCallingUI];
        }
    }];
}

-(void)showCallingUI{
    if(_toolbar == nil){
        UIWindow *win = [DFUITools getWindow];
        _toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
        //样式
        _toolbar.barStyle = UIBarStyleBlackTranslucent;
        //透明度
        _toolbar.alpha = 0.05f;
        [win addSubview:_toolbar];
        
        if(_callTapGestureRecognizer == nil){
            _callTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelClick)];
        }
        [win addGestureRecognizer:_callTapGestureRecognizer];
        
        if(_callPanGestureRecognizer == nil){
            _callPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelClick)];
        }
        [win addGestureRecognizer:_callPanGestureRecognizer];
        
        if(_callSwipeGestureRecognizer == nil){
            _callSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handelClick)];
        }
        [win addGestureRecognizer:_callSwipeGestureRecognizer];
    }
}

-(void)dismissCallingUI{
    UIWindow *win = [DFUITools getWindow];

    if(_callTapGestureRecognizer){
        _callTapGestureRecognizer.enabled = NO;
        [win removeGestureRecognizer:_callTapGestureRecognizer];
        _callTapGestureRecognizer = nil;
    }
    if(_callPanGestureRecognizer){
        _callPanGestureRecognizer.enabled = NO;
        [win removeGestureRecognizer:_callPanGestureRecognizer];
        _callPanGestureRecognizer = nil;
    }
    if(_callSwipeGestureRecognizer){
        _callSwipeGestureRecognizer.enabled = NO;
        [win removeGestureRecognizer:_callSwipeGestureRecognizer];
        _callSwipeGestureRecognizer = nil;
    }
    if(_toolbar){
        [_toolbar removeFromSuperview];
        _toolbar = nil;
    }
}

//MARK: - 监听设备变化
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

#pragma mark 显示弹框
-(void)noteBleStatusAlert:(NSNotification*)note{
    JL_EntityM *entity = note.object;
    /*--- 在搜索界面存在时，不弹窗。 ---*/
    BOOL isSearchView = [[JLUI_Cache sharedInstance] isSearchView];
    if (entity.mType!= JL_DeviceTypeTradition &&
        isSearchView == NO) {
        [_alert697 refresh:entity];
    }
}


@end

