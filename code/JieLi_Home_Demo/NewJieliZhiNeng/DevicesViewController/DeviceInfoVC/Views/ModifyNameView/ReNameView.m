//
//  ReNameView.m
//  CMD_APP
//
//  Created by Ezio on 2018/2/5.
//  Copyright © 2018年 DFung. All rights reserved.
//

#import "ReNameView.h"

#define ReNameView_W      self.frame.size.width
#define ReNameView_H      self.frame.size.height

@interface ReNameView()<UITextFieldDelegate>{
    UITapGestureRecognizer *tapges;
    UIImageView *bgImgv;
    UIView *centerView;
    int mMaxLeft;
    int mMaxRight;
    int mType; // 0:修改名字 1：修改左耳通透增益值 2：修改右耳通透增益值
}
@end
@implementation ReNameView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.sizeLength = 20;
        self.frame = frame;
        [self initUI];
        [self adjustDark];
    }
    return self;
    
}

#pragma mark 适配暗黑模式
-(void)adjustDark{
    if (@available(iOS 13.0, *)) {
        UIColor *bgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
            }
            else {
                return [UIColor colorWithRed:60/255.0 green:61/255.0 blue:74/255.0 alpha:1.0];
            }
        }];
        [_nameTxfd setBackgroundColor:bgColor];
        [centerView setBackgroundColor:bgColor];
    } else {
        // Fallback on earlier versions
        [_nameTxfd setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
        [centerView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
    }
}

-(void)initUI{
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, ReNameView_W, ReNameView_H)];
    //样式
    toolbar.barStyle = UIBarStyleBlackTranslucent;//半透明
    UITapGestureRecognizer *ttohLefttapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnAction:)];
    [toolbar addGestureRecognizer:ttohLefttapGestureRecognizer];
    toolbar.userInteractionEnabled=YES;
    //透明度
    toolbar.alpha = 0.45f;
    [self addSubview:toolbar];
    
    //命令背景View
    centerView = [[UIView alloc] initWithFrame:CGRectMake(46,ReNameView_H/4,ReNameView_W-46*2,165)];
    centerView.backgroundColor = [UIColor whiteColor];
    centerView.alpha=1.0;
    centerView.layer.cornerRadius = 5;
    [self addSubview:centerView];
    
    //提示框名称
    _titleLab = [[UILabel alloc] init];
    _titleLab.frame = CGRectMake(centerView.frame.size.width/2-52/2,19,52,14);
    _titleLab.numberOfLines = 0;
    _titleLab.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:_titleLab];
    
    if (@available(iOS 13.0, *)) {
        UIColor *titleColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0];
            }
            else {
                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
            }
        }];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("name2") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 15],NSForegroundColorAttributeName: titleColor}];
        
        _titleLab.attributedText = string;
    } else {
        // Fallback on earlier versions
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("name2") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0]}];
        
        _titleLab.attributedText = string;
    }
    
    _nameTxfd = [[UITextField alloc]initWithFrame:CGRectMake(22, 50, centerView.frame.size.width-22*2, 46)];
    _nameTxfd.borderStyle = UITextBorderStyleRoundedRect;
    [_nameTxfd setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 14]];
    if (@available(iOS 13.0, *)) {
        UIColor *nameColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0];
            }
            else {
                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
            }
        }];
        [_nameTxfd setTextColor:nameColor];
    } else {
        // Fallback on earlier versions
        [_nameTxfd setTextColor:[UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0]];
    }
    [centerView addSubview:_nameTxfd];
    _nameTxfd.text = _txfdStr;
    _nameTxfd.delegate = self;
    
    UIView *view_1 = [[UIView alloc] init];
    view_1.frame = CGRectMake(0,121,centerView.frame.size.width,0.5);
    view_1.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [centerView addSubview:view_1];
    
    _cancelBtn = [[UIButton alloc] initWithFrame: CGRectMake(0,121.5,(centerView.frame.size.width-1)/2,44)];
    [_cancelBtn setTitle:kJL_TXT("cancel_1") forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor colorWithRed:152/255.0 green:152/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 14]];
    [_cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:_cancelBtn];
    
    UIView *view_2 = [[UIView alloc] init];
    view_2.frame = CGRectMake(_cancelBtn.frame.size.width,121.5,1,44);
    view_2.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [centerView addSubview:view_2];
    
    
    _finishBtn = [[UIButton alloc] initWithFrame: CGRectMake(_cancelBtn.frame.size.width+1,121.5,(centerView.frame.size.width-1)/2,44)];
    [_finishBtn setTitle:kJL_TXT("confirm_1") forState:UIControlStateNormal];
    [_finishBtn setTitleColor:kDF_RGBA(68, 142, 255, 1.0) forState:UIControlStateNormal];
    [_finishBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size: 14]];
    [_finishBtn addTarget:self action:@selector(finishBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:_finishBtn];
}

-(void)setType:(int)type{
    mType = type;
    
    if(type == 0){
        _titleLab.frame = CGRectMake(centerView.frame.size.width/2-120/2,19,120,14);

        if (@available(iOS 13.0, *)) {
            UIColor *titleColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
                }
            }];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("name2") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: titleColor}];
            
            _titleLab.attributedText = string;
        } else {
            // Fallback on earlier versions
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("name2") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0]}];
            
            _titleLab.attributedText = string;
        }
        self.nameTxfd.keyboardType = UIKeyboardTypeDefault;
    }else{
        _titleLab.frame = CGRectMake(centerView.frame.size.width/2-110/2,19,110,14);
        if (@available(iOS 13.0, *)) {
            UIColor *titleColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
                }
            }];
            _titleLab.textColor = titleColor;
        } else {
            // Fallback on earlier versions
            _titleLab.textColor = [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0];
        }
        self.titleLab.font = [UIFont fontWithName:@"PingFang SC" size: 15];
        self.nameTxfd.keyboardType = UIKeyboardTypeNumberPad;
    }
}

- (void)cancelBtnAction:(UIButton *)sender {
    [self removeFromSuperview];
}

- (void)finishBtnAction:(UIButton *)sender {
    [_nameTxfd endEditing:YES];
    
    if(mType == 0){
        if(_nameTxfd.text.length == 0){
            [DFUITools showText:kJL_TXT("tip_empty_device_name") onView:self delay:1.0];
            return;
        }
        
        NSData *data = [_nameTxfd.text dataUsingEncoding:NSUTF8StringEncoding];

        if(data.length>self.sizeLength){
            [DFUITools showText:kJL_TXT("tip_device_name_len_err") onView:self delay:1.0];
            return;
        }
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        if([_nameTxfd.text isEqualToString:bleSDK.mBleEntityM.mItem]){
            [DFUITools showText:kJL_TXT("tip_same_device_name") onView:self delay:1.0];
            return;
        }
        if ([_delegate respondsToSelector:@selector(didSelectBtnAction:WithText:)]) {
            [_delegate didSelectBtnAction:_finishBtn WithText:_nameTxfd.text];
        }
    }
    if(mType == 1 || mType ==2){
        int value = 0;
        if(mType == 1){
            value = mMaxLeft;
        }
        if(mType ==2){
            value = mMaxRight;
        }
        
        if([_nameTxfd.text intValue]>value || [_nameTxfd.text intValue]<0){
            [DFUITools showText:kJL_TXT("outof_transparent_value") onView:self delay:1.0];
            return;
        }
        
        if(mType == 1){
            if ([_delegate respondsToSelector:@selector(didSelectLeftAction:WithText:)]) {
                [_delegate didSelectLeftAction:_finishBtn WithText:_nameTxfd.text];
            }
        }
        if(mType == 2){
            if ([_delegate respondsToSelector:@selector(didSelectRightAction:WithText:)]) {
                [_delegate didSelectRightAction:_finishBtn WithText:_nameTxfd.text];
            }
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [_nameTxfd endEditing:YES];
    [self finishBtnAction:_finishBtn];
    return YES;
}

-(void)setMaxLeft:(int)maxLeft{
    mMaxLeft = maxLeft;
}

-(void)setMaxRight:(int)maxRight{
    mMaxRight = maxRight;
}

@end
