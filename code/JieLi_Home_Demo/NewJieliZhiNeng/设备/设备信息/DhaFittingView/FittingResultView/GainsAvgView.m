//
//  GainsAvgView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/1.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "GainsAvgView.h"
#import "JLUI_Effect.h"
#import <TYCoreText/TYCoreText.h>

@interface GainsAvgView(){
    UILabel *leftLab;
    TYAttributedLabel *leftDbLab;
    UILabel *rightLab;
    TYAttributedLabel *rightDbLab;
    UIImageView *lineView;
    UIView *centerView;
}
@end

@implementation GainsAvgView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self stepUI];
    }
    return self;
}

-(void)stepUI{
    
    centerView = [UIView new];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:centerView];
    [JLUI_Effect addShadowOnView:centerView];
    centerView.layer.masksToBounds = YES;
    
    leftLab = [UILabel new];
    [centerView addSubview:leftLab];
    leftLab.text = kJL_TXT("Left_auditory_threshold_mean");
    leftLab.font = FontMedium(14);
    leftLab.adjustsFontSizeToFitWidth = YES;
    leftLab.textColor = [UIColor colorFromHexString:@"#242424"];
    leftLab.textAlignment = NSTextAlignmentCenter;
    
    
    rightLab = [UILabel new];
    [centerView addSubview:rightLab];
    rightLab.text = kJL_TXT("Right_ear_threshold_mean");
    rightLab.font = FontMedium(14);
    rightLab.adjustsFontSizeToFitWidth = YES;
    rightLab.textColor = [UIColor colorFromHexString:@"#242424"];
    rightLab.textAlignment = NSTextAlignmentCenter;
    
    leftDbLab = [TYAttributedLabel new];
    [centerView addSubview:leftDbLab];
    
    rightDbLab = [TYAttributedLabel new];
    [centerView addSubview:rightDbLab];
    
    lineView = [UIImageView new];
    lineView.backgroundColor = [UIColor colorFromHexString:@"#ECECEC"];
    [centerView addSubview:lineView];
    
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(3);
        make.bottom.equalTo(self.mas_bottom).offset(-3);
        make.left.equalTo(self.mas_left).offset(16);
        make.right.equalTo(self.mas_right).offset(-16);
    }];
    
    [leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_top).offset(2);
        make.left.equalTo(centerView.mas_left).offset(0);
        make.right.equalTo(rightLab.mas_left).offset(0);
        make.bottom.equalTo(leftDbLab.mas_top).offset(0);
        make.width.equalTo(rightLab.mas_width);
        make.height.offset(35);
    }];
    
    [rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_top).offset(2);
        make.left.equalTo(leftLab.mas_right).offset(0);
        make.right.equalTo(centerView.mas_right).offset(0);
        make.bottom.equalTo(leftDbLab.mas_top).offset(0);
        make.width.equalTo(leftLab.mas_width);
        make.height.offset(35);
    }];
    
    [leftDbLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(leftLab.mas_bottom).offset(0);
        make.left.equalTo(centerView.mas_left).offset(0);
        make.right.equalTo(rightDbLab.mas_left).offset(0);
        make.bottom.equalTo(centerView.mas_bottom).offset(-1);
        make.width.equalTo(rightDbLab.mas_width);
    }];
    
    [rightDbLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(leftLab.mas_bottom).offset(0);
        make.left.equalTo(centerView.mas_right).offset(0);
        make.right.equalTo(centerView.mas_right).offset(0);
        make.bottom.equalTo(centerView.mas_bottom).offset(-1);
        make.width.equalTo(leftDbLab.mas_width);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(leftLab.mas_top).offset(10);
        make.bottom.equalTo(centerView.mas_bottom).offset(-10);
        make.centerX.offset(0);
        make.width.offset(1);
    }];
    
}

-(void)setLeftDb:(double)leftDb{
    _leftDb = leftDb;
    [self setDb:leftDb Color:[UIColor colorFromHexString:@"#4E89F4"] View:leftDbLab];
}

-(void)setRightDb:(double)rightDb{
    _rightDb = rightDb;
    [self setDb:rightDb Color:[UIColor colorFromHexString:@"#FF9E39"] View:rightDbLab];
}


-(void)setDb:(double)value Color:(UIColor *)color View:(TYAttributedLabel*)view{
    TYTextContainer *container = [[TYTextContainer alloc] init];
    container.paragraphSpacing = 10;
    NSString *text =  [NSString stringWithFormat:@"%.0fdB",value];
    container.text =  text;
    container.font = FontMedium(36);
    container.textColor = color;
    container.textAlignment = kCTTextAlignmentCenter;
    
    TYTextStorage *storage = [[TYTextStorage alloc] init];
    storage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    storage.range = [text rangeOfString:@"dB"];
    storage.textColor = [UIColor colorFromHexString:@"#ABABAB"];
    [container addTextStorage:storage];
    view.textContainer = container;
}


-(void)resetByLeft:(float)value Type:(DhaChannel)channel{
    
    rightLab.hidden = YES;
    lineView.hidden = YES;
    rightDbLab.hidden = YES;
    
    leftLab.textAlignment = NSTextAlignmentLeft;
    leftDbLab.textAlignment = kCTTextAlignmentCenter;
    leftDbLab.verticalAlignment = TYVerticalAlignmentCenter;
    
    [centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
        make.left.equalTo(self.mas_left).offset(16);
        make.right.equalTo(self.mas_right).offset(-16);
    }];
    
    [leftLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.equalTo(centerView.mas_left).offset(16);
        make.right.equalTo(leftDbLab.mas_left).offset(-10);
    }];
    
    [leftDbLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_top).offset(0);
        make.left.equalTo(leftLab.mas_right).offset(10);
        make.right.equalTo(centerView.mas_right).offset(10);
        make.bottom.equalTo(centerView.mas_bottom).offset(10);
        make.width.offset(90.0);
        make.height.offset(50.0);
    }];

    if (channel == DhaChannel_left) {
        _leftDb = value;
        [self setDb:value Color:[UIColor colorFromHexString:@"#4E89F4"] View:leftDbLab];
    }else{
        _leftDb = value;
        [self setDb:value Color:[UIColor colorFromHexString:@"#FF9E39"] View:leftDbLab];
        leftLab.text = kJL_TXT("Right_ear_threshold_mean");
    }
    
}




@end
