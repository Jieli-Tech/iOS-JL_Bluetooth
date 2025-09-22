//
//  MultiLinksViewController.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/9/5.
//  Copyright © 2023 杰理科技. All rights reserved.
//

#import "MultiLinksViewController.h"
#import "MultiLinksTbCell.h"



@interface MultiLinksViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UIView *statusView;
    UISwitch *switchView;
    UILabel *funcLab;
    UILabel *tipsLab;
    UILabel *connectLab;
    UITableView *subTable;
    NSMutableArray *itemList;
}

@end

@implementation MultiLinksViewController

- (void)viewDidLoad {
    itemList = [NSMutableArray new];
    [super viewDidLoad];
    self.naviView.titleLab.text = kJL_TXT("dual_device_connection");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleListChange:) name:kJL_MULIT_NAME_LIST object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJL_MULIT_NAME_LIST object:nil];
}

-(void)initUI{
    statusView = [UIView new];
    [self.view addSubview:statusView];
    statusView.backgroundColor = [UIColor whiteColor];

    funcLab = [UILabel new];
    funcLab.textColor = [UIColor colorFromRGBAArray:@[@(0.0),@(0.0),@(0.0),@(0.9)]];
    funcLab.text = kJL_TXT("dual_device_connection");
    funcLab.font = FontMedium(15);
    [statusView addSubview:funcLab];
    
    switchView = [UISwitch new];
    [statusView addSubview:switchView];
    switchView.tintColor = [UIColor whiteColor];
    switchView.onTintColor = [UIColor colorFromHexString:@"#7657EC"];
    switchView.on = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mTwsManager.dragWithMore;
    
    tipsLab = [UILabel new];
    [self.view addSubview:tipsLab];
    tipsLab.textColor = [UIColor colorFromRGBAArray:@[@(0),@(0),@(0),@(0.6)]];
    tipsLab.font = FontMedium(12);
    tipsLab.numberOfLines = 0;
    tipsLab.text = kJL_TXT("dual_device_connect_tips");
    
    connectLab = [UILabel new];
    [self.view addSubview:connectLab];
    connectLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 14];
    connectLab.textColor = [UIColor colorFromRGBAArray:@[@(0.0),@(0.0),@(0.0),@(0.9)]];
    connectLab.text = kJL_TXT("dual_devices_connected_device");
    
    subTable = [UITableView new];
    subTable.rowHeight = 56;
    subTable.delegate = self;
    subTable.dataSource = self;
    [subTable registerClass:[MultiLinksTbCell class] forCellReuseIdentifier:@"MultiLinksTbCell"];
    subTable.tableFooterView = [UIView new];
    subTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:subTable];
    
    
    [statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.naviView.mas_bottom).offset(8);
        make.height.equalTo(@(56));
    }];
    
    [funcLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(statusView.mas_left).offset(16);
        make.centerY.equalTo(statusView);
    }];
    
    [switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(statusView.mas_right).offset(-16);
        make.width.equalTo(@(51));
        make.height.equalTo(@(31));
        make.centerY.equalTo(statusView);
    }];
    
    [tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(16);
        make.top.equalTo(statusView.mas_bottom).offset(8);
    }];
    
    [connectLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(16);
        make.height.equalTo(@(20));
        make.top.equalTo(tipsLab.mas_bottom).offset(28);
    }];
    
    
    [subTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(connectLab.mas_bottom).offset(8);
        make.bottom.equalTo(self.view);
    }];
     
    [switchView addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
}


-(void)changeSwitch:(UISwitch *)sw{
    JL_TwsManager *tws = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mTwsManager;
    NSData *addr = [[NSUserDefaults standardUserDefaults] valueForKey:PhoneEdrAddr];
    NSString *phoneName = [[NSUserDefaults standardUserDefaults] valueForKey:PhoneName];
    
    if (sw.isOn == tws.dragWithMore || addr == nil || phoneName == nil){
        return;
    }
    
    if (sw.isOn){
        
        [tws setDragWithMore:sw.isOn phoneBleAddr:addr result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
            [self dragWithMoreStatus:status];
        }];
        return;
    }
    
    
    NSString *localStr = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("dual_trun_off_tips"),phoneName,kJL_TXT("some_one_disconnected")];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kJL_TXT("are_you_sure_trun_off_dual") message:localStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:kJL_TXT("jl_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [sw setOn:tws.dragWithMore];
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:kJL_TXT("confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tws setDragWithMore:sw.isOn phoneBleAddr:addr result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
            [self dragWithMoreStatus:status];
        }];
    }];
    
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presentViewController:alert animated:true completion:nil];
}


-(void)dragWithMoreStatus:(JL_CMDStatus)status{
    JL_TwsManager *tws = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mTwsManager;
    if(status == JL_CMDStatusSuccess){
        
    }else{
        switchView.on = tws.dragWithMore;
        [DFUITools showText:kJL_TXT("setting_failed_need_devices_all_online") onView:self.view delay:2];
    }
}


-(void)initData{
    JL_TwsManager *tws = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mTwsManager;
    
    [itemList removeAllObjects];
    [tws cmdGetDeviceInfoListResult:^(JL_CMDStatus status, NSArray<JLTWSAddrNameInfo *> * _Nullable phoneInfos) {
        if (status == JL_CMDStatusSuccess){
            
            [self->itemList setArray:phoneInfos];
            for (JLTWSAddrNameInfo *info in phoneInfos){
                [info logProperties];
            }
            
            NSData *addr = [[NSUserDefaults standardUserDefaults] valueForKey:PhoneEdrAddr];

            if (phoneInfos.count == 1){
                JLTWSAddrNameInfo *info = phoneInfos.firstObject;
                [[NSUserDefaults standardUserDefaults] setValue:info.phoneEdrAddr forKey:PhoneEdrAddr];
                [[NSUserDefaults standardUserDefaults] setValue:info.phoneName forKey:PhoneName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //绑定
                [tws cmdBindDeviceInfo:info.phoneEdrAddr phone:info.phoneName result:^(JL_CMDStatus status, NSArray<JLTWSAddrNameInfo *> * _Nullable phoneInfos) {
                    [self->subTable reloadData];
                }];
            }
            if (phoneInfos.count == 2){
                for (JLTWSAddrNameInfo *info in phoneInfos) {
                    if (info.isBind){
                        if ([info.phoneEdrAddr isEqualToData:addr]){
                            [[NSUserDefaults standardUserDefaults] setValue:info.phoneName forKey:PhoneName];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            //绑定
                            [tws cmdBindDeviceInfo:info.phoneEdrAddr phone:info.phoneName result:^(JL_CMDStatus status, NSArray<JLTWSAddrNameInfo *> * _Nullable phoneInfos) {
                                [self->subTable reloadData];
                            }];
                            
                        }
                    }else{
                        if ([info.phoneEdrAddr isEqualToData:addr]){
                            [[NSUserDefaults standardUserDefaults] setValue:info.phoneEdrAddr forKey:PhoneEdrAddr];
                            [[NSUserDefaults standardUserDefaults] setValue:info.phoneName forKey:PhoneName];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            //绑定
                            [tws cmdBindDeviceInfo:info.phoneEdrAddr phone:info.phoneName result:^(JL_CMDStatus status, NSArray<JLTWSAddrNameInfo *> * _Nullable phoneInfos) {
                                [self->subTable reloadData];
                            }];
                        }
                    }
                }
            }
        }
        [self->subTable reloadData];
    }];
    
    
}



-(void)handleListChange:(NSNotification *)note{
    NSDictionary *dict = note.object;
    NSString *uuid = dict[kJL_MANAGER_KEY_UUID];
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    if ([entity.mUUID isEqualToString:uuid]){
        NSArray *array = dict[kJL_MANAGER_KEY_OBJECT];
        [itemList setArray:array];
        [subTable reloadData];
    }
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MultiLinksTbCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultiLinksTbCell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[MultiLinksTbCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MultiLinksTbCell"];
    }
    JLTWSAddrNameInfo *item = itemList[indexPath.row];
    cell.mainLab.text = item.phoneName;
    
    NSData *addr = [[NSUserDefaults standardUserDefaults] valueForKey:PhoneEdrAddr];
    
    if([addr isEqualToData:item.phoneEdrAddr]){
        cell.isLocalLab.hidden = false;
    }else{
        cell.isLocalLab.hidden = true;
    }
    
    if (indexPath.row == itemList.count-1){
        cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
    }else{
        cell.separatorInset = UIEdgeInsetsMake(0, 52, 0, 0);
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return itemList.count;
}


@end
