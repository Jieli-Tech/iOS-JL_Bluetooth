//
//  RTCAlertView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/25.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "RTCAlertView.h"
#import "JL_RunSDK.h"

@implementation RTCAlertView

- (instancetype)init
{
    self = [super init];
    self = [[NSBundle mainBundle] loadNibNamed:@"RTCAlertView" owner:nil options:nil].firstObject;
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.msgLab.text = kJL_TXT("闹钟正在响铃");
        self.titleLab.text = kJL_TXT("tips_0");
        [self.stopBtn setTitle:kJL_TXT("停止") forState:UIControlStateNormal];
        self.centerView.layer.cornerRadius = 8;
        self.centerView.layer.masksToBounds = YES;
    }
    return self;
}


- (IBAction)stopBtnAction:(id)sender {
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager.mAlarmClockManager cmdRtcStopResult:nil];
    [self removeFromSuperview];
    if (self.ablock) {
        self.ablock(YES);
    }
}



@end
