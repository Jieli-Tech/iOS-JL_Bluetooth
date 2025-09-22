//
//  HeadSetANC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/27.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "HeadSetANC.h"

@interface HeadSetANC(){
    UILabel *voiceCtlLab;
    UIButton *moreBtn;
    UIView *centerView;
    UIButton *denoiseBtn;
    UIButton *normalBtn;
    UIButton *transparentBtn;
    UILabel *denoiseLab;
    UILabel *normalLab;
    UILabel *transparentLab;
    NSArray *arrayView;
    NSArray *btnArray;
}

@property(nonatomic,strong)NSMutableArray *masonryViewArray;
@end



@implementation HeadSetANC

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self stepUI];
        [self addNote];
    }
    return self;
}


-(void)stepUI{
    
    self.backgroundColor = [UIColor colorFromHexString:@"#FFFFFF"];
    [JLUI_Effect addShadowOnView:self];
    self.layer.masksToBounds = true;
    voiceCtlLab = [UILabel new];
    voiceCtlLab.font = FontMedium(13);
    voiceCtlLab.textColor = [UIColor colorFromHexString:@"#242424"];
    voiceCtlLab.text = kJL_TXT("noise_control");
    [self addSubview:voiceCtlLab];
    
    moreBtn = [UIButton new];
    [moreBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_more_nol"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:moreBtn];
    
    centerView = [UIView new];
    centerView.backgroundColor = [UIColor colorFromHexString:@"#E5E8EA"];
    centerView.layer.cornerRadius = 20;
    centerView.layer.masksToBounds = YES;
    [self addSubview:centerView];
    
    denoiseBtn = [UIButton new];
    [denoiseBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"] forState:UIControlStateNormal];
    [denoiseBtn addTarget:self action:@selector(denoiseBtnAction) forControlEvents:UIControlEventTouchUpInside];
    denoiseBtn.layer.cornerRadius = 18;
    denoiseBtn.layer.masksToBounds = YES;
    [self addSubview:denoiseBtn];
    
    normalBtn = [UIButton new];
    [normalBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_close_nol"] forState:UIControlStateNormal];
    [normalBtn addTarget:self action:@selector(normalBtnAction) forControlEvents:UIControlEventTouchUpInside];
    normalBtn.layer.cornerRadius = 18;
    normalBtn.layer.masksToBounds = YES;
    [self addSubview:normalBtn];
    
    transparentBtn = [UIButton new];
    [transparentBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_mode_nol"] forState:UIControlStateNormal];
    [transparentBtn addTarget:self action:@selector(transparentBtnAction) forControlEvents:UIControlEventTouchUpInside];
    transparentBtn.layer.cornerRadius = 18;
    transparentBtn.layer.masksToBounds = YES;
    [self addSubview:transparentBtn];
    
    denoiseLab = [UILabel new];
    denoiseLab.textAlignment = NSTextAlignmentLeft;
    denoiseLab.textColor = [UIColor colorFromHexString:@"#242424"];
    denoiseLab.text = kJL_TXT("noise_mode_denoise");
    denoiseLab.font = [UIFont systemFontOfSize:13];
    [self addSubview:denoiseLab];
    
    normalLab = [UILabel new];
    normalLab.textAlignment = NSTextAlignmentCenter;
    normalLab.textColor = [UIColor colorFromHexString:@"#242424"];
    normalLab.text = kJL_TXT("noise_mode_close");
    normalLab.font = [UIFont systemFontOfSize:13];
    [self addSubview:normalLab];
    
    transparentLab = [UILabel new];
    transparentLab.textAlignment = NSTextAlignmentRight;
    transparentLab.textColor = [UIColor colorFromHexString:@"#242424"];
    transparentLab.text = kJL_TXT("noise_mode_transparent");
    transparentLab.font = [UIFont systemFontOfSize:13];
    [self addSubview:transparentLab];
    
    [voiceCtlLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(20);
        make.left.equalTo(self.mas_left).offset(18.5);
        make.height.offset(25);
    }];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(17);
        make.right.equalTo(self.mas_right).offset(-23.5);
        make.width.offset(30);
        make.height.offset(30);
    }];
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(moreBtn.mas_bottom).offset(14);
        make.right.equalTo(self.mas_right).offset(-23);
        make.left.equalTo(self.mas_left).offset(23);
        make.height.offset(40);
    }];
    
    btnArray = @[denoiseBtn,normalBtn,transparentBtn];
    arrayView = @[denoiseLab,normalLab,transparentLab];
    
    [btnArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:36 leadSpacing:25 tailSpacing:25];
    [btnArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_top).offset(2);
        make.height.offset(36);
    }];

    
    [arrayView mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:20 tailSpacing:20];
    [arrayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_bottom).offset(10);
        make.height.offset(20);
    }];
    
}




//MARK: - Buttons 响应
-(void)moreBtnAction{
    if ([_delegate respondsToSelector:@selector(headSetDenoiseMore:)]) {
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        JLModel_Device *deviceModel = [entity.mCmdManager getDeviceModel];
        [_delegate headSetDenoiseMore:deviceModel.mAncModeCurrent];
    }
}

-(void)denoiseBtnAction{
    [self setAncAction:JL_AncMode_NoiseReduction];
    [self setBgView:denoiseBtn];
}

-(void)normalBtnAction{
    [self setAncAction:JL_AncMode_Normal];
    [self setBgView:normalBtn];
}

-(void)transparentBtnAction{
    [self setAncAction:JL_AncMode_Transparent];
    [self setBgView:transparentBtn];
}


-(void)setAncAction:(JL_AncMode )type{
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    for (JLModel_ANC *model in deviceModel.mAncModeArray) {
        if(model.mAncMode == type) {
            [entity.mCmdManager.mTwsManager cmdSetANC:model];
        }
    }
}

-(void)setBgView:(UIButton *)btn{
    [btn setImage:[UIImage imageNamed:@"Theme.bundle/icon_denoise_sel"] forState:UIControlStateNormal];
    moreBtn.hidden = NO;
    [btn setBackgroundColor:kColor_0000];
    if ([btn isEqual:normalBtn]) {
        [normalBtn setBackgroundColor:[UIColor grayColor]];
        [denoiseBtn setBackgroundColor:[UIColor clearColor]];
        [denoiseBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"] forState:UIControlStateNormal];
        [transparentBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_mode_nol"] forState:UIControlStateNormal];
        [transparentBtn setBackgroundColor:[UIColor clearColor]];
        moreBtn.hidden = YES;
    }
    
    if ([btn isEqual:denoiseBtn]) {
        [normalBtn setBackgroundColor:[UIColor clearColor]];
        [normalBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_close_nol"] forState:UIControlStateNormal];
        [transparentBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_mode_nol"] forState:UIControlStateNormal];
        [transparentBtn setBackgroundColor:[UIColor clearColor]];
    }
    if ([btn isEqual:transparentBtn]) {
        [normalBtn setBackgroundColor:[UIColor clearColor]];
        [normalBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_close_nol"] forState:UIControlStateNormal];
        [denoiseBtn setBackgroundColor:[UIColor clearColor]];
        [denoiseBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_denoise_nol"] forState:UIControlStateNormal];
        [transparentBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_mode_sel"] forState:UIControlStateNormal];
    }
}

//MARK: - 初始化数据UI
-(void)createData{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    NSMutableArray *newArray = [NSMutableArray new];
    NSMutableArray *array2 = [NSMutableArray new];
    denoiseBtn.hidden = YES;
    denoiseLab.hidden = YES;
    normalBtn.hidden = YES;
    normalLab.hidden = YES;
    transparentBtn.hidden = YES;
    transparentLab.hidden = YES;
    
    for (JLModel_ANC *model in deviceModel.mAncModeArray) {
        if(model.mAncMode ==  JL_AncMode_NoiseReduction) {
            [newArray addObject:denoiseBtn];
            [array2 addObject:denoiseLab];
            denoiseBtn.hidden = NO;
            denoiseLab.hidden = NO;
        }
    }
    if (array2.count>0) {
        for (JLModel_ANC *model in deviceModel.mAncModeArray) {
            if(model.mAncMode ==  JL_AncMode_Normal) {
                [newArray addObject:normalBtn];
                [array2 addObject:normalLab];
                normalBtn.hidden = NO;
                normalLab.hidden = NO;
            }
        }
        for (JLModel_ANC *model in deviceModel.mAncModeArray) {
            if(model.mAncMode ==  JL_AncMode_Transparent) {
                [newArray addObject:transparentBtn];
                [array2 addObject:transparentLab];
                transparentBtn.hidden = NO;
                transparentLab.hidden = NO;
            }
        }
    }else{
        for (JLModel_ANC *model in deviceModel.mAncModeArray) {
            if(model.mAncMode ==  JL_AncMode_Transparent) {
                [newArray addObject:transparentBtn];
                [array2 addObject:transparentLab];
                transparentBtn.hidden = NO;
                transparentLab.hidden = NO;
            }
        }
        for (JLModel_ANC *model in deviceModel.mAncModeArray) {
            if(model.mAncMode ==  JL_AncMode_Normal) {
                [newArray addObject:normalBtn];
                [array2 addObject:normalLab];
                normalBtn.hidden = NO;
                normalLab.hidden = NO;
            }
        }
    }
    

    arrayView = array2;
    btnArray = newArray;
    
  
    [btnArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:36 leadSpacing:25 tailSpacing:25];
    [btnArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_top).offset(2);
        make.height.offset(36);
    }];
    
    [arrayView mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:20 tailSpacing:20];
    [arrayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_bottom).offset(10);
        make.height.offset(20);
    }];
    
    switch (deviceModel.mAncModeCurrent.mAncMode) {
        case JL_AncMode_Normal:
            [self setBgView:normalBtn];
            break;
        case JL_AncMode_Transparent:{
            [self setBgView:transparentBtn];
        }break;
        case JL_AncMode_NoiseReduction:{
            [self setBgView:denoiseBtn];
        }break;
        default:
            break;
    }
    
}


///MARK: - 监听来自设备的通知
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
    switch (deviceModel.mAncModeCurrent.mAncMode) {
        case JL_AncMode_Normal:
            [self setBgView:normalBtn];
            break;
        case JL_AncMode_Transparent:{
            [self setBgView:transparentBtn];
        }break;
        case JL_AncMode_NoiseReduction:{
            [self setBgView:denoiseBtn];
        }break;
        default:
            break;
    }
}

@end
