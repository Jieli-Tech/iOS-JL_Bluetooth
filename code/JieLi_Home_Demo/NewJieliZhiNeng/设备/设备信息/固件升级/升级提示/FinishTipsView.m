//
//  FinishTipsView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "FinishTipsView.h"
#import "JL_RunSDK.h"
#import <DFUnits/DFUnits.h>
#import "JLUI_Effect.h"

@interface FinishTipsView(){
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet UILabel *centerLab;
    __weak IBOutlet UIButton *okBtn;
    FinishBlock blockAction;
}
@end

@implementation FinishTipsView

- (instancetype)init
{
    
    self = [DFUITools loadNib:@"FinishTipsView"];
    if (self) {
        float sW = [UIScreen mainScreen].bounds.size.width;
        float sH = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(0, 0, sW, sH);
        CGFloat k = 15;
        
        if (kJL_IS_IPHONE_X) {
            k = 30;
        }
        if (kJL_IS_IPHONE_Xr) {
            k = 30;
            
        }
        if (kJL_IS_IPHONE_Xs_Max) {
            k = 30;
            
        }
        centerView.layer.cornerRadius = k;
        centerView.layer.masksToBounds = YES;
        centerLab.text = kJL_TXT("upgrade_success");
        [okBtn setTitle:kJL_TXT("confirm") forState:UIControlStateNormal];

    }
    
    return self;
}

-(void)okBlock:(FinishBlock)block{
    blockAction = block;
}

- (IBAction)okBtnAction:(id)sender {
    if (blockAction) { blockAction();}
    [self removeFromSuperview];
}


@end
