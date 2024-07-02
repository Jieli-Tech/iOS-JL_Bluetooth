//
//  SearchView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "SearchView.h"
#import "JL_RunSDK.h"
#import "DeviceListCell.h"
#import "JLUI_Effect.h"
#import "SqliteManager.h"
#import "JLUI_Cache.h"
#import "ElasticHandler.h"

@interface SearchView()<UITableViewDelegate,UITableViewDataSource,LanguagePtl>{
    UIView *bgImgv;
    UITableView *deviceTable;
    UILabel *titleLab;
    UIActivityIndicatorView *activeView;

    UIView *centerView;
    UITapGestureRecognizer *tapges;

    JL_RunSDK   *bleSDK;
    NSString    *bleUUID;
    BOOL        isConnectOK;
}
@property (weak,nonatomic) NSMutableArray *foundArray;
@end

@implementation SearchView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[LanguageCls share] add:self];
        [self stepUI];
    }
    return self;
}


-(void)stepUI{
    isConnectOK = YES;
    
    self.backgroundColor = [UIColor clearColor];
//    bgImgv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bgImgv = [[UIView alloc] init];
    bgImgv.backgroundColor = [UIColor blackColor];
    bgImgv.alpha = 0.3;
    [self addSubview:bgImgv];
    
    
    centerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0.6*self.frame.size.height+40)];
    [JLUI_Effect addShadowOnView:centerView];
    [self addSubview:centerView];
    
//    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, 160, 25.0)];
    titleLab = [[UILabel alloc] init];
    titleLab.text = kJL_TXT("connectable_devies");
    titleLab.font = [UIFont systemFontOfSize:15.0];
    titleLab.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0];
    [centerView addSubview:titleLab];
    
//    activeView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(100, 12.0, 25.0, 25.0)];
    activeView = [[UIActivityIndicatorView alloc] init];
    [activeView startAnimating];
    [centerView addSubview:activeView];
    activeView.activityIndicatorViewStyle =  UIActivityIndicatorViewStyleGray;
    
//    deviceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 40.0, centerView.frame.size.width, centerView.frame.size.height-40-40)];
    deviceTable = [[UITableView alloc] init];
    deviceTable.rowHeight = 50.0;

    deviceTable.delegate = self;
    deviceTable.dataSource = self;
    deviceTable.backgroundColor = [UIColor clearColor];
    deviceTable.tableFooterView = [UIView new];
    deviceTable.separatorColor = kDF_RGBA(238, 238, 238, 1.0);
    [deviceTable registerNib:[UINib nibWithNibName:@"DeviceListCell" bundle:nil] forCellReuseIdentifier:@"DeviceListCell"];
    [centerView addSubview:deviceTable];
    
    tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAction)];
    [bgImgv addGestureRecognizer:tapges];
    
    [self stepUILayout];
    
}

-(void)stepUILayout{
    UIView *superview = self;
    
    [bgImgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top).offset(0);
        make.left.equalTo(superview.mas_left).offset(0);
        make.right.equalTo(superview.mas_right).offset(0);
        make.bottom.equalTo(superview.mas_bottom).offset(0);
    }];
    
    //CGRectMake(20.0, 12.0, 160, 25.0)
    //centerView
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->centerView.mas_left).offset(20);
        make.top.equalTo(self->centerView.mas_top).offset(12);
        make.right.equalTo(self->activeView.mas_left).offset(-2.0);
        make.bottom.equalTo(self->deviceTable.mas_top).offset(-8);
        make.height.offset(25);
    }];
    //CGRectMake(100, 12.0, 25.0, 25.0)
    //centerView
    [activeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->titleLab.mas_right).offset(2.0);
        make.top.equalTo(self->centerView.mas_top).offset(12);
        make.bottom.equalTo(self->deviceTable.mas_top).offset(-8);
        make.height.offset(25.0);
        make.width.offset(25.0);
    }];
    
    //CGRectMake(0, 40.0, centerView.frame.size.width, centerView.frame.size.height-40-40)
    [deviceTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->titleLab.mas_bottom).offset(8.0);
        make.left.equalTo(self->centerView.mas_left).offset(0.0);
        make.right.equalTo(self->centerView.mas_right).offset(0.0);
        make.bottom.equalTo(self->centerView.mas_bottom).offset(-40);
    }];
    

}


-(void)dismissAction{
    [[JLUI_Cache sharedInstance] setIsSearchView:NO];
    
    /*--- 开启BLE广播 ---*/
    [JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];
    
    [JL_Tools remove:kJL_BLE_M_FOUND Own:self];
    
    CGRect rect = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0.6*self.frame.size.height+40);
    [UIView animateWithDuration:0.2 animations:^{
        self->centerView.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


-(void)startSearch{
    [[JLUI_Cache sharedInstance] setIsSearchView:YES];
    
    isConnectOK = YES;
    
    bleSDK = [JL_RunSDK sharedMe];
    self.foundArray = bleSDK.mBleMultiple.blePeripheralArr;
    
    [JL_Tools add:kJL_BLE_M_FOUND Action:@selector(noteBleFoundDevice:) Own:self];
    
    CGRect rect = CGRectMake(0, 0.4*self.frame.size.height,
                             self.frame.size.width,
                             0.6*self.frame.size.height+40);
    [UIView animateWithDuration:0.2 animations:^{
        self->centerView.frame = rect;
        [self->deviceTable reloadData];
    }];
}


-(void)noteBleFoundDevice:(NSNotification*)note{
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
    [deviceTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mrak < tableView Delegate >
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.foundArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //DeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceListCell" forIndexPath:indexPath];
    
    DeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceListCell"];
    if (cell == nil) {
        cell = [[DeviceListCell alloc] init];
    }
    
    
    cell.statusImgv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
    
    JL_EntityM *entity = self.foundArray[indexPath.row];
    cell.deviceNameLab.text = entity.mItem;
    
    if (entity.mBLE_IS_PAIRED) {
        cell.statusImgv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
    }else{
        cell.statusImgv.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
    }
    
    if (entity.mType == JL_DeviceTypeTWS) {
        if (entity.mProtocolType == PTLVersion){//挂脖耳机
            cell.deviceImgv.image = [UIImage imageNamed:@"Theme.bundle/connect_icon_earphone_03"];
        }else{
            cell.deviceImgv.image = [UIImage imageNamed:@"Theme.bundle/connect_icon_earphone"];
        }
    }else if(entity.mType == JL_DeviceTypeSoundCard){
        cell.deviceImgv.image = [UIImage imageNamed:@"Theme.bundle/connect_icon_mic"];
    }else{
        cell.deviceImgv.image = [UIImage imageNamed:@"Theme.bundle/connect_icon_speaker"];
    }
    
    if ([entity.mUUID isEqual:bleUUID]) {
        cell.activeView.hidden = NO;
        [cell.activeView startAnimating];
    }else{
        [cell.activeView stopAnimating];
        cell.activeView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (self.foundArray.count == 0) {
        NSLog(@"---> BLE 刷新中...");
        //[JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];
        return;
    }else{
        /*--- 关闭BLE广播 ---*/
        [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
    }
    
    if (isConnectOK == NO) return;
    isConnectOK = NO;
    
    JL_EntityM *bleEntity = self.foundArray[indexPath.row];
    
    bleUUID = bleEntity.mUUID;
    [deviceTable reloadData];
    
    /*--- 请求设备图片 ---*/
    NSString *uuidStr = bleEntity.mUUID;
    NSNumber *vidNumber = [NSNumber numberWithLong:strtoul(bleEntity.mVID.UTF8String, 0, 16)];
    NSString *vidStr = [vidNumber stringValue];
     
    NSNumber *pidNumber = [NSNumber numberWithLong:strtoul(bleEntity.mPID.UTF8String, 0, 16)];
    NSString *pidStr = [pidNumber stringValue];
 
     
    if (vidStr.length == 0) vidStr = @"0000";
    if (pidStr.length == 0) pidStr = @"0000";
    
    
    NSArray *itemArr = @[@"PRODUCT_LOGO",@"DOUBLE_HEADSET",
                         @"LEFT_DEVICE_CONNECTED",@"RIGHT_DEVICE_CONNECTED",
                         @"CHARGING_BIN_IDLE"];

    NSLog(@"---> 图片刷新...");
    [bleEntity.mCmdManager cmdRequestDeviceImageVid:vidStr Pid:pidStr
                                          ItemArray:itemArr Result:^(NSMutableDictionary * _Nullable dict) {
        if (dict) {
            NSDictionary *dict_1 = [NSDictionary dictionaryWithDictionary:dict];
            //[[JLUI_Cache sharedInstance] setAllImage:dict_1 WithUuid:uuidStr];
            [[JLCacheBox cacheUuid:uuidStr] setAllImage:dict_1 WithUuid:uuidStr];
        }
        
        /*--- 连接设备 ---*/
        NSLog(@"---> 搜索界面，连接设备：%@，Edr：%@",bleEntity.mItem,bleEntity.mEdr);
        
        __weak typeof(self) wSelf = self;
        [self->bleSDK.mBleMultiple connectEntity:bleEntity
                                          Result:^(JL_EntityM_Status status) {
            
            self->isConnectOK = YES;
            UIWindow *win = [DFUITools getWindow];
            NSString *txt = [JL_RunSDK textEntityStatus:status];
            
            //加入黑名单
            [[ElasticHandler sharedInstance] setToBlackList:bleEntity];
            
            if (status == JL_EntityM_StatusPaired) {
                
                //插入连接历史记录数据库
                [[SqliteManager sharedInstance] installWithDevice:bleEntity];
                
                //[bleEntity.mCmdManager cmdHeatsetAdvEnable:NO];
            }
            [JL_Tools mainTask:^{
                [DFUITools showText:txt onView:win delay:1.0];
                [JL_Tools delay:0.5 Task:^{
                    [wSelf dismissAction];
                }];
            }];
            
            self->bleUUID = nil;
            [JL_Tools mainTask:^{
                [self->deviceTable reloadData];
            }];
        }];
    }];
}

-(void)languageChange {
    titleLab.text = kJL_TXT("connectable_devies");
}

@end
