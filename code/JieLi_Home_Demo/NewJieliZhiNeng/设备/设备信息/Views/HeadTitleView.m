//
//  HeadTitleView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/5/19.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "HeadTitleView.h"

@interface HeadTitleView()
@property(nonatomic,strong)UILabel *lab;
@end

@implementation HeadTitleView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lab = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 5.0, self.frame.size.width, 45)];
        self.lab.font = [UIFont boldSystemFontOfSize:17];
        self.lab.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
        self.lab.text = self.titleStr;
        [self addSubview:self.lab];
    }
    return self;
}

- (void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
    self.lab.text = titleStr;
}

@end
