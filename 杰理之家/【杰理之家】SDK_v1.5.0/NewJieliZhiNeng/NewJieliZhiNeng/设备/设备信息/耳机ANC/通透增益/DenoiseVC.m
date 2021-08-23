//
//  DenoiseVC.m
//  NewJieliZhiNeng
//
//  Created by 李放 on 2021/3/25.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "DenoiseVC.h"
#import "JL_RunSDK.h"
#import "TongTouPick.h"
#import "ReNameView.h"

@interface DenoiseVC ()<TongTouPickDelegate,ReNameViewDelegate>{
    __weak IBOutlet UIView *headView;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UIButton *saveBtn;
    
    float sw;
    float sh;
    
    UILabel *leftLabel;
    UILabel *rightLabel;
    
    UIButton *leftBtn;
    UIButton *rightBtn;
    
    TongTouPick   *pick_0; //左耳通透增益值
    TongTouPick   *pick_1; //右耳通透增益值
    
    ReNameView *leftReNameView;
    ReNameView *rightReNameView;
    NSString *selectLeftTxt;
    NSString *selectRightTxt;
    
    int leftCurrentValue;  //左耳通透增益值
    int rightCurrentValue; //右耳通透增益值
}

@end

@implementation DenoiseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    NSArray *textArray;
    if (deviceModel.mAncModeCurrent.mAncMode == JL_AncMode_NoiseReduction) {
        textArray = @[kJL_TXT("降噪增益值"),kJL_TXT("左耳降噪增益值"),kJL_TXT("右耳降噪增益值")];
    }else if(deviceModel.mAncModeCurrent.mAncMode == JL_AncMode_Transparent){
        textArray = @[kJL_TXT("通透增益值"),kJL_TXT("左耳通透增益值"),kJL_TXT("右耳通透增益值")];
    }
     
    
    sw = [DFUITools screen_2_W];
    sh = [DFUITools screen_2_H];
    
    float sw = [DFUITools screen_2_W];
    headView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    titleName.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(16, kJL_HeightStatusBar-5, 44, 44);
    saveBtn.frame  = CGRectMake(sw-16-44, kJL_HeightStatusBar-5, 44, 44);
    titleName.text = textArray[0];
    titleName.bounds = CGRectMake(0, 0, 200, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+16);
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(sw/2-105/2, kJL_HeightNavBar+49.5, 105, 15)];
    lab.text = textArray[1];
    lab.font = [UIFont fontWithName:@"PingFang SC" size:14];
    lab.textColor = kDF_RGBA(36, 36, 36, 1.0);
    lab.contentMode = NSTextAlignmentCenter;
    [self.view addSubview:lab];
    
    leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(sw/2-80/2, lab.frame.origin.y+lab.frame.size.height+21.5, 80, 22.5)];
    leftLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    leftLabel.textColor = kColor_0000;
    leftLabel.contentMode = NSTextAlignmentCenter;
    [self.view addSubview:leftLabel];
    leftLabel.text = [NSString stringWithFormat:@"%d", self.model_ANC.mAncCurrent_L];
    selectLeftTxt = [NSString stringWithFormat:@"%d", self.model_ANC.mAncCurrent_L];
    
    leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftLabel.frame.origin.x+leftLabel.frame.size.width+25,lab.frame.origin.y+lab.frame.size.height+23,22,22)];
    [leftBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_input_nol"]  forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.tag = 0;
    [self.view addSubview:leftBtn];

    CGRect rect_0 = CGRectMake(0, leftLabel.frame.origin.y+leftLabel.frame.size.height+51, sw, 90);
    
    int leftMax;
    if((self.model_ANC.mAncMax_L%100)<100 && (self.model_ANC.mAncMax_L%100)>0){
        leftMax = (self.model_ANC.mAncMax_L+100)/100;
    }else{
        leftMax = self.model_ANC.mAncMax_L/100;
    }
    pick_0 = [[TongTouPick alloc] initWithFrame:rect_0 StartPoint:0 EndPoint:leftMax];
    pick_0.delegate = self;
    pick_0.type = 0;
    pick_0.maxValue = self.model_ANC.mAncMax_L;
    int currentLeft = self.model_ANC.mAncCurrent_L;
    
    if((currentLeft == self.model_ANC.mAncMax_L) && (currentLeft%100<100)){
        currentLeft = (currentLeft/100)+1;
    }else{
        currentLeft = currentLeft/100;
    }
    [pick_0 setTongTouPoint:currentLeft];
    [self.view addSubview:pick_0];
    
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(sw/2-105/2, pick_0.frame.origin.y+pick_0.frame.size.height+30, 105, 15)];
    lab2.text = textArray[2];
    lab2.font = [UIFont fontWithName:@"PingFang SC" size:14];
    lab2.textColor = kDF_RGBA(36, 36, 36, 1.0);
    lab2.contentMode = NSTextAlignmentCenter;
    [self.view addSubview:lab2];
    
    rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(sw/2-80/2, lab2.frame.origin.y+lab2.frame.size.height+21.5, 80, 22.5)];
    rightLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    rightLabel.textColor = kColor_0000;
    rightLabel.contentMode = NSTextAlignmentCenter;
    [self.view addSubview:rightLabel];
    rightLabel.text = [NSString stringWithFormat:@"%d", self.model_ANC.mAncCurrent_R];
    selectRightTxt = [NSString stringWithFormat:@"%d", self.model_ANC.mAncCurrent_R];
    
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(rightLabel.frame.origin.x+rightLabel.frame.size.width+25,lab2.frame.origin.y+lab2.frame.size.height+23,22,22)];
    [rightBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_input_nol"]  forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.tag = 1;
    [self.view addSubview:rightBtn];
    
    CGRect rect_1 = CGRectMake(0, rightLabel.frame.origin.y+rightLabel.frame.size.height+51, sw, 90);
    int rightMax;
    if((self.model_ANC.mAncMax_R%100)<100 && (self.model_ANC.mAncMax_R%100)>0){
        rightMax = (self.model_ANC.mAncMax_R+100)/100;
    }else{
        rightMax = self.model_ANC.mAncMax_R/100;
    }
    
    pick_1 = [[TongTouPick alloc] initWithFrame:rect_1 StartPoint:0 EndPoint:rightMax];
    pick_1.delegate = self;
    pick_1.type = 1;
    int currentRight = self.model_ANC.mAncCurrent_R;
    pick_1.maxValue = self.model_ANC.mAncMax_R;
    
    if((currentRight == self.model_ANC.mAncMax_R) && (currentRight%100<100)){
        currentRight = (currentRight/100)+1;
    }else{
        currentRight = currentRight/100;
    }
    [pick_1 setTongTouPoint:currentRight];
    [self.view addSubview:pick_1];
    
    if(self.model_ANC.mAncCurrent_L > 0 && self.model_ANC.mAncCurrent_R == 0){
//        lab.hidden = NO;
//        leftLabel.hidden = NO;
//        leftBtn.hidden = NO;
        //pick_0.hidden = NO;
        
//        lab2.hidden = YES;
//        rightLabel.hidden = YES;
//        rightBtn.hidden = YES;
        //pick_1.hidden = YES;
    }else if(self.model_ANC.mAncCurrent_L == 0 && self.model_ANC.mAncCurrent_R > 0){
//        lab.hidden = YES;
//        leftLabel.hidden = YES;
//        leftBtn.hidden = YES;
        //pick_0.hidden = YES;
        
//        lab2.hidden = NO;
//        rightLabel.hidden = NO;
//        rightBtn.hidden = NO;
        //pick_1.hidden = NO;
    }else if(self.model_ANC.mAncCurrent_L > 0 && self.model_ANC.mAncCurrent_R>0){
//        lab.hidden = NO;
//        leftLabel.hidden = NO;
//        leftBtn.hidden = NO;
        //pick_0.hidden = NO;
        
//        lab2.hidden = NO;
//        rightLabel.hidden = NO;
//        rightBtn.hidden = NO;
        //pick_1.hidden = NO;
    }
}

- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveBtn:(UIButton *)sender {
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if (model.mAncModeCurrent.mAncMode == JL_AncMode_NoiseReduction ||
        model.mAncModeCurrent.mAncMode == JL_AncMode_Transparent ) {
        _model_ANC.mAncCurrent_L = leftCurrentValue;
        _model_ANC.mAncCurrent_R = rightCurrentValue;
        [entity.mCmdManager cmdSetANC:_model_ANC];
        [JL_Tools delay:0.1 Task:^{
            [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON Result:^(NSArray * _Nullable array) {
            }];
        }];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark 进入通透增益值界面
-(void)btnAction:(UIButton *)btn{
    switch (btn.tag) {
        case 0: //左耳通透增益值
        {
            leftReNameView = [[ReNameView alloc] initWithFrame:CGRectMake(0, 0, [DFUITools screen_2_W], [DFUITools screen_2_H])];
            leftReNameView.delegate = self;
            leftReNameView.maxLeft = self.model_ANC.mAncMax_L;
            leftReNameView.type = 1;
            leftReNameView.nameTxfd.text = selectLeftTxt;
            [self.view addSubview:leftReNameView];
        }
            break;
        case 1: //右耳通透增益值
        {
            rightReNameView = [[ReNameView alloc] initWithFrame:CGRectMake(0, 0, [DFUITools screen_2_W], [DFUITools screen_2_H])];
            rightReNameView.delegate = self;
            rightReNameView.maxRight = self.model_ANC.mAncMax_R;
            rightReNameView.type = 2;
            rightReNameView.nameTxfd.text = selectRightTxt;
            [self.view addSubview:rightReNameView];
        }
            break;
        default:
            break;
    }
}

-(void)onTongTouPick:(TongTouPick *)view didChangeLeft:(NSInteger)point{

    leftLabel.text = [NSString stringWithFormat:@"%ld",(long)point];
    selectLeftTxt = leftLabel.text;
    leftCurrentValue = [leftLabel.text intValue];
}

-(void)onTongTouPick:(TongTouPick *)view didChangeRight:(NSInteger)point{
    rightLabel.text = [NSString stringWithFormat:@"%ld",(long)point];
    selectRightTxt = rightLabel.text;
    rightCurrentValue = [rightLabel.text intValue];
}

-(void)didSelectLeftAction:(UIButton *)btn WithText:(NSString *)text{
    selectLeftTxt = text;
    [leftReNameView removeFromSuperview];
    leftReNameView = nil;
    
    leftLabel.text = text;
    leftCurrentValue = [text intValue];
    
    int currentValue;
    if((leftCurrentValue%100)<100 && (leftCurrentValue%100)>0){
        currentValue = (leftCurrentValue/100)+1;
    }else{
        currentValue = leftCurrentValue/100;
    }
    [pick_0 setTongTouPoint:currentValue];
}

-(void)didSelectRightAction:(UIButton *)btn WithText:(NSString *)text{
    selectRightTxt = text;
    [rightReNameView removeFromSuperview];
    rightReNameView = nil;
    
    rightLabel.text = text;
    rightCurrentValue = [text intValue];
    
    int currentValue;
    if((rightCurrentValue%100)<100 && (rightCurrentValue%100)>0){
        currentValue = (rightCurrentValue/100)+1;
    }else{
        currentValue = rightCurrentValue/100;
    }
    [pick_1 setTongTouPoint:currentValue];
}

-(void)didSelectBtnAction:(UIButton *)btn WithText:(NSString *)text{
    
}

@end
