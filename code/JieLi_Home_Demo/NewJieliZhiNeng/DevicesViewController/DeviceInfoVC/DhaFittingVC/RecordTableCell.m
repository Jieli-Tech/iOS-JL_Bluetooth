//
//  RecordTableCell.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/30.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "RecordTableCell.h"
#import "JLUI_Effect.h"

@interface RecordTableCell(){
    UIImageView *rightView;
}

@end

@implementation RecordTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    
    UIView *centerView = [[UIView alloc] init];
    centerView.backgroundColor = [UIColor clearColor];
    [self addSubview:centerView];
    
    self.typeLab = [[UILabel alloc] init];
    [centerView addSubview:self.typeLab];
    
    self.recordLab = [[UILabel alloc] init];
    self.recordLab.textColor = [UIColor colorFromHexString:@"#242424"];
    self.recordLab.font = [UIFont systemFontOfSize:15];
    [centerView addSubview:self.recordLab];
    
    rightView = [UIImageView new];
    rightView.image = [UIImage imageNamed:@"Theme.bundle/icon_next"];
    [centerView addSubview:rightView];
    
    self.typeLab = [UILabel new];
    self.typeLab.textAlignment = NSTextAlignmentCenter;
    self.typeLab.layer.cornerRadius = 12.0;
    self.typeLab.layer.masksToBounds = YES;
    [centerView addSubview:self.typeLab];
    
    
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(6);
        make.left.equalTo(self.mas_left).offset(6);
        make.right.equalTo(self.mas_right).offset(-6);
        make.bottom.equalTo(self.mas_bottom).offset(-6);
    }];
    
    [self.typeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.equalTo(centerView.mas_left).offset(14);
        make.width.offset(50);
        make.height.offset(24);
    }];
    
    [self.recordLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.equalTo(self.typeLab.mas_right).offset(10);
    }];
    
  
    
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.equalTo(centerView.mas_right).offset(-16);
        make.width.offset(16);
        make.height.offset(16);
    }];
    [JLUI_Effect addShadowOnView:centerView];
    centerView.layer.masksToBounds = YES;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
    return self;
}









@end
