//
//  MapListVC.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/8/18.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "MapListVC.h"
#import "MapViewController.h"
#import "MapListCell.h"
#import "SqliteManager.h"
#import "MapLocationRequest.h"

#import "JLUI_Cache.h"
#import "NoNetView.h"


@interface MapListVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    __weak IBOutlet NSLayoutConstraint *topViewH;
    __weak IBOutlet UITableView *subTableView;
    
    __weak IBOutlet NSLayoutConstraint *subTableView_H;
    NSMutableArray *dataArray;
    NoNetView *noNetView;
    NSMutableDictionary  *powerDict;
}

@end

@implementation MapListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self addNote];
    
    noNetView = [[NoNetView alloc] initByFrame:CGRectMake(0,kJL_HeightNavBar, [UIScreen mainScreen].bounds.size.width, 40)];
    [self.view addSubview:noNetView];
    noNetView.hidden = YES;
    
    /*--- 网络监测 ---*/
    [self isNetwork];


}

-(void)noteNetworkStatus:(NSNotification*)note{
    [self isNetwork];
}

-(BOOL)isNetwork{
    /*--- 网络监测 ---*/
    AFNetworkReachabilityStatus netSt = [[JLUI_Cache sharedInstance] networkStatus];
    if (netSt == AFNetworkReachabilityStatusUnknown ||
        netSt == AFNetworkReachabilityStatusNotReachable) {
        //[DFUITools showText:@"请检查手机网络!" onView:self.view delay:1.0];
        subTableView_H.constant = 50;
        noNetView.hidden = NO;
        return NO;
    }else{
        subTableView_H.constant = 10;
        noNetView.hidden = YES;
        return YES;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [self reloadData];
}

-(void)reloadData{
    dataArray = [NSMutableArray new];
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];

    NSString *mUuid = entity.mPeripheral.identifier.UUIDString;
    
    NSArray *arr = [[SqliteManager sharedInstance] checkOutAll];
    for (DeviceObjc *model in arr) {
        if ([model.findDevice isEqual:@"1"]) {
            if([model.uuid isEqualToString:mUuid]){
                if (model.address.length == 0) {
                    NSLog(@"---> 设备定位 1");
                    [[MapLocationRequest shareInstanced] requestLocation:entity];
                }
                [dataArray insertObject:model atIndex:0];
            }else{
                [dataArray addObject:model];
            }
        }
    }
    [subTableView reloadData];
    
    if (dataArray.count == 0) {
        [DFUITools showText:kJL_TXT("暂无设备可查找") onView:self.view delay:1.0];
    }
}

-(void)setupUI{
    powerDict = [NSMutableDictionary new];
    
    topViewH.constant = kJL_HeightNavBar;
    
    subTableView.tableFooterView = [UIView new];
    subTableView.rowHeight = 95.0;
    subTableView.delegate = self;
    subTableView.dataSource = self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MapListCell *cell = [tableView dequeueReusableCellWithIdentifier:[MapListCell ID]];
    if (cell == nil) {
        cell = [[MapListCell alloc] init];
    }
    cell.backgroundColor = [UIColor clearColor];
    DeviceObjc *model = dataArray[indexPath.row];
    cell.mLabel_0.text = model.name;
    if (model.type == 0) {
        cell.mImageView.image = [UIImage imageNamed:@"Theme.bundle/icon_spaeker_03"];
    }else if(model.type == 4){
        cell.mImageView.image = [UIImage imageNamed:@"Theme.bundle/icon_mic_02"];
    }else{
        cell.mImageView.image = [UIImage imageNamed:@"Theme.bundle/icon_eraphone_03"];
    }
    
    cell.mLabel_1.text = model.address?:@"";
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JL_BLEMultiple *multiple = [[JL_RunSDK sharedMe] mBleMultiple];
    
    BOOL isConnect = NO;
    for (JL_EntityM *item in multiple.bleConnectedArr) {
        if ([item.mUUID isEqualToString:model.uuid]) {
            isConnect = YES;
            break;
        }
    }
    if (isConnect) {
        cell.mLabel_2.textColor = [UIColor colorWithRed:27/255.0 green:192.0/255.0 blue:23.0/255.0 alpha:1.0];
        cell.mLabel_2.text = kJL_TXT("• 已连接");
    }else{
        cell.mLabel_2.textColor = [UIColor colorWithRed:95.0/255.0 green:95.0/255.0 blue:95.0/255.0 alpha:1.0];
        cell.mLabel_2.text = kJL_TXT("• 未连接");
    }
    if ([model.uuid isEqualToString:entity.mUUID]) {
        cell.mLabel_2.textColor = kDF_RGBA(31, 150, 243, 1.0);
        cell.mLabel_2.text = kJL_TXT("正在使用");
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MapViewController *vc = [[MapViewController alloc] init];
    
    DeviceObjc *objc = dataArray[indexPath.row];
    
    vc.deviceObjc = dataArray[indexPath.row];
    powerDict = [[JLUI_Cache sharedInstance] mPowerDic];
    vc.powerDict = powerDict;
    vc.deviceUUID = objc.uuid;
    vc.modalPresentationStyle = 0;
    [self presentViewController:vc animated:YES completion:nil];
}


- (IBAction)btn_Back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)udpateMapList{
    [self reloadData];
}

-(void)handleDisconnect:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


-(void)noteDeviceDisconnect:(NSNotification*)note{
    CBPeripheral *pl = note.object;
    NSString *uuid = pl.identifier.UUIDString;
    [powerDict removeObjectForKey:uuid];
}


-(void)addNote{
    [JL_Tools add:kJL_BLE_M_ENTITY_DISCONNECTED Action:@selector(noteDeviceDisconnect:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(handleDisconnect:) Own:self];
    [JL_Tools add:@"UPDATE_MAP_LIST" Action:@selector(udpateMapList) Own:self];
    [JL_Tools add:AFNetworkingReachabilityDidChangeNotification Action:@selector(noteNetworkStatus:) Own:self];

}

-(void)viewDidDisappear:(BOOL)animated{
    [JL_Tools remove:nil Own:self];
}
@end
