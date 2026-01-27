//
//  RTCAlertSingle.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/27.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "RTCAlertSingle.h"
#import "JL_RunSDK.h"
#import "RTCAlertView.h"

@interface RTCAlertSingle (){
    RTCAlertView *alert;
}
@end

@implementation RTCAlertSingle

+(instancetype)sharedInstance{
    static RTCAlertSingle *me;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        me = [[RTCAlertSingle alloc] init];
    });
    return me;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [JL_Tools add:kJL_MANAGER_RTC_RINGING Action:@selector(alarmRingingNote:) Own:self];
        [JL_Tools add:kJL_MANAGER_RTC_RINGSTOP Action:@selector(alarmRingStopNote:) Own:self];
    }
    return self;
}

-(void)alarmRingingNote:(NSNotification *)note{
    if (!alert) {
        alert = [[RTCAlertView alloc] init];
        [[[UIApplication sharedApplication] keyWindow] addSubview:alert];
        alert.ablock = ^(BOOL status) {
            self->alert = nil;
        };
    }
}

-(void)alarmRingStopNote:(NSNotification *)note{
    if (alert) {
        [alert removeFromSuperview];
        alert = nil;
    }
}

@end
