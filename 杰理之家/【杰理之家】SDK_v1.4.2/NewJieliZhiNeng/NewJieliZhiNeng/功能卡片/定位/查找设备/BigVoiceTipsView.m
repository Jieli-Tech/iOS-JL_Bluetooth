//
//  BigVoiceTipsView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/23.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "BigVoiceTipsView.h"
#import "JL_RunSDK.h"

@interface BigVoiceTipsView(){
 
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet UILabel *tipsTitle;
    __weak IBOutlet UILabel *messageLab;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *commitBtn;

}
@end

@implementation BigVoiceTipsView

- (instancetype)init
{
    self = [DFUITools loadNib:@"BigVoiceTipsView"];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        centerView.layer.cornerRadius = 10;
        centerView.layer.masksToBounds = YES;
        [cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
        [commitBtn setTitle:kJL_TXT("播放声音") forState:UIControlStateNormal];
        UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf)];
        [self addGestureRecognizer:tapges];
        if([kJL_GET hasPrefix:@"zh"]){
            messageLab.textAlignment = NSTextAlignmentLeft;
        }
    }
    return self;
}
-(void)setTitle:(NSString *)title{
    tipsTitle.text = title;
}
-(void)setMessage:(NSString *)message{
    messageLab.text = message;
}

- (IBAction)cancelBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(voiceDidSelectWith:)]) {
        [_delegate voiceDidSelectWith:0];
    }
}
- (IBAction)commitBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(voiceDidSelectWith:)]) {
        [_delegate voiceDidSelectWith:1];
    }
}

-(void)dismissSelf{
    if ([_delegate respondsToSelector:@selector(voiceDidSelectWith:)]) {
           [_delegate voiceDidSelectWith:0];
       }
}


@end
