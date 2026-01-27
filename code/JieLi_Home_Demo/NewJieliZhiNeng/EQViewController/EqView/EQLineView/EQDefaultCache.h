//
//  EQDefaultCache.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/5.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface EQDefaultCache : NSObject

+(instancetype)sharedInstance;
-(void)normalSetting;

/// 获取缓存中的数值
/// @param mode 类型
/// @return array 数组
-(NSArray *)getPointArray:(JL_EQMode )mode;

/// 设置eq值
/// @param eqArray eq值
/// @param mode 类型
-(void)saveEq:(NSArray *)eqArray withName:(JL_EQMode )mode;


/// 设置自定义EQ保存
/// @param eq EQ数组
/// @param mode 类型
-(void)saveCustom:(NSArray *)eq mode:(JL_EQMode)mode;

/// 设置eq值
/// @param eqArray eq值
/// @param cfArray center frequency
/// @param mode 类型
-(void)saveEq:(NSArray *)eqArray centerFrequency:(NSArray *)cfArray withName:(JL_EQMode )mode;

/// 设置自定义EQ保存
/// @param eq EQ数组
/// @param cfArray center frequency
/// @param mode 类型
-(void)saveCustom:(NSArray *)eq centerFrequency:(NSArray *)cfArray mode:(JL_EQMode)mode;

@end

NS_ASSUME_NONNULL_END
