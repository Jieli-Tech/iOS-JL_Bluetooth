//
//  Alert697xTools.h
//  newAPP
//
//  Created by EzioChan on 2020/5/30.
//  Copyright © 2020 Ezio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Alert697xTools : NSObject

/// 获取电量图标
/// @param power 电量  （-1的时候就充电中）
/// @return 图标
+(UIImage *)getPowerImg:(int)power;

@end

NS_ASSUME_NONNULL_END
