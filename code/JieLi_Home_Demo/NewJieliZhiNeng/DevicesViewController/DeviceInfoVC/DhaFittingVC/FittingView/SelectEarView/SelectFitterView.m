//
//  SelectFitterView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/6.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "SelectFitterView.h"

@interface SelectFitterView(){
    UIImageView *centerImgv;
    UILabel *tipsLab;
    UIButton *doubleBtn;;
    UIButton *leftBtn;
    UIButton *rightBtn;
}
@end

@implementation SelectFitterView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        centerImgv = [UIImageView new];
        centerImgv.image = [UIImage imageNamed:@"Theme.bundle/illustration_img_02"];
        centerImgv.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:centerImgv];
        
        tipsLab = [UILabel new];
        tipsLab.font = FontMedium(15);
        tipsLab.textColor = [UIColor colorFromHexString:@"#000000"];
        tipsLab.text = kJL_TXT("请选择需要验配的助听器");
        tipsLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:tipsLab];
        
        doubleBtn = [UIButton new];
        [doubleBtn setTitle:kJL_TXT("双耳") forState:UIControlStateNormal];
        [doubleBtn setTitleColor:[UIColor colorFromHexString:@"#805BEB"] forState:UIControlStateNormal];
        doubleBtn.titleLabel.font = FontMedium(15);
        [doubleBtn addTarget:self action:@selector(doubleBtnAction) forControlEvents:UIControlEventTouchUpInside];
        doubleBtn.layer.cornerRadius = 24;
        doubleBtn.layer.masksToBounds = YES;
        [doubleBtn setBackgroundColor:[UIColor colorFromHexString:@"#F6F7F9"]];
        [self addSubview:doubleBtn];
        
        leftBtn = [UIButton new];
        [leftBtn setTitle:kJL_TXT("左耳") forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor colorFromHexString:@"#000000"] forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor colorFromHexString:@"#805BEB"] forState:UIControlStateHighlighted];
        leftBtn.titleLabel.font = FontMedium(15);
        [leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
        leftBtn.layer.cornerRadius = 24;
        leftBtn.layer.masksToBounds = YES;
        [leftBtn setBackgroundColor:[UIColor colorFromHexString:@"#F6F7F9"]];
        [self addSubview:leftBtn];
        
        rightBtn = [UIButton new];
        [rightBtn setTitle:kJL_TXT("右耳") forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorFromHexString:@"#000000"] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorFromHexString:@"#805BEB"] forState:UIControlStateHighlighted];
        rightBtn.titleLabel.font = FontMedium(15);
        [rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.layer.cornerRadius = 24;
        rightBtn.layer.masksToBounds = YES;
        [rightBtn setBackgroundColor:[UIColor colorFromHexString:@"#F6F7F9"]];
        [self addSubview:rightBtn];
        
        [centerImgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(kJL_HeightNavBar-19);
            make.left.equalTo(self.mas_left).offset(62);
            make.right.equalTo(self.mas_right).offset(-62);
            make.bottom.equalTo(tipsLab.mas_top).offset(-24);
        }];
        
        [tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(centerImgv.mas_bottom).offset(kJL_HeightStatusBar);
            make.centerX.offset(0);
            make.left.equalTo(self.mas_left).offset(60);
            make.right.equalTo(self.mas_right).offset(-60);
            make.bottom.equalTo(doubleBtn.mas_top).offset(-40);
        }];
        
        [doubleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tipsLab.mas_bottom).offset(40);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.bottom.equalTo(leftBtn.mas_top).offset(-28);
            make.height.offset(48);
        }];
        
        [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(doubleBtn.mas_bottom).offset(28);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.bottom.equalTo(rightBtn.mas_top).offset(-28);
            make.height.offset(48);
        }];
        
        [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(leftBtn.mas_bottom).offset(28);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.height.offset(48);
        }];
        
    }
    return self;
}


-(void)setDhaType:(NSString *)fittingType{
    
    if ([fittingType isEqualToString:DoubleFitter]) {
        doubleBtn.hidden = NO;
        leftBtn.hidden = NO;
        rightBtn.hidden = NO;
        [doubleBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tipsLab.mas_bottom).offset(40);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.bottom.equalTo(leftBtn.mas_top).offset(-28);
            make.height.offset(48);
        }];
        
        [leftBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(doubleBtn.mas_bottom).offset(28);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.bottom.equalTo(rightBtn.mas_top).offset(-28);
            make.height.offset(48);
        }];
        
        [rightBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(leftBtn.mas_bottom).offset(28);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.height.offset(48);
        }];
    }
    
    if ([fittingType isEqualToString: LeftFitter]) {
        doubleBtn.hidden = YES;
        leftBtn.hidden = NO;
        rightBtn.hidden = YES;
        [doubleBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tipsLab.mas_bottom).offset(40);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.bottom.equalTo(leftBtn.mas_top).offset(-28);
            make.height.offset(0);
        }];
        
        [leftBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(doubleBtn.mas_bottom).offset(0);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.bottom.equalTo(rightBtn.mas_top).offset(-28);
            make.height.offset(48);
        }];
        
    }
    if ([fittingType isEqualToString: RightFitter]) {
        doubleBtn.hidden = YES;
        leftBtn.hidden = YES;
        rightBtn.hidden = NO;
        [doubleBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tipsLab.mas_bottom).offset(40);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.bottom.equalTo(leftBtn.mas_top).offset(0);
            make.height.offset(0);
        }];
        
        [leftBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(doubleBtn.mas_bottom).offset(0);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.bottom.equalTo(rightBtn.mas_top).offset(0);
            make.height.offset(0);
        }];
        [rightBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(leftBtn.mas_bottom).offset(0);
            make.left.equalTo(self.mas_left).offset(26);
            make.right.equalTo(self.mas_right).offset(-26);
            make.height.offset(48);
        }];
    }
    
}

-(void)doubleBtnAction{
    if ([_delegate respondsToSelector:@selector(fitterDidSelect:)]) {
        [_delegate fitterDidSelect:0];
    }
}

-(void)leftBtnAction{
    if ([_delegate respondsToSelector:@selector(fitterDidSelect:)]) {
        [_delegate fitterDidSelect:1];
    }
}

-(void)rightBtnAction{
    if ([_delegate respondsToSelector:@selector(fitterDidSelect:)]) {
        [_delegate fitterDidSelect:2];
    }
}

@end
