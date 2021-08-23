//
//  UpgradeCell.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "UpgradeCell.h"
#import "JL_RunSDK.h"

@implementation UpgradeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.downloadBtn.layer.cornerRadius = 13.0;
    self.downloadBtn.layer.masksToBounds = YES;
    
    if([kJL_GET hasPrefix:@"zh"]){
        self.checkBtnWidth.constant = 72;
    }else{
        self.checkBtnWidth.constant = 130;
    }
    self.lastVersionLab.text = kJL_TXT("已是最新版本");
    [self.checkBtn setTitle:kJL_TXT("检查更新") forState:UIControlStateNormal];
    self.checkBtn.layer.cornerRadius = 13.0;
    self.checkBtn.layer.masksToBounds = YES;
    [self.checkBtn setBackgroundColor:kColor_0000];
    [self.downloadBtn setBackgroundColor:kColor_0000];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)downloadBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(upgradeCellDidTouch:)]) {
        [_delegate upgradeCellDidTouch:self.index];
    }
}

- (IBAction)checkUpdateBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(checkUpdateCellDidTouch)]) {
        [_delegate checkUpdateCellDidTouch];
    }
}


@end
