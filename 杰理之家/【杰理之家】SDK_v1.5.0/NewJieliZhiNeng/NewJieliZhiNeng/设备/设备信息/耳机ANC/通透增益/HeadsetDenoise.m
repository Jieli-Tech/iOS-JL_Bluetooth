//
//  HeadsetDenoise.m
//  NewJieliZhiNeng
//
//  Created by 李放 on 2021/3/25.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "HeadsetDenoise.h"
#import "JL_RunSDK.h"

@interface HeadsetDenoise()<UIGestureRecognizerDelegate,UIGestureRecognizerDelegate>{
    float sw;
    float sh;
    
    UIButton *btn; //更多按钮
    UIView   *modeView; //切换模式的View
    UISlider *modeSlider;
    
    UIView      *view_0;
    UIView      *view_1;
    UIView      *view_2;
    UIImageView *imv_0;
    UIImageView *imv_1;
    UIImageView *imv_2;
    
    UILabel  *label_1;
    UILabel  *label_2;
    UILabel  *label_3;
    
    NSMutableArray *tempArray;
    
    JLModel_Device *deviceModel;
    int mode1LeftCurrent;
    int mode1LeftMax;
    int mode1RightCurrent;
    int mode1RightMax;
    
    int mode2LeftCurrent;
    int mode2LeftMax;
    int mode2RightCurrent;
    int mode2RightMax;
}

@end


@implementation HeadsetDenoise


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        [self addNote];
    }
    return self;
}

-(void)initUI{
    self.backgroundColor = [UIColor whiteColor];
    
    sw = [DFUITools screen_2_W];
    sh = [DFUITools screen_2_H];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(18.5, 24.5, 65, 15)];
    lab.text = kJL_TXT("噪声控制");
    lab.font = [UIFont boldSystemFontOfSize:15];
    lab.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [self addSubview:lab];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(sw-46-22,21.5,35,35)];
    [btn setImage:[UIImage imageNamed:@"Theme.bundle/icon_more_nol"]  forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    modeView = [[UIView alloc] init];
    modeView.frame = CGRectMake(23,58,sw-46-23,40);
    modeView.backgroundColor =  kDF_RGBA(229.0, 232.0, 234.0, 1.0);;
    modeView.layer.cornerRadius = 20;
    modeView.layer.masksToBounds = YES;
    [self addSubview:modeView];
    
    view_0 = [[UIView alloc] init];
    view_0.frame = CGRectMake(2,2,36,36);
    view_0.backgroundColor =  kColor_0000;
    view_0.layer.cornerRadius = view_0.frame.size.width/2;
    view_0.layer.masksToBounds = YES;
    [modeView addSubview:view_0];
    
    imv_0 = [[UIImageView alloc]initWithFrame:CGRectMake(2+view_0.frame.size.width/2-22/2,2+view_0.frame.size.height/2-18/2,22,18)];
    imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"];
    imv_0.contentMode = UIViewContentModeScaleAspectFit;
    [modeView addSubview:imv_0];
    
    view_1 = [[UIView alloc] init];
    view_1.frame = CGRectMake(modeView.frame.size.width/2-16,2,36,36);
    view_1.backgroundColor =  kColor_0000;
    view_1.layer.cornerRadius = view_1.frame.size.width/2;
    view_1.layer.masksToBounds = YES;
    [modeView addSubview:view_1];
    
    imv_1 = [[UIImageView alloc]initWithFrame:CGRectMake(modeView.frame.size.width/2-16+view_1.frame.size.width/2-22/2,2+view_1.frame.size.height/2-18/2,22,18)];
    imv_1.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
    imv_1.contentMode = UIViewContentModeScaleAspectFit;
    [modeView addSubview:imv_1];
    
    view_2 = [[UIImageView alloc]initWithFrame:CGRectMake(modeView.frame.size.width-38,2,36,36)];
    view_2.backgroundColor = kColor_0000;
    view_2.layer.cornerRadius = view_2.frame.size.width/2;
    view_2.layer.masksToBounds = YES;
    [modeView addSubview:view_2];
    
    imv_2 = [[UIImageView alloc]initWithFrame:CGRectMake(modeView.frame.size.width-38+view_2.frame.size.width/2-22/2,2+view_2.frame.size.height/2-18/2,22,18)];
    imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_nol"];
    imv_2.contentMode = UIViewContentModeScaleAspectFit;
    [modeView addSubview:imv_2];
    
    label_1 = [[UILabel alloc] init];
    label_1.frame = CGRectMake(31,modeView.frame.origin.y+10+40,50,13.7);
    [self addSubview:label_1];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("降噪") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13.0],NSForegroundColorAttributeName: kDF_RGBA(36, 36, 36, 1)}];
    label_1.attributedText = str1;
    
    label_2 = [[UILabel alloc] init];
    label_2.frame = CGRectMake(modeView.frame.size.width/2,modeView.frame.origin.y+10+40,50,13.7);
    [self addSubview:label_2];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("关闭") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13.0],NSForegroundColorAttributeName: kDF_RGBA(36, 36, 36, 1)}];
    label_2.attributedText = str2;
    label_2.textAlignment = NSTextAlignmentCenter;
    
    label_3 = [[UILabel alloc] init];
    label_3.frame = CGRectMake(modeView.frame.size.width-80,modeView.frame.origin.y+10+40,100,13.7);
    [self addSubview:label_3];
    NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("通透模式") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13.0],NSForegroundColorAttributeName: kDF_RGBA(36, 36, 36, 1)}];
    label_3.attributedText = str3;
    label_3.textAlignment = NSTextAlignmentRight;
    
    modeSlider = [UISlider new];
    modeSlider.frame = CGRectMake(0,2,modeView.frame.size.width, 40);
    modeSlider.maximumValue = 2;
    modeSlider.minimumValue = 0;
    modeSlider.thumbTintColor = [UIColor clearColor];
    modeSlider.maximumTrackTintColor = [UIColor clearColor];//kDF_RGBA(198, 211, 218, 1);
    modeSlider.minimumTrackTintColor = [UIColor clearColor];//kDF_RGBA(105, 194, 234, 1);
    [modeSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpInside];
    [modeView addSubview:modeSlider];
    modeSlider.value = 0;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    gesture.delegate = self;
    [modeSlider addGestureRecognizer:gesture];
}

-(void)setCurrentMode:(int)currentMode{
    int rv = 0.5;
    
    if(tempArray.count == 3 &&[tempArray containsObject:@(JL_AncMode_Normal)] && [tempArray containsObject:@(JL_AncMode_NoiseReduction)]
       && [tempArray containsObject:@(JL_AncMode_Transparent)]){ //三种模式都存在
        if(currentMode == JL_AncMode_NoiseReduction){ //降噪
            rv = 0;
            
            view_0.hidden = NO;
            imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_sel"];
            view_1.hidden = YES;
            imv_1.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
            view_2.hidden = YES;
            imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_nol"];
        }else if(currentMode == JL_AncMode_Normal){ //关闭
            rv = 1;
            
            view_0.hidden = YES;
            imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"];
            view_1.hidden = NO;
            view_1.backgroundColor = [UIColor grayColor];
            imv_1.image = [UIImage imageNamed:@"Theme.bundle/icon_close_sel"];
            view_2.hidden = YES;
            imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_nol"];
        }else if(currentMode == JL_AncMode_Transparent){ //通透模式
            rv = 2;
            
            view_0.hidden = YES;
            imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"];
            view_1.hidden = YES;
            imv_1.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
            view_2.hidden = NO;
            imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_sel"];
        }
    }
    
    if(tempArray.count ==2){
        if([tempArray containsObject:@(JL_AncMode_Normal)] && [tempArray containsObject:@(JL_AncMode_NoiseReduction)]){ //降噪、关闭模式
            if(currentMode == JL_AncMode_NoiseReduction){ //降噪
                rv = 0;
                
                view_0.hidden = NO;
                view_2.hidden = YES;
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_sel"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
            }else if(currentMode == JL_AncMode_Normal){ //关闭
                rv = 1;
                
                view_0.hidden = YES;
                view_2.hidden = NO;
                view_2.backgroundColor = [UIColor grayColor];
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_sel"];
            }
        }
        if([tempArray containsObject:@(JL_AncMode_NoiseReduction)] && [tempArray containsObject:@(JL_AncMode_Transparent)]){ //降噪、通透模式
            if(currentMode == JL_AncMode_NoiseReduction){ //降噪
                rv = 0;
                
                view_0.hidden = NO;
                view_2.hidden = YES;
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_sel"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_nol"];
            }else if(currentMode == JL_AncMode_Transparent){ //通透
                rv = 1;
                
                view_0.hidden = YES;
                view_2.hidden = NO;
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_sel"];
            }
        }
        if([tempArray containsObject:@(JL_AncMode_Normal)] && [tempArray containsObject:@(JL_AncMode_Transparent)]){ //通透、关闭模式
            if(currentMode == JL_AncMode_Transparent){ //通透
                rv = 0;
                
                view_0.hidden = NO;
                view_2.hidden = YES;
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_sel"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
            }else if(currentMode == JL_AncMode_Normal){ //关闭
                rv = 1;
                
                view_0.hidden = YES;
                view_2.hidden = NO;
                view_2.backgroundColor = [UIColor grayColor];
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_nol"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_sel"];
            }
        }
    }
    modeSlider.value = rv;
    
    if(currentMode == JL_AncMode_Normal){
        btn.hidden = YES;
    }else{
        btn.hidden = NO;
    }
}

-(void)setHeadsetDict:(NSDictionary *)headsetDict{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    self->deviceModel = [entity.mCmdManager outputDeviceModel];
    
    if(self->tempArray == nil){
        self->tempArray = [NSMutableArray new];
    }
    if(self->tempArray.count>0){
        [self->tempArray removeAllObjects];
    }
    for (JLModel_ANC *modelANC in self->deviceModel.mAncModeArray) {
        int mMode = modelANC.mAncMode;
        
        if(mMode == 1){ //降噪模式
            self->mode1LeftCurrent = modelANC.mAncCurrent_L;
            self->mode1LeftMax = modelANC.mAncMax_L;
            self->mode1RightCurrent = modelANC.mAncCurrent_R;
            self->mode1RightMax = modelANC.mAncMax_R;
        }
        if(mMode ==2){ //通透模式
            self->mode2LeftCurrent = modelANC.mAncCurrent_L;
            self->mode2LeftMax = modelANC.mAncMax_L;
            self->mode2RightCurrent = modelANC.mAncCurrent_R;
            self->mode2RightMax = modelANC.mAncMax_R;
        }
        [self->tempArray addObject:@(mMode)];
    }
    
    if(self->tempArray.count == 3 && [self->tempArray containsObject:@(JL_AncMode_Normal)] && [tempArray containsObject:@(JL_AncMode_NoiseReduction)]
       && [self->tempArray containsObject:@(JL_AncMode_Transparent)]){ //三种模式都存在
        self->view_0.hidden = NO;
        self->view_1.hidden = NO;
        self->view_2.hidden = NO;
        
        self->imv_0.hidden = NO;
        self->imv_1.hidden = NO;
        self->imv_2.hidden = NO;
        
        self->label_1.hidden = NO;
        self->label_2.hidden = NO;
        self->label_3.hidden = NO;
        
        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("降噪") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13.0],NSForegroundColorAttributeName: kDF_RGBA(36, 36, 36, 1)}];
        self->label_1.attributedText = str1;
        
        NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("关闭") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13.0],NSForegroundColorAttributeName: kDF_RGBA(36, 36, 36, 1)}];
        self->label_2.attributedText = str2;
        
        NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("通透模式") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13.0],NSForegroundColorAttributeName: kDF_RGBA(36, 36, 36, 1)}];
        self->label_3.attributedText = str3;
        
        self->imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_sel"];
        self->imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
        
        self->modeSlider.maximumValue = 2;
        self->modeSlider.minimumValue = 0;
    }
    if(self->tempArray.count == 2){
        if([self->tempArray containsObject:@(JL_AncMode_Normal)] && [self->tempArray containsObject:@(JL_AncMode_NoiseReduction)]){ //降噪、关闭模式
            self->view_0.hidden = NO;
            self->view_1.hidden = YES;
            self->view_2.hidden = YES;
            
            self->imv_0.hidden = NO;
            self->imv_1.hidden = YES;
            self->imv_2.hidden = NO;
            
            self->label_1.hidden = NO;
            self->label_2.hidden = YES;
            self->label_3.hidden = NO;
            
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("降噪") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13.0],NSForegroundColorAttributeName: kDF_RGBA(36, 36, 36, 1)}];
            self->label_1.attributedText = str1;
            
            NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("关闭") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13.0],NSForegroundColorAttributeName: kDF_RGBA(36, 36, 36, 1)}];
            self->label_3.attributedText = str3;
            
            self->imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_sel"];
            self->imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
            
            self->modeSlider.maximumValue = 1;
            self->modeSlider.minimumValue = 0;
        }
        if([self->tempArray containsObject:@(JL_AncMode_NoiseReduction)] && [self->tempArray containsObject:@(JL_AncMode_Transparent)]){ //降噪、通透模式
            self->view_0.hidden = NO;
            self->view_1.hidden = YES;
            self->view_2.hidden = YES;
            
            self->imv_0.hidden = NO;
            self->imv_1.hidden = YES;
            self->imv_2.hidden = NO;
            
            self->label_1.hidden = NO;
            self->label_2.hidden = YES;
            self->label_3.hidden = NO;
            
            self->imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_sel"];
            self->imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_nol"];
            
            self->modeSlider.maximumValue = 1;
            self->modeSlider.minimumValue = 0;
        }
        if([self->tempArray containsObject:@(JL_AncMode_Normal)] && [self->tempArray containsObject:@(JL_AncMode_Transparent)]){ //关闭、通透模式
            self->view_0.hidden = NO;
            self->view_1.hidden = YES;
            self->view_2.hidden = YES;
            
            self->imv_0.hidden = NO;
            self->imv_1.hidden = YES;
            self->imv_2.hidden = NO;
            
            self->label_1.hidden = NO;
            self->label_2.hidden = YES;
            self->label_3.hidden = NO;
            
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("通透") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13.0],NSForegroundColorAttributeName: kDF_RGBA(36, 36, 36, 1)}];
            self->label_1.attributedText = str1;
            
            NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("关闭") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13.0],NSForegroundColorAttributeName: kDF_RGBA(36, 36, 36, 1)}];
            self->label_3.attributedText = str3;
            
            self->imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_sel"];
            self->imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
            
            self->modeSlider.maximumValue = 1;
            self->modeSlider.minimumValue = 0;
        }
    }
}

#pragma mark 进入通透增益值界面
-(void)btnAction:(UIButton *)btn{
    [JL_Tools delay:0.25 Task:^{
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        self->deviceModel = [entity.mCmdManager outputDeviceModel];
        
        if ([self->_delegate respondsToSelector:@selector(HeadsetDenoiseMore:)]) {
            [self->_delegate HeadsetDenoiseMore:self->deviceModel];
        }
    }];
}

#pragma mark 切换模式
-(void)sliderAction:(UISlider*)slider{
    int value = (int)slider.value;
    [self setValueForSlider:value];
    [slider setUserInteractionEnabled:NO];
}

-(int)setValueForSlider:(int)value{
    int rv = 0.5;
    
    if(tempArray.count == 3 &&[tempArray containsObject:@(JL_AncMode_Normal)] && [tempArray containsObject:@(JL_AncMode_NoiseReduction)]
       && [tempArray containsObject:@(JL_AncMode_Transparent)]){ //三种模式都存在
        if(value < 0.5){ //降噪
            rv = 0;
            
            deviceModel.mAncModeCurrent.mAncMode =  JL_AncMode_NoiseReduction;
            deviceModel.mAncModeCurrent.mAncMax_L = mode1LeftMax;
            deviceModel.mAncModeCurrent.mAncCurrent_L = mode1LeftCurrent;
            deviceModel.mAncModeCurrent.mAncMax_R = mode1RightMax;
            deviceModel.mAncModeCurrent.mAncCurrent_R = mode1RightCurrent;
            
            view_0.hidden = NO;
            imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_sel"];
            view_1.hidden = YES;
            imv_1.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
            view_2.hidden = YES;
            imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_nol"];
        }else if(value>= 0.5 && value <= 1.5){ //关闭
            rv = 1;
            
            deviceModel.mAncModeCurrent.mAncMode =  JL_AncMode_Normal;
            
            view_0.hidden = YES;
            imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"];
            view_1.hidden = NO;
            view_1.backgroundColor = [UIColor grayColor];
            imv_1.image = [UIImage imageNamed:@"Theme.bundle/icon_close_sel"];
            view_2.hidden = YES;
            imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_nol"];
        }else if(value > 1.5){ //通透模式
            rv = 2;
            
            deviceModel.mAncModeCurrent.mAncMode =  JL_AncMode_Transparent;
            deviceModel.mAncModeCurrent.mAncCurrent_L = mode2LeftCurrent;
            deviceModel.mAncModeCurrent.mAncMax_L = mode2LeftMax;
            deviceModel.mAncModeCurrent.mAncCurrent_R = mode2RightCurrent;
            deviceModel.mAncModeCurrent.mAncMax_R = mode2RightMax;

            view_0.hidden = YES;
            imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"];
            view_1.hidden = YES;
            imv_1.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
            view_2.hidden = NO;
            imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_sel"];
        }
    }
    
    if(tempArray.count ==2){
        if([tempArray containsObject:@(JL_AncMode_Normal)] && [tempArray containsObject:@(JL_AncMode_NoiseReduction)]){ //降噪、关闭模式
            if(value==0){ //降噪
                rv = 0;
                deviceModel.mAncModeCurrent.mAncMode =  JL_AncMode_NoiseReduction;
                deviceModel.mAncModeCurrent.mAncMax_L = mode1LeftMax;
                deviceModel.mAncModeCurrent.mAncCurrent_L = mode1LeftCurrent;
                deviceModel.mAncModeCurrent.mAncMax_R = mode1RightMax;
                deviceModel.mAncModeCurrent.mAncCurrent_R = mode1RightCurrent;
                
                view_0.hidden = NO;
                view_2.hidden = YES;
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_sel"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
            }else if(value>0){ //关闭
                rv = 1;
                deviceModel.mAncModeCurrent.mAncMode =  JL_AncMode_Normal;
                
                view_0.hidden = YES;
                view_2.hidden = NO;
                view_2.backgroundColor = [UIColor grayColor];
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_sel"];
            }
        }
        if([tempArray containsObject:@(JL_AncMode_NoiseReduction)] && [tempArray containsObject:@(JL_AncMode_Transparent)]){ //降噪、通透模式
            if(value==0){ //降噪
                rv = 0;
                deviceModel.mAncModeCurrent.mAncMode =  JL_AncMode_NoiseReduction;
                deviceModel.mAncModeCurrent.mAncMax_L = mode1LeftMax;
                deviceModel.mAncModeCurrent.mAncCurrent_L = mode1LeftCurrent;
                deviceModel.mAncModeCurrent.mAncMax_R = mode1RightMax;
                deviceModel.mAncModeCurrent.mAncCurrent_R = mode1RightCurrent;
                
                view_0.hidden = NO;
                view_2.hidden = YES;
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_sel"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_nol"];
            }else if(value>0){ //通透
                rv = 1;
                deviceModel.mAncModeCurrent.mAncMode =  JL_AncMode_Transparent;
                deviceModel.mAncModeCurrent.mAncCurrent_L = mode2LeftCurrent;
                deviceModel.mAncModeCurrent.mAncMax_L = mode2LeftMax;
                deviceModel.mAncModeCurrent.mAncCurrent_R = mode2RightCurrent;
                deviceModel.mAncModeCurrent.mAncMax_R = mode2RightMax;
                
                view_0.hidden = YES;
                view_2.hidden = NO;
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_sel"];
            }
        }
        if([tempArray containsObject:@(JL_AncMode_Normal)] && [tempArray containsObject:@(JL_AncMode_Transparent)]){ //通透、关闭模式
            if(value==0){ //通透
                rv = 0;
                
                deviceModel.mAncModeCurrent.mAncMode =  JL_AncMode_Transparent;
                deviceModel.mAncModeCurrent.mAncCurrent_L = mode2LeftCurrent;
                deviceModel.mAncModeCurrent.mAncMax_L = mode2LeftMax;
                deviceModel.mAncModeCurrent.mAncCurrent_R = mode2RightCurrent;
                deviceModel.mAncModeCurrent.mAncMax_R = mode2RightMax;
                
                view_0.hidden = NO;
                view_2.hidden = YES;
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_sel"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_nol"];
            }else if(value>0){ //关闭
                rv = 1;
                
                deviceModel.mAncModeCurrent.mAncMode =  JL_AncMode_Normal;
                
                view_0.hidden = YES;
                view_2.hidden = NO;
                view_2.backgroundColor = [UIColor grayColor];
                imv_0.image = [UIImage imageNamed:@"Theme.bundle/icon_mode_nol"];
                imv_2.image = [UIImage imageNamed:@"Theme.bundle/icon_close_sel"];
            }
        }
    }
    modeSlider.value = rv;
    
    if(deviceModel.mAncModeCurrent.mAncMode == JL_AncMode_Normal){
        btn.hidden = YES;
    }else{
        btn.hidden = NO;
    }
    
    //发送数据给固件
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdSetANC:deviceModel.mAncModeCurrent];
    
    return rv;
}

-(void)actionTapGesture:(UITapGestureRecognizer *)sender{
    CGPoint touchPoint = [sender locationInView:modeSlider];
    CGFloat value = (modeSlider.maximumValue - modeSlider.minimumValue) * (touchPoint.x / modeSlider.frame.size.width );
    CGFloat v1 = value;
    
    if(tempArray.count ==3 && [tempArray containsObject:@(JL_AncMode_Normal)] && [tempArray containsObject:@(JL_AncMode_NoiseReduction)] //三种模式都存在
       && [tempArray containsObject:@(JL_AncMode_Transparent)]){
        if(value>= 0.5 && value <= 1.5){
            v1 = 1;
        }else if(value < 0.5){
            v1 = 0;
        }else if(value > 1.5){
            v1 = 2;
        }
    }
    if(tempArray.count ==2){
        if(([tempArray containsObject:@(JL_AncMode_Normal)] && [tempArray containsObject:@(JL_AncMode_NoiseReduction)])
           || ([tempArray containsObject:@(JL_AncMode_Normal)] && [tempArray containsObject:@(JL_AncMode_Transparent)])){ //降噪、关闭模式|通透、关闭模式
            if(value<0.5){
                v1 = 0;
            }else if(value >= 0.5){
                v1 = 1;
            }
        }
        if([tempArray containsObject:@(JL_AncMode_NoiseReduction)] && [tempArray containsObject:@(JL_AncMode_Transparent)]){ //降噪、通透模式
            if(value<0.5){
                v1 = 0;
            }else if(value >= 0.5){
                v1 = 1;
            }
        }
    }
    [modeSlider setValue:v1 animated:NO];
    [self sliderAction:modeSlider];
}
///MARK:监听来自设备的通知
-(void)addNote{
    [JLModel_Device observeModelProperty:@"mAncModeCurrent"
                                  Action:@selector(noteCurrentAncModel:)
                                    Own:self];
}

-(void)noteCurrentAncModel:(NSNotification *)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    self.currentMode = deviceModel.mAncModeCurrent.mAncMode;
    [modeSlider setUserInteractionEnabled:YES];
}


@end
