//
//  FindPhoneView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/23.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "FindPhoneView.h"
#import "JL_RunSDK.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface FindPhoneView(){
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet UIButton *closeBtn;
    __weak IBOutlet UILabel *titleLab;
    NSTimer *voiceTimer;
}
@property (nonatomic, strong) CTCallCenter *callCenter;
@end

@implementation FindPhoneView

- (instancetype)init
{
    self = [DFUITools loadNib:@"FindPhoneView"];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        centerView.layer.cornerRadius = 10;
        centerView.layer.masksToBounds = YES;
        [JL_Tools add:AVAudioSessionInterruptionNotification Action:@selector(noteInterruption:) Own:self];
        
//        _callCenter = [[CTCallCenter alloc] init];
//        _callCenter.callEventHandler = ^(CTCall * call) {
//            if (self.isHidden == NO) {
//                self.hidden = YES;
//                [JL_Manager cmdFindDevice:NO timeOut:10 findIphone:YES];
//                [self removeFromSuperview];
//            }
//            
//        };
        [JL_Tools add:kJL_BT_FIND_PHONE Action:@selector(recivedVoiceNote:) Own:self];
    }
    return self;
}
-(void)setTitleStr:(NSString *)titleStr{
    titleLab.text = titleStr;
    _titleStr = titleStr;
}

- (IBAction)closeBtnAction:(id)sender {
    self.hidden = YES;
    [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager cmdFindDevice:NO timeOut:10 findIphone:YES Operation:nil];
    [self removeFromSuperview];
    [voiceTimer invalidate];
    voiceTimer = nil;
}


-(void)startVoice{
    [voiceTimer invalidate];
    voiceTimer = nil;
    voiceTimer = [NSTimer scheduledTimerWithTimeInterval:1.8 target:self selector:@selector(beginVoice) userInfo:nil repeats:YES];
    [voiceTimer fire];
}



-(void)beginVoice{
    AudioServicesPlaySystemSoundWithCompletion(1304, nil);
}


-(void)noteInterruption:(NSNotification*)note{
    self.hidden = YES;
    [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager cmdFindDevice:NO timeOut:10 findIphone:YES Operation:nil];
    [self removeFromSuperview];
    [voiceTimer invalidate];
    voiceTimer = nil;
}

-(void)recivedVoiceNote:(NSNotification*)note{
    NSDictionary *dict = [note object];
    NSDictionary *dict1 = dict[kJL_MANAGER_KEY_OBJECT];
     if ([dict1[@"op"] intValue] != 1) {
        self.hidden = YES;
        [self removeFromSuperview];
        [voiceTimer invalidate];
        voiceTimer = nil;
    }
}

@end
