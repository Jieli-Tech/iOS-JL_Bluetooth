//
//  FittingVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/30.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "FittingVC.h"
#import "DhaFittingChartsView.h"
#import "FittingResultVC.h"
#import "DhaWarningView.h"



@interface FittingVC ()<DhaFittingFinishPtl>{
    DhaFittingChartsView *fittingView;
    DhaWarningView *warningView;
}

@end

@implementation FittingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self stepUI];
    [self stepData];
    
}

-(void)stepUI{
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F8FAFC"];
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Theme.bundle/icon_return.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backBtnAction)];
    leftBtn.tintColor = [UIColor grayColor];
    [self.navigationItem setLeftBarButtonItem:leftBtn];
    self.title = kJL_TXT("fitting");
    
    warningView = [DhaWarningView new];
    warningView.hidden = YES;
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [window addSubview:warningView];
    
    
    
    fittingView = [[DhaFittingChartsView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:fittingView];
    fittingView.delegate = self;
    
   

    [warningView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(window.mas_top).offset(0);
        make.left.equalTo(window.mas_left).offset(0);
        make.right.equalTo(window.mas_right).offset(0);
        make.bottom.equalTo(window.mas_bottom).offset(0);
    }];
    
    
    [fittingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kJL_HeightNavBar);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(-kJL_HeightTabBar);
    }];
    
    
}

-(void)stepData{
    fittingView.dhaType = self.type;
    if (self.type == DHAEarTypeBoth){
        self.title = kJL_TXT("dha_both_fitting");
    }
    if (self.type == DHAEarTypeLeft){
        
        self.title = kJL_TXT("dha_left_fitting");
    }
    if (self.type == DHAEarTypeRight){
        self.title = kJL_TXT("dha_right_fitting");
    }
    
    if (self.dhaFitter) {
        if ([self.dhaFitter.type isEqualToString:DoubleFitter]) {
            fittingView.dhaType = DHAEarTypeBoth;
            self.title = kJL_TXT("dha_both_fitting");
        }
        if ([self.dhaFitter.type isEqualToString:LeftFitter]) {
            fittingView.dhaType = DHAEarTypeLeft;
            self.title = kJL_TXT("dha_left_fitting");
        }
        if ([self.dhaFitter.type isEqualToString:RightFitter]) {
            fittingView.dhaType = DHAEarTypeRight;
            self.title = kJL_TXT("dha_right_fitting");
        }
        [fittingView setDhaSqlFitter:self.dhaFitter];
    }else{
        [fittingView beginFitting];
    }
}



-(void)backBtnAction{
    if (fittingView.isFitting) {
        JL_ManagerM *cmd = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
        [[JLDhaFitting new] auxiCloseManager:cmd Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
#if UseSaveCache
            self->warningView.hidden = NO;
            [self->warningView dhaMessage:kJL_TXT("dha_fitting_exit_save_tips") cancel:kJL_TXT("dha_don_save") confirm:kJL_TXT("dha_save") action:^(DhaAlertSelectType type) {
                if (type == DhaAlertSelectType_Cancel) {
                    
                }else{
                    [self->fittingView saveToSql];
                }
                self->warningView.hidden = YES;
                NSInteger index = [[self.navigationController viewControllers]indexOfObject:self];
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-3]animated:YES];
            }];
#else
            NSInteger index = [[self.navigationController viewControllers]indexOfObject:self];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-3]animated:YES];
#endif
            
        }];
    }else{
        if (fittingView.isHidden) {
            [self.navigationController popViewControllerAnimated:true];
        }
    }
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
  };
}


-(void)dhaFittingFinish:(NSArray<FittingMgr *> *)results{
    
    JL_ManagerM *cmd = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    [[JLDhaFitting new] auxiCloseManager:cmd Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
    }];
    
    fittingView.isFitting = false;
    FittingResultVC *vc = [[FittingResultVC alloc] init];
    vc.results = results;
    vc.exitNumber = 4;
    vc.fitResultSql = fittingView.dhaSqlFitter;
    vc.isCache = self.isCache;
    [self.navigationController pushViewController:vc animated:true];
}

-(void)goBackToRoot{
#if UseSaveCache
    self->warningView.hidden = NO;
    [self->warningView dhaMessage:kJL_TXT("dha_fitting_exit_save_tips") cancel:kJL_TXT("dha_don_save") confirm:kJL_TXT("dha_save") action:^(DhaAlertSelectType type) {
        if (type == DhaAlertSelectType_Cancel) {
            
        }else{
            [self->fittingView saveToSql];
        }
        self->warningView.hidden = YES;
        NSInteger index = [[self.navigationController viewControllers]indexOfObject:self];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-3]animated:YES];
    }];
#else
    [self.navigationController popToRootViewControllerAnimated:true];
#endif
}



@end
