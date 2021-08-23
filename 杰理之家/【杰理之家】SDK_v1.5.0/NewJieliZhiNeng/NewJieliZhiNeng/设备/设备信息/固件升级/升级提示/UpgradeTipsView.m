//
//  UpgradeTipsView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "UpgradeTipsView.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"

@interface UpgradeTipsView(){
 
    UIView *centerView;
    UIButton *closeBtn;
    UILabel *titleLab;
    UILabel *textLab;
    
}
@end

@implementation UpgradeTipsView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.3;
        [self addSubview:bgView];
        centerView = [[UIView alloc]initWithFrame:CGRectMake(6.0, frame.size.height, frame.size.width-12, 155)];
        centerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:centerView];
        
        titleLab = [[UILabel alloc] initWithFrame:CGRectMake(centerView.frame.size.width/2-100, 20.0, 200.0, 35.0)];
        titleLab.textColor = [UIColor colorWithRed:36.0/255.0 green:36.0/255.0 blue:36.0/255.0 alpha:1.0];
        titleLab.font = [UIFont systemFontOfSize:18.0];
        titleLab.text = kJL_TXT("新版本");
        titleLab.textAlignment = NSTextAlignmentCenter;
        [centerView addSubview:titleLab];
        
        closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerView.frame.size.width-40, 5, 35.0, 35.0)];
        [closeBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
        [centerView addSubview:closeBtn];
        
        textLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 50.0, centerView.frame.size.width-40.0, centerView.frame.size.height-50)];
        textLab.textColor = [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0];
        textLab.numberOfLines = 0;
        textLab.font = [UIFont systemFontOfSize:14.0];
        [centerView addSubview:textLab];
        
        CGFloat k = 15;
        if (kJL_IS_IPHONE_X) {
            k = 30;
        }
        if (kJL_IS_IPHONE_Xr) {
            k = 30;
            
        }
        if (kJL_IS_IPHONE_Xs_Max) {
            k = 30;
            
        }
        centerView.layer.cornerRadius = k;
        centerView.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAction)];
        [bgView addGestureRecognizer:tapges];
    }
    return self;
}

-(void)initWithNews:(NSString *)version tips:(NSString*)tips{
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = CGRectMake(7.0, self.frame.size.height-161.0, self.frame.size.width-14, 155);
        self->centerView.frame = rect;
    }];
    NSString *title = [NSString stringWithFormat:@"%@%@",kJL_TXT("新版本"),version];
    titleLab.text = title;
    textLab.text = tips;
    
}

-(void)dismissAction{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = CGRectMake(7.0, self.frame.size.height, self.frame.size.width-14, 155);
        self->centerView.frame = rect;
    }];
    [self removeFromSuperview];
}


@end
