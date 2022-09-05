//
//  FitStepOneVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/15.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "FitStepOneVC.h"
#import "FitStepTwoVC.h"
#import "DhaWarningView.h"


@interface FitStepOneVC ()<StepTipsPtl>{
    DhaStepTipView *tipsView;
    
    DhaWarningView *warningView;
}

@end

@implementation FitStepOneVC




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = kJL_TXT("fitting");
    
    tipsView = [[DhaStepTipView alloc] initWithFrame:CGRectZero];
    tipsView.delegate = self;
    [self.view addSubview:tipsView];
    
    warningView = [DhaWarningView new];
    warningView.hidden = YES;
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [window addSubview:warningView];
    
    [warningView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(window.mas_top).offset(0);
        make.left.equalTo(window.mas_left).offset(0);
        make.right.equalTo(window.mas_right).offset(0);
        make.bottom.equalTo(window.mas_bottom).offset(0);
    }];
    
    
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kJL_HeightNavBar);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
    

}


- (void)goBackToRoot{
    [self.navigationController popToRootViewControllerAnimated:true];
}


-(void)stepViewToDismiss{
    
    FitStepTwoVC *vc = [[FitStepTwoVC alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}


-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:true];
}

@end
