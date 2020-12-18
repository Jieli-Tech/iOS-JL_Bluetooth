//
//  AlarmClockVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/29.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AlarmClockVC.h"
#import "AlarmClockCell.h"
#import "JL_RunSDK.h"
#import "AlarmSetVC.h"
#import "AlarmObject.h"
#import "RTCAlertView.h"

@interface AlarmClockVC ()<UITableViewDelegate,UITableViewDataSource,AlarmClockCellDelegate>{
    __weak IBOutlet UILabel *titleLab;
    __weak IBOutlet UITableView *alarmTable;
    NSMutableArray *itemArray;
    __weak IBOutlet UIButton *syncDateBtn;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    RTCAlertView *rtcAlert;
}

@end

@implementation AlarmClockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    itemArray = [NSMutableArray new];
//    [itemArray addObject:@"01"];
//    [itemArray addObject:@"02"];
    [self initWithData];
    
    titleHeight.constant = kJL_HeightNavBar+10;
    
    alarmTable.delegate = self;
    alarmTable.dataSource = self;
    alarmTable.rowHeight = 80.0;
    alarmTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    alarmTable.tableFooterView = [UIView new];
    alarmTable.backgroundColor = [UIColor clearColor];
    [alarmTable registerNib:[UINib nibWithNibName:@"AlarmClockCell" bundle:nil] forCellReuseIdentifier:@"AlarmClockCell"];
    syncDateBtn.layer.cornerRadius = 25.0;
    syncDateBtn.layer.masksToBounds = YES;
    
    [self addNote];
}

-(void)initWithData{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeRTC SelectionBit:0xF2 Result:^(NSArray * _Nullable array) {
        JLModel_Device *devModel = [entity.mCmdManager outputDeviceModel];
         self->itemArray = [NSMutableArray arrayWithArray:devModel.rtcAlarms];
         [self->alarmTable reloadData];
        
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [self initWithData];
}

-(void)rtcNote:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    JLModel_Device *model = [note object][kJL_MANAGER_KEY_OBJECT];
    itemArray = [NSMutableArray arrayWithArray:model.rtcAlarms];
    [alarmTable reloadData];
}

-(void)noteDeviceChange:(NSNotification *)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (IBAction)leftBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)addBtnAction:(id)sender {
    if (itemArray.count>=5) {
        [DFUITools showText:@"闹钟数量已满" onView:self.view delay:1.0];
    }else{
        
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:@[@(0),@(1),@(2),@(3),@(4)]];
        
        uint8_t index = 0;
        for (JLModel_RTC *rtcMd in itemArray) {
            uint8_t rtcIndex = rtcMd.rtcIndex;
            if ([mArr containsObject:@(rtcIndex)]) {
                [mArr removeObject:@(rtcIndex)];
            }
        }
        if (mArr.count > 0) {
            index = (uint8_t)[mArr[0] intValue];
        }
        NSLog(@"----> Add RTC Index: %d",index);
        
        AlarmSetVC *vc = [[AlarmSetVC alloc] init];
        vc.modalPresentationStyle = 0;
        vc.createType = YES;
        vc.alarmIndex = index;
        [self presentViewController:vc animated:YES completion:nil];
    }
}
- (IBAction)syncDateBtnAction:(id)sender {
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdSetSystemTime:[NSDate new]];
}


#pragma mark ///TableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 8)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return itemArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlarmClockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmClockCell" forIndexPath:indexPath];
    JLModel_RTC *model = itemArray[indexPath.section];
    if(model.rtcMin<10){
        cell.ClockLab.text = [NSString stringWithFormat:@"%d:0%d",model.rtcHour,model.rtcMin];
    }else{
        cell.ClockLab.text = [NSString stringWithFormat:@"%d:%d",model.rtcHour,model.rtcMin];
    }
    NSString *name = model.rtcName;
    NSString *repeat = [AlarmObject stringMode:model.rtcMode];
    NSString *newStr = [NSString stringWithFormat:@"%@ %@",name,repeat];
    cell.detailLab.text = newStr;
    cell.tag = indexPath.section;
    [cell.select setOn:model.rtcEnable animated:YES];
    [cell.select setOnTintColor:kColor_0000];
    cell.delegate = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AlarmSetVC *vc = [[AlarmSetVC alloc] init];
    vc.rtcmodel = itemArray[indexPath.section];
    vc.createType = NO;
    vc.modalPresentationStyle = 0;
    [self presentViewController:vc animated:YES completion:nil];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kJL_TXT("删除");
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    JLModel_RTC *model = itemArray[indexPath.section];
    [itemArray removeObjectAtIndex:indexPath.section];
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdRtcDeleteIndexArray:@[@(model.rtcIndex)] Result:^(NSArray *array) {
        JL_CMDStatus state = (UInt8)[array[0] intValue];
        if(state == JL_CMDStatusSuccess){
            [DFUITools showText:@"删除成功!" onView:self.view delay:1.0];
        }
        if(state == JL_CMDStatusFail){
            [DFUITools showText:@"删除失败!" onView:self.view delay:1.0];
        }
        
    }];
    [tableView reloadData];
}


#pragma mark ///Cell Delegate
-(void)alarmClockCellDidSelect:(NSInteger)index status:(BOOL)status{
    
    JLModel_RTC *rtcModel = itemArray[index];
    rtcModel.rtcEnable = status;
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdRtcSetArray:@[rtcModel] Result:^(NSArray * _Nullable array) {
        JL_CMDStatus state = (UInt8)[array[0] intValue];
        if(state == JL_CMDStatusSuccess){
            
        }
        if(state == JL_CMDStatusFail){
            [DFUITools showText:@"设置失败" onView:self.view delay:1.0];
            [self initWithData];
        }
    }];
}

-(void)addNote{
    [JL_Tools add:kJL_MANAGER_SYSTEM_INFO Action:@selector(rtcNote:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [JL_Tools remove:nil Own:self];
}

@end
