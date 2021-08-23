//
//  RingTimeCell.m
//  JieliJianKang
//
//  Created by 李放 on 2021/4/2.
//

#import "RingTimeCell.h"
#import "JL_RunSDK.h"

@implementation RingTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.cellLabel = [[UILabel alloc] init];
        self.cellLabel.frame = CGRectMake(24, 60/2-22/2, 100, 22);
        self.cellLabel.numberOfLines = 0;
        [self addSubview:self.cellLabel];
        self.cellLabel.font = [UIFont fontWithName:@"PingFangSC" size: 16];
        self.cellLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
        
        self.cellBtn = [[UIButton alloc] initWithFrame:CGRectMake([DFUITools screen_2_W]-32-24-24,60/2-24/2,24,24)];
        [self.cellBtn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellBtn setContentMode:UIViewContentModeScaleAspectFit];
        [self.cellBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_choose2_nol"] forState:UIControlStateNormal];
        [self addSubview:self.cellBtn];
    }
    return self;
}

-(void)selectBtn:(UIButton *)btn{

}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
