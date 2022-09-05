//
//  MofifyNameAlert.m
//  IntelligentBox
//
//  Created by kaka on 2019/10/8.
//  Copyright © 2019 Zhuhia Jieli Technology. All rights reserved.
//

#import "MofifyNameAlert.h"

#define MofifyNameAlert_W      self.frame.size.width
#define MofifyNameAlert_H      self.frame.size.height

@interface MofifyNameAlert(){
    UITapGestureRecognizer *tapges;
    UIImageView *bgImgv;
    UIView *centerView;
    UILabel *titleLab;
    UIButton *cancelBtn;
    UIButton *finishBtn;
    UILabel *robotTip1;
    UILabel *robotTip2;
    UILabel *robotTip3;
    UIView *view_1; //横向分割线;
    UIView *view_2; //竖向分割线;
}
@end

@implementation MofifyNameAlert

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
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
        [centerView setBackgroundColor:bgColor];
    } else {
        // Fallback on earlier versions
        [centerView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
    }
}

-(void)updateAlertInfo{
    
    if(_funType == 2){
        //背景View
        centerView.frame = CGRectMake(46,MofifyNameAlert_H/4,MofifyNameAlert_W-52.5*2,130);
    }else{
        //背景View
        centerView.frame = CGRectMake(46,MofifyNameAlert_H/4,MofifyNameAlert_W-46*2,165);
    }
    
    if([kJL_GET hasPrefix:@"zh"]){
        cancelBtn.titleLabel.adjustsFontSizeToFitWidth = NO;
        cancelBtn.titleLabel.minimumScaleFactor = 1.0;

        //0:修改名字 1：用于ADV设置同步后需要主机操作的行为 2:忽略设备
        if(_funType == 2){
            robotTip1.frame = CGRectMake(46,46,centerView.frame.size.width-46*2,18);
            view_1.frame = CGRectMake(0,85.5,centerView.frame.size.width,0.5);
            view_2.frame = CGRectMake(cancelBtn.frame.size.width,86,1,44);
            cancelBtn.frame =  CGRectMake(0,86,(centerView.frame.size.width-1)/2,44);
            finishBtn.frame = CGRectMake(cancelBtn.frame.size.width+1,86,(centerView.frame.size.width-1)/2,44);
            [cancelBtn setTitle:kJL_TXT("jl_cancel") forState:UIControlStateNormal];
        }else{
            if([UIScreen mainScreen].bounds.size.width == 320.0){
                robotTip1.frame = CGRectMake(15,55,centerView.frame.size.width-15*2,18);
            }else{
                robotTip1.frame = CGRectMake(46,55,centerView.frame.size.width-46*2,18);
            }
            view_1.frame = CGRectMake(0,121,centerView.frame.size.width,0.5);
            view_2.frame = CGRectMake(cancelBtn.frame.size.width,121.5,1,44);
            cancelBtn.frame =  CGRectMake(0,121.5,(centerView.frame.size.width-1)/2,44);
            finishBtn.frame = CGRectMake(cancelBtn.frame.size.width+1,121.5,(centerView.frame.size.width-1)/2,44);
            [cancelBtn setTitle:kJL_TXT("not_immediately_effective") forState:UIControlStateNormal];
        }
        finishBtn.titleLabel.adjustsFontSizeToFitWidth = NO;
        finishBtn.titleLabel.minimumScaleFactor = 1.0;
        if(_funType == 2){
            [finishBtn setTitle:kJL_TXT("confirm") forState:UIControlStateNormal];
        }else{
            [finishBtn setTitle:kJL_TXT("immediately_effective") forState:UIControlStateNormal];
        }
        robotTip1.adjustsFontSizeToFitWidth = NO;
        robotTip1.minimumScaleFactor = 1.0;
        NSString *robotTip1Str;
        if(_funType ==0){
            robotTip1Str = kJL_TXT("device_name_change_tips");
        }
        if(_funType ==1){
            robotTip1Str = kJL_TXT("have_new_msg");
        }
        if(_funType ==2){
            robotTip1Str = kJL_TXT("remove_history_device_tips");
        }
        if (@available(iOS 13.0, *)) {
            UIColor *myColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
                }
            }];
            NSMutableAttributedString *robotTip1_Str = [[NSMutableAttributedString alloc] initWithString:robotTip1Str attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName:myColor}];

            robotTip1.attributedText = robotTip1_Str;
        } else {
            // Fallback on earlier versions
            NSMutableAttributedString *robotTip1_Str = [[NSMutableAttributedString alloc] initWithString:robotTip1Str attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];

            robotTip1.attributedText = robotTip1_Str;
        }

        robotTip2.adjustsFontSizeToFitWidth = NO;
        robotTip2.minimumScaleFactor = 1.0;
        if([UIScreen mainScreen].bounds.size.width == 320.0){
            robotTip2.frame = CGRectMake(60,robotTip1.frame.origin.y+18+2,centerView.frame.size.width-60*2,18);
        }else{
            robotTip2.frame = CGRectMake(66,robotTip1.frame.origin.y+18+2,centerView.frame.size.width-66*2,18);
        }

        if([UIScreen mainScreen].bounds.size.width == 320.0){
            robotTip3.frame = CGRectMake(14,robotTip2.frame.origin.y+18+2,centerView.frame.size.width-14*2,18);
        }else if([UIScreen mainScreen].bounds.size.width ==812.0){
            robotTip3.frame = CGRectMake(14,robotTip2.frame.origin.y+18+2,centerView.frame.size.width-14*2,18);
        }else{
            robotTip3.frame = CGRectMake(20,robotTip2.frame.origin.y+18+2,centerView.frame.size.width-20*2,18);
        }
        
        if(_funType ==0){
            robotTip2.hidden = NO;
            robotTip3.hidden = NO;
        }
        if(_funType ==1){
            robotTip2.hidden = NO;
            robotTip3.hidden = NO;
        }
        if(_funType ==2){
            robotTip2.hidden = YES;
            robotTip3.hidden = YES;
        }

        if (@available(iOS 13.0, *)) {
            UIColor *myColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
                }
            }];
            NSMutableAttributedString *robotTip2_Str = [[NSMutableAttributedString alloc] initWithString:@"device_name_change_tips" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: myColor}];

            robotTip2.attributedText = robotTip2_Str;
        } else {
            // Fallback on earlier versions
            NSMutableAttributedString *robotTip2_Str = [[NSMutableAttributedString alloc] initWithString:@"device_name_change_tips" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];

            robotTip2.attributedText = robotTip2_Str;
        }
        
        if (@available(iOS 13.0, *)) {
            UIColor *myColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:126/255.0 green:126/255.0 blue:126/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
                }
            }];
            NSMutableAttributedString *robotTip3_Str = [[NSMutableAttributedString alloc] initWithString:@"modify_dev_name_tips" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 12],NSForegroundColorAttributeName: myColor}];

            robotTip3.attributedText = robotTip3_Str;
        } else {
            // Fallback on earlier versions
            NSMutableAttributedString *robotTip3_Str = [[NSMutableAttributedString alloc] initWithString:@"modify_dev_name_tips" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 12],NSForegroundColorAttributeName: [UIColor colorWithRed:126/255.0 green:126/255.0 blue:126/255.0 alpha:1.0]}];

            robotTip3.attributedText = robotTip3_Str;
        }
    }else{
        cancelBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        cancelBtn.titleLabel.minimumScaleFactor = 0.5;
        
        //0:修改名字 1：用于ADV设置同步后需要主机操作的行为 2:忽略设备
        if(_funType == 2){
            if([UIScreen mainScreen].bounds.size.width == 320.0){
                robotTip1.frame = CGRectMake(8,46,centerView.frame.size.width-8*2,18);
            }else{
                robotTip1.frame = CGRectMake(26,46,centerView.frame.size.width-26*2,18);
            }
            view_1.frame = CGRectMake(0,85.5,centerView.frame.size.width,0.5);
            view_2.frame = CGRectMake(cancelBtn.frame.size.width,86,1,44);
            cancelBtn.frame =  CGRectMake(0,86,(centerView.frame.size.width-1)/2,44);
            finishBtn.frame = CGRectMake(cancelBtn.frame.size.width+1,86,(centerView.frame.size.width-1)/2,44);
            [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        }else{
            if([UIScreen mainScreen].bounds.size.width == 320.0){
                robotTip1.frame = CGRectMake(8,55,centerView.frame.size.width-8*2,18);
            }else{
                robotTip1.frame = CGRectMake(26,55,centerView.frame.size.width-26*2,18);

            }
            view_1.frame = CGRectMake(0,121,centerView.frame.size.width,0.5);
            view_2.frame = CGRectMake(cancelBtn.frame.size.width,121.5,1,44);
            cancelBtn.frame =  CGRectMake(0,121.5,(centerView.frame.size.width-1)/2,44);
            finishBtn.frame = CGRectMake(cancelBtn.frame.size.width+1,121.5,(centerView.frame.size.width-1)/2,44);
            [cancelBtn setTitle:@"Next boot-up takes effect" forState:UIControlStateNormal];
        }
        finishBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        finishBtn.titleLabel.minimumScaleFactor = 0.5;
        if(_funType == 2){
            [finishBtn setTitle:@"Sure" forState:UIControlStateNormal];
        }else{
            [finishBtn setTitle:@"Immediate effect" forState:UIControlStateNormal];
        }
        
        robotTip1.adjustsFontSizeToFitWidth = YES;
        robotTip1.minimumScaleFactor = 0.5;
        NSString *robotTip1Str;
        if(_funType ==0){
            robotTip1Str = @"This operation requires a reboot of the device to take effect,";
        }
        if(_funType ==1){
            robotTip1Str = @"Device configuration information updated,";
        }
        if(_funType ==2){
            robotTip1Str = @"Do you want to ignore this device?";
        }
        
        if (@available(iOS 13.0, *)) {
            UIColor *myColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
                }
            }];
            NSMutableAttributedString *robotTip1_Str = [[NSMutableAttributedString alloc] initWithString:robotTip1Str attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName:myColor}];
            
            robotTip1.attributedText = robotTip1_Str;
        } else {
            // Fallback on earlier versions
            NSMutableAttributedString *robotTip1_Str = [[NSMutableAttributedString alloc] initWithString:robotTip1Str attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
            
            robotTip1.attributedText = robotTip1_Str;
        }
        
        robotTip2.adjustsFontSizeToFitWidth = YES;
        robotTip2.minimumScaleFactor = 0.5;
        robotTip2.frame = CGRectMake(66,robotTip1.frame.origin.y+18+2,centerView.frame.size.width-66*2,18);
        
        if([UIScreen mainScreen].bounds.size.width == 320.0){
            robotTip3.frame = CGRectMake(14,robotTip2.frame.origin.y+18+2,centerView.frame.size.width-14*2,18);
        }else if([UIScreen mainScreen].bounds.size.width ==812.0){
            robotTip3.frame = CGRectMake(14,robotTip2.frame.origin.y+18+2,centerView.frame.size.width-14*2,18);
        }else{
            robotTip3.frame = CGRectMake(20,robotTip2.frame.origin.y+18+2,centerView.frame.size.width-20*2,18);
        }
        
        if(_funType ==0){
            robotTip2.hidden = NO;
            robotTip3.hidden = NO;
        }
        if(_funType ==1){
            robotTip2.hidden = NO;
            robotTip3.hidden = NO;
        }
        if(_funType ==2){
            robotTip2.hidden = YES;
            robotTip3.hidden = YES;
        }
        
        if (@available(iOS 13.0, *)) {
            UIColor *myColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
                }
            }];
            NSMutableAttributedString *robotTip2_Str = [[NSMutableAttributedString alloc] initWithString:@"Is it effective immediately?" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName:myColor}];
            
            robotTip2.attributedText = robotTip2_Str;
        } else {
            // Fallback on earlier versions
            NSMutableAttributedString *robotTip2_Str = [[NSMutableAttributedString alloc] initWithString:@"Is it effective immediately?" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
            
            robotTip2.attributedText = robotTip2_Str;
        }
        
        if (@available(iOS 13.0, *)) {
            UIColor *myColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:126/255.0 green:126/255.0 blue:126/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
                }
            }];
            NSMutableAttributedString *robotTip3_Str = [[NSMutableAttributedString alloc] initWithString:@"(Incorrect name, Please match again)" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 12],NSForegroundColorAttributeName: myColor}];

            robotTip3.attributedText = robotTip3_Str;
        } else {
            // Fallback on earlier versions
            NSMutableAttributedString *robotTip3_Str = [[NSMutableAttributedString alloc] initWithString:@"(Incorrect name, Please match again)" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 12],NSForegroundColorAttributeName: [UIColor colorWithRed:126/255.0 green:126/255.0 blue:126/255.0 alpha:1.0]}];

            robotTip3.attributedText = robotTip3_Str;
        }
    }
}

-(void)initUI{
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, MofifyNameAlert_W, MofifyNameAlert_H)];
    //样式
    toolbar.barStyle = UIBarStyleBlackTranslucent;//半透明
    UITapGestureRecognizer *ttohLefttapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnAction:)];
    [toolbar addGestureRecognizer:ttohLefttapGestureRecognizer];
    toolbar.userInteractionEnabled=YES;
    //透明度
    toolbar.alpha = 0.45f;
    [self addSubview:toolbar];
    
    //背景View
    centerView = [[UIView alloc] initWithFrame:CGRectMake(46,MofifyNameAlert_H/4,MofifyNameAlert_W-46*2,165)];
    centerView.backgroundColor = [UIColor whiteColor];
    centerView.alpha=1.0;
    centerView.layer.cornerRadius = 5;
    [self addSubview:centerView];
    
    titleLab = [[UILabel alloc] init];
    titleLab.frame = CGRectMake(centerView.frame.size.width/2-52/2,19,52,14);
    titleLab.numberOfLines = 0;
    titleLab.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:titleLab];
    
    if (@available(iOS 13.0, *)) {
        UIColor *titleColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
            }
            else {
                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
            }
        }];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("tips_1") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: titleColor}];
        
        titleLab.attributedText = string;
    } else {
        // Fallback on earlier versions
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("tips_1") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
        
        titleLab.attributedText = string;
    }
    
    robotTip1 = [[UILabel alloc] init];
    robotTip1.numberOfLines = 0;
    robotTip1.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:robotTip1];
    
    robotTip2 = [[UILabel alloc] init];
    robotTip2.numberOfLines = 0;
    robotTip2.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:robotTip2];
    
    robotTip3 = [[UILabel alloc] init];
    robotTip3.numberOfLines = 2;
    robotTip3.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:robotTip3];
    
    [self updateAlertInfo];
    
    view_1 = [[UIView alloc] init];
    view_1.frame = CGRectMake(0,121,centerView.frame.size.width,0.5);
    view_1.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [centerView addSubview:view_1];
    
    cancelBtn = [[UIButton alloc] initWithFrame: CGRectMake(0,121.5,(centerView.frame.size.width-1)/2,44)];
    [cancelBtn setTitleColor:[UIColor colorWithRed:152/255.0 green:152/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size: 14]];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:cancelBtn];
    
    view_2 = [[UIView alloc] init];
    view_2.frame = CGRectMake(cancelBtn.frame.size.width,121.5,1,44);
    view_2.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [centerView addSubview:view_2];
    
    
    finishBtn = [[UIButton alloc] initWithFrame: CGRectMake(cancelBtn.frame.size.width+1,121.5,(centerView.frame.size.width-1)/2,44)];
    [finishBtn setTitleColor:kColor_0000 forState:UIControlStateNormal];
    [finishBtn.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size: 14]];
    [finishBtn addTarget:self action:@selector(finishBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:finishBtn];
}

- (void)cancelBtnAction:(UIButton *)sender {
    [self removeFromSuperview];
}

- (void)finishBtnAction:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didSelectBtnAction:)]) {
        [_delegate didSelectBtnAction:finishBtn];
    }
}

@end
