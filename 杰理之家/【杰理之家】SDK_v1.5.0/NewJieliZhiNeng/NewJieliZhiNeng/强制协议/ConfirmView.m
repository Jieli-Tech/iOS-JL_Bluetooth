//
//  ConfirmView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/21.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "ConfirmView.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "UILabel+YBAttributeTextTapAction.h"


@interface ConfirmView(){
    __weak IBOutlet UILabel *tipsTitle;
    __weak IBOutlet UILabel *tipsCenterLab;
    __weak IBOutlet UIButton *confirmBtn;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet NSLayoutConstraint *tipsCenterLabHeight;
    __weak IBOutlet UIImageView *bgView;
}
@end



@implementation ConfirmView

- (instancetype)init
{
    self = [DFUITools loadNib:@"ConfirmView"];
    if (self) {
        CGFloat sW = [DFUITools screen_2_W];
        CGFloat sH = [DFUITools screen_2_H];
        self.frame = CGRectMake(0, 0, sW, sH);
        tipsTitle.text = kJL_TXT("温馨提示");
        
        NSString *showText;
        NSArray *lightArray;
        
        if([kJL_GET hasPrefix:@"zh"]){
            if(kJL_UI_SERIES == 0){ //杰理之家
                showText = @"        欢迎使用杰理之家APP！在您使用时，需连接数据网络或WLAN运营商，产生的流量费用请咨询当地运营商。我们非常重视您的隐私保护和个人信息保护。在您使用杰理之家APP前，请认真阅读 《用户服务协议》 及 《隐私政策》 全部条款，您同意并接受全部条款后再开始使用我们的服务。";
            }
            if(kJL_UI_SERIES == 1){ //PiLink
                showText = @"        欢迎使用【PiLink】APP!在您使用时，需连接数据网络或WLAN运营商，产生的流量费用请咨询当地运营商。我们非常重视您的隐私保护和个人信息保护。在您使用【PiLink】APP前，请认真阅读 《用户服务协议》 及 《隐私政策》 全部条款，您同意并接受全部条款后再开始使用我们的服务。";
            }
            lightArray = @[@"《用户服务协议》",@"《隐私政策》"];
        }else{
            if(kJL_UI_SERIES == 0){ //杰理之家
                showText = @"Welcome to JieLi home app! For the traffic cost, please consult the local operator. We attach great importance to your diet protection and personal information protection. When you use JieLi home app before, please verify and read all terms of the User agreement and Privacy policy. After you agree and accept all terms, you can start to use our service。";
            }
            if(kJL_UI_SERIES == 1){ //PiLink
                showText = @"Welcome to [PiLink] app! For the traffic cost, please consult the local operator. We attach great importance to your diet protection and personal information protection. When you use [PiLink] app before, please verify and read all terms of the User agreement and Privacy policy. After you agree and accept all terms, you can start to use our service。";
            }
            lightArray = @[@"User agreement",@"Privacy policy"];
        }
        
        UIColor *color = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1];
        UIColor *color2 = [UIColor colorWithRed:68.0/255.0 green:142.0/255.0 blue:255.0/255.0 alpha:1.0];
        tipsCenterLab.attributedText = [self getAttributeWith:lightArray string:showText orginFont:14 orginColor:color attributeFont:14 attributeColor:color2];
        [tipsCenterLab yb_addAttributeTapActionWithStrings:lightArray tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
            if ([self->_delegate respondsToSelector:@selector(confirmDidSelect:)]) {
                [self->_delegate confirmDidSelect:(int)index];
            }
        }];
        [confirmBtn setBackgroundImage:[UIImage imageNamed:@"Theme.bundle/defaultt_bt"] forState:UIControlStateNormal];
        [confirmBtn setTitle:kJL_TXT("同意并继续") forState:UIControlStateNormal];
        confirmBtn.layer.cornerRadius = 20.0;
        confirmBtn.layer.masksToBounds = YES;
        [cancelBtn setTitle:kJL_TXT("不同意并退出") forState:UIControlStateNormal];
        [JLUI_Effect addShadowOnView:centerView];
    }
    return self;
}



- (IBAction)confirmBtnAction:(id)sender {
    [JL_Tools setUser:@"OK" forKey:@"CONMIT_PROTOCOL"];
    if ([_delegate respondsToSelector:@selector(confirmConfirmBtnAction)]) {
        [_delegate confirmConfirmBtnAction];
    }
    [self removeFromSuperview];
}

- (IBAction)cancelBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(confirmCancelBtnAction)]) {
        [_delegate confirmCancelBtnAction];
    }
}


- (NSAttributedString *)getAttributeWith:(id)sender
                                  string:(NSString *)string
                               orginFont:(CGFloat)orginFont
                              orginColor:(UIColor *)orginColor
                           attributeFont:(CGFloat)attributeFont
                          attributeColor:(UIColor *)attributeColor
{
    __block  NSMutableAttributedString *totalStr = [[NSMutableAttributedString alloc] initWithString:string];
    [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:orginFont] range:NSMakeRange(0, string.length)];
    [totalStr addAttribute:NSForegroundColorAttributeName value:orginColor range:NSMakeRange(0, string.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5.0f]; //设置行间距
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [totalStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [totalStr length])];
    
    if ([sender isKindOfClass:[NSArray class]]) {
        
        __block NSString *oringinStr = string;
        __weak typeof(self) weakSelf = self;
        
        [sender enumerateObjectsUsingBlock:^(NSString *  _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSRange range = [oringinStr rangeOfString:str];
            [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:attributeFont] range:range];
            [totalStr addAttribute:NSForegroundColorAttributeName value:attributeColor range:range];
            oringinStr = [oringinStr stringByReplacingCharactersInRange:range withString:[weakSelf getStringWithRange:range]];
        }];
        
    }else if ([sender isKindOfClass:[NSString class]]) {
        
        NSRange range = [string rangeOfString:sender];
        
        [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:attributeFont] range:range];
        [totalStr addAttribute:NSForegroundColorAttributeName value:attributeColor range:range];
    }
    return totalStr;
}

- (NSString *)getStringWithRange:(NSRange)range
{
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < range.length ; i++) {
        [string appendString:@" "];
    }
    return string;
}


@end
