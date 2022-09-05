//
//  DhaWriteTipsView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/2.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DhaWriteTipsView.h"


@interface DhaWriteTipsView()<UITextFieldDelegate>{
    UIView *centerView;
    UIView *bgView;
    UILabel *titleLab;
    UITextField *writeTxfd;
    UIImageView *lineView;
    UIButton *safeBtn;
    UIButton *cancelBtn;
    UIButton *confirmBtn;
    UIImageView *line1;
    UIImageView *line2;
    BOOL isSave;
}
@end

@implementation DhaWriteTipsView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        isSave = YES;
        
        self.backgroundColor = [UIColor clearColor];
        bgView = [UIView new];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.6;
        [self addSubview:bgView];
        [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchBgView)]];
        
        
        centerView = [UIView new];
        centerView.backgroundColor = [UIColor whiteColor];
        [JLUI_Effect addShadowOnView:centerView];
        centerView.layer.masksToBounds = YES;
        [self addSubview:centerView];
        
        titleLab = [UILabel new];
        titleLab.font = FontMedium(18);
        titleLab.textColor = [UIColor colorFromHexString:@"#242424"];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = kJL_TXT("Make_sure_to_write_the_hearing_aid");
        titleLab.numberOfLines = 0;
        titleLab.adjustsFontSizeToFitWidth = true;
        [centerView addSubview:titleLab];
        
        writeTxfd = [UITextField new];
        writeTxfd.placeholder = @"记录的名称";
        writeTxfd.keyboardType = UIKeyboardTypeDefault;
        writeTxfd.font = [UIFont systemFontOfSize:15];
        writeTxfd.textColor = [UIColor colorFromHexString:@"#242424"];
        writeTxfd.autocorrectionType = UITextAutocorrectionTypeNo;
        writeTxfd.minimumFontSize = 12;
        writeTxfd.borderStyle = UITextBorderStyleNone;
        UIImageView *rightView = [UIImageView new];
        rightView.image = [UIImage imageNamed:@"Theme.bundle/icon_edit"];
        rightView.frame = CGRectMake(0, 0, 30, 30);
        writeTxfd.rightView = rightView;
        writeTxfd.rightViewMode = UITextFieldViewModeAlways;
        writeTxfd.delegate = self;
        [centerView addSubview:writeTxfd];
        
        lineView = [UIImageView new];
        lineView.backgroundColor = [UIColor colorFromHexString:@"#EBEBEB"];
        [centerView addSubview:lineView];
        
        safeBtn = [UIButton new];
        
        [safeBtn setTitleColor:[UIColor colorFromHexString:@"#242424"] forState:UIControlStateNormal];
        [safeBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [safeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 12)];
        [safeBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_choose_sel"] forState:UIControlStateNormal];
        safeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [centerView addSubview:safeBtn];
        
        cancelBtn = [UIButton new];
        [cancelBtn setTitle:kJL_TXT("jl_cancel") forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor colorFromHexString:@"#808080"] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [centerView addSubview:cancelBtn];
        
        confirmBtn = [UIButton new];
        [confirmBtn setTitle:kJL_TXT("confirm") forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor colorFromHexString:@"#558CFF"] forState:UIControlStateNormal];
        confirmBtn.titleLabel.font = FontMedium(18);
        [confirmBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [confirmBtn addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [centerView addSubview:confirmBtn];
        
        line1 = [UIImageView new];
        line1.backgroundColor = [UIColor colorFromHexString:@"#F7F7F7"];
        [centerView addSubview:line1];
        
        line2 = [UIImageView new];
        line2.backgroundColor = [UIColor colorFromHexString:@"#F7F7F7"];
        [centerView addSubview:line2];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(0);
            make.right.equalTo(self.mas_right).offset(0);
            make.left.equalTo(self.mas_left).offset(0);
            make.bottom.equalTo(self.mas_bottom).offset(0);
        }];
        
        [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.centerY.offset(-20);
            make.left.equalTo(self.mas_left).offset(20);
            make.right.equalTo(self.mas_right).offset(-20);
            make.height.offset(210);
        }];
        
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.height.lessThanOrEqualTo(@(60));
            make.top.equalTo(centerView.mas_top).offset(6);
            make.left.equalTo(centerView.mas_left).offset(8);
            make.right.equalTo(centerView.mas_right).offset(-8);
            make.bottom.equalTo(writeTxfd.mas_top).offset(-10);
        }];
        
        [writeTxfd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLab.mas_bottom).offset(10);
            make.left.equalTo(centerView.mas_left).offset(20);
            make.right.equalTo(centerView.mas_right).offset(-20);
            make.height.offset(30);
            make.bottom.equalTo(lineView.mas_top).offset(-1);
        }];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(writeTxfd.mas_bottom).offset(1);
            make.left.equalTo(centerView.mas_left).offset(20);
            make.right.equalTo(centerView.mas_right).offset(-20);
            make.height.offset(1);
            make.bottom.equalTo(safeBtn.mas_top).offset(-10);
        }];
        
        [safeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView.mas_bottom).offset(10);
            make.left.equalTo(centerView.mas_left).offset(20);
            make.bottom.equalTo(line1.mas_top).offset(-10);
            make.height.offset(30);
            make.width.offset(110);
        }];
        
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(safeBtn.mas_bottom).offset(10);
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
        [safeBtn setTitle:kJL_TXT("Keep_the_fitting_record") forState:UIControlStateNormal];
        
    }
    return self;
}

-(void)noNeedSave{
    [safeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(10);
        make.left.equalTo(centerView.mas_left).offset(20);
        make.bottom.equalTo(line1.mas_top).offset(-10);
        make.height.offset(0);
        make.width.offset(110);
    }];
    
    [centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.offset(-20);
        make.left.equalTo(self.mas_left).offset(20);
        make.right.equalTo(self.mas_right).offset(-20);
        make.height.offset(180);
    }];
    safeBtn.hidden = YES;
}

-(void)saveBtnAction{
    isSave = !isSave;
    if (isSave) {
        [safeBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_choose_sel"] forState:UIControlStateNormal];
    }else{
        [safeBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_choose_nol"] forState:UIControlStateNormal];
    }
    
}

-(void)existTips{
    [self cancelBtnAction];
}

-(void)cancelBtnAction{
    self.hidden = YES;
    [writeTxfd endEditing:YES];
}

-(void)confirmBtnAction{
    
    if (writeTxfd.text.length == 0) {
        [DFUITools showText:kJL_TXT("tip_empty_device_name") onView:self delay:1];
        return;
    }
    if (writeTxfd.text.length >20) {
        [DFUITools showText:kJL_TXT("tip_device_name_len_err") onView:self delay:1];
        return;
    }
    [writeTxfd endEditing:YES];
    if([_delegate respondsToSelector:@selector(dhaWrite:saveToDb:)]){
        [_delegate dhaWrite:writeTxfd.text saveToDb:isSave];
    }
}

-(void)setShowText:(NSString *)showText{
    _showText = showText;
    writeTxfd.text = _showText;
}


-(void)didTouchBgView{
    [writeTxfd endEditing:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [writeTxfd endEditing:YES];
    return true;
}
@end
