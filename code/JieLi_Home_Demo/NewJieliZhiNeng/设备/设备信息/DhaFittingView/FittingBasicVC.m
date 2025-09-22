//
//  FittingBasicVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/26.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "FittingBasicVC.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface FittingBasicVC (){
    CTCallCenter *callCenter;
    JLModel_Device *devModel;
}

@end

@implementation FittingBasicVC

static void *dhaFitSwitchContext = &dhaFitSwitchContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _naviView = [[NavTopView alloc] init];
    _naviView.titleLab.text = @"DHA";
    [_naviView.existBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_naviView];
    
    [_naviView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@kJL_HeightNavBar);
    }];
    
    [self handOnCall];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    devModel = [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager getDeviceModel];
    [devModel addObserver:self forKeyPath:@"dhaFitSwitch" options:NSKeyValueObservingOptionNew context:dhaFitSwitchContext];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [devModel removeObserver:self forKeyPath:@"dhaFitSwitch" context:dhaFitSwitchContext];
}

-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)test{
    DhaFittingSwitch *sw = [DhaFittingSwitch new];
    sw.leftOn = NO;
    sw.rightOn = NO;
    devModel.dhaFitSwitch = sw;
}


-(void)handOnCall{
    callCenter = [[CTCallCenter alloc] init];
    __weak typeof (self) weakSelf = self;
    callCenter.callEventHandler = ^(CTCall *call) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([call.callState isEqualToString:CTCallStateDisconnected]) {
                kJLLog(JLLOG_DEBUG,@"CTCallCenter:Call has been disconnected");
            } else if ([call.callState isEqualToString:CTCallStateConnected]) {
                kJLLog(JLLOG_DEBUG,@"CTCallCenter:Callhasjustbeen connected");
            } else if ([call.callState isEqualToString:CTCallStateIncoming]) {
                kJLLog(JLLOG_DEBUG,@"CTCallCenter:Call is incoming");
                [weakSelf goBackToRoot];
            } else if ([call.callState isEqualToString:CTCallStateDialing]) {
                kJLLog(JLLOG_DEBUG,@"CTCallCenter:Call is Dialing");
                [weakSelf goBackToRoot];
            } else {
                kJLLog(JLLOG_DEBUG,@"CTCallCenter:Nothing is done");
            }
        });
    };
}

-(void)goBackToRoot{
    
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (context == dhaFitSwitchContext) {
        if ([change objectForKey:@"new"]) {
            
            JL_ManagerM *manager = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
            TwsElectricity *electricity = manager.mTwsManager.electricity;
            DhaFittingSwitch *sw = [change objectForKey:@"new"];
            if (electricity.powerLeft > 0 && electricity.powerRight>0) {
                //双耳
                if (sw.rightOn == NO || sw.leftOn == NO) {
                    [self goBackToRoot];
                }
            }
            if (electricity.powerLeft == 0 && electricity.powerRight>0) {
                //右耳
                if (sw.rightOn == NO) {
                    [self goBackToRoot];
                }
               
            }
            if (electricity.powerRight == 0 && electricity.powerLeft>0) {
                //左耳
                if (sw.leftOn == NO) {
                    [self goBackToRoot];
                }
            }
            
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
