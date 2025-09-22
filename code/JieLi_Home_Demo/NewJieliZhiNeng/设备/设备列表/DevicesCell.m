//
//  DevicesCell.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DevicesCell.h"
#import "JLUI_Effect.h"
#import "JL_RunSDK.h"

@implementation DevicesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
    self.deleteBtn.hidden = YES;

    UILongPressGestureRecognizer *lg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    lg.minimumPressDuration = 0.5;
    [self.contentView addGestureRecognizer:lg];

    if([kJL_GET hasPrefix:@"zh"]){
        _connectStatusLablewidth.constant = 72;
    }else{
        _connectStatusLablewidth.constant = 111;
    }
    self.connectStatusLab.layer.cornerRadius = 4;
    self.connectStatusLab.layer.masksToBounds = YES;

    _subView.layer.masksToBounds = YES;
//    _subView.backgroundColor = kDF_RGBA(255, 255, 255, 1);
//    _subView.layer.shadowColor = [UIColor greenColor].CGColor;
//    _subView.layer.shadowOffset = CGSizeMake(0,1);
//    _subView.layer.shadowOpacity = 1;
//    _subView.layer.shadowRadius = 13;
////    _subView.layer.borderWidth = 0.5;
////    _subView.layer.borderColor =kDF_RGBA(243.0, 243, 243, 1).CGColor;
//    _subView.layer.cornerRadius = 10;
    [JLUI_Effect addShadowOnView_1:_subView];
    _connectStatusLab.hidden = NO;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)sender{
     if (sender.state == UIGestureRecognizerStateBegan) {
         AudioServicesPlaySystemSound(1519);
         if ([self.delegate respondsToSelector:@selector(deviceCellDidDelete)]) {
             [self.delegate deviceCellDidDelete];
         }
     }
}

- (IBAction)deleteBtnAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deviceCellDidSelectWith:)]) {
        [self.delegate deviceCellDidSelectWith:self.index];
    }
}

- (IBAction)deviceBtnLocation:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deviceBtnLocation:)]) {
           [self.delegate deviceBtnLocation:self.index];
       }
}

@end
