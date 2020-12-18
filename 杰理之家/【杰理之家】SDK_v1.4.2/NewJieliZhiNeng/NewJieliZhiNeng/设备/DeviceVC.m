//
//  DeviceVC.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/13.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DeviceVC.h"
#import "DeviceInfoVC.h"
#import "TopView.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "DevicesCardView.h"
#import "SearchView.h"
#import "DevicesListView.h"
#import "SqliteManager.h"
#import "DeviceInfoVC.h"
#import "AppSettingVC.h"
#import "DeviceChangeView.h"
#import "DeviceChangeModel.h"
#import "JLUI_Cache.h"
#import "NoNetView.h"
#import "ElasticHandler.h"
#import "MapViewController.h"
#import "UpgradeVC.h"

NSString *kUI_TURN_TO_DEVICEVC = @"UI_TURN_TO_DEVICEVC";

static NSDictionary *bleDeviceDict;

@interface DeviceVC ()<DevicesListViewDelegate>{
    
    DevicesCardView     *cardView;
    UILabel             *deviceLab;
    UIButton            *connectBtn;
    SearchView          *searchView;
    DevicesListView     *listView;
    DFTips              *loadingTp;
    NoNetView           *noNetView;
    
    JL_RunSDK           *bleSDK;
    DeviceChangeView    *devView;
}

@end

@implementation DeviceVC

static TopView *topView = nil;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addNote];
    
    bleSDK = [JL_RunSDK sharedMe];
 

    /*--- 网络监测 ---*/
    AFNetworkReachabilityManager *net = [AFNetworkReachabilityManager sharedManager];
    [self actionNetStatus:net.networkReachabilityStatus];
    
    [net setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [self actionNetStatus:status];
    }];
    
}

#pragma mark - 网络监测
-(void)actionNetStatus:(AFNetworkReachabilityStatus)status{
    if (status == AFNetworkReachabilityStatusNotReachable) {
        //NSLog(@"---> AFNetworkReachabilityStatusNotReachable");
        if(noNetView){
            noNetView.hidden = NO;
        }
    }
    if (status == AFNetworkReachabilityStatusUnknown) {
        //NSLog(@"---> AFNetworkReachabilityStatusUnknown");
        if(noNetView){
            noNetView.hidden = NO;
        }
    }
    if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        //NSLog(@"---> AFNetworkReachabilityStatusReachableViaWWAN");
        if(noNetView){
            noNetView.hidden = YES;
        }
    }
    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        //NSLog(@"---> AFNetworkReachabilityStatusReachableViaWiFi");
        if(noNetView){
            noNetView.hidden = YES;
        }
    }
}

- (IBAction)onTapGesture:(id)sender {
    [listView closeAllDeleteBtn];
}

-(void)viewWillAppear:(BOOL)animated{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /*--- 顶部栏 ---*/
        topView = [[TopView alloc] init];
        [topView viewFirstLoad];
        [self.view addSubview:topView];
        
        
        __weak typeof(self) wSelf = self;
        [topView onBLK_Device:^{
            if (self->bleSDK.mBleMultiple.bleManagerState == CBManagerStatePoweredOff) {
                [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self.view delay:1.0];
                return;
            }
            self->devView = [[DeviceChangeView alloc] init];
            [self->devView onShow];
            
            [self->devView setDeviceChangeBlock:^(NSString *uuid,NSInteger index) {
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
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [wSelf presentViewController:vc animated:YES completion:nil];
        }];
        [self updateUI];
    });
}

-(void)viewDidAppear:(BOOL)animated{
    /*--- 刷新UI界面数据 ---*/
    [self updateDataUI];
}

-(void)updateUI{
    
    CGFloat headHight = kJL_HeightNavBar+10;
    cardView = [[DevicesCardView alloc] initWithFrame:CGRectMake(12.0, headHight, [UIScreen mainScreen].bounds.size.width-24.0, 165)];
    [JLUI_Effect addShadowOnView:cardView];
    [self.view addSubview:cardView];
    
    deviceLab = [[UILabel alloc] initWithFrame:CGRectMake(14.0, headHight+cardView.frame.size.height+15.0, 120.0, 35.0)];
    deviceLab.font = [UIFont boldSystemFontOfSize:18.0];
    deviceLab.text = kJL_TXT("我的设备");
    deviceLab.textColor = [UIColor darkTextColor];
    [self.view addSubview:deviceLab];
    
    
    connectBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 94.0, headHight+cardView.frame.size.height+15.0+6, 80.0, 24.0)];
    [connectBtn setTitle:kJL_TXT("连接设备") forState:UIControlStateNormal];
    [connectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [connectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    connectBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [connectBtn setBackgroundImage:[UIImage imageNamed:@"Theme.bundle/product_btn_nol"] forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(connectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    connectBtn.layer.cornerRadius = 12;
    [self.view addSubview:connectBtn];
    
    searchView = [[SearchView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [DFUITools screen_H])];
    
    CGFloat H1 = headHight+cardView.frame.size.height+15.0+6+40;
    
    listView = [[DevicesListView alloc] initWithFrame:CGRectMake(14, H1, [UIScreen mainScreen].bounds.size.width-28, [UIScreen mainScreen].bounds.size.height - H1-kJL_HeightTabBar)];
    listView.delegate = self;
    [listView refreshStatus];
    [self.view addSubview:listView];
    
    if(noNetView == nil){
        noNetView = [[NoNetView alloc] initByFrame:CGRectMake(0,listView.frame.origin.y+listView.frame.size.height-40, [UIScreen mainScreen].bounds.size.width, 40)];
        [self.view addSubview:noNetView];
    }
    if(noNetView){
        noNetView.hidden = YES;
    }
}


-(void)connectBtnAction{
    if (bleSDK.mBleMultiple.bleManagerState == CBManagerStatePoweredOff) {
        [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self.view delay:1.0];
        return;
    }
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    [win addSubview:searchView];
    [searchView startSearch];
}

#pragma mark 【设备列表】 DevicesListViewDelegate
-(void)onDeviceListViewDidSelect:(DeviceObjc *)objc{
    
    JLUuidType type = [JL_RunSDK getStatusUUID:objc.uuid];
    
    /*--- 未连接 ---*/
    if (type == JLUuidTypeDisconnected) {
        NSLog(@"---> 设备列表，连接设备：%@",objc.name);
        [self startLoadingView:kJL_TXT("连接中...") Delay:15];
 
        __weak typeof(self) wSelf = self;
        JL_EntityM *entity = [bleSDK.mBleMultiple makeEntityWithUUID:objc.uuid];
        [bleSDK.mBleMultiple connectEntity:entity Result:^(JL_EntityM_Status status) {
            if (status == JL_EntityM_StatusPaired) {
                //[entity.mCmdManager cmdHeatsetAdvEnable:NO];
            }
            [JL_Tools mainTask:^{
                NSString *txt = [JL_RunSDK textEntityStatus:status];
                [wSelf setLoadingText:txt Delay:1.0];
            }];
        }];
    }
    
    /*--- 已连接 ---*/
    if (type == JLUuidTypeConnected) {
        /*--- 激活设备 ---*/
        [JL_RunSDK setActiveUUID:objc.uuid];
    }
    
    /*--- 正在使用 ---*/
    if (type == JLUuidTypeInUse) {
        DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
        vc.headsetDict = bleDeviceDict;
        vc.modalPresentationStyle = 0;
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    /*--- 需要OTA升级 ---*/
    if (type == JLUuidTypeNeedOTA) {
        UpgradeVC *vc = [[UpgradeVC alloc] init];
        vc.otaEntity  = [JL_RunSDK getEntity:objc.uuid];
        vc.rootNumber = 1;
        vc.modalPresentationStyle = 0;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

-(void)onDeviceMapLocationSelect:(DeviceObjc *)objc{
    MapViewController *vc = [[MapViewController alloc] init];
    vc.modalPresentationStyle = 0;
    vc.deviceObjc = objc;
    [self presentViewController:vc animated:YES completion:nil];
}


-(void)enterDeviceList{
    if (bleSDK.mBleEntityM) {
        DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
        vc.headsetDict = bleDeviceDict;
        vc.modalPresentationStyle = 0;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

-(void)startLoadingView:(NSString*)text Delay:(NSTimeInterval)delay{
    [loadingTp removeFromSuperview];
    loadingTp = nil;
    
    UIWindow *win = [DFUITools getWindow];
    loadingTp = [DFUITools showHUDWithLabel:text
                                     onView:win
                                      alpha:0.8
                                      color:[UIColor blackColor]
                             labelTextColor:[UIColor whiteColor]//kDF_RGBA(36, 36, 36, 1.0)
                     activityIndicatorColor:[UIColor whiteColor]];
    [loadingTp hide:YES afterDelay:delay];
}

-(void)setLoadingText:(NSString*)text Delay:(NSTimeInterval)delay{
    loadingTp.labelText = text;
    [loadingTp hide:YES afterDelay:delay];
    [JL_Tools delay:delay+0.5 Task:^{
        [self->loadingTp removeFromSuperview];
        self->loadingTp = nil;
    }];
}

-(void)closeLoadingView{
    [loadingTp hide:YES];
    [loadingTp removeFromSuperview];
    loadingTp = nil;
}



#pragma mark 设备状态改变
-(void)noteDeviceChange:(NSNotification*)note{
    [self updateDataUI];
    
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline) {
        [self renameToRelinkDevice];
    }
}

-(void)updateDataUI{
    [listView refreshStatus];
    [topView viewFirstLoad];

    if (bleSDK.mBleEntityM == nil) {
        [cardView configPowerStatus:nil];
    }else{
        /*--- 刷新卡片数据界面 ---*/
        NSLog(@"---> 获取耳机信息... 0");
        [bleSDK.mBleEntityM.mCmdManager cmdHeatsetGetAdvFlag:0x3F
                                        Result:^(NSDictionary * _Nullable dict) {
            bleDeviceDict = dict;
            [self->cardView configPowerStatus:dict];
        }];
    }
}

-(void)noteDeviePreparing:(NSNotification*)note{
    [listView refreshStatus];
}

#pragma mark 修改名字后的回连处理
-(void)renameToRelinkDevice{
    NSString *uuid = [[JLUI_Cache sharedInstance] renameUUID];
    if (uuid.length > 0) {
        if (![bleSDK.mBleUUID isEqual:uuid]) {

            NSLog(@"---> 修改名字，回连设备：%@",uuid);
            [self startLoadingView:kJL_TXT("重连设备...") Delay:15];
            
            __weak typeof(self) wSelf = self;
            JL_EntityM *entity = [bleSDK.mBleMultiple makeEntityWithUUID:uuid];
            [bleSDK.mBleMultiple connectEntity:entity Result:^(JL_EntityM_Status status) {
                
                if (status == JL_EntityM_StatusPaired) {
                    //[entity.mCmdManager cmdHeatsetAdvEnable:NO];
                }
                
                [JL_Tools mainTask:^{
                    NSString *txt = [JL_RunSDK textEntityStatus:status];
                    [wSelf setLoadingText:txt Delay:1.0];
                    NSLog(@"---> 回连结果:【%@】",txt);
                }];
                [[JLUI_Cache sharedInstance] setRenameUUID:nil];//清除回连的UUID
                [JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];//重启广播包
            }];
        }
    }
}


#pragma mark <- 新增通知 ->
-(void)addNote{
    [JL_Tools add:kUI_TURN_TO_DEVICEVC Action:@selector(enterDeviceList) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_PREPARING Action:@selector(noteDeviePreparing:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

@end
