//
//  SegmengCtrlView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/30.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "SegmengCtrlView.h"

@interface SegmengCtrlView(){
    UIView *centerBgView;
    UIView *swapBgView;
    UIButton *leftBtn;
    UIButton *rightBtn;
    int stepNumber;
   
}


@end

@implementation SegmengCtrlView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        centerBgView = [UIView new];
        [self addSubview:centerBgView];
        centerBgView.backgroundColor = [UIColor colorFromHexString:@"#EDF0F5"];
        centerBgView.layer.cornerRadius = 19;
        centerBgView.layer.masksToBounds = YES;
        
        swapBgView = [UIView new];
        swapBgView.backgroundColor = [UIColor whiteColor];
        swapBgView.layer.cornerRadius = 16;
        swapBgView.layer.masksToBounds = YES;
        [self addSubview:swapBgView];
        
        leftBtn = [UIButton new];
        [self addSubview:leftBtn];
        leftBtn.backgroundColor = [UIColor clearColor];
        [leftBtn setTitle:kJL_TXT("Left_ear") forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setTitleColor:[UIColor colorFromHexString:@"#242424"] forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        rightBtn = [UIButton new];
        [self addSubview:rightBtn];
        rightBtn.backgroundColor = [UIColor clearColor];
        rightBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [rightBtn setTitle:kJL_TXT("Right_ear") forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitleColor:[UIColor colorFromHexString:@"#808080"] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        [self stepUI];
        
    }
    return self;
}


-(void)stepUI{
    [centerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.left.equalTo(self.mas_left).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(0);
    }];
    
    
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(3);
        make.left.equalTo(self.mas_left).offset(3);
        make.right.equalTo(rightBtn.mas_left).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(-3);
        make.width.equalTo(rightBtn.mas_width);
    }];
    
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(3);
        make.left.equalTo(rightBtn.mas_right).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(-3);
        make.width.equalTo(leftBtn.mas_width);
    }];
    [swapBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(3);
        make.left.equalTo(self.mas_left).offset(3);
        make.bottom.equalTo(self.mas_bottom).offset(-3);
        make.width.equalTo(rightBtn.mas_width).offset(-6);
    }];
    [leftBtn setTitleColor:[UIColor colorFromHexString:@"#242424"] forState:UIControlStateNormal];
}


-(void)leftBtnAction{
   
    [leftBtn setTitleColor:[UIColor colorFromHexString:@"#242424"] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor colorFromHexString:@"#808080"] forState:UIControlStateNormal];
    [swapBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(3);
        make.left.equalTo(self.mas_left).offset(3);
        make.bottom.equalTo(self.mas_bottom).offset(-3);
        make.width.offset(self.frame.size.width/2-6);
    }];
    
    if ([_delegate respondsToSelector:@selector(segmengDidTouchBtn:)]) {
        [_delegate segmengDidTouchBtn:0];
    }
   
}
-(void)rightBtnAction{
    
    [rightBtn setTitleColor:[UIColor colorFromHexString:@"#242424"] forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor colorFromHexString:@"#808080"] forState:UIControlStateNormal];
    [swapBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top).offset(3);
        make.right.equalTo(self.mas_right).offset(-3);
        make.bottom.equalTo(self.mas_bottom).offset(-3);
        
        make.width.offset(self.frame.size.width/2-6);
    }];
    
    if ([_delegate respondsToSelector:@selector(segmengDidTouchBtn:)]) {
        [_delegate segmengDidTouchBtn:1];
    }
    
}

-(void)setBtnTo:(NSInteger)index{
    if (index == 0) {
        [leftBtn setTitleColor:[UIColor colorFromHexString:@"#242424"] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorFromHexString:@"#808080"] forState:UIControlStateNormal];
        [swapBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(3);
            make.left.equalTo(self.mas_left).offset(3);
            make.bottom.equalTo(self.mas_bottom).offset(-3);
            make.width.offset(self.frame.size.width/2-6);
        }];
    }else{
        [rightBtn setTitleColor:[UIColor colorFromHexString:@"#242424"] forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor colorFromHexString:@"#808080"] forState:UIControlStateNormal];
        [swapBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.mas_top).offset(3);
            make.right.equalTo(self.mas_right).offset(-3);
            make.bottom.equalTo(self.mas_bottom).offset(-3);
            
            make.width.offset(self.frame.size.width/2-6);
        }];
    }
}



@end
