//
//  DeviceVC_2.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/9/28.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DeviceVC_2.h"
#import "DeviceCell_2.h"

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




@interface DeviceVC_2 ()<UITableViewDelegate,UITableViewDataSource,LanguagePtl>{
    UITapGestureRecognizer              *dismissTapAction;
    
    __weak IBOutlet UIView              *subTitleView;
    __weak IBOutlet NSLayoutConstraint  *subTitleView_H;
    __weak IBOutlet UIImageView         *subImage_0;
    __weak IBOutlet UIButton            *subBtn_0;
    __weak IBOutlet UIButton            *subBtn_1;
    __weak IBOutlet UIButton            *subBtn_2;
    __weak IBOutlet UIImageView         *kongImage;
    __weak IBOutlet UILabel             *kongLabel;
    __weak IBOutlet UILabel             *noDeviceLabel;
    
    __weak IBOutlet UITableView         *subTableView;
    __weak IBOutlet NSLayoutConstraint  *subTableView_Top;
    __weak IBOutlet NSLayoutConstraint  *subTableView_Foot;
    
    NSMutableDictionary                 *powerDict;
    NSArray                             *dataArray;
    DFTips                              *loadingTp;
    SearchView                          *searchView;
    JL_RunSDK                           *bleSDK;
    NSDictionary                        *bleDeviceDict;
    
    float sW;
    float sH;
    
    NSIndexPath                         *subIndexPath;
}

@end

@implementation DeviceVC_2

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LanguageCls share] add:self];
    [self setupUI];
    [self addNote];
    bleSDK = [JL_RunSDK sharedMe];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getSoundboxPower];
    [self startPowerTimer];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self endPowerTimer];
}

-(void)setupUI{
    powerDict = [NSMutableDictionary new];
    
    sW = [UIScreen mainScreen].bounds.size.width;
    sH = [UIScreen mainScreen].bounds.size.height;
    
    kongImage.hidden = NO;
    kongLabel.hidden = NO;
    
    [subBtn_2 setTitle:kJL_TXT("add_device") forState:UIControlStateNormal];
    subTitleView_H.constant = kJL_HeightNavBar;
    noDeviceLabel.text = kJL_TXT("unconnected_device_tips");
    
//    CAGradientLayer *gl = [CAGradientLayer layer];
//    gl.frame = CGRectMake(0,0,sW,kJL_HeightNavBar);
//    gl.startPoint = CGPointMake(0, 0.5);
//    gl.locations  = @[@(0.0),@(1.0)];
//    gl.endPoint   = CGPointMake(1, 0.5);
//    gl.colors     = @[(__bridge id)kColor_0004.CGColor,
//                      (__bridge id)kColor_0005.CGColor];
//    [subTitleView.layer addSublayer:gl];
    
//    [subTitleView bringSubviewToFront:subImage_0];
//    [subTitleView bringSubviewToFront:subBtn_0];
//    [subTitleView bringSubviewToFront:subBtn_1];
//    [subTitleView bringSubviewToFront:subBtn_2];
    
    subTableView_Foot.constant = kJL_HeightTabBar;
    subTableView.delegate = self;
    subTableView.dataSource = self;
    subTableView.tableFooterView = [UIView new];
    
    searchView = [[SearchView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
    
    dismissTapAction = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                               action:@selector(cancelDeleteAction)];
    [self reloadTableViewData];
    [subTableView reloadData];
}
#pragma mark - 添加设备
- (IBAction)btn_Add:(id)sender {
    if (bleSDK.mBleMultiple.bleManagerState == CBManagerStatePoweredOff) {
        [DFUITools showText:kJL_TXT("bluetooth_not_enable") onView:self.view delay:1.0];
        return;
    }
    UIWindow *win = [DFUITools getWindow];
    [win addSubview:searchView];
    [searchView startSearch];
}

#pragma mark - APP简介
- (IBAction)btn_setting:(id)sender {
    AppSettingVC *vc = [[AppSettingVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
    //[self noteHeadsetInfo:nil];
}

#pragma mark - 地图定位
-(void)noteDeviceMapLocal:(NSNotification*)note{
    NSInteger index = [note.object intValue];
    DeviceObjc *objc = dataArray[index];
    
    MapViewController *vc = [[MapViewController alloc] init];
    vc.modalPresentationStyle = 0;
    vc.deviceObjc = objc;
    vc.powerDict = powerDict;
    vc.deviceUUID = objc.uuid;
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - 删除设备
static BOOL isDelete = NO;
-(void)noteDeviceLongPress:(NSNotification*)note{
    if (isDelete) {
        isDelete = NO;
        [subTableView removeGestureRecognizer:dismissTapAction];
    }else{
        isDelete = YES;
        [subTableView addGestureRecognizer:dismissTapAction];
    }
    [subTableView reloadData];
}

-(void)closeAllDeleteBtn{
    isDelete = NO;
    [self scrollTableViewNoneUI];
}

-(void)cancelDeleteAction{
    isDelete = NO;
    [subTableView removeGestureRecognizer:dismissTapAction];
    [self scrollTableViewNoneUI];
}

-(void)noteDeviceDelete:(NSNotification*)note{
    NSInteger index = [note.object intValue];
    DeviceObjc *model = dataArray[index];

    NSLog(@"---> Delete History:%@",model.name);
    [[SqliteManager sharedInstance] deleteItemByIdInt:model.idInt];
    [self reloadTableViewData];
    [self scrollTableViewNoneUI];
}

-(void)scrollTableViewNoneUI{
    [subTableView reloadData];
    if (dataArray.count > 0) {
        [subTableView scrollToRowAtIndexPath:subIndexPath
                            atScrollPosition:UITableViewScrollPositionNone
                                    animated:NO];
    }
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceObjc *model = dataArray[indexPath.row];
    float heigth = [DeviceCell_2 cellHeightWithModel:model PowerDict:powerDict];
    return heigth;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    //DeviceCell_2 *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    DeviceCell_2 *cell = [tableView dequeueReusableCellWithIdentifier:[DeviceCell_2 ID]];
    if (cell == nil) {
        cell = [[DeviceCell_2 alloc] init];
    }
    cell.mPowerDict = powerDict;
    
    DeviceObjc *model = dataArray[indexPath.row];
    cell.isDelete     = isDelete;
    cell.mIndex       = indexPath.row;
    cell.mSubObject   = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    subIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    DeviceObjc *model = dataArray[indexPath.row];
    JLUuidType type = [JL_RunSDK getStatusUUID:model.uuid];
    
    /*--- 未连接 ---*/
    if (type == JLUuidTypeDisconnected) {
        NSLog(@"---> 设备列表，连接设备：%@",model.name);
        [self startLoadingView:kJL_TXT("bt_connecting") Delay:15];
 
        __weak typeof(self) wSelf = self;
        JL_EntityM *entity = [bleSDK.mBleMultiple makeEntityWithUUID:model.uuid];
        [bleSDK.mBleMultiple connectEntity:entity Result:^(JL_EntityM_Status status) {
            if (status == JL_EntityM_StatusPaired) {
                //[entity.mCmdManager.mTwsManager cmdHeadsetAdvEnable:NO];
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
        [JL_RunSDK setActiveUUID:model.uuid];
    }
    
    /*--- 正在使用 ---*/
    if (type == JLUuidTypeInUse) {
        __weak typeof(self) wself = self;
        if(bleSDK.mBleEntityM.mType == JL_DeviceTypeTWS){
            [bleSDK.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetGetAdvFlag:0x3F
                                            Result:^(NSDictionary * _Nullable dict) {
                self->bleDeviceDict = dict;
                DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
                vc.headsetDict = dict;
                NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
                nav.modalPresentationStyle = 0;
                [wself presentViewController:nav animated:YES completion:nil];
            }];
        }else{
            DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
            vc.headsetDict = bleDeviceDict;
            NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = 0;
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
    
    /*--- 需要OTA升级 ---*/
    if (type == JLUuidTypeNeedOTA) {
        UpgradeVC *vc = [[UpgradeVC alloc] init];
        vc.otaEntity  = [JL_RunSDK getEntity:model.uuid];
        vc.rootNumber = 1;
        vc.modalPresentationStyle = 0;
        [self presentViewController:vc animated:YES completion:nil];
    }

}

#pragma mark - 刷新数据
-(void)reloadTableViewData{
    NSArray *array = [[SqliteManager sharedInstance] checkOutAll];
    
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    NSMutableArray *arr_0 = [NSMutableArray new];
    NSMutableArray *arr_1 = [NSMutableArray new];
    NSMutableArray *arr_2 = [NSMutableArray new];
    NSMutableArray *arr_3 = [NSMutableArray new];
    NSMutableArray *arr_4 = [NSMutableArray new];
    
    for (DeviceObjc *objc in array) {
        JLUuidType type = [JL_RunSDK getStatusUUID:objc.uuid];
        if (type == JLUuidTypeInUse) {
            [arr_0 addObject:objc];
        }
        if (type == JLUuidTypePreparing) {
            [arr_1 addObject:objc];
        }
//        if (type == JLUuidTypeConnected) {
//            [arr_2 addObject:objc];
//        }
        if (type == JLUuidTypeNeedOTA) {
            [arr_3 addObject:objc];
        }
        if (type == JLUuidTypeDisconnected) {
            [arr_4 addObject:objc];
        }
    }
    
    /*--- 已连接的设备 ---*/
    NSArray *linkedUuidArr = [JL_RunSDK getLinkedArray];
    for (NSString *uuid in linkedUuidArr) {
        for (DeviceObjc *objc in array) {
            if ([uuid isEqual:objc.uuid]) {
                [arr_2 addObject:objc];
                break;
            }
        }
    }
    [newArray addObjectsFromArray:arr_0];
    [newArray addObjectsFromArray:arr_1];
    [newArray addObjectsFromArray:arr_2];
    [newArray addObjectsFromArray:arr_3];
    [newArray addObjectsFromArray:arr_4];
    dataArray = newArray;

    if (dataArray.count == 0) {
        kongImage.hidden = NO;
        kongLabel.hidden = NO;
    }else{
        kongImage.hidden = YES;
        kongLabel.hidden = YES;
    }
    [subTableView reloadData];
}

#pragma mark - 跳至设备信息界面
-(void)enterDeviceList:(NSNotification*)note{
    if(bleSDK.mBleEntityM.mType == JL_DeviceTypeTWS){
        __weak typeof(self) wself = self;
        [bleSDK.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetGetAdvFlag:0x3F
                                                      Result:^(NSDictionary * _Nullable dict) {
            self->bleDeviceDict = dict;
            DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
            vc.headsetDict = dict;
            NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = 0;
            [wself presentViewController:nav animated:YES completion:nil];
        }];
    }else{
        if (bleSDK.mBleEntityM) {
            DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
            vc.headsetDict = bleDeviceDict;
            NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = 0;
            [self presentViewController:nav animated:YES completion:nil];
        }
        
    }
}

#pragma mark - 刷新设备信息界面
-(void)viewDidAppear:(BOOL)animated{
    /*--- 刷新UI界面数据 ---*/
    [self updateDataUI];
}

#pragma mark - 设备状态改变
-(void)noteDeviceChange:(NSNotification*)note{
    
    [self getSoundboxPower];
    
  
        
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline) {
        [self renameToRelinkDevice];
        
    }
    
    if (tp == JLDeviceChangeTypeSomethingConnected) {
        /*--- 刷新卡片数据界面 ---*/
        NSLog(@"---> 获取耳机信息... 0");
        [bleSDK.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetGetAdvFlag:0x3F
                                        Result:^(NSDictionary * _Nullable dict) {
            self->bleDeviceDict = dict;
        }];
        
    }
    if (tp == JLDeviceChangeTypeConnectedOffline) {

    }
    
    if (tp == JLDeviceChangeTypeManualChange) {

    }
    if (tp == JLDeviceChangeTypeBleOFF){
        [powerDict removeAllObjects];
    }
    [self reloadTableViewData];
    [subTableView reloadData];
    if (dataArray.count > 0) {
        [subTableView scrollToRowAtIndexPath:subIndexPath
                            atScrollPosition:UITableViewScrollPositionTop
                                    animated:NO];
    }

    
}

static NSTimer *powerTimer = nil;
-(void)startPowerTimer{
    if (powerTimer == nil) {
        powerTimer = [JL_Tools timingStart:@selector(getSoundboxPower)
                                    target:self Time:30];
    }
}

-(void)endPowerTimer{
    [JL_Tools timingPause:powerTimer];
}

-(void)getSoundboxPower{
    NSLog(@"----->startPowerTimer");
    if(bleSDK.mBleEntityM){
        NSLog(@"---> 获取耳机信息... 1");
        [bleSDK.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetGetAdvFlag:0x3F
                                        Result:^(NSDictionary * _Nullable dict) {
            
            NSString *uuid = self->bleSDK.mBleUUID;
            
//            BOOL isLoad = [self isReloadInfoUuid:uuid Dict:dict];
            [self isReloadInfoUuid:uuid Dict:dict];
            //if (isLoad) {
                NSLog(@"power--->1 L:%@[%@] R:%@[%@] C:%@[%@]",
                      dict[@"POWER_L"],dict[@"ISCHARGING_L"],
                      dict[@"POWER_R"],dict[@"ISCHARGING_R"],
                      dict[@"POWER_C"],dict[@"ISCHARGING_C"]);
                [self->powerDict setValue:dict forKey:uuid];
                [[JLUI_Cache sharedInstance] setMPowerDic:self->powerDict];
                [self->subTableView reloadData];
//            }else{
//                //NSLog(@"----> No reload info.");
//            }
        }];
    }
}



#pragma mark - 修改名字后的回连处理
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
                    //[entity.mCmdManager.mTwsManager cmdHeadsetAdvEnable:NO];
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


-(void)noteDeviePreparing:(NSNotification*)note{
    [self reloadTableViewData];
    [subTableView reloadData];
    [subTableView scrollToRowAtIndexPath:subIndexPath
                        atScrollPosition:UITableViewScrollPositionTop
                                animated:NO];
}


-(void)updateDataUI{
    [self reloadTableViewData];
    [JL_Tools delay:0.2 Task:^{
        if (self->bleSDK.mBleEntityM) {
            /*--- 刷新卡片数据界面 ---*/
            NSLog(@"---> 获取耳机信息... 1");
            [self->bleSDK.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetGetAdvFlag:0x3F
                                            Result:^(NSDictionary * _Nullable dict) {
                self->bleDeviceDict = dict;
            }];
        }
    }];
}


#pragma mark - 电量信息
-(void)noteHeadsetInfo:(NSNotification*)note{
    [JL_Tools mainTask:^{
        NSDictionary *info = note.object;
        NSString *uuid = info[kJL_MANAGER_KEY_UUID];
        NSDictionary *dict = info[kJL_MANAGER_KEY_OBJECT];
        
//        BOOL isLoad = [self isReloadInfoUuid:uuid Dict:dict];
        [self isReloadInfoUuid:uuid Dict:dict];
//        if (isLoad) {
            NSLog(@"power---> L:%@[%@] R:%@[%@] C:%@[%@]",
                  dict[@"POWER_L"],dict[@"ISCHARGING_L"],
                  dict[@"POWER_R"],dict[@"ISCHARGING_R"],
                  dict[@"POWER_C"],dict[@"ISCHARGING_C"]);
            [self->powerDict setValue:dict forKey:uuid];
            [[JLUI_Cache sharedInstance] setMPowerDic:self->powerDict];
            [self->subTableView reloadData];
//        }else{
//            //NSLog(@"----> No reload info.");
//        }
    }];
}

-(BOOL)isReloadInfoUuid:(NSString*)uuid Dict:(NSDictionary*)dict{

    NSDictionary *cacheDict = powerDict[uuid];
    if (cacheDict) {
        int pw_L      = [dict[@"POWER_L"] intValue];
        int pw_R      = [dict[@"POWER_R"] intValue];
        int pw_C      = [dict[@"POWER_C"] intValue];
        int pw_en_L   = [dict[@"ISCHARGING_L"] intValue];
        int pw_en_R   = [dict[@"ISCHARGING_R"] intValue];
        int pw_en_C   = [dict[@"ISCHARGING_C"] intValue];
        
        int c_pw_L    = [cacheDict[@"POWER_L"] intValue];
        int c_pw_R    = [cacheDict[@"POWER_R"] intValue];
        int c_pw_C    = [cacheDict[@"POWER_C"] intValue];
        int c_pw_en_L = [cacheDict[@"ISCHARGING_L"] intValue];
        int c_pw_en_R = [cacheDict[@"ISCHARGING_R"] intValue];
        int c_pw_en_C = [cacheDict[@"ISCHARGING_C"] intValue];
        
        if (pw_en_L != c_pw_en_L) return YES;
        if (pw_en_R != c_pw_en_R) return YES;
        if (pw_en_C != c_pw_en_C) return YES;
        
        /*--- 左边判断 ---*/
        BOOL is_L = [self isEnable:pw_en_L Pw:pw_L C_Pw:c_pw_L];
        
        /*--- 右边判断 ---*/
        BOOL is_R = [self isEnable:pw_en_R Pw:pw_R C_Pw:c_pw_R];
        
        /*--- 充电判断 ---*/
        BOOL is_C = [self isEnable:pw_en_C Pw:pw_C C_Pw:c_pw_C];
        
        if (is_L || is_R || is_C) {
            return YES;
        }else{
            return NO;
        }

    }else{
        return YES;
    }
}

-(BOOL)isEnable:(int8)pw_en Pw:(int8)pw C_Pw:(int8)c_pw{
    if (pw_en == 0) {
        if (pw >= c_pw) {
            return NO;
        }else{
            return YES;
        }
    }else{
        if (pw <= c_pw) {
            return NO;
        }else{
            return YES;
        }
    }
}


-(void)noteDeviceDisconnect:(NSNotification*)note{
    CBPeripheral *pl = note.object;
    NSString *uuid = pl.identifier.UUIDString;
    [powerDict removeObjectForKey:uuid];
    [self reloadTableViewData];
    [subTableView reloadData];
}


#pragma mark - UI加载框
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

-(void)addNote{
    [JL_Tools add:kUI_TURN_TO_DEVICEVC Action:@selector(enterDeviceList:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_PREPARING Action:@selector(noteDeviePreparing:) Own:self];
    [JL_Tools add:kJL_MANAGER_HEADSET_ADV Action:@selector(noteHeadsetInfo:) Own:self];
    [JL_Tools add:kJL_BLE_M_ENTITY_DISCONNECTED Action:@selector(noteDeviceDisconnect:) Own:self];
    
    [JL_Tools add:kUI_DEVICE_CELL_DELETE Action:@selector(noteDeviceDelete:) Own:self];
    [JL_Tools add:kUI_DEVICE_CELL_LOCAL Action:@selector(noteDeviceMapLocal:) Own:self];
    [JL_Tools add:kUI_DEVICE_CELL_LONGPRESS Action:@selector(noteDeviceLongPress:) Own:self];

}


-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

- (void)languageChange {
    
    [subBtn_2 setTitle:kJL_TXT("add_device") forState:UIControlStateNormal];
    noDeviceLabel.text = kJL_TXT("unconnected_device_tips");
    [self reloadTableViewData];
    
}

@end
