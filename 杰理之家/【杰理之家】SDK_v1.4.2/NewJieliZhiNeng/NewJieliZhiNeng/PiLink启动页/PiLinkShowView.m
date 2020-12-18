//
//  PiLinkShowView.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/8/11.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "PiLinkShowView.h"

@implementation PiLinkShowView{
    UIImageView *bgView; //背景图片
    UIImageView *contentView; //内容图片
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 1.0;
        self.backgroundColor = [UIColor clearColor];
                
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(0,0,[DFUITools screen_2_W], [DFUITools screen_2_H]);
        gl.startPoint = CGPointMake(0, 0);
        gl.endPoint = CGPointMake(1, 1);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:96/255.0 green:167/255.0 blue:240/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:60/255.0 green:93/255.0 blue:203/255.0 alpha:1.0].CGColor];
        gl.locations = @[@(0.0),@(1.0)];
        [self.layer addSublayer:gl];
        
        contentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, [DFUITools screen_2_H]-250, [DFUITools screen_2_W],187)];
        contentView.image = [UIImage imageNamed:@"Theme.bundle/login_bg_01"];
        contentView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:contentView];
        
        bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [DFUITools screen_2_W], [DFUITools screen_2_H]-150)];
        bgView.image = [UIImage imageNamed:@"Theme.bundle/login_bg_02"];
        bgView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:bgView];
        
        

        [self actionAnimationDuration:1.5];
    }
    return self;
}

-(void)actionAnimationDuration:(float)duration{
    [DFAction delay:duration+1.0 Task:^{
        [UIView animateWithDuration:1.0 animations:^{
            self.alpha = 0.0;
        }];
    }];
    [DFAction delay:duration+2.0 Task:^{
        [self removeFromSuperview];
    }];
}

@end
