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


@end
