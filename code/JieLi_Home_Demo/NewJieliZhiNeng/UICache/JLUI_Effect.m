//
//  JLUI_Effect.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "JLUI_Effect.h"

@implementation JLUI_Effect

+(UIView*)addShadowOnView:(UIView*)aView{
    aView.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    aView.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.4).CGColor;
    aView.layer.shadowOffset = CGSizeMake(0,1);
    aView.layer.shadowOpacity = 1;
    aView.layer.shadowRadius = 10;
    aView.layer.cornerRadius = 13;
    return aView;
}

+(UIView*)addShadowOnView_1:(UIView*)aView{
    aView.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    aView.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.2).CGColor;
    aView.layer.shadowOffset = CGSizeMake(0,1);
    aView.layer.shadowOpacity = 1;
    aView.layer.shadowRadius = 8;
    aView.layer.cornerRadius = 6.5;
    return aView;
}
+(UIView*)addShadowOnView_2:(UIView*)aView{
    aView.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    aView.layer.shadowColor = kDF_RGBA(0, 38, 68, 0.17).CGColor;
    aView.layer.shadowOffset = CGSizeMake(0,0);
    aView.layer.shadowOpacity = 1;
    aView.layer.shadowRadius = 5;
    aView.layer.cornerRadius = 13;
    return aView;
}

+(UIView*)addShadowOnView_3:(UIView*)aView{
    aView.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    aView.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.2).CGColor;
    aView.layer.shadowOffset = CGSizeMake(0,0);
    aView.layer.shadowOpacity = 1;
    aView.layer.shadowRadius = 12;
    aView.layer.borderWidth = 0.5;
    aView.layer.borderColor =kDF_RGBA(243.0, 243, 243, 1).CGColor;
    aView.layer.cornerRadius = 10;
    return aView;
}

+(CALayer*)setCAGradientLayer:(UIColor *)start to:(UIColor *)endColor withFrame:(CGRect)frame{
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = frame;
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    gl.colors = @[(__bridge id)start.CGColor,(__bridge id)endColor.CGColor];
    gl.locations = @[@(0.0),@(1.0)];
    gl.cornerRadius = frame.size.width/8.0;
    return gl;
}

@end
