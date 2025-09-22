//
//  DhaWarningView.m
//  NewJieliZhiNeng
//
//  Created by JLee on 2022/7/12.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DhaWarningView.h"

@interface DhaWarningView(){
    UIImageView *bgview;
    UIView *centerView;
    UILabel *titleLab;
    UILabel *msgLabel;
    UIImageView *line1;
    UIImageView *line2;
    UIButton *cancelBtn;
    UIButton *confirmBtn;
    
    DhaSelectAlert alertResult;
}
@end

@implementation DhaWarningView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self stepUI];
    }
    return self;
}

-(void)stepUI{
    self.backgroundColor = [UIColor clearColor];
    bgview = [UIImageView new];
    bgview.backgroundColor = [UIColor blackColor];
    bgview.alpha = 0.7;
    [self addSubview:bgview];
    
    centerView = [UIView new];
    centerView.backgroundColor = [UIColor colorFromHexString:@"#FFFFFF"];
    [JLUI_Effect addShadowOnView:centerView];
    centerView.layer.masksToBounds = YES;
    [self addSubview:centerView];
    
    titleLab = [UILabel new];
    titleLab.text = kJL_TXT("tips_0");
    titleLab.textColor = [UIColor colorFromHexString:@"#242424"];
    titleLab.font = FontMedium(16);
    titleLab.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:titleLab];
    
    msgLabel = [UILabel new];
    msgLabel.text = kJL_TXT("dha_fitting_exit_save_tips");
    msgLabel.textColor = [UIColor colorFromHexString:@"#5C5C5C"];
    msgLabel.numberOfLines = 0;
    msgLabel.font = [UIFont systemFontOfSize:14];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:msgLabel];
    
    line1 = [UIImageView new];
    line1.backgroundColor = [UIColor colorFromHexString:@"#F2F2F2"];
    [centerView addSubview:line1];
    
    
    cancelBtn = [UIButton new];
    [cancelBtn setTitleColor:[UIColor colorFromHexString:@"#558CFF"] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorFromHexString:@"#5C5C5C"] forState:UIControlStateHighlighted];
    cancelBtn.titleLabel.font = FontMedium(16);
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:cancelBtn];
    
    
    confirmBtn = [UIButton new];
    [confirmBtn setTitleColor:[UIColor colorFromHexString:@"#558CFF"] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor colorFromHexString:@"#5C5C5C"] forState:UIControlStateHighlighted];
    confirmBtn.titleLabel.font = FontMedium(16);
    [confirmBtn addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:confirmBtn];
    
    line2 = [UIImageView new];
    line2.backgroundColor = [UIColor colorFromHexString:@"#F2F2F2"];
    [centerView addSubview:line2];
    
    [bgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.left.equalTo(self.mas_left).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(0);
    }];
    
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(-20);
        make.height.offset(154);
        make.width.offset(284);
        make.centerX.offset(0);
    }];
    
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_top).offset(15);
        make.left.equalTo(centerView.mas_left).offset(10);
        make.right.equalTo(centerView.mas_right).offset(-10);
        make.height.offset(30);
    }];
    
    [msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLab.mas_bottom).offset(8);
        make.left.equalTo(centerView.mas_left).offset(10);
        make.right.equalTo(centerView.mas_right).offset(-10);
        make.bottom.equalTo(line1.mas_top).offset(-10);
    }];
    
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(msgLabel.mas_bottom).offset(10);
        make.left.equalTo(centerView.mas_left).offset(0);
        make.right.equalTo(centerView.mas_right).offset(0);
        make.height.offset(1);
    }];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(0);
        make.left.equalTo(centerView.mas_left).offset(0);
        make.right.equalTo(confirmBtn.mas_left).offset(-1);
        make.bottom.equalTo(centerView.mas_bottom).offset(0);
        make.width.equalTo(confirmBtn.mas_width);
        make.height.offset(47);
    }];
    
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(0);
        make.left.equalTo(cancelBtn.mas_right).offset(1);
        make.right.equalTo(centerView.mas_right).offset(-1);
        make.bottom.equalTo(centerView.mas_bottom).offset(0);
        make.width.equalTo(cancelBtn.mas_width);
        make.height.offset(47);
    }];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(0);
        make.centerX.offset(0);
        make.width.offset(1);
        make.bottom.equalTo(centerView.mas_bottom).offset(0);
    }];
    
}


-(void)dhaMessage:(NSString *)msg cancel:(NSString *)cancelName confirm:(NSString *)confirmName action:(DhaSelectAlert) select{
    msgLabel.text = msg;
    [cancelBtn setTitle:cancelName forState:UIControlStateNormal];
    [confirmBtn setTitle:confirmName forState:UIControlStateNormal];
    alertResult = select;
    line2.hidden = NO;
    cancelBtn.hidden = NO;
    
    [cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(0);
        make.left.equalTo(centerView.mas_left).offset(0);
        make.right.equalTo(confirmBtn.mas_left).offset(-1);
        make.bottom.equalTo(centerView.mas_bottom).offset(0);
        make.width.equalTo(confirmBtn.mas_width);
        make.height.offset(47);
    }];
    
    [confirmBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(0);
        make.left.equalTo(cancelBtn.mas_right).offset(1);
        make.right.equalTo(centerView.mas_right).offset(-1);
        make.bottom.equalTo(centerView.mas_bottom).offset(0);
        make.width.equalTo(cancelBtn.mas_width);
        make.height.offset(47);
    }];
}


-(void)dhaMessage:(NSString *)msg confirm:(NSString *)confirmName action:(DhaSelectAlert) select{
    msgLabel.text = msg;
    [confirmBtn setTitle:confirmName forState:UIControlStateNormal];
    alertResult = select;
    line2.hidden = YES;
    cancelBtn.hidden = YES;
    
    [cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(0);
        make.width.offset(0);
        make.height.offset(0);
    }];
    
    [confirmBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(0);
        make.left.equalTo(centerView.mas_left).offset(1);
        make.right.equalTo(centerView.mas_right).offset(-1);
        make.bottom.equalTo(centerView.mas_bottom).offset(0);
        make.height.offset(47);
    }];
    
}




-(void)cancelBtnAction{
    if (alertResult) {
        alertResult(DhaAlertSelectType_Cancel);
    }
}

-(void)confirmBtnAction{
    if (alertResult) {
        alertResult(DhaAlertSelectType_Confirm);
    }

}

@end
