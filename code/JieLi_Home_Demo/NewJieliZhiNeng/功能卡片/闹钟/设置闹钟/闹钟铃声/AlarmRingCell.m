//
//  AlarmRingCell.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/7.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AlarmRingCell.h"

@implementation AlarmRingCell


-(instancetype)init{
    self = [[NSBundle mainBundle] loadNibNamed:@"AlarmRingCell" owner:nil options:nil][0];
    if (self) {
        float sw = [UIScreen mainScreen].bounds.size.width;
        CGRect rect_lb = CGRectMake(53, 10, sw-100, 30);
        self.animaLab = [[DFLabel alloc] initWithFrame:rect_lb];
        self.animaLab.textColor = [UIColor blackColor];
        self.animaLab.font = FontRegular(16);
        self.animaLab.labelType = DFLeftRight;
        self.animaLab.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.animaLab];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
