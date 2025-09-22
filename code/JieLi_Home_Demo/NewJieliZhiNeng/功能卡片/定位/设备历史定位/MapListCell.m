//
//  MapListCell.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/8/18.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "MapListCell.h"

@interface MapListCell(){
    __weak IBOutlet UIView *bgView;
    
}

@end

@implementation MapListCell

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
    self = [DFUITools loadNib:@"MapListCell"];
    if (self) {
        [JLUI_Effect addShadowOnView:bgView];
        self.mLabel_2.backgroundColor = kDF_RGBA(244, 247, 255, 1.0);
        self.mLabel_2.layer.masksToBounds = YES;
        self.mLabel_2.layer.cornerRadius = 5;

    }
    return self;
}


+(NSString*)ID{
    return @"MAPCELL";
}

@end
