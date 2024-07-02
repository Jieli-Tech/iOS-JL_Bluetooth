//
//  DhaChartView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/1.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DhaChartView.h"



@implementation DhaChartView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.chartsView = [[EcChartsView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.chartsView];
        [self initData];
        [self stepUI];
    }
    return self;
}

-(void)initData{
    [self.chartsView setMaxIndex:7];
    self.chartsView.shouldTag = -1;
    [self.chartsView setXAxisList:@[@"250",@"500",@"1000",@"2000",@"4000",@"6000"]];
//    [self.chartsView setLineArrays:@[@(20.0),@(30.0),@(10.0),@(80.0),@(50.0),@(0.0)] Array2:@[@(50.0),@(40.0),@(40.0),@(20.0),@(60.0),@(5.0)]];
    [self.chartsView setBarValues:@[@(0.0),@(0.0),@(0.0),@(0.0),@(0.0),@(0.0)]];
}


-(void)stepUI{
    
    self.hearLab1 = [UILabel new];
    [self addSubview:self.hearLab1];
    self.hearLab1.text = [NSString stringWithFormat:@"%@/dB HL",kJL_TXT("Auditory_threshold")];
    self.hearLab1.textColor = [UIColor colorFromHexString:@"#ABABAB"];
    self.hearLab1.font = [UIFont systemFontOfSize:12];
    
    self.leftLabl = [UILabel new];
    self.leftLabl.text = [NSString stringWithFormat:@"● %@",kJL_TXT("Left_ear")];
    self.leftLabl.textColor = [UIColor colorFromHexString:@"#4E89F4"];
    self.leftLabl.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.leftLabl];
    
    self.rightLabl = [UILabel new];
    self.rightLabl.text = [NSString stringWithFormat:@"● %@",kJL_TXT("Right_ear")];
    self.rightLabl.textColor = [UIColor colorFromHexString:@"#E7933B"];
    self.rightLabl.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.rightLabl];
    
    
    self.freqLab = [UILabel new];
    [self addSubview:self.freqLab];
    self.freqLab.text = [NSString stringWithFormat:@"%@/Hz",kJL_TXT("frequency")];
    self.freqLab.textColor = [UIColor colorFromHexString:@"#ABABAB"];
    self.freqLab.font = [UIFont systemFontOfSize:12];
    
    
    [self.hearLab1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.left.equalTo(self.mas_left).offset(28);
        make.height.offset(25);
    }];
    
    [self.leftLabl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.right.equalTo(self.rightLabl.mas_left).offset(-12);
        make.height.offset(25);
    }];
    
    [self.rightLabl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.right.equalTo(self.mas_right).offset(-16);
        make.left.equalTo(self.leftLabl.mas_right).offset(12);
        make.height.offset(25);
    }];
    
    [self.chartsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hearLab1.mas_bottom).offset(6);
        make.left.equalTo(self.mas_left).offset(10);
        make.right.equalTo(self.mas_right).offset(-10);
        make.bottom.equalTo(self.freqLab.mas_top).offset(-15);
    }];
    
    [self.freqLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(5);
        make.right.equalTo(self.mas_right).offset(-16);
        make.height.offset(25);
    }];
}

@end
