//
//  EQDrawView.h
//  newAPP
//
//  Created by EzioChan on 2020/6/3.
//  Copyright © 2020 Ezio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface EQDrawView : UIView

/// 传入eq
/// @param eqArray eq
-(void)setUpEqArray:(NSArray *)eqArray;

/// 传入要修改的某个值
/// @param eqArray EQ数组
/// @param number 增益
/// @param index 序号
-(void)setUpEqArray1:(NSArray *)eqArray withNum:(int) number withIndex:(int) index;


/// 传入要修改的某个值（自定义EQ数目）
/// @param cfArray 中心频率数组
/// @param eqArray EQ数组
/// @param number 增益
/// @param index 序号
-(void)setUpCenterFrequency:(NSArray * __nullable)cfArray EqArray:(NSArray *)eqArray withNum:(int) number withIndex:(int) index;


/// 传入EQ整个数组
/// @param eqArray eq
/// @param mode 类型
-(void)setUpEqArrayAll:(NSArray *)eqArray withType:(JL_EQMode)mode;

/// 传入EQ整个数组（自定义EQ数目）
/// @param eqArray eq
/// @param cfArray center frequency
/// @param mode 类型
-(void)setUpEqArrayAll:(NSArray *)eqArray centerFrequency:(NSArray  * _Nullable )cfArray withType:(JL_EQMode)mode;


@end

NS_ASSUME_NONNULL_END
