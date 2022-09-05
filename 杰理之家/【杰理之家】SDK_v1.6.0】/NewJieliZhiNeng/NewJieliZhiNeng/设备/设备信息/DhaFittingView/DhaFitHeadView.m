//
//  DhaFitHeadView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/30.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DhaFitHeadView.h"


@interface DhaFitHeadView(){
    UIImageView *imgView;
    UILabel *mainLab;
    UILabel *secondLab;
    UIImageView *rightView;
}
@end

@implementation DhaFitHeadView



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        imgView = [UIImageView new];
        [self addSubview:imgView];
        imgView.image = [UIImage imageNamed:@"Theme.bundle/img_01_2"];
        
        mainLab = [[UILabel alloc] init];
        mainLab.text = kJL_TXT("go_for_fitting");
        mainLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        mainLab.textColor = [UIColor darkTextColor];
        [self addSubview:mainLab];
        
        secondLab = [[UILabel alloc] init];
        secondLab.text = kJL_TXT("detect_hearing_impairment");
        secondLab.textColor = [UIColor colorFromHexString:@"#ABABAB"];
        secondLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
        [self addSubview:secondLab];
        
        rightView = [[UIImageView alloc] init];
        rightView.image = [UIImage imageNamed:@"Theme.bundle/icon_next"];
        [self addSubview:rightView];
        
    
        [self stepUI];
    }
    return self;
}

-(void)stepUI{
   
    UIView *superview = self;
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top).offset(21);
        make.left.equalTo(superview.mas_left).offset(12);
        make.bottom.equalTo(superview.mas_bottom).offset(-12);
        make.right.equalTo(mainLab.mas_left).offset(-18);
        make.width.offset(70);
    }];
    
    [mainLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top).offset(37);
        make.left.equalTo(imgView.mas_right).offset(18);
        make.bottom.equalTo(secondLab.mas_top).offset(-5);
        make.right.equalTo(rightView.mas_left).offset(-10);
        
    }];
    
    [secondLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainLab.mas_bottom).offset(5);
        make.left.equalTo(imgView.mas_right).offset(18);
        make.right.equalTo(rightView.mas_left).offset(-10);
        make.bottom.equalTo(superview.mas_bottom).offset(-37);
    }];

    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.equalTo(mainLab.mas_right).offset(10);
        make.right.equalTo(superview.mas_right).offset(-25);
        make.height.offset(15);
        make.width.offset(15);
    }];
    
}






@end
