//
//  OpenShowView.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/29.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "OpenShowView.h"
#import "JL_RunSDK.h"

@interface OpenShowView(){
    
    __weak IBOutlet UILabel *mLabel;
    __weak IBOutlet UIImageView *mImageView;
}

@end


@implementation OpenShowView

- (instancetype)init
{
    self = [DFUITools loadNib:@"OpenShowView"];
    if (self) {
        float sW = [DFUITools screen_1_W];
        float sH = [DFUITools screen_2_H];
        self.frame = CGRectMake(0, 0, sW, sH);

        
        mLabel.text = kJL_TXT("杰 理 之 家");
        mLabel.transform = CGAffineTransformMakeScale(0, 0);
        mLabel.alpha = 0.0;

        mImageView.bounds = CGRectMake(0, 0, 120, 120);
        mImageView.center = CGPointMake(sW/2.0, sH/2.0-15-30-60.0);
        mImageView.transform = CGAffineTransformMakeScale(0, 0);
        mImageView.alpha = 0.0;
        self.alpha = 1.0;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

static OpenShowView *openView = nil;

-(void)actionAnimationDuration:(float)duration{

    [UIView animateWithDuration:duration animations:^{
        self->mImageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self->mLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self->mImageView.alpha = 1.0;
        self->mLabel.alpha = 1.0;
    }];
    [DFAction delay:duration+1.0 Task:^{
        [UIView animateWithDuration:1.0 animations:^{
            self.alpha = 0.0;
        }];
    }];
    [DFAction delay:duration+2.0 Task:^{
        [self removeFromSuperview];
        openView = nil;
    }];
}

+(void)startOpenAnimation{
    UIWindow *win = [DFUITools getWindow];
    openView = [[OpenShowView alloc] init];
    [win addSubview:openView];
    [openView actionAnimationDuration:1.5];
}






@end
