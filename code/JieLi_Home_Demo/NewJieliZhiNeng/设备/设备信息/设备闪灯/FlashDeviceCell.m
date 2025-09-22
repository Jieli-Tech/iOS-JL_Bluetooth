//
//  FlashDeviceCell.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/8/6.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "FlashDeviceCell.h"

@implementation FlashDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)init
{
    self = [DFUITools loadNib:@"FlashDeviceCell"];
    if (self) {
        
    }
    return self;
}

+(NSString*)ID{
    return @"FLASH_DEV_CELL";
}

//icon_nor
//icon_sel

@end
