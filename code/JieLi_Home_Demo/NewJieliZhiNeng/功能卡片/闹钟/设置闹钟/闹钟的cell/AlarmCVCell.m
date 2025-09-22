//
//  AlarmCVCell.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/29.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AlarmCVCell.h"

@implementation AlarmCVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _bgView.layer.cornerRadius = 15.0;
    _bgView.layer.masksToBounds = YES;
}

@end
