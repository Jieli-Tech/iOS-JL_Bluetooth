//
//  JLAV2CodeInfo.m
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/10.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

#import "JLAV2CodeInfo.h"

@implementation JLAV2CodeInfo

+(JLAV2CodeInfo *)defaultInfo {
    JLAV2CodeInfo *info = [[JLAV2CodeInfo alloc] init];
    info.sampleRate = 16000;
    info.bitRate = 16000;
    info.frameIdx = JLAV2CodeInfoFrameIdx160;
    info.channels = 1;
    info.isSupportBit24 = NO;
    return info;
}

@end
