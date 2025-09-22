//
//  JLUI_Effect.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DFUnits/DFUnits.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLUI_Effect : NSObject
+(UIView*)addShadowOnView:(UIView*)aView;
+(UIView*)addShadowOnView_1:(UIView*)aView;
+(UIView*)addShadowOnView_2:(UIView*)aView;
+(UIView*)addShadowOnView_3:(UIView*)aView;
/// 渐变色Layer
/// @param start 开始颜色
/// @param endColor 结束颜色
/// @param frame layer的rect
+(CALayer*)setCAGradientLayer:(UIColor *)start to:(UIColor *)endColor withFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
