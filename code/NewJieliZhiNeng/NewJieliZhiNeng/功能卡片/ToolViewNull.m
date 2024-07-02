//
//  ToolViewNull.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "ToolViewNull.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"

@interface ToolViewNull()<LanguagePtl>{
    __weak IBOutlet UIView *subView;
    __weak IBOutlet UILabel *label;
}

@end

@implementation ToolViewNull

- (instancetype)init
{
    self = [DFUITools loadNib:@"ToolViewNull"];
    if (self) {
        float sW = [UIScreen mainScreen].bounds.size.width;
        
        if([UIScreen mainScreen].bounds.size.width == 320.0){
            label.font = [UIFont systemFontOfSize:10];
        }else{
            label.font = [UIFont systemFontOfSize:14];
        }
        label.text = kJL_TXT("no_data_connect_first");
        self.frame = CGRectMake(0, kJL_HeightStatusBar+44, sW, 200);
        [JLUI_Effect addShadowOnView:subView];
        
        [[LanguageCls share] add:self];
    }
    return self;
}

-(void)languageChange{
    label.text = kJL_TXT("no_data_connect_first");
}

@end
