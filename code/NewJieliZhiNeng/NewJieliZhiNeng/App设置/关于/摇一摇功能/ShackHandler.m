//
//  ShackHandler.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2021/1/27.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "ShackHandler.h"
#import "JL_RunSDK.h"
#import "JLCacheBox.h"
#import "CorePlayer.h"
#import "NetworkPlayer.h"
#import "JLCacheBox.h"

@implementation ShackHandler

+(instancetype)sharedInstance{
    static ShackHandler *shacker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shacker = [[ShackHandler alloc] init];
    });
    return shacker;
}

-(void)shackerHandle{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    int v1 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SHACK_SONG"] intValue];
    int v2 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SHACK_LIGHT"] intValue];
    switch (deviceModel.currentFunc) {
        case JL_FunctionCodeBT:
            if (v1 == 1) {
                BOOL isEdr = [self isEdrOK];
                if (isEdr == NO) return;
                
                if(self.index == 9){
                    CorePlayer *cp = [CorePlayer shareInstanced];
                    if (cp.status == DFNetPlayer_STATUS_PLAY || cp.status == DFNetPlayer_STATUS_STOP
                        || cp.status == DFNetPlayer_STATUS_PENDING || cp.status == DFNetPlayer_STATUS_PAUSE){
                        NetworkPlayer *netPlayer = [NetworkPlayer sharedMe];
                        [netPlayer didNext];
                    }
                }else{
                    [DFNotice post:@"TOBE_NEXT_LOCAL_MUSIC" Object:nil];
                }
            }
            break;
        case JL_FunctionCodeMUSIC:
            if (v1 == 1) {
                [entity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                                        Command:JL_FCmdMusicNEXT
                                         Extend:0x00
                                         Result:nil];
            }
            break;
        case JL_FunctionCodeFM:{
            if (v1 == 1) {
                [DFNotice post:@"TOBE_NEXT_FM" Object:nil];
            }
        }break;
        case JL_FunctionCodeLIGHT:{
            if (v2 == 1) {
                
            }
        }break;
        default:
            break;
    }
}

-(BOOL)isEdrOK{
    /*--- 判断有无连经典蓝牙 ---*/
    NSDictionary *info = [JL_BLEMultiple outputEdrInfo];
    NSString *addr = info[@"ADDRESS"];
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    if (![addr isEqualToString:entity.mEdr]) {
        UIWindow *win = [DFUITools getWindow];
        [DFUITools showText:kJL_TXT("connect_match_edr") onView:win delay:1.0];
        return NO;
    }
    return YES;
}

@end
