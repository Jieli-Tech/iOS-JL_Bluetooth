//
//  AppStatusManager.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/8/1.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppStatusManager : NSObject

/// APP正在OTA升级
@property(nonatomic,assign)BOOL isOTAIng;

+(instancetype)shareInstance;
@end

NS_ASSUME_NONNULL_END
