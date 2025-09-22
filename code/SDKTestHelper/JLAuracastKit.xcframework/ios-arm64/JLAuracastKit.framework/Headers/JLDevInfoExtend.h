//
//  JLDevInfoExtend.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/23.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 设备扩展信息
@interface JLDevInfoExtend : NSObject

/// 是否支持Auracast
@property (nonatomic, assign)BOOL isSupportAuracast;

/// 是否支持扫描Auracast
@property (nonatomic, assign)BOOL isSupportScanAuracast;

/// 是否支持设置发射器
@property (nonatomic, assign)BOOL isSupportAuracastSetAudioLauncher;

+ (JLDevInfoExtend *)beModel:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
