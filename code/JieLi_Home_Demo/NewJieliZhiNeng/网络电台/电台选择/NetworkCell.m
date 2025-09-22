//
//  NetworkCell.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/8.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "NetworkCell.h"

NSString *kNETWORK_CELL_DELETE = @"NETWORK_CELL_DELETE";

@interface NetworkCell(){
    __weak IBOutlet UIView *bgView;
}

@end

@implementation NetworkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
    
    bgView.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.4).CGColor;
    bgView.layer.shadowOffset = CGSizeMake(0,1);
    bgView.layer.shadowOpacity= 1;
    bgView.layer.shadowRadius = 8;
    bgView.layer.cornerRadius = 7;
    
    self.subImageView.layer.cornerRadius = 7;
    
    
}
- (IBAction)onDeleteBtn:(id)sender {
    kJLLog(JLLOG_DEBUG,@"--->Delete: %ld",(long)self.subTag);
    [JL_Tools post:kNETWORK_CELL_DELETE Object:@(self.subTag)];
}

@end
