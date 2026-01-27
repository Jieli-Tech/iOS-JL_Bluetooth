//
//  HQEditImageActionView.m
//  CivilAviation
//
//  Created by iOS on 2019/3/29.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "HQEditImageActionView.h"

@interface HQEditImageActionView ()

@property (nonatomic, strong) UIView *line;

@end

@implementation HQEditImageActionView

- (instancetype)init {
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor colorWithRed:19/255.0 green:19/255.0 blue:19/255.0 alpha:1.0];
        
        [self addSubview:self.cancelButton];
        [self addSubview:self.finishButton];
        
        [self addSubview:self.line];
        
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    

    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.width.equalTo(@50);
        make.height.equalTo(@49);
        make.centerY.equalTo(self);
    }];
    
    
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-20);
        make.width.equalTo(@50);
        make.height.equalTo(@49);
        make.centerY.equalTo(self);
    }];
    
}

#pragma mrak - event response
- (void)buttonAction:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(action:didClickButton:atIndex:)]) {
        [self.delegate action:self didClickButton:button atIndex:button.tag];
    }
}



- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        
        [_cancelButton setTitle:kJL_TXT("jl_cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _cancelButton.tag = 1;
        [_cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}



- (UIButton *)finishButton {
    if (!_finishButton) {
        _finishButton = [[UIButton alloc] init];
        
        [_finishButton setTitle:kJL_TXT("confirm_1") forState:UIControlStateNormal];
        [_finishButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _finishButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _finishButton.tag = 3;
        [_finishButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}



@end
