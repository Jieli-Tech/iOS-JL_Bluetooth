//
//  DhaStepTipView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/30.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DhaStepTipView.h"
#import "StepTipsView.h"

@interface DhaStepTipView(){
    UIImageView *centerImgv;
    UILabel *readyLab;
    StepTipsView *stepTips1;
    StepTipsView *stepTips2;
    UIButton *iKnowBtn;
}
@end

@implementation DhaStepTipView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self stepUI];
    }
    return self;
}


-(void)stepUI{
   
    centerImgv = [UIImageView new];
    centerImgv.image = [UIImage imageNamed:@"Theme.bundle/illustration_img_01"];
    centerImgv.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:centerImgv];
    
    readyLab = [[UILabel alloc] init];
    readyLab.text = kJL_TXT("Please_prepare_for_the_following_tests");
    readyLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    readyLab.textColor = [UIColor colorFromHexString:@"#000000"];
    readyLab.numberOfLines = 0;
    readyLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:readyLab];
    
    
    stepTips1 = [[StepTipsView alloc] initWithFrame:CGRectZero];
    stepTips1.stepLab.text = @"1";
    stepTips1.detailLab.text = kJL_TXT("Please_wear_your_hearing_aid_Choose_a_quiet_place_to_start.");
    [self addSubview:stepTips1];
    
    stepTips2 = [[StepTipsView alloc] initWithFrame:CGRectZero];
    stepTips2.stepLab.text = @"2";
    stepTips2.detailLab.text = kJL_TXT("hear_or_not_hear");
    [self addSubview:stepTips2];
    
    iKnowBtn = [UIButton new];
    [iKnowBtn setBackgroundColor:[UIColor colorFromHexString:@"#805BEB"]];
    [iKnowBtn setTitle:kJL_TXT("i_know_it.") forState:UIControlStateNormal];
    [iKnowBtn addTarget:self action:@selector(didSelectTouch) forControlEvents:UIControlEventTouchUpInside];
    iKnowBtn.layer.cornerRadius = 24;
    iKnowBtn.layer.masksToBounds = YES;
    iKnowBtn.titleLabel.font = FontMedium(15);
    [iKnowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [iKnowBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self addSubview:iKnowBtn];
    
    [centerImgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(kJL_HeightNavBar-19);
        make.left.equalTo(self.mas_left).offset(62);
        make.right.equalTo(self.mas_right).offset(-62);
        make.bottom.equalTo(readyLab.mas_top).offset(-24);
    }];
    
    [readyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerImgv.mas_bottom).offset(kJL_HeightStatusBar);
        make.centerX.offset(0);
        make.left.equalTo(self.mas_left).offset(60);
        make.right.equalTo(self.mas_right).offset(-60);
        make.bottom.equalTo(stepTips1.mas_top).offset(-(kJL_HeightStatusBar+6));
    }];
    
    [stepTips1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(readyLab.mas_bottom).offset(kJL_HeightStatusBar+6);
        make.centerX.offset(0);
        make.left.equalTo(self.mas_left).offset(28);
        make.right.equalTo(self.mas_right).offset(-28);
        make.height.mas_lessThanOrEqualTo(@(120));
        make.bottom.equalTo(stepTips2.mas_top).offset(-16);
        
    }];
    
    [stepTips2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stepTips1.mas_bottom).offset(16);
        make.centerX.offset(0);
        make.left.equalTo(self.mas_left).offset(28);
        make.right.equalTo(self.mas_right).offset(-28);
        make.height.mas_lessThanOrEqualTo(@(120));
    }];
    
    [iKnowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-kJL_HeightStatusBar-6);
        make.centerX.offset(0);
        make.left.equalTo(self.mas_left).offset(40);
        make.right.equalTo(self.mas_right).offset(-40);
        make.height.offset(48);
    }];
    
}

-(void)didSelectTouch{
    if ([_delegate respondsToSelector:@selector(stepViewToDismiss)]) {
        [_delegate stepViewToDismiss];
    }
}


@end
