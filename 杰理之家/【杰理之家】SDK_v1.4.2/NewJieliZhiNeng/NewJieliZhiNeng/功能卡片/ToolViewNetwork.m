//
//  ToolViewNetwork.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/9.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "ToolViewNetwork.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "NetworkPlayer.h"

@interface ToolViewNetwork(){
    __weak IBOutlet UIView *subView;
    __weak IBOutlet UIButton *subBtnPP;
    __weak IBOutlet UILabel *subLabel;
}

@end

@implementation ToolViewNetwork

- (instancetype)init
{
    self = [DFUITools loadNib:@"ToolViewNetwork"];
    if (self) {
        float sW = [DFUITools screen_2_W];
        self.frame = CGRectMake(0, kJL_HeightStatusBar+44, sW, 200);
        [JLUI_Effect addShadowOnView:subView];
        
        [JL_Tools add:kNETWORK_PLAYER_STATUS
               Action:@selector(noteNetworkPlayerStatus:) Own:self];
        [JLModel_Device observeModelProperty:@"currentFunc" Action:@selector(noteCurrentFunction:) Own:self];
        
        UITapGestureRecognizer *noPairViewtapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subLabelClick)];
        [subLabel addGestureRecognizer:noPairViewtapGestureRecognizer];
        subLabel.userInteractionEnabled = YES;
    }
    return self;
}

-(void)noteNetworkPlayerStatus:(NSNotification*)note{
    NetworkPlayer *netPlayer = [NetworkPlayer sharedMe];
    NSDictionary *playInfo = netPlayer.mNowInfo;
    if (playInfo) {
        NSString *name= playInfo[@"name"];
        subLabel.text = name;
    }else{
        subLabel.text = @"未知曲目";
    }

//    DFNetPlayer_STATUS st = netPlayer.mNetPlayer.status;
    DFNetPlayer_STATUS st = [[CorePlayer shareInstanced] status];
    if (st == DFNetPlayer_STATUS_PLAY) {
        [subBtnPP setImage:[UIImage imageNamed:@"Theme.bundle/mul_icon_pause_03"] forState:UIControlStateNormal];
    }else{
        [subBtnPP setImage:[UIImage imageNamed:@"Theme.bundle/mul_icon_play_03"] forState:UIControlStateNormal];
    }
}
- (IBAction)btn_before:(id)sender {
    NetworkPlayer *netPlayer = [NetworkPlayer sharedMe];
    [netPlayer didBefore];
}

- (IBAction)btn_pp:(id)sender {
    NetworkPlayer *netPlayer = [NetworkPlayer sharedMe];
//    DFNetPlayer_STATUS st = netPlayer.mNetPlayer.status;
    DFNetPlayer_STATUS st = [[CorePlayer shareInstanced] status];
    if (st == DFNetPlayer_STATUS_PLAY) {
        [netPlayer didPause];
    }else{
        [netPlayer didContinue];
    }
}
- (IBAction)btn_next:(id)sender {
    NetworkPlayer *netPlayer = [NetworkPlayer sharedMe];
    [netPlayer didNext];
}

-(void)noteCurrentFunction:(NSNotification *)note{
    NetworkPlayer *netPlayer = [NetworkPlayer sharedMe];
    NSDictionary *dict = [note object];
    if ([dict[kJL_MANAGER_KEY_OBJECT] intValue] != 0) {
        [netPlayer didStop];
    }
}

-(void)subLabelClick{
    if ([_delegate respondsToSelector:@selector(enterNetVC)]) {
         [_delegate enterNetVC];
     }
}

@end
