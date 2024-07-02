//
//  RingAgainIntervalView.m
//  JieliJianKang
//
//  Created by 李放 on 2021/4/2.
//

#import "RingAgainIntervalView.h"
#import "JL_RunSDK.h"

@interface RingAgainIntervalView()<UIGestureRecognizerDelegate>{
    float sw;
    float sh;
    
    UIView *bgView;
    UIView *contentView;
    
    UISlider *slider1;
    UISlider *slider2;
    
    UILabel *labelFunOne;
    UILabel *labelFunTwo;
    
    UILabel *label0;
    
    //响铃间隔时间
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    UILabel *label4;
    UILabel *label5;
    UILabel *label6;
    
    //重复响铃次数
    UILabel *label7;
    UILabel *label8;
    UILabel *label9;
    UILabel *label10;
    
    UIView *fengeView;
    UIView *fengeView2;
    
    UIButton *cancelBtn;
    UIButton *sureBtn;
    
    JLModel_AlarmSetting *mAlarmSetting;
    
    int firstRV;
    int secondRV;
}

@end
@implementation RingAgainIntervalView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        sw = frame.size.width;
        sh = frame.size.height;
                
        firstRV = 0.5;
        secondRV = 0.5;
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
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(16, sh/2-365/2, sw-32, 365)];
    [self addSubview:contentView];
    contentView.backgroundColor = kDF_RGBA(255.0, 255.0, 255.0, 1.0);
    contentView.layer.cornerRadius = 16;
    contentView.layer.masksToBounds = YES;
    
    label0 = [[UILabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"]){
        label0.frame = CGRectMake(contentView.frame.size.width/2-72/2,20,72,25);
    }else{
        label0.frame = CGRectMake(contentView.frame.size.width/2-150/2,20,150,25);
    }
    label0.numberOfLines = 0;
    [contentView addSubview:label0];
    label0.contentMode = NSTextAlignmentCenter;
    label0.font =  [UIFont fontWithName:@"PingFang SC" size: 18];
    label0.text =  kJL_TXT("alarm_bell_interval");
    label0.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    labelFunOne = [[UILabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"]){
        labelFunOne.frame = CGRectMake(20,label0.frame.origin.y+label0.frame.size.height+30,160,21);
    }else{
        labelFunOne.frame = CGRectMake(20,label0.frame.origin.y+label0.frame.size.height+30,200,21);
    }
    labelFunOne.numberOfLines = 0;
    [contentView addSubview:labelFunOne];
    labelFunOne.contentMode = NSTextAlignmentCenter;
    labelFunOne.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    labelFunOne.text =  [NSString stringWithFormat:@"%@ %@",kJL_TXT("bell_interal_time_title"),kJL_TXT("min3_format")];
    labelFunOne.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    slider1 = [UISlider new];
    slider1.frame = CGRectMake(20,labelFunOne.frame.origin.y+labelFunOne.frame.size.height+12,contentView.frame.size.width-20*2, 15);
    slider1.maximumValue = 30;
    slider1.minimumValue = 5;
    slider1.maximumTrackTintColor = kDF_RGBA(216, 216, 216, 1);
    slider1.minimumTrackTintColor = kDF_RGBA(128, 91, 235, 1);
    [slider1 setThumbImage:[UIImage imageNamed:@"Theme.bundle/slider_nol"] forState:UIControlStateNormal];
    [slider1 addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:slider1];
    slider1.tag = 0;
    
    label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(23,slider1.frame.origin.y+slider1.frame.size.height+13,20,17);
    label1.numberOfLines = 0;
    [contentView addSubview:label1];
    label1.contentMode = NSTextAlignmentLeft;
    label1.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label1.text =  @"5";
    label1.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(label1.frame.origin.x+label1.frame.size.width+45,slider1.frame.origin.y+slider1.frame.size.height+13,20,17);
    label2.numberOfLines = 0;
    [contentView addSubview:label2];
    label2.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label2.text =  @"10";
    label2.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(label2.frame.origin.x+label2.frame.size.width+45,slider1.frame.origin.y+slider1.frame.size.height+13,20,17);
    label3.numberOfLines = 0;
    [contentView addSubview:label3];
    label3.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label3.text =  @"15";
    label3.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    label4 = [[UILabel alloc] init];
    label4.frame = CGRectMake(label3.frame.origin.x+label3.frame.size.width+45,slider1.frame.origin.y+slider1.frame.size.height+13,20,17);
    label4.numberOfLines = 0;
    [contentView addSubview:label4];
    label4.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label4.text =  @"20";
    label4.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    label5 = [[UILabel alloc] init];
    label5.frame = CGRectMake(label4.frame.origin.x+label4.frame.size.width+45,slider1.frame.origin.y+slider1.frame.size.height+13,20,17);
    label5.numberOfLines = 0;
    [contentView addSubview:label5];
    label5.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label5.text =  @"25";
    label5.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    label6 = [[UILabel alloc] init];
    label6.frame = CGRectMake(contentView.frame.size.width-20-15,slider1.frame.origin.y+slider1.frame.size.height+13,20,17);
    label6.numberOfLines = 0;
    [contentView addSubview:label6];
    label6.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label6.text =  @"30";
    label6.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    labelFunTwo = [[UILabel alloc] init];
    labelFunTwo.frame = CGRectMake(20,label1.frame.origin.y+label1.frame.size.height+24,96,21);
    labelFunTwo.numberOfLines = 0;
    [contentView addSubview:labelFunTwo];
    labelFunTwo.contentMode = NSTextAlignmentCenter;
    labelFunTwo.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    labelFunTwo.text =  kJL_TXT("bell_repeat_count_title");
    labelFunTwo.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    slider2 = [UISlider new];
    slider2.frame = CGRectMake(20,labelFunTwo.frame.origin.y+labelFunTwo.frame.size.height+12,contentView.frame.size.width-20*2, 15);
    slider2.maximumValue = 10;
    slider2.minimumValue = 1;
    slider2.maximumTrackTintColor = kDF_RGBA(216, 216, 216, 1);
    slider2.minimumTrackTintColor = kDF_RGBA(128, 91, 235, 1);
    [slider2 setThumbImage:[UIImage imageNamed:@"Theme.bundle/slider_nol"] forState:UIControlStateNormal];
    [slider2 addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:slider2];
    slider2.tag = 1;
    
    label7 = [[UILabel alloc] init];
    label7.frame = CGRectMake(24,slider2.frame.origin.y+slider2.frame.size.height+15,20,17);
    label7.numberOfLines = 0;
    [contentView addSubview:label7];
    label7.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label7.text =  @"1";
    label7.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    label8 = [[UILabel alloc] init];
    label8.frame = CGRectMake(label7.frame.origin.x+label7.frame.size.width+89.5,slider2.frame.origin.y+slider2.frame.size.height+15,20,17);
    label8.numberOfLines = 0;
    [contentView addSubview:label8];
    label8.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label8.text =  @"3";
    label8.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    label9 = [[UILabel alloc] init];
    label9.frame = CGRectMake(label8.frame.origin.x+label8.frame.size.width+89,slider2.frame.origin.y+slider2.frame.size.height+15,20,17);
    label9.numberOfLines = 0;
    [contentView addSubview:label9];
    label9.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label9.text =  @"5";
    label9.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    label10 = [[UILabel alloc] init];
    label10.frame = CGRectMake(contentView.frame.size.width-20-13,slider2.frame.origin.y+slider2.frame.size.height+15,20,17);
    label10.numberOfLines = 0;
    [contentView addSubview:label10];
    label10.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label10.text =  @"10";
    label10.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    fengeView = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.frame.size.height-50, sw, 1)];
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

-(void)sliderAction:(UISlider *)slider{
    switch (slider.tag) {
        case 0:
        {
            int currentValue = (int)slider.value;
            [self setValueFirstSlider:currentValue];
        }
            break;
        case 1:
        {
            int currentValue = (int)slider.value;
            [self setValueSecondSlider:currentValue];
        }
            break;
        default:
            break;
    }
}

-(int)setValueFirstSlider:(int)value{
    if(value >= 5 && value < 10){
        firstRV = 5;
    }else if(value >= 10 && value < 15){
        firstRV = 10;
    }else if(value >= 15 && value < 20){
        firstRV = 15;
    }else if(value >= 20 && value < 25){
        firstRV = 20;
    }else if(value >= 25 && value < 30){
        firstRV = 25;
    }else if(value==30){
        firstRV = 30;
    }
    slider1.value = firstRV;
    return firstRV;
}

-(int)setValueSecondSlider:(int)value{
    int mValue = 0.5;
    if(value==1){
        secondRV = 1;
        mValue = 1;
    }
    if(value>1 && value<=5){
        secondRV = 3;
        mValue = 4;
    }
    if(value>5 && value<10){
        secondRV = 5;
        mValue = 7;
    }
    if(value == 10){
        secondRV = 10;
        mValue = 10;
    }
    slider2.value = mValue;
    return secondRV;
}

-(void)cancelBtn:(UIButton *)btn{
    self.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(onRingAgainIntervalCancel)]) {
        [_delegate onRingAgainIntervalCancel];
    }
}

-(void)sureBtn:(UIButton *)btn{
    self.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(onRingAgainIntervalSure:WithCount:WithIndex:)]) {
        [_delegate onRingAgainIntervalSure:firstRV WithCount:secondRV WithIndex:mAlarmSetting.index];
    }
}

- (void)cancelBtnAction:(UIButton *)sender {
    self.hidden = YES;
}

-(void)setRtcSettingModel:(JLModel_AlarmSetting *)rtcSettingModel{
    mAlarmSetting = rtcSettingModel;

    if(mAlarmSetting.count == 3){
        slider2.value  = 4;
    }else if(mAlarmSetting.count == 5){
        slider2.value  = 7;
    }else{
        slider2.value = mAlarmSetting.count;
    }
    
    firstRV = mAlarmSetting.interval;
    secondRV = mAlarmSetting.count;
    
    slider1.value = mAlarmSetting.interval;
    
    if(mAlarmSetting.isInterval ==0 && mAlarmSetting.isCount ==1){
        slider1.hidden = YES;
        slider2.hidden = NO;
        
        labelFunOne.hidden = YES;
        labelFunTwo.hidden = NO;

        label1.hidden = YES;
        label2.hidden = YES;
        label3.hidden = YES;
        label4.hidden = YES;
        label5.hidden = YES;
        label6.hidden = YES;
        
        label7.hidden = NO;
        label8.hidden = NO;
        label9.hidden = NO;
        label10.hidden = NO;
        
        if([kJL_GET hasPrefix:@"zh"]){
            labelFunTwo.frame = CGRectMake(20,label0.frame.origin.y+label0.frame.size.height+30,160,21);
        }else{
            labelFunTwo.frame = CGRectMake(20,label0.frame.origin.y+label0.frame.size.height+30,200,21);
        }
    }else{
        if([kJL_GET hasPrefix:@"zh"]){
            labelFunTwo.frame = CGRectMake(20,label1.frame.origin.y+label1.frame.size.height+24,96,21);
        }else{
            labelFunTwo.frame = CGRectMake(20,label1.frame.origin.y+label1.frame.size.height+24,200,21);
        }
        
        if(mAlarmSetting.isInterval ==1 && mAlarmSetting.isCount ==1){
            slider1.hidden = NO;
            slider2.hidden = NO;
            
            labelFunOne.hidden = NO;
            labelFunTwo.hidden = NO;

            label1.hidden = NO;
            label2.hidden = NO;
            label3.hidden = NO;
            label4.hidden = NO;
            label5.hidden = NO;
            label6.hidden = NO;
            
            label7.hidden = NO;
            label8.hidden = NO;
            label9.hidden = NO;
            label10.hidden = NO;
        }
        if(mAlarmSetting.isInterval ==1 && mAlarmSetting.isCount ==0){
            slider1.hidden = NO;
            slider2.hidden = YES;
            
            labelFunOne.hidden = NO;
            labelFunTwo.hidden = YES;

            label1.hidden = NO;
            label2.hidden = NO;
            label3.hidden = NO;
            label4.hidden = NO;
            label5.hidden = NO;
            label6.hidden = NO;
            
            label7.hidden = YES;
            label8.hidden = YES;
            label9.hidden = YES;
            label10.hidden = YES;
        }
    }
}

@end
