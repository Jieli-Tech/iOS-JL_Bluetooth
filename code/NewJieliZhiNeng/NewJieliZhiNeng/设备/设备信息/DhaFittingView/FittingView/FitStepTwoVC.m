//
//  FitStepTwoVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/15.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "FitStepTwoVC.h"
#import "SelectFitterView.h"
#import "DhaWarningView.h"
#import "FittingVC.h"


@interface FitStepTwoVC ()<SelectFitterViewDelegate>{
    SelectFitterView *selecterView;
    DhaWarningView *warningView;
    DhaFittingSql *dhaFitter;
}

@end

@implementation FitStepTwoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#FFFFFF"];
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Theme.bundle/icon_return.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backBtnAction)];
    leftBtn.tintColor = [UIColor grayColor];
    [self.navigationItem setLeftBarButtonItem:leftBtn];
    self.title = kJL_TXT("fitting");
    
    selecterView = [[SelectFitterView alloc] initWithFrame:CGRectZero];
    selecterView.delegate = self;
    [self.view addSubview:selecterView];
    
    
    [selecterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kJL_HeightNavBar);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
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
    
    [self checkCache];
    
    JL_ManagerM *manager = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    TwsElectricity *electricity = manager.mTwsManager.electricity;
    
    if (electricity.powerLeft > 0 && electricity.powerRight>0) {
        [selecterView setDhaType:DoubleFitter];
    }
    if (electricity.powerLeft == 0 && electricity.powerRight>0) {
        [selecterView setDhaType:RightFitter];
    }
    if (electricity.powerRight == 0 && electricity.powerLeft>0) {
        [selecterView setDhaType:LeftFitter];
    }
    
    
}


-(void)checkCache{
    
#if (DHAUITest == 0)
    JLModel_Device *md = [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager outputDeviceModel];
    int number = md.dhaFitInfo.ch_num;
#elif (DHAUITest == 1)
    int number = 6;
#endif
    [[DhaSqlite share] checkBy:[[JL_RunSDK sharedMe] mBleEntityM].mUUID Number:number Result:^(NSArray<DhaFittingSql *> * _Nonnull list) {
        if(list.count>0){
            self->dhaFitter =  list.firstObject;
            self->warningView.hidden = NO;
            [self->warningView dhaMessage:kJL_TXT("dha_record_continue") cancel:kJL_TXT("dha_restart") confirm:kJL_TXT("dha_continue") action:^(DhaAlertSelectType type) {
                if (type == DhaAlertSelectType_Cancel) {
                    [self deleteCache];
                }else{
                    FittingVC *vc = [[FittingVC alloc] init];
                    vc.dhaFitter = self->dhaFitter;
                    vc.isCache = YES;
                    [self.navigationController pushViewController:vc animated:true];
                }
                self->warningView.hidden = YES;
            }];
        }else{
            
        }
    }];
}

-(void)deleteCache{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[DhaSqlite share] remove:self->dhaFitter];
    });
}

//MARK: - 左右耳验配选择器
-(void)fitterDidSelect:(NSInteger)index{
    
    FittingVC *vc = [[FittingVC alloc] init];
    if (index == 0){
        vc.type = DHAEarTypeBoth;
    }
    if (index == 1){
        vc.type = DHAEarTypeLeft;
    }
    if (index == 2){
        vc.type = DHAEarTypeRight;
    }
    [self.navigationController pushViewController:vc animated:true];
    
}


-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)goBackToRoot{
    [self.navigationController popToRootViewControllerAnimated:true];
}

@end
