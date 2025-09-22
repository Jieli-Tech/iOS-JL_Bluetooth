//
//  BasicViewController.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/9/5.
//  Copyright © 2023 杰理科技. All rights reserved.
//

#import "BasicViewController.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface BasicViewController (){
    CTCallCenter *callCenter;
}

@end

@implementation BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorFromHexString:@"#FFFFFF"];
    UIImage *image = [[UIImage imageNamed:@"Theme.bundle/icon_return.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(backBtnAction)];
    leftBtn.tintColor = [UIColor grayColor];
    [self.navigationItem setLeftBarButtonItem:leftBtn];
    
    _naviView = [[NavTopView alloc] init];
    
    [_naviView.existBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_naviView];
    
    [_naviView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@kJL_HeightNavBar);
    }];
    
    [self handOnCall];
    
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    [self initData];
    [self initUI];
    
    [JL_Tools add:kJL_BLE_M_ENTITY_DISCONNECTED Action:@selector(handleDisconnect) Own:self];
}

-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)initUI{
    
}

-(void)initData{
    
}

-(void)goBackToRoot{
    
}

-(void)handleDisconnect{
    [self.navigationController popToRootViewControllerAnimated:true];
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

@end
