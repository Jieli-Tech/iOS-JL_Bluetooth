//
//  UTipsView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/25.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "UTipsView.h"
#import "JL_RunSDK.h"

@interface UTipsView(){
    
    
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet UIButton *okBtn;
    
}
@end
@implementation UTipsView
- (instancetype)init
{
    self = [super init];
    self = [DFUITools loadNib:@"UTipsView"];
    if (self) {
        float sW = [DFUITools screen_2_W];
        float sH = [DFUITools screen_2_H];
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
        
        [okBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];

    }
    return self;
}
- (IBAction)okBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(UtipsOkWithIndex:)]) {
        [_delegate UtipsOkWithIndex:self.index];
    }
}

@end
