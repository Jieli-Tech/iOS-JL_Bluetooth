//
//  AlarmClockCell.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/29.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AlarmClockCell.h"

@implementation AlarmClockCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.select.transform = CGAffineTransformMakeScale(0.75, 0.7);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)switchDidChange:(UISwitch *)sender {
    if ([_delegate respondsToSelector:@selector(alarmClockCellDidSelect:status:)]) {
        [_delegate alarmClockCellDidSelect:self.tag status:sender.on];
    }
}

@end
