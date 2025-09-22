//
//  NavTopView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2024/4/29.
//  Copyright © 2024 杰理科技. All rights reserved.
//

#import "NavTopView.h"

@implementation NavTopView

-(instancetype)init{
    self = [super init];
    if(self){
        [self initUI];
    }
    return self;
}

-(void)initUI{
    self.backgroundColor = [UIColor whiteColor];
    _titleLab = [[UILabel alloc] init];
    _existBtn = [[UIButton alloc] init];
    _rightView = [[UIView alloc] init];
    _titleLab.textColor = kDF_RGBA(36, 36, 36, 1);
    _titleLab.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.adjustsFontSizeToFitWidth = YES;
    
    [_existBtn setTitleColor:[UIColor colorFromHexString:@"#242424"] forState:UIControlStateNormal];
    _existBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_existBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_return"] forState:UIControlStateNormal];
    
    [self addSubview:_titleLab];
    [self addSubview:_existBtn];
    [self addSubview:_rightView];
    
    [_existBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(6);
        make.bottom.equalTo(self).offset(-6);
        make.width.equalTo(@44);
        make.height.equalTo(@35);
    }];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(_existBtn);
    }];
    
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).inset(10);
        make.centerY.equalTo(_existBtn);
        make.height.equalTo(@35);
    }];
}



@end
