//
//  AlarmSetVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/29.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AlarmSetVC.h"
#import "JL_RunSDK.h"
#import "AlarmCVCell.h"
#import "AlarmSetCell.h"
#import "AlarmRingVC.h"
#import "ReNameView.h"
#import "ECPickerView.h"
#import "AlarmObject.h"

#define txC1 kDF_RGBA(84, 84, 84, 1)
#define txC2 kDF_RGBA(255, 255, 255, 1)
#define cNorc kDF_RGBA(226,226,226,1)
#define cSelc kDF_RGBA(128, 91, 235, 1)
#define cPiLinkSelc kDF_RGBA(74, 104, 204, 1)


@interface AlarmSetVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource,ECPickerViewDataSourse,ECPickerViewDelegate,ReNameViewDelegate>{
 
    __weak IBOutlet UILabel *titleLab;
    __weak IBOutlet UIButton *commitBtn;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet NSLayoutConstraint *titleHight;
    
    UICollectionView *collectView;
    UITableView *tableView;
    __weak IBOutlet UIButton *deleteBtn;
    NSArray *itemArray;
    NSArray *nameArray;
    NSMutableArray *ecRepeatArr;
    NSArray *repeatItemArr;
    ECPickerView *pickerView;
    ReNameView *reNameVew;
    
    NSArray *minArray;
    NSArray *basicArray;
}
@end

@implementation AlarmSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initWithData];
    [self initWithUI];
    [self addNote];
}

-(void)viewWillAppear:(BOOL)animated{
    if (self.rtcmodel.ringInfo) {
        NSString *ringName = [[NSString alloc] initWithData:self.rtcmodel.ringInfo.data encoding:NSUTF8StringEncoding];
        if (!ringName) {
            ringName = @"unknowName";
        }
        nameArray = @[self.rtcmodel.rtcName,ringName];
    }else{
        nameArray = @[self.rtcmodel.rtcName];
        itemArray = @[kJL_TXT("名称")];
    }
    [tableView reloadData];
}

- (IBAction)leftBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)commitBtnAction:(id)sender {
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    self.rtcmodel.rtcEnable = YES;
    [entity.mCmdManager cmdRtcSetArray:@[self.rtcmodel] Result:^(NSArray * _Nullable array) {
        JL_CMDStatus state = (UInt8)[array[0] intValue];
        if(state == JL_CMDStatusSuccess){
            [JL_Tools mainTask:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        if(state == JL_CMDStatusFail){
            [DFUITools showText:@"设置失败" onView:self.view delay:1.0];
        }
    }];
}
- (IBAction)deleteBtnAction:(id)sender {
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdRtcDeleteIndexArray:@[@(self.rtcmodel.rtcIndex)] Result:^(NSArray * _Nullable array) {
        JL_CMDStatus state = (UInt8)[array[0] intValue];
        if(state == JL_CMDStatusSuccess){
            [JL_Tools mainTask:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        if(state == JL_CMDStatusFail){
            [DFUITools showText:@"删除失败!" onView:self.view delay:1.0];
        }
    }];
}

-(void)initWithData{
    itemArray = @[kJL_TXT("名称"),kJL_TXT("铃声")];
    ecRepeatArr = [NSMutableArray new];
    repeatItemArr = @[kJL_TXT("周一"),kJL_TXT("周二"),kJL_TXT("周三"),kJL_TXT("周四"),kJL_TXT("周五"),kJL_TXT("周六"),kJL_TXT("周日")];
    if (self.createType == NO) {
        NSArray *tmpA = [AlarmObject stringsMode:self.rtcmodel.rtcMode];
        [ecRepeatArr setArray:tmpA];
        if (self.rtcmodel.ringInfo) {
            NSString *ringName = [[NSString alloc] initWithData:self.rtcmodel.ringInfo.data encoding:NSUTF8StringEncoding];
            if (!ringName) {
                ringName = @"unknowName";
            }
            nameArray = @[self.rtcmodel.rtcName,ringName];
        }else{
            nameArray = @[self.rtcmodel.rtcName];
            itemArray = @[kJL_TXT("名称")];
        }
    }else{
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        JLModel_Device *device = [entity.mCmdManager outputDeviceModel];
      
        self.rtcmodel = [JLModel_RTC new];
        self.rtcmodel.rtcName = kJL_TXT("闹钟");
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy:MM:DD:HH:mm:ss";
        NSString *nowStr = [formatter stringFromDate:[NSDate new]];
        NSArray *timeArr = [nowStr componentsSeparatedByString:@":"];
        self.rtcmodel.rtcYear = [timeArr[0] intValue];
        self.rtcmodel.rtcMonth = [timeArr[1] intValue];
        self.rtcmodel.rtcDay = [timeArr[2] intValue];
        self.rtcmodel.rtcHour = [timeArr[3] intValue];
        self.rtcmodel.rtcMin = [timeArr[4] intValue];
        self.rtcmodel.rtcSec = [timeArr[5] intValue];
        self.rtcmodel.rtcMode = 0x00;
        self.rtcmodel.rtcEnable = YES;
        self.rtcmodel.rtcIndex = self.alarmIndex;
        if (device.rtcDfRings.count>0) {
            JLModel_Ring *ring = device.rtcDfRings[0];
            nameArray = @[kJL_TXT("闹钟"),ring.name];
            self.rtcmodel.ringInfo = [RTC_RingInfo new];
            self.rtcmodel.ringInfo.type = 0;
            self.rtcmodel.ringInfo.dev = 0;
            self.rtcmodel.ringInfo.clust = 0;
            self.rtcmodel.ringInfo.data = [ring.name dataUsingEncoding:NSUTF8StringEncoding];
            self.rtcmodel.ringInfo.len = (uint8_t)self.rtcmodel.ringInfo.data.length;
        }else{
            nameArray = @[kJL_TXT("闹钟")];
            itemArray = @[kJL_TXT("名称")];
        }
        
    }
    

    NSMutableArray *ar = [NSMutableArray new];
    NSMutableArray *ar1 = [NSMutableArray new];
     for (int i = 0; i<60; i++) {
         NSString *str;
         if (i<10) {
             str = [NSString stringWithFormat:@"0%d",i];
         }else{
             str = [NSString stringWithFormat:@"%d",i];
         }
         [ar addObject:str];
         if (i<24) {
             [ar1 addObject:str];
         }
     }
     minArray  = ar;
     basicArray = ar1;
}

-(void)initWithUI{
    
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    titleHight.constant = kJL_HeightNavBar+10;
    
    pickerView = [[ECPickerView alloc] initWithFrame:CGRectMake(sw/2-85, 20, 170, 210)];
    pickerView.datasourse = self;
    pickerView.delegate = self;
    [contentView addSubview:pickerView];
    
    CGFloat hight = 74+202+8+8+24;
    UICollectionViewFlowLayout *cf = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = (sw-40)/7;
    cf.itemSize = CGSizeMake(itemW, 80);
    cf.minimumLineSpacing = 2.0;
    cf.minimumInteritemSpacing = 0;
    cf.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(16, hight, sw-32, 80) collectionViewLayout:cf];
    collectView.delegate = self;
    collectView.dataSource = self;
    collectView.backgroundColor = [UIColor clearColor];
    [collectView registerNib:[UINib nibWithNibName:@"AlarmCVCell" bundle:nil] forCellWithReuseIdentifier:@"AlarmCVCell"];
    collectView.scrollEnabled = NO;
    [self.view addSubview:collectView];
    
    hight+=collectView.frame.size.height;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(26, hight-0.5, sw-26, 0.3)];
    lineView.backgroundColor = kDF_RGBA(238, 238, 238, 1);
    [self.view addSubview:lineView];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, hight, sw, 140)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 70.0;
    [tableView registerNib:[UINib nibWithNibName:@"AlarmSetCell" bundle:nil] forCellReuseIdentifier:@"AlarmSetCell"];
    tableView.tableFooterView = [UIView new];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollEnabled = NO;
    [self.view addSubview:tableView];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(26, hight-0.3+70, sw-26, 0.3)];
    lineView2.backgroundColor = kDF_RGBA(238, 238, 238, 1);
    [self.view addSubview:lineView2];
    
    deleteBtn.layer.cornerRadius = 24;
    deleteBtn.layer.masksToBounds = YES;
    [deleteBtn setTitle:kJL_TXT("删除闹钟") forState:UIControlStateNormal];
//    deleteBtn.hidden = YES;
    reNameVew = [[ReNameView alloc] initWithFrame:CGRectMake(0, 0, [DFUITools screen_2_W], [DFUITools screen_2_H])];
    reNameVew.sizeLength = 10;
    reNameVew.delegate = self;
    
    if (self.createType) {
        titleLab.text = kJL_TXT("新建闹钟");
        deleteBtn.hidden = YES;
    }else{
        titleLab.text = kJL_TXT("编辑闹钟");
        deleteBtn.hidden = NO;
        NSString *clockTimeStr;
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH:mm:ss";
        clockTimeStr = [NSString stringWithFormat:@"%d:%d:%d",self.rtcmodel.rtcHour,self.rtcmodel.rtcMin,self.rtcmodel.rtcSec];
        NSDate *date = [formatter dateFromString:clockTimeStr];
        [pickerView scrollToDate:date];
        
    }
    
    
}
#pragma mark ///ECPickerView datasoure
-(NSArray *)pickerView:(ECPickerView *)view withSection:(NSInteger)section{
    if (section == 0) {
        return basicArray;
    }else{
        return minArray;
    }
}
- (UIView *)pickerView:(ECPickerView *)view withSection:(NSInteger)section indexPath:(NSInteger)index{
    NSString *str1;
      if (section == 0) {
          str1 = basicArray[index];
      }else{
          str1 = minArray[index];
      }
      CGFloat width = view.frame.size.width/2;
      UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
      lab.text = str1;
      lab.font = [UIFont systemFontOfSize:25];
      lab.textColor = [UIColor blackColor];
      lab.textAlignment = NSTextAlignmentCenter;
      return lab;
}
-(CGFloat)pickerView:(ECPickerView *)view setHightForCell:(NSInteger)section indexPath:(NSInteger)index{
    return 40;
}

-(NSInteger)numberOfItemsInSection:(ECPickerView *)view{
    return 2;
}
#pragma mark ///EC DatePicker Delegate

-(void)cpickerViewMoveToItemEndAnimation:(NSArray *)selectArray{
    self.rtcmodel.rtcHour = [selectArray[0] intValue];
    self.rtcmodel.rtcMin = [selectArray[1] intValue];
}

-(void)cpickerViewMoveToItem:(NSArray *)selectArray{
    self.rtcmodel.rtcHour = [selectArray[0] intValue];
    self.rtcmodel.rtcMin = [selectArray[1] intValue];
}


#pragma mark ///CollectionView Delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
     AlarmCVCell *cell = (AlarmCVCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.bgView.backgroundColor = [UIColor lightGrayColor];
}
-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    AlarmCVCell *cell = (AlarmCVCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.bgView.backgroundColor = cNorc;
//    NSValue *value = @(indexPath.row);
    if ([ecRepeatArr containsObject:repeatItemArr[indexPath.row]]) {
        cell.bgView.backgroundColor = cSelc;
        cell.textlab.textColor = txC2;
    }else{
        cell.bgView.backgroundColor = cNorc;
        cell.textlab.textColor = txC1;
    }
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return repeatItemArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AlarmCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlarmCVCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textlab.text = repeatItemArr[indexPath.row];
    
    if ([ecRepeatArr containsObject:repeatItemArr[indexPath.row]]) {
        if(kJL_UI_SERIES == 0){ //杰理之家
            cell.bgView.backgroundColor = cSelc;
        }
        if(kJL_UI_SERIES == 1){ //PiLink
            cell.bgView.backgroundColor = cPiLinkSelc;
        }
        cell.textlab.textColor = txC2;
    }else{
        cell.bgView.backgroundColor = cNorc;
        cell.textlab.textColor = txC1;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    if ([ecRepeatArr containsObject:repeatItemArr[indexPath.row]]) {
        [ecRepeatArr removeObject:repeatItemArr[indexPath.row]];
    }else{
        [ecRepeatArr addObject:repeatItemArr[indexPath.row]];
    }
    [self caculateCyc];
    [collectView reloadData];
}

#pragma mark ///计算闹钟循环
-(void)caculateCyc{
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *item in ecRepeatArr) {
        if([item isEqualToString:kJL_TXT("周一")]) [array addObject:@"1"];
        if([item isEqualToString:kJL_TXT("周二")]) [array addObject:@"2"];
        if([item isEqualToString:kJL_TXT("周三")]) [array addObject:@"3"];
        if([item isEqualToString:kJL_TXT("周四")]) [array addObject:@"4"];
        if([item isEqualToString:kJL_TXT("周五")]) [array addObject:@"5"];
        if([item isEqualToString:kJL_TXT("周六")]) [array addObject:@"6"];
        if([item isEqualToString:kJL_TXT("周日")]) [array addObject:@"7"];
    }
    
    uint8_t mode = 0x00;
    if (array.count > 0) {
        for (NSString *num in array) {
            uint8_t tmp = 0x01;
            int n = [num intValue];
            uint8_t tmp_n = tmp<<n;
            mode = mode|tmp_n;
        }
    }else{
        mode = 0x01;
    }
    
    if (self.rtcmodel) {
        if(mode == 1){
            self.rtcmodel.rtcMode = 0x00;
        }else if(mode == 254){
            self.rtcmodel.rtcMode = 0x01;
        }else{
            self.rtcmodel.rtcMode = mode;
        }
    }
}


#pragma mark ///TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return itemArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlarmSetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmSetCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.titleLab.text = itemArray[indexPath.row];
    cell.detailLab.text = nameArray[indexPath.row];
    if (indexPath.row == 0) {
        cell.typeImg.image = [UIImage imageNamed:@"Theme.bundle/clock_icon_name"];
    }
    if (indexPath.row == 1) {
        cell.typeImg.image = [UIImage imageNamed:@"Theme.bundle/clock_icon_bell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            reNameVew.nameTxfd.text = nameArray[indexPath.row];
            [self.view addSubview:reNameVew];
        }break;
        case 1:{
            AlarmRingVC *vc = [[AlarmRingVC alloc] init];
            vc.rtcModel = self.rtcmodel;
            vc.modalPresentationStyle = 0;
            [self presentViewController:vc animated:YES completion:nil];
        }break;
            
        default:
            break;
    }
}


#pragma mark ///ReName Delegate
-(void)didSelectBtnAction:(UIButton *)btn WithText:(NSString *)text{
    [reNameVew removeFromSuperview];
    self.rtcmodel.rtcName = text;
    if (self.rtcmodel.ringInfo) {
        NSString *ringName = [[NSString alloc] initWithData:self.rtcmodel.ringInfo.data encoding:NSUTF8StringEncoding];
        nameArray = @[self.rtcmodel.rtcName,ringName];
    }else{
        nameArray = @[self.rtcmodel.rtcName];
    }
    [tableView reloadData];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [JL_Tools remove:nil Own:self];
}
@end
