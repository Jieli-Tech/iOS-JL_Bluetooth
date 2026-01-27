//
//  AppStatusManager.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/8/1.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AppStatusManager.h"

@implementation AppStatusManager

+(instancetype)shareInstance{
    static AppStatusManager *mgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[AppStatusManager alloc] init];
    });
    return mgr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isOTAIng = NO;
    }
    return self;
}

//MARK: - 是否支持Auracast
- (BOOL)isSupportAuracast {
    NSString *uuid = [[JL_RunSDK sharedMe] mBleUUID];
    if (uuid == nil) {
        return false;
    }
    JLDeviceConfigTws *twsConfig = [[JLDeviceConfig share] deviceGetTwsConfigWithUUID:uuid];
    if (twsConfig.isSupportAuracast) {
        return twsConfig.isSupportAuracast;
    }
    JLDeviceConfigSoundBox *soundBoxConfig = [[JLDeviceConfig share] deviceGetSoundBoxConfigWithUUID:uuid];
    if (soundBoxConfig.isSupportAuracast ) {
        return soundBoxConfig.isSupportAuracast;
    }
    JLDeviceConfigDongle *dongleConfig = [[JLDeviceConfig share] deviceGetAuracastConfigWithUUID:uuid];
    if (dongleConfig.isSupportAuracast) {
        return dongleConfig.isSupportAuracast;
    }
    return false;
}

- (BOOL)isAuracastReceiver {
    NSString *uuid = [[JL_RunSDK sharedMe] mBleUUID];
    if (uuid == nil) {
        return false;
    }
    JLDeviceConfigTws *twsConfig = [[JLDeviceConfig share] deviceGetTwsConfigWithUUID:uuid];
    if (twsConfig.isSupportReceiveAuracast) {
        return twsConfig.isSupportReceiveAuracast;
    }
    JLDeviceConfigSoundBox *soundBoxConfig = [[JLDeviceConfig share] deviceGetSoundBoxConfigWithUUID:uuid];
    if (soundBoxConfig.isSupportReceiveAuracast) {
        return soundBoxConfig.isSupportReceiveAuracast;
    }
    
    JLDeviceConfigDongle *dongleConfig = [[JLDeviceConfig share] deviceGetAuracastConfigWithUUID:uuid];
    if (dongleConfig.isSupportReceiveAuracast) {
        return dongleConfig.isSupportReceiveAuracast;
    }
    return false;
}

- (BOOL)isAuracastLancer {
    NSString *uuid = [[JL_RunSDK sharedMe] mBleUUID];
    if (uuid == nil) {
        return false;
    }
    JLDeviceConfigTws *twsConfig = [[JLDeviceConfig share] deviceGetTwsConfigWithUUID:uuid];
    if (twsConfig.isSupportLancerAuracast) {
        return twsConfig.isSupportLancerAuracast;
    }
    JLDeviceConfigSoundBox *soundBoxConfig = [[JLDeviceConfig share] deviceGetSoundBoxConfigWithUUID:uuid];
    if (soundBoxConfig.isSupportLancerAuracast) {
        return soundBoxConfig.isSupportLancerAuracast;
    }
    JLDeviceConfigDongle *dongleConfig = [[JLDeviceConfig share] deviceGetAuracastConfigWithUUID:uuid];
    if (dongleConfig.isSupportLancerAuracast) {
        return dongleConfig.isSupportLancerAuracast;
    }
    return false;
}


@end
