//
//  SongListCell.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "SongListCell.h"

@implementation SongListCell

-(instancetype)init{
    self = [[NSBundle mainBundle] loadNibNamed:@"SongListCell" owner:nil options:nil][0];
    if (self) {
        float sw = [UIScreen mainScreen].bounds.size.width;
        CGRect rect_lb = CGRectMake(53, 10, sw-80, 20);
        self.songName = [[DFLabel alloc] initWithFrame:rect_lb];
        self.songName.textColor = [UIColor blackColor];
        self.songName.font = [UIFont systemFontOfSize:15.0];
        self.songName.labelType = DFLeftRight;
        self.songName.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.songName];
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
