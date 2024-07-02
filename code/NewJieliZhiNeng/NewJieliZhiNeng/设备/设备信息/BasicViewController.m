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
    [self handOnCall];
    
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
}

-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:true];
}



-(void)goBackToRoot{
    
}


-(void)handOnCall{
    callCenter = [[CTCallCenter alloc] init];
    __weak typeof (self) weakSelf = self;
    callCenter.callEventHandler = ^(CTCall *call) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([call.callState isEqualToString:CTCallStateDisconnected]) {
                NSLog(@"CTCallCenter:Call has been disconnected");
            } else if ([call.callState isEqualToString:CTCallStateConnected]) {
                NSLog(@"CTCallCenter:Callhasjustbeen connected");
            } else if ([call.callState isEqualToString:CTCallStateIncoming]) {
                NSLog(@"CTCallCenter:Call is incoming");
                [weakSelf goBackToRoot];
            } else if ([call.callState isEqualToString:CTCallStateDialing]) {
                NSLog(@"CTCallCenter:Call is Dialing");
                [weakSelf goBackToRoot];
            } else {
                NSLog(@"CTCallCenter:Nothing is done");
            }
        });
    };
}

@end
