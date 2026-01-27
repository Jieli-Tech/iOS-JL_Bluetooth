//
//  NoNetView.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/5/27.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "NoNetView.h"
#import "JL_RunSDK.h"

@implementation NoNetView

-(id)initByFrame:(CGRect)rect{
    self = [super initWithFrame:rect];
    if (self) {
        self.frame = rect;
        [self initUI];
    }
    return self;
}

-(void)initUI{
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,40);
    bgView.backgroundColor = [UIColor colorWithRed:255/255.0 green:222/255.0 blue:222/255.0 alpha:1.0];
    [self addSubview:bgView];
    
    UIImageView *noNetImv = [[UIImageView alloc] initWithFrame:CGRectMake(24.0, 10.5, 19.0, 19.0)];
    noNetImv.image = [UIImage imageNamed:@"Theme.bundle/no_net_icon"];
    noNetImv.contentMode = UIViewContentModeCenter;
    [self addSubview:noNetImv];
    
    UILabel *noNetLabel = [[UILabel alloc] init];
    noNetLabel.frame = CGRectMake(53.5,13,[UIScreen mainScreen].bounds.size.width-19.0,13.5);
    noNetLabel.numberOfLines = 0;
    [self addSubview:noNetLabel];

    NSMutableAttributedString *noNetStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("no_network") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];

    noNetLabel.attributedText = noNetStr;
}
@end
