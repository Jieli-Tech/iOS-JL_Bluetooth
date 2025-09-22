//
//  MultiLinksTbCell.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/9/5.
//  Copyright © 2023 杰理科技. All rights reserved.
//

#import "MultiLinksTbCell.h"

@implementation MultiLinksTbCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        _mainLab = [UILabel new];
        _mainLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
        _mainLab.textColor = [UIColor colorFromRGBAArray:@[@(0.0),@(0.0),@(0.0),@(0.9)]];
        [self.contentView addSubview:_mainLab];
        
        _mainLab.text = @"HUAWEI MATE 60";
        
        _mainImgv = [UIImageView new];
        _mainImgv.image = [UIImage imageNamed:@"Theme.bundle/icon_phone"];
        [self.contentView addSubview:_mainImgv];
        
        _isLocalLab = [UILabel new];
        _isLocalLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 11];
        _isLocalLab.textColor = [UIColor colorFromHexString:@"#1BC017"];
        _isLocalLab.layer.cornerRadius = 4;
        _isLocalLab.layer.masksToBounds = true;
        _isLocalLab.layer.borderColor = [UIColor colorFromHexString:@"#1BC017"].CGColor;
        _isLocalLab.layer.borderWidth = 1;
        _isLocalLab.text = kJL_TXT("this_machine");
        [self.contentView addSubview:_isLocalLab];
        
        [_mainImgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(16);
            make.width.height.equalTo(@(24));
            make.centerY.equalTo(self.contentView);
        }];
        
        [_mainLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainImgv.mas_right).offset(12);
            make.centerY.equalTo(self.contentView);
        }];
        
        [_isLocalLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainLab.mas_right).offset(16);
            make.centerY.equalTo(self.contentView);
        }];
        
        
        
    }
    return self;
}

@end
