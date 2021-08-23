//
//  HeadphoneFunVC.m
//  IntelligentBox
//
//  Created by kaka on 2019/7/24.
//  Copyright © 2019 Zhuhia Jieli Technology. All rights reserved.
//

#import "HeadphoneFunVC.h"
#import "Headphonecell.h"
#import "JL_RunSDK.h"
#import "ANCModeView.h"



#define kJL_W           [DFUITools screen_2_W]
#define kJL_H           [DFUITools screen_2_H]
@interface HeadphoneFunVC ()<UITableViewDelegate,UITableViewDataSource,ANCModeViewDelegate>{
    int  clickIndex;
    JL_RunSDK   *bleSDK;
    NSString    *bleName;
    NSString    *bleUUID;
    ANCModeView *ancModeView;
    NSMutableArray *ancArr;
    UILabel *ancLabel2;
}

@property (weak, nonatomic) IBOutlet UIButton *titleName;
@property(nonatomic,strong) UITableView *listTable;
@property(nonatomic,strong) NSArray  *tmpArray;
@property(nonatomic,strong) NSArray  *valueArray;
@property(nonatomic,strong) NSArray  *workModeArray;
@property(nonatomic,strong) NSArray  *micModeArray;
@property(nonatomic,strong) NSArray  *lighModeArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headHeight;

@property(nonatomic,strong) UIView *ancView;
@end

@implementation HeadphoneFunVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bleSDK = [JL_RunSDK sharedMe];
    bleName = bleSDK.mBleEntityM.mItem;
    bleUUID = bleSDK.mBleEntityM.mUUID;
    
    [self initUI];
    [self addNote];
}

-(void)setHeadsetDict:(NSDictionary *)headsetDict{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdHeatsetGetAdvFlag:1<<10
                                                  Result:^(NSDictionary * _Nullable dict) {
        self->ancArr = dict[@"KEY_ANC_MODE"];
        if(self->ancArr.count >= 2 && self->_oneClickkeyFunc == 255){
            self->ancLabel2.hidden = NO;
        }else{
            self->ancLabel2.hidden = YES;
        }
    }];
}

-(void)initUI{
    _headHeight.constant = kJL_HeightNavBar;
                
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    
    if(deviceModel.ancType == JL_AncTypeYES){
        if(_ancView == nil){
            _ancView = [[UIView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+10, kJL_W, 55)];
            [self.view addSubview:_ancView];
        }
        _ancView.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterANCModeUI)];
        [_ancView addGestureRecognizer:gestureRecognizer];
        _ancView.userInteractionEnabled=YES;
        
        UILabel *ancLabel;
        if(ancLabel == nil){
            ancLabel = [[UILabel alloc] init];
            ancLabel.frame = CGRectMake(16,55/2-21/2,kJL_W-70,21);
            ancLabel.numberOfLines = 0;
            [_ancView addSubview:ancLabel];
            ancLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
            ancLabel.text =  kJL_TXT("噪声控制");
            ancLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
        }

        UIButton *ancBtn = [[UIButton alloc] initWithFrame:CGRectMake(kJL_W-8-24.5,55/2-11/2,24.5,11)];
        [ancBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_app_settings_next"] forState:UIControlStateNormal];
        [_ancView addSubview:ancBtn];

        ancLabel2 = [[UILabel alloc] init];
        ancLabel2.frame = CGRectMake(kJL_W-16-24.5-35,55/2-18/2,60,18);
        ancLabel2.numberOfLines = 0;
        [_ancView addSubview:ancLabel2];
        ancLabel2.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
        ancLabel2.text =  kJL_TXT("已启用");
        ancLabel2.textColor = kDF_RGBA(111, 206, 124, 1.0);
        ancLabel2.hidden = YES;
    }
    
    //短按耳机
    UILabel *sph_label = [[UILabel alloc] init];
    
    if(deviceModel.ancType == JL_AncTypeYES){
        sph_label.frame = CGRectMake(18,kJL_HeightNavBar+10+55,160,50);
    }else{
        sph_label.frame = CGRectMake(18,kJL_HeightNavBar+10,160,50);
    }
    sph_label.numberOfLines = 1;
    [self.view addSubview:sph_label];
    sph_label.textColor = [UIColor colorWithRed:152/255.0 green:152/255.0 blue:152/255.0 alpha:1.0];
    sph_label.font = [UIFont systemFontOfSize:13];
    
    _listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+10+50.0,kJL_W,kJL_H-(kJL_HeightNavBar+10+50.0)-27)];
    _listTable.delegate      = self;
    _listTable.dataSource    = self;
    _listTable.rowHeight = 55.0;
    _listTable.scrollEnabled = YES;
    _listTable.tableFooterView = [UIView new];
    _listTable.backgroundColor = [UIColor clearColor];
    _listTable.separatorColor = kDF_RGBA(238, 238, 238, 1.0);
    [self.view addSubview:_listTable];
    
    if(_funType == 0) { //0:短按耳机 1:轻点两下耳机
        
        sph_label.text = kJL_TXT("短按耳机");
    
    }
    if(_funType == 1) { //0:短按耳机 1:轻点两下耳机
        sph_label.text = kJL_TXT("轻点两下耳机");
    }
    if(_directionType == 0) { //0:左耳 1:右耳
        [_titleName setTitle:kJL_TXT("左") forState:UIControlStateNormal];
    }
    if(_directionType == 1) { //0:左耳 1:右耳
        [_titleName setTitle:kJL_TXT("右") forState:UIControlStateNormal];
    }
    if(_directionType == 2){ //未配对
         [_titleName setTitle:kJL_TXT("未配对") forState:UIControlStateNormal];
    }
    if(_directionType == 3){ //未连接
        [_titleName setTitle:kJL_TXT("未连接") forState:UIControlStateNormal];
    }
    if(_directionType == 4){ //已连接
        [_titleName setTitle:kJL_TXT("已连接") forState:UIControlStateNormal];
    }
    
    
    if(_funType ==0 || _funType == 1) //0:短按耳机 1:轻点两下耳机
    {
        NSMutableArray *keyFuncArray=[[NSMutableArray alloc] init];
        if([kJL_GET hasPrefix:@"zh"]){
            for (int i = 0; i < _key_function.count; i++) {
                NSString *key = _key_function[i][@"title"][@"zh"];
                [keyFuncArray addObject:key];
            }
        }else{
            for (int i = 0; i < _key_function.count; i++) {
                NSString *key = _key_function[i][@"title"][@"en"];
                [keyFuncArray addObject:key];
            }
        }
        _tmpArray = [keyFuncArray copy];
        NSMutableArray *keyValueArray=[[NSMutableArray alloc] init];
        for (int i = 0; i < _key_function.count; i++) {
               NSString *keyValue = _key_function[i][@"value"];
               [keyValueArray addObject:keyValue];
        }
        _valueArray = [keyValueArray copy];
        sph_label.hidden = NO;
        
        clickIndex = _oneClickkeyFunc;

        if(deviceModel.ancType == JL_AncTypeYES){
            _listTable.frame = CGRectMake(0, kJL_HeightNavBar+10+50.0+55.0,kJL_W,kJL_H-(kJL_HeightNavBar+10+55.0+50.0)-27);
        }else{
            _listTable.frame = CGRectMake(0, kJL_HeightNavBar+10+50.0,kJL_W,kJL_H-(kJL_HeightNavBar+10+50.0)-27);
        }
    }
    if(_funType == 2) //2:耳机模式
    {
        _listTable.frame = CGRectMake(0, kJL_HeightNavBar+10,kJL_W,kJL_H-(kJL_HeightNavBar+10)-27);
        NSMutableArray *keyFuncArray=[[NSMutableArray alloc] init];
        if([kJL_GET hasPrefix:@"zh"]){
            for (int i = 0; i < _work_mode.count; i++) {
                NSString *key = _work_mode[i][@"title"][@"zh"];
                [keyFuncArray addObject:key];
            }
        }else{
            for (int i = 0; i < _work_mode.count; i++) {
                NSString *key = _work_mode[i][@"title"][@"en"];
                [keyFuncArray addObject:key];
            }
        }
        _tmpArray = [keyFuncArray copy];
        NSMutableArray *keyWorkModeArray=[[NSMutableArray alloc] init];
        for (int i = 0; i < _work_mode.count; i++) {
            NSString *keyValue = _work_mode[i][@"value"];
            [keyWorkModeArray addObject:keyValue];
        }
        _workModeArray = [keyWorkModeArray copy];
        [_titleName setTitle:kJL_TXT("工作模式") forState:UIControlStateNormal];
        sph_label.hidden = YES;
   
        clickIndex = _workMode;
    }
    if(_funType == 3) //3:麦克风
    {
        _listTable.frame = CGRectMake(0, kJL_HeightNavBar+10,kJL_W,kJL_H-(kJL_HeightNavBar+10)-27);
        NSMutableArray *keyFuncArray=[[NSMutableArray alloc] init];
        if([kJL_GET hasPrefix:@"zh"]){
            for (int i = 0; i < _mic_channel.count; i++) {
                NSString *key = _mic_channel[i][@"title"][@"zh"];
                [keyFuncArray addObject:key];
            }
        }else{
            for (int i = 0; i < _mic_channel.count; i++) {
                NSString *key = _mic_channel[i][@"title"][@"en"];
                [keyFuncArray addObject:key];
            }
        }
        _tmpArray = [keyFuncArray copy];
        
        NSMutableArray *keyWorkModeArray=[[NSMutableArray alloc] init];
        for (int i = 0; i < _mic_channel.count; i++) {
            NSString *keyValue = _mic_channel[i][@"value"];
            [keyWorkModeArray addObject:keyValue];
        }
        _micModeArray = [keyWorkModeArray copy];
        
        [_titleName setTitle:kJL_TXT("麦克风") forState:UIControlStateNormal];
        sph_label.hidden = YES;
    
        clickIndex = _micMode;
    }
    if(_funType == 4){
        _listTable.frame = CGRectMake(0, kJL_HeightNavBar+10,kJL_W,kJL_H-(kJL_HeightNavBar+10)-27);
        NSMutableArray *keyEffectArray=[[NSMutableArray alloc] init];
        if([kJL_GET hasPrefix:@"zh"]){
            for (int i = 0; i < _key_effect.count; i++) {
                NSString *key = _key_effect[i][@"title"][@"zh"];
                [keyEffectArray addObject:key];
            }
        }else{
            for (int i = 0; i < _key_effect.count; i++) {
                NSString *key = _key_effect[i][@"title"][@"en"];
                [keyEffectArray addObject:key];
            }
        }
        _tmpArray = [keyEffectArray copy];
        
        NSMutableArray *keyLightModeArray=[[NSMutableArray alloc] init];
        for (int i = 0; i < _key_effect.count; i++) {
            NSString *keyValue = _key_effect[i][@"value"];
            [keyLightModeArray addObject:keyValue];
        }
        _lighModeArray = [keyLightModeArray copy];
        sph_label.hidden = YES;

        if(_directionType ==2){
            clickIndex = _noPairLedEffect;
        }
        if(_directionType ==3){
            clickIndex = _noConnectLedEffect;
        }
        if(_directionType ==4){
            clickIndex = _connectedLedEffect;
        }
    }
    
    [_listTable reloadData];
    
    ancModeView = [[ANCModeView alloc] initWithFrame:CGRectMake(0, 0, kJL_W, kJL_H)];
    [self.view addSubview:ancModeView];
    ancModeView.delegate = self;
    ancModeView.hidden = YES;
}

- (IBAction)leftBtnAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [JL_Tools post:@"UPDATE_DEVICE" Object:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tmpArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Headphonecell *cell = [tableView dequeueReusableCellWithIdentifier:[Headphonecell ID]];
    if (cell == nil) {
        cell = [[Headphonecell alloc] init];
    }
//    if (@available(iOS 13.0, *)) {
//        UIColor *myColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
//            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
//                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
//            }
//            else {
//                return [UIColor colorWithRed:30/255.0 green:31/255.0 blue:48/255.0 alpha:1.0];
//            }
//        }];
//        cell.contentView.backgroundColor = myColor;
//    } else {
//        cell.contentView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
//    }
    cell.contentView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    cell.cellLabel.text = _tmpArray[indexPath.row];
//    if (@available(iOS 13.0, *)) {
//        UIColor *myColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
//            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
//                return [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0];
//            }
//            else {
//                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
//            }
//        }];
//        [cell.cellLabel setTextColor:myColor];
//    } else {
//        [cell.cellLabel setTextColor:[UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0]];
//    }
    [cell.cellLabel setTextColor:[UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0]];
    
    cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
    if(self->_funType == 0 || self->_funType == 1){ //按键设置
        if(clickIndex == [_valueArray[indexPath.row] intValue]){
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
        }else{
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
        }
    }
    if(self->_funType ==2){ //工作模式设置
        if(clickIndex == [_workModeArray[indexPath.row] intValue]){
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
        }else{
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
        }
    }
    if(self->_funType == 3) { //麦克风模式设置
        if(clickIndex == [_micModeArray[indexPath.row] intValue]){
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
        }else{
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
        }
    }
    if(self->_funType == 4) { //闪灯设置
        if(clickIndex == [_lighModeArray[indexPath.row] intValue]){
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
        }else{
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
        }
    }
    
    
    if(indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1){
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 1.5*cell.bounds.size.width);
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self->ancLabel2.hidden = YES;
    
    [JL_Tools mainTask:^{
        self->clickIndex = (int)indexPath.row;
        
        //按键功能
        if(self->_funType == 0 && self->_directionType == 0){
            if(self->clickIndex !=0){
                self->clickIndex = self->clickIndex + 2;
            }
            [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetKeySettingKey:0x01 Action:0x01 Function:self->clickIndex];
        }
        if(self->_funType == 0 && self->_directionType == 1){
            if(self->clickIndex !=0){
                self->clickIndex = self->clickIndex + 2;
            }
            [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetKeySettingKey:0x02 Action:0x01 Function:self->clickIndex];
        }
        if(self->_funType == 1 && self->_directionType == 0){
            if(self->clickIndex !=0){
                self->clickIndex = self->clickIndex + 2;
            }
            [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetKeySettingKey:0x01 Action:0x02 Function:self->clickIndex];
        }
        if(self->_funType == 1 && self->_directionType == 1){
            if(self->clickIndex !=0){
                self->clickIndex = self->clickIndex + 2;
            }
            [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetKeySettingKey:0x02 Action:0x02 Function:self->clickIndex];
        }
        //耳机模式
        if(self->_funType == 2){
            self->clickIndex = self->clickIndex +1;
            [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetWorkSettingMode:self->clickIndex];
                /*--- 游戏模式 ---*/
                if (self->clickIndex == 2) {
                    [DFAction delay:0.5 Task:^{
                        [self->bleSDK.mBleEntityM.mCmdManager cmdGetLowDelay:^(uint16_t mtu, uint32_t delay) {
                            NSLog(@"----> In GAME MODE...【MTU：%d】【DELAY：%d】",mtu,delay);
                            int delay_time = 50;
                            if (delay>0) delay_time = delay;


                            [self->bleSDK.mBleEntityM setGameMode:YES MTU:mtu Delay:delay_time];
                        }];
                    }];
                }else{
                    /*--- 普通模式 ---*/
                    [self->bleSDK.mBleEntityM setGameMode:NO MTU:0 Delay:0];
                }
        }
        
        //麦克风
        if(self->_funType == 3){
            JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
            if (model.gameType == JL_GameTypeYES) {
                [DFUITools showText:kJL_TXT("游戏模式导致设置失败") onView:self.view delay:1.0];
                return;
            }
            self->clickIndex = self->clickIndex +1;
            [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetMicSettingMode:self->clickIndex Result:^(NSArray * _Nullable array) {
            }];
        }
        
        //闪灯设置
        if(self->_funType == 4){

            if(self->_directionType == 2){
                [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetLedSettingScene:0x01 Effect:self->clickIndex];
            }
            if(self->_directionType == 3){
                [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetLedSettingScene:0x02 Effect:self->clickIndex];
            }
            if(self->_directionType == 4){
                [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetLedSettingScene:0x03 Effect:self->clickIndex];
            }
        }
        
        [self->_listTable reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [self addNote];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self removeNote];
}

#pragma mark 进入噪声模式选择界面
-(void)enterANCModeUI{
    self->ancLabel2.hidden = NO;
    
    clickIndex = -1;
    [_listTable reloadData];

    if(self->_funType == 0 && self->_directionType == 0){
        [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetKeySettingKey:0x01 Action:0x01 Function:255];
    }
    if(self->_funType == 0 && self->_directionType == 1){
        [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetKeySettingKey:0x02 Action:0x01 Function:255];
    }
    if(self->_funType == 1 && self->_directionType == 0){
        [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetKeySettingKey:0x01 Action:0x02 Function:255];
    }
    if(self->_funType == 1 && self->_directionType == 1){
        [self->bleSDK.mBleEntityM.mCmdManager cmdHeatsetKeySettingKey:0x02 Action:0x02 Function:255];
    }

    ancModeView.mAncArray = self->ancArr;
    ancModeView.hidden = NO;
}

-(void)removeNote{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)noteDeviceChange:(NSNotification *) note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline) {
        if(_funType == 4){
            [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)onANCSure:(NSArray *) array{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdHeatsetAncArray:array];
    
    [JL_Tools delay:0.2 Task:^{
        [entity.mCmdManager cmdHeatsetGetAdvFlag:1<<10
                                                      Result:^(NSDictionary * _Nullable dict) {
            self->ancArr = dict[@"KEY_ANC_MODE"];
        }];
    }];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

@end
