//
//  StepTipsView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/30.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "StepTipsView.h"

@implementation StepTipsView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.stepLab = [[UILabel alloc] init];
        self.stepLab.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:0.09];
        self.stepLab.textColor = [UIColor colorFromHexString:@"#805BEB"];
        self.stepLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
        self.stepLab.textAlignment = NSTextAlignmentCenter;
        self.stepLab.layer.cornerRadius = 14;
        self.stepLab.layer.masksToBounds = true;
        [self addSubview:self.stepLab];
        
        self.detailLab = [[UILabel alloc] init];
        self.detailLab.font = FontMedium(13);
        self.detailLab.textColor = [UIColor colorFromHexString:@"#505050"];
        self.detailLab.numberOfLines = 0;
        self.detailLab.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.detailLab];
        
        [self.stepLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(6);
            make.left.equalTo(self.mas_left).offset(6);
            make.height.offset(28);
            make.width.offset(28);
        }];
        [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(6);
            make.left.equalTo(self.stepLab.mas_right).offset(12);
            make.right.equalTo(self.mas_right).offset(-6);
            make.bottom.equalTo(self.mas_bottom).offset(-6);
        }];
        
    }
    return self;
}



@end
