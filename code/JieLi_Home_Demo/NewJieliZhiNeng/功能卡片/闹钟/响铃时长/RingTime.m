//
//  RingTime.m
//  JieliJianKang
//
//  Created by 李放 on 2021/4/2.
//

#import "RingTime.h"
#import "JL_RunSDK.h"
#import "RingTimeCell.h"

@interface RingTime()<UITableViewDelegate,UITableViewDataSource>{
    float sw;
    float sh;
    
    NSArray *ringTimeArray;
    NSArray *indexArray;
    
    UIView *bgView;
    UIView *contentView;
    UITableView *mTableView;
    
    UIView *fengeView;
    UIView *fengeView2;
    UIButton *cancelBtn;
    UIButton *sureBtn;
    
    JLModel_AlarmSetting *mRtcSettingModel;
    NSIndexPath *clickIndexPath;
    
    int selectTime;
}
@end

@implementation RingTime

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        sw = frame.size.width;
        sh = frame.size.height;
                
        [self initUI];
    }
    return self;
}

-(void)initUI{
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, sw, sh)];
    //样式
    toolbar.barStyle = UIBarStyleBlackTranslucent;//半透明
    UITapGestureRecognizer *ttohLefttapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnAction:)];
    [toolbar addGestureRecognizer:ttohLefttapGestureRecognizer];
    toolbar.userInteractionEnabled=YES;
    //透明度
    toolbar.alpha = 0.45f;
    [self addSubview:toolbar];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(16, sh/2-515/2, sw-32, 515)];
    [self addSubview:contentView];
    contentView.backgroundColor = kDF_RGBA(255.0, 255.0, 255.0, 1.0);
    contentView.layer.cornerRadius = 16;
    contentView.layer.masksToBounds = YES;
    
    UILabel *label = [[UILabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"]){
        label.frame = CGRectMake(contentView.frame.size.width/2-72/2,20,72,25);
    }else{
        label.frame = CGRectMake(contentView.frame.size.width/2-72/2,20,150,25);
    }
    label.numberOfLines = 0;
    [contentView addSubview:label];
    label.contentMode = NSTextAlignmentCenter;
    label.font =  [UIFont fontWithName:@"PingFang SC" size: 18];
    label.text =  kJL_TXT("alarm_bell_time");
    label.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    ringTimeArray = @[@"1分钟",@"5分钟",@"10分钟",@"15分钟",@"20分钟",@"25分钟",@"30分钟"];
    indexArray = @[@1,@5,@10,@15,@20,@25,@30];
    
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, contentView.frame.size.width, 420)];
    mTableView.rowHeight = 60.0;
    mTableView.delegate = self;
    mTableView.dataSource =self;
    mTableView.scrollEnabled = NO;
    mTableView.backgroundColor = [UIColor clearColor];
    mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [mTableView registerClass:[RingTimeCell class] forCellReuseIdentifier:@"Cell"];
    [contentView addSubview:mTableView];
    
    fengeView = [[UIView alloc] initWithFrame:CGRectMake(0, 45+419, sw, 1)];
    [contentView addSubview:fengeView];
    fengeView.backgroundColor = kDF_RGBA(247.0, 247.0, 247.0, 1.0);
    
    cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,contentView.frame.size.height-50,contentView.frame.size.width/2,50)];
    [cancelBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:kJL_TXT("jl_cancel") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:kDF_RGBA(84,140, 255, 1.0) forState:UIControlStateNormal];
    [contentView addSubview:cancelBtn];
    
    fengeView2 = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2,contentView.frame.size.height-50, 1, 50)];
    [contentView addSubview:fengeView2];
    fengeView2.backgroundColor = kDF_RGBA(247.0, 247.0, 247.0, 1.0);
    
    sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(fengeView2.frame.origin.x,contentView.frame.size.height-50,contentView.frame.size.width/2,50)];
    [sureBtn addTarget:self action:@selector(sureBtn:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:kJL_TXT("confirm") forState:UIControlStateNormal];
    [sureBtn setTitleColor:kDF_RGBA(84,140, 255, 1.0) forState:UIControlStateNormal];
    [contentView addSubview:sureBtn];
}

-(void)cancelBtn:(UIButton *)btn{
    self.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(onRingTimeCancel)]) {
        [_delegate onRingTimeCancel];
    }
}

-(void)sureBtn:(UIButton *)btn{
    self.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(onRingTimeSure:WithIndex:)]) {
        [_delegate onRingTimeSure:selectTime WithIndex:mRtcSettingModel.index];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ringTimeArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RingTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[RingTimeCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.subIndex = indexPath.row;
    cell.cellLabel.text = ringTimeArray[indexPath.row];
    
    if(selectTime == [indexArray[indexPath.row] intValue]){
        [cell.cellBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_choose2_sel"] forState:UIControlStateNormal];
    }else{
        [cell.cellBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_choose2_nol"] forState:UIControlStateNormal];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    selectTime = [indexArray[indexPath.row] intValue];

    [tableView reloadData];
}

-(void)onRingTimeCellSelectIndex:(NSInteger)index{
    
}

- (void)cancelBtnAction:(UIButton *)sender {
    self.hidden = YES;
}

-(void)setRtcSettingModel:(JLModel_AlarmSetting *)rtcSettingModel{
    mRtcSettingModel = rtcSettingModel;
    
    selectTime = mRtcSettingModel.time;
    kJLLog(JLLOG_DEBUG,@"RingTime:%d",selectTime);
    [mTableView reloadData];
}

@end
