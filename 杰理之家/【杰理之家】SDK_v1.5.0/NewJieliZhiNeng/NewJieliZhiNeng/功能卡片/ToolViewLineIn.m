//
//  ToolViewLineIn.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/6/30.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "ToolViewLineIn.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"

@interface ToolViewLineIn (){
    
    __weak IBOutlet UIButton *btnVoice;
    __weak IBOutlet UIView *subView;
    NSUInteger volume_cur;
}

@end

@implementation ToolViewLineIn

- (instancetype)init
{
    self = [DFUITools loadNib:@"ToolViewLineIn"];
    if (self) {
        float sW = [DFUITools screen_2_W];

        self.frame = CGRectMake(0, kJL_HeightStatusBar+44, sW, 200);
        [JLUI_Effect addShadowOnView:subView];

        [self addNote];
    }
    return self;
}

- (IBAction)btn_voice:(id)sender {
//    JLDeviceModel *md = [JL_Manager outputDeviceModel];
//    NSUInteger vol = md.currentVol;
//    if (vol >0) {
//        [btnVoice setImage:[UIImage imageNamed:@"mul_icon_voice"] forState:UIControlStateNormal];
//        [JL_Manager cmdSetSystemVolume:0];
//    }else{
//        [btnVoice setImage:[UIImage imageNamed:@"mul_icon_mute"] forState:UIControlStateNormal];
//        [JL_Manager cmdSetSystemVolume:volume_cur];
//    }
    [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager cmdFunction:JL_FunctionCodeLINEIN Command:JL_FCmdLineInPP Extend:0 Result:nil];
}

-(void)noteLineInStatus:(NSNotification*)note{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *md = [entity.mCmdManager outputDeviceModel];
    if(md.currentFunc == JL_FunctionCodeLINEIN){
        if (md.lineInStatus == JL_LineInStatusPause) {
            [btnVoice setImage:[UIImage imageNamed:@"Theme.bundle/mul_icon_mute"] forState:UIControlStateNormal];
        }else{
            volume_cur = md.currentVol;
            [btnVoice setImage:[UIImage imageNamed:@"Theme.bundle/mul_icon_voice"] forState:UIControlStateNormal];
        }
    }
}

-(void)noteSystemInfo:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    [self noteLineInStatus:nil];
}

-(void)addNote{
    [JL_Tools add:kUI_JL_LINEIN_INFO Action:@selector(noteLineInStatus:) Own:self];
    [JL_Tools add:kJL_MANAGER_SYSTEM_INFO Action:@selector(noteSystemInfo:) Own:self];
}



@end
