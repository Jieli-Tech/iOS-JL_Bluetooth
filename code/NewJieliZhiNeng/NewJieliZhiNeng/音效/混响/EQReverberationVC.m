//
//  EQReverberationVC.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/9/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "EQReverberationVC.h"
#import "JL_RunSDK.h"
#import "IACircularSlider.h"

@interface EQReverberationVC (){
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    
    IACircularSlider *depthSlider;
    IACircularSlider *intensitySlider;
    IACircularSlider *dynamicLimiterSlider;
    
    UIImageView *depthCircleImv;
    UIImageView *intensityImv;
    UIImageView *dynamicLimiterImv;
    
    UILabel *depthLabel;
    UILabel *intensityLabel;
    UILabel *dynamicLimiterLabel;
    
    UIImageView *depthLow;
    UIImageView *intensityLow;
    UIImageView *dynamicLimiterLow;
    
    UIImageView *depthHigh;
    UIImageView *inensityHigh;
    UIImageView *dynamicLimiterHigh;
    
    UILabel *depthLabelStr;
    UILabel *intensityLabelStr;
    
    UILabel *label; //混响
    UILabel *label_2; //动态限幅器
    
    //JL_BLEUsage *JL_ug;
    __weak IBOutlet UISwitch *switch_1; //混响的开关
    
    JL_RunSDK   *bleSDK;
    NSString    *bleUUID;
}

@end

@implementation EQReverberationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bleSDK = [JL_RunSDK sharedMe];
    bleUUID= bleSDK.mBleUUID;
    
    [self initUI];
    [self addNote];
}

-(void)initUI{
    float sW = [UIScreen mainScreen].bounds.size.width;
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    subTitleView.frame = CGRectMake(0, 0, sW, kJL_HeightStatusBar+44);
    subTitleView.backgroundColor = [UIColor whiteColor];
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("eq_advanced_setting");
    titleName.bounds = CGRectMake(0, 0, 200, 20);
    titleName.center = CGPointMake(sW/2.0, kJL_HeightStatusBar+20);
    [self handleContentUI];
}

#define kCircle_Gap  20
#define kCircle_h    kJL_HeightNavBar+20
-(void)handleContentUI{
    float sW =  [UIScreen mainScreen].bounds.size.width;
    //float sH =  [UIScreen mainScreen].bounds.size.height;
    
    float all_w = sW-kCircle_Gap*2.0;
    float max_w = all_w/2;
    float min_w = max_w*0.75;
    
    label = [[UILabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"]){
        label.frame = CGRectMake(20.5,kJL_HeightNavBar+20,58,14);
    }else{
        label.frame = CGRectMake(20.5,kJL_HeightNavBar+20,100,14);
    }
    label.numberOfLines = 0;
    [self.view addSubview:label];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("eq_advanced_reverberation") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    
    label.attributedText = string;
    
    CGPoint start = CGPointMake(200, 100);
    CGPoint end = CGPointMake(0, 100);
    
    // 深度
    depthSlider = [[IACircularSlider alloc] initWithFrame:CGRectMake(31, 31.0+kCircle_h, min_w, min_w)];
    [self.view  addSubview:depthSlider];
    
    depthSlider.trackHighlightedTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    depthSlider.thumbTintColor = [UIColor whiteColor];
    depthSlider.trackTintColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
    depthSlider.thumbHighlightedTintColor = [UIColor whiteColor];
    depthSlider.trackWidth = 7;
    depthSlider.thumbWidth = 25;
    depthSlider.minimumValue = 0;
    depthSlider.maximumValue = 100;
    depthSlider.startAngle = 0.7*M_PI;
    depthSlider.endAngle = 0.3*M_PI;
    depthSlider.clockwise = YES;
    depthSlider.type = 1;
    [depthSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_nol"]];
    [depthSlider setThumbWidth:60];
    
    [depthSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
    [depthSlider addTarget:self action:@selector(handleDepthValue:) forControlEvents:UIControlEventValueChanged];
    
    depthCircleImv = [[UIImageView alloc] initWithFrame:CGRectMake(37, 37.0+kCircle_h, min_w-6*2.0, min_w-6*2.0)];
    depthCircleImv.image = [UIImage imageNamed:@"Theme.bundle/eq_bg_circle"];
    depthCircleImv.contentMode = UIViewContentModeScaleAspectFill;
    [self.view  addSubview:depthCircleImv];
    
    depthLabel = [[UILabel alloc] init];
    [depthLabel setFrame:CGRectMake(depthCircleImv.frame.size.width/2-50/2, depthCircleImv.frame.size.height/2-50/2, 50, 50)];
    [depthLabel setTextAlignment:NSTextAlignmentCenter];
    [depthLabel setBackgroundColor:[UIColor clearColor]];
    [depthLabel  setTextColor:[UIColor blackColor]];
    [depthLabel setFont:[UIFont systemFontOfSize:16.f]];
    [depthCircleImv addSubview:depthLabel];
    
    depthLow = [[UIImageView alloc] initWithFrame:CGRectMake(53.0, min_w+31.0+kCircle_h, 10.0, 10.0)];
    depthLow.image = [UIImage imageNamed:@"Theme.bundle/mul_reduce"];
    depthLow.contentMode = UIViewContentModeCenter;
    [self.view  addSubview:depthLow];
    
    depthHigh = [[UIImageView alloc] initWithFrame:CGRectMake(depthLow.frame.origin.x+depthCircleImv.frame.size.width-46.0, min_w+31.0+kCircle_h, 10.0, 10.0)];
    depthHigh.image = [UIImage imageNamed:@"Theme.bundle/mul_plus"];
    depthHigh.contentMode = UIViewContentModeCenter;
    [self.view  addSubview:depthHigh];
    
    depthLabelStr = [[UILabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"]){
        depthLabelStr.frame = CGRectMake(depthCircleImv.frame.size.width/2+20.0, min_w+56.0+kCircle_h,39,13.5);
    }else{
        depthLabelStr.frame = CGRectMake(depthCircleImv.frame.size.width/2+20.0, min_w+56.0+kCircle_h,39,15);
    }
    depthLabelStr.numberOfLines = 0;
    [self.view  addSubview:depthLabelStr];
    
    NSMutableAttributedString *depthLabelString = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("eq_advanced_depth") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    
    depthLabelStr.attributedText = depthLabelString;
    
    // 强度
    intensitySlider = [[IACircularSlider alloc] initWithFrame:CGRectMake(sW-min_w-31.0, 31.0+kCircle_h, min_w, min_w)];
    [self.view  addSubview:intensitySlider];
    
    intensitySlider.trackHighlightedTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    intensitySlider.thumbTintColor = [UIColor whiteColor];
    intensitySlider.trackTintColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
    intensitySlider.thumbHighlightedTintColor = [UIColor whiteColor];
    intensitySlider.trackWidth = 7;
    intensitySlider.thumbWidth = 25;
    intensitySlider.minimumValue = 0;
    intensitySlider.maximumValue = 100;
    intensitySlider.startAngle = 0.7*M_PI;
    intensitySlider.endAngle = 0.3*M_PI;
    intensitySlider.clockwise = YES;
    intensitySlider.type = 1;
    [intensitySlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_nol"]];
    [intensitySlider setThumbWidth:60];
    
    [intensitySlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
    [intensitySlider addTarget:self action:@selector(handleIntensityValue:) forControlEvents:UIControlEventValueChanged];
    
    intensityImv = [[UIImageView alloc] initWithFrame:CGRectMake(sW-min_w-31.0+6.0, 37.0+kCircle_h, min_w-6*2.0, min_w-6*2.0)];
    intensityImv.image = [UIImage imageNamed:@"Theme.bundle/eq_bg_circle"];
    intensityImv.contentMode = UIViewContentModeScaleAspectFill;
    [self.view  addSubview:intensityImv];
    
    intensityLabel = [[UILabel alloc] init];
    [intensityLabel setFrame:CGRectMake(intensityImv.frame.size.width/2-50/2, intensityImv.frame.size.height/2-50/2, 50, 50)];
    [intensityLabel setTextAlignment:NSTextAlignmentCenter];
    [intensityLabel setBackgroundColor:[UIColor clearColor]];
    [intensityLabel  setTextColor:[UIColor blackColor]];
    [intensityLabel setFont:[UIFont systemFontOfSize:16.f]];
    [intensityImv addSubview:intensityLabel];
    
    intensityLow = [[UIImageView alloc] initWithFrame:CGRectMake(sW-min_w+15.0-22.0, min_w+31.0+kCircle_h, 10.0, 10.0)];
    intensityLow.image = [UIImage imageNamed:@"Theme.bundle/mul_reduce"];
    intensityLow.contentMode = UIViewContentModeCenter;
    [self.view  addSubview:intensityLow];
    
    inensityHigh = [[UIImageView alloc] initWithFrame:CGRectMake(intensityLow.frame.origin.x+intensityImv.frame.size.width-46.0, min_w+31.0+kCircle_h, 10.0, 10.0)];
    inensityHigh.image = [UIImage imageNamed:@"Theme.bundle/mul_plus"];
    inensityHigh.contentMode = UIViewContentModeCenter;
    [self.view  addSubview:inensityHigh];
    
    intensityLabelStr = [[UILabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"] || [kJL_GET hasPrefix:@"ja"]){
        intensityLabelStr.frame = CGRectMake(intensityLow.frame.origin.x+intensityImv.frame.size.width/2-28.0, min_w+56.0+kCircle_h,39,13.5);
    }else{
        intensityLabelStr.frame = CGRectMake(intensityLow.frame.origin.x+intensityImv.frame.size.width/2-43.0, min_w+56.0+kCircle_h,55,15);
    }
    intensityLabelStr.numberOfLines = 0;
    [self.view  addSubview:intensityLabelStr];
    
    NSMutableAttributedString *intensityLabelString = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("eq_advanced_strength") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    
    intensityLabelStr.attributedText = intensityLabelString;
    
    //动态限幅器
    label_2 = [[UILabel alloc] init];
    label_2.frame = CGRectMake(20.5,depthCircleImv.frame.origin.y+depthCircleImv.frame.size.height+103.5,154,14.5);
    label_2.numberOfLines = 0;
    [self.view  addSubview:label_2];
    
    NSMutableAttributedString *string_2 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("eq_advanced_dynamic") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    
    label_2.attributedText = string_2;
    
    dynamicLimiterSlider = [[IACircularSlider alloc] initWithFrame:CGRectMake(31, 31.0+label_2.frame.origin.y+label_2.frame.size.height, min_w, min_w)];
    [self.view  addSubview:dynamicLimiterSlider];
    
    dynamicLimiterSlider.trackHighlightedTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    dynamicLimiterSlider.thumbTintColor = [UIColor whiteColor];
    dynamicLimiterSlider.trackTintColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
    dynamicLimiterSlider.thumbHighlightedTintColor = [UIColor whiteColor];
    dynamicLimiterSlider.trackWidth = 7;
    dynamicLimiterSlider.thumbWidth = 25;
    dynamicLimiterSlider.minimumValue = -60;
    dynamicLimiterSlider.maximumValue = 0;
    dynamicLimiterSlider.startAngle = 0.7*M_PI;
    dynamicLimiterSlider.endAngle = 0.3*M_PI;
    dynamicLimiterSlider.clockwise = YES;
    dynamicLimiterSlider.type = 1;
    [dynamicLimiterSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_nol"]];
    [dynamicLimiterSlider setThumbWidth:60];
    
    [dynamicLimiterSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
    [dynamicLimiterSlider addTarget:self action:@selector(handleDynamicLimiterValue:) forControlEvents:UIControlEventValueChanged];
    
    dynamicLimiterImv = [[UIImageView alloc] initWithFrame:CGRectMake(37, 37.0+label_2.frame.origin.y+label_2.frame.size.height, min_w-6*2.0, min_w-6*2.0)];
    dynamicLimiterImv.image = [UIImage imageNamed:@"Theme.bundle/eq_bg_circle"];
    dynamicLimiterImv.contentMode = UIViewContentModeScaleAspectFill;
    [self.view  addSubview:dynamicLimiterImv];
    
    dynamicLimiterLabel = [[UILabel alloc] init];
    [dynamicLimiterLabel setFrame:CGRectMake(dynamicLimiterImv.frame.size.width/2-50/2, dynamicLimiterImv.frame.size.height/2-50/2, 50, 50)];
    [dynamicLimiterLabel setTextAlignment:NSTextAlignmentCenter];
    [dynamicLimiterLabel setBackgroundColor:[UIColor clearColor]];
    [dynamicLimiterLabel  setTextColor:[UIColor blackColor]];
    [dynamicLimiterLabel setFont:[UIFont systemFontOfSize:16.f]];
    [dynamicLimiterImv addSubview:dynamicLimiterLabel];
    
    dynamicLimiterLow = [[UIImageView alloc] initWithFrame:CGRectMake(53.0, min_w+31.0+label_2.frame.origin.y+label_2.frame.size.height, 10.0, 10.0)];
    dynamicLimiterLow.image = [UIImage imageNamed:@"Theme.bundle/mul_reduce"];
    dynamicLimiterLow.contentMode = UIViewContentModeCenter;
    [self.view  addSubview:dynamicLimiterLow];
    
    dynamicLimiterHigh = [[UIImageView alloc] initWithFrame:CGRectMake(dynamicLimiterLow.frame.origin.x+dynamicLimiterImv.frame.size.width-46.0, min_w+31.0+label_2.frame.origin.y+label_2.frame.size.height, 10.0, 10.0)];
    dynamicLimiterHigh.image = [UIImage imageNamed:@"Theme.bundle/mul_plus"];
    dynamicLimiterHigh.contentMode = UIViewContentModeCenter;
    [self.view  addSubview:dynamicLimiterHigh];
    
    //混响的开关
    switch_1.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-12-41-20.5, kJL_HeightNavBar+13, 41, 21);
    [switch_1 setOnTintColor:kColor_0000];
    [self.view  addSubview:switch_1];
    
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    
    if(model.reverberationTypes.count ==0){ //混响、振幅器都不支持
        
        [DFUITools showText:kJL_TXT("eq_advanced_unspport_reverberation") onView:self.view delay:2.0];
        
        depthSlider.userInteractionEnabled = NO;
        intensitySlider.userInteractionEnabled = NO;
        dynamicLimiterSlider.userInteractionEnabled = NO;
        switch_1.userInteractionEnabled = NO;
        
        switch_1.on =0;
        
        depthSlider.value = 0.f;
        intensitySlider.value = 0.f;
        dynamicLimiterSlider.value =-60.f;
        
        depthLabel.text = [NSString stringWithFormat:@"%.00f",depthSlider.value];
        intensityLabel.text = [NSString stringWithFormat:@"%.00f",intensitySlider.value];
        dynamicLimiterLabel.text = [NSString stringWithFormat:@"%.00f",dynamicLimiterSlider.value];
        
        [depthSlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
        [intensitySlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
        [dynamicLimiterSlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
        [depthLabel  setTextColor: [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
        [intensityLabel  setTextColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
        [dynamicLimiterLabel setTextColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
        [depthSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
        [intensitySlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
        [dynamicLimiterSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
        return;
    }
    [self updateReverberation];
}

- (IBAction)backExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark 设置深度
-(void)handleDepthValue:(IACircularSlider*)slider{
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    
    if(model.reverberationTypes.count ==0){ //混响、振幅器都不支持
        if(bleSDK.mBleEntityM){
            slider.userInteractionEnabled = NO;
            switch_1.on = 0;
            [DFUITools showText:kJL_TXT("eq_advanced_unspport") onView:self.view delay:1.0];
        }
    }else{
        if(switch_1.on){
            slider.userInteractionEnabled = YES;
        }else{
            slider.userInteractionEnabled = NO;
        }
    }
    depthLabel.text = [NSString stringWithFormat:@"%.00f", slider.value];
}

#pragma mark 设置强度
-(void)handleIntensityValue:(IACircularSlider*)slider{
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    
    if(model.reverberationTypes.count ==0){ //混响、振幅器都不支持
        if(bleSDK.mBleEntityM){
            slider.userInteractionEnabled = NO;
            switch_1.on = 0;
            [DFUITools showText:kJL_TXT("eq_advanced_unspport") onView:self.view delay:1.0];
        }
    }else{
        if(switch_1.on){
            slider.userInteractionEnabled = YES;
        }else{
            slider.userInteractionEnabled = NO;
        }
    }
    intensityLabel.text = [NSString stringWithFormat:@"%.00f", slider.value];
}

#pragma mark 设置动态限幅器
-(void)handleDynamicLimiterValue:(IACircularSlider*)slider{
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    
    if(model.reverberationTypes.count ==0){ //混响、振幅器都不支持
        if(bleSDK.mBleEntityM){
            slider.userInteractionEnabled = NO;
            [DFUITools showText:kJL_TXT("eq_advanced_unspport_dynamic") onView:self.view delay:1.0];
        }
    }
    if((model.reverberationTypes.count==2  && [model.reverberationTypes containsObject:@(0)]) //支持混响和限幅器
       || (model.reverberationTypes.count==1  && [model.reverberationTypes containsObject:@(1)])){ //只支持限幅器
       slider.userInteractionEnabled = YES;
    }
    if(model.reverberationTypes.count==1  && [model.reverberationTypes containsObject:@(0)]) {//只支持混响
        slider.userInteractionEnabled = NO;
    }
    dynamicLimiterLabel.text = [NSString stringWithFormat:@"%.00f", slider.value];
}

#pragma mark 发送命令给固件
-(void)sendMessage{
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    int type = -1; //0:支持混响和限幅器 1：只支持混响 2：只支持限幅器
    if(model.reverberationTypes.count==2  && [model.reverberationTypes containsObject:@(JL_ReverberationAndDynamicType)] //支持混响和限幅器
       && [model.reverberationTypes containsObject:@(1)]){
        type = 0;
    }
    if(model.reverberationTypes.count==1  && [model.reverberationTypes containsObject:@(JL_OnlyReverberationType)]) {//只支持混响
        type = 1;
    }
    if(model.reverberationTypes.count==1  && [model.reverberationTypes containsObject:@(JL_OnlyDynamicLimiterType)]) {//只支持限幅器
        type = 2;
    }
    
    [bleSDK.mBleEntityM.mCmdManager.mChargingBinManager cmdSetReverberation:[depthLabel.text intValue]
                                         IntensityValue:[intensityLabel.text intValue]
                                    DynamicLimiterValue:[dynamicLimiterLabel.text intValue]
                                       SwtichReverState:switch_1.on FunType:type];
}

#pragma 手势抬起事件
-(void)endTouch{
    [self sendMessage];
}



-(void)noteSystemInfo:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    [self updateReverberation];
}

#pragma mark 从固件读取更新混响和动态限幅器
-(void)updateReverberation{
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    
    CGPoint start = CGPointMake(200, 100);
    CGPoint end = CGPointMake(0, 100);
    
    if(model.reverberationTypes.count==2  && [model.reverberationTypes containsObject:@(0)] //支持混响和限幅器
       && [model.reverberationTypes containsObject:@(1)]){
        switch_1.on =model.reverberationSwitchState;
        
        depthSlider.userInteractionEnabled = YES;
        intensitySlider.userInteractionEnabled = YES;
        switch_1.userInteractionEnabled = YES;
        dynamicLimiterSlider.userInteractionEnabled = YES;
        
        if(!switch_1.on){
            depthSlider.userInteractionEnabled = NO;
            intensitySlider.userInteractionEnabled = NO;
        }else{
            depthSlider.userInteractionEnabled = YES;
            intensitySlider.userInteractionEnabled = YES;
        }
        
        if(switch_1.on){
            [depthSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [intensitySlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [depthLabel  setTextColor:[UIColor blackColor]];
            [intensityLabel  setTextColor:[UIColor blackColor]];
            [depthSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_nol"]];
            [intensitySlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_nol"]];
        }else{
            [depthSlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [intensitySlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [depthLabel  setTextColor: [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
            [intensityLabel  setTextColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
            [depthSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
            [intensitySlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
        }
    }
    if(model.reverberationTypes.count==1  && [model.reverberationTypes containsObject:@(0)]) {//只支持混响
        switch_1.on =model.reverberationSwitchState;
        
        depthSlider.userInteractionEnabled = YES;
        intensitySlider.userInteractionEnabled = YES;
        switch_1.userInteractionEnabled = YES;
        dynamicLimiterSlider.userInteractionEnabled = NO;
        
        [dynamicLimiterSlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
        [dynamicLimiterLabel  setTextColor: [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
        [dynamicLimiterSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
        
        if(!switch_1.on){
            depthSlider.userInteractionEnabled = NO;
            intensitySlider.userInteractionEnabled = NO;
        }else{
            depthSlider.userInteractionEnabled = YES;
            intensitySlider.userInteractionEnabled = YES;
        }
        
        if(switch_1.on){
            [depthSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [intensitySlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [depthLabel  setTextColor:[UIColor blackColor]];
            [intensityLabel  setTextColor:[UIColor blackColor]];
            [depthSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_nol"]];
            [intensitySlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_nol"]];
        }else{
            [depthSlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [intensitySlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [depthLabel  setTextColor: [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
            [intensityLabel  setTextColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
            [depthSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
            [intensitySlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
        }
    }
    if(model.reverberationTypes.count==1  && [model.reverberationTypes containsObject:@(1)]) {//只支持限幅器
        depthSlider.userInteractionEnabled = NO;
        intensitySlider.userInteractionEnabled = NO;
        switch_1.userInteractionEnabled = NO;
        dynamicLimiterSlider.userInteractionEnabled = YES;
        
        [depthSlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
        [intensitySlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
        [depthLabel  setTextColor: [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
        [intensityLabel  setTextColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
        [depthSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
        [intensitySlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
        [dynamicLimiterSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
        
        [dynamicLimiterLabel  setTextColor:[UIColor blackColor]];
        [dynamicLimiterSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_nol"]];
    }
    
    //获取混响深度的值
    depthSlider.value = (CGFloat)model.depthValue;
    depthLabel.text = [NSString stringWithFormat:@"%.00f",depthSlider.value];
    //获取混响强度的值
    intensitySlider.value = (CGFloat)model.intensityValue;
    intensityLabel.text = [NSString stringWithFormat:@"%.00f",intensitySlider.value];
    //获取动态限幅器的值
    dynamicLimiterSlider.value = (CGFloat)model.dynamicLimiterValue;
    dynamicLimiterLabel.text = [NSString stringWithFormat:@"%.00f",dynamicLimiterSlider.value];
}


#pragma mark 混响的开关
- (IBAction)switch_1:(UISwitch *)sender {
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    
    if(bleSDK.mBleEntityM){
        if(model.reverberationTypes.count ==0){ //混响、振幅器都不支持
            switch_1.userInteractionEnabled = NO;
            switch_1.on = 0;
            [DFUITools showText:kJL_TXT("eq_advanced_unspport") onView:self.view delay:1.0];
        }
    }
    
    if((model.reverberationTypes.count == 2 && [model.reverberationTypes containsObject:@(0)]) ||
       (model.reverberationTypes.count == 1 && [model.reverberationTypes containsObject:@(0)]) ){
        switch_1.userInteractionEnabled = YES;
        switch_1.on = sender.on;
        
        if(!switch_1.on){
            depthSlider.userInteractionEnabled = NO;
            intensitySlider.userInteractionEnabled = NO;
        }else{
            depthSlider.userInteractionEnabled = YES;
            intensitySlider.userInteractionEnabled = YES;
        }
        
        CGPoint start = CGPointMake(200, 100);
        CGPoint end = CGPointMake(0, 100);
        
        if(switch_1.on){
            [depthSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [intensitySlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [depthLabel  setTextColor:[UIColor blackColor]];
            [intensityLabel  setTextColor:[UIColor blackColor]];
            [depthSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_nol"]];
            [intensitySlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_nol"]];
        }else{
            [depthSlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [intensitySlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0] colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
            [depthLabel  setTextColor: [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
            [intensityLabel  setTextColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
            [depthSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
            [intensitySlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_03_dis"]];
        }
        
        [self sendMessage];
    }
}

-(void)noteDeviceChange:(NSNotification*)note{
    
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (tp == JLDeviceChangeTypeBleOFF) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_REVERBERATION_END_TOUCH Action:@selector(endTouch) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kJL_MANAGER_SYSTEM_INFO Action:@selector(noteSystemInfo:) Own:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [JL_Tools remove:nil Own:self];
}

@end
