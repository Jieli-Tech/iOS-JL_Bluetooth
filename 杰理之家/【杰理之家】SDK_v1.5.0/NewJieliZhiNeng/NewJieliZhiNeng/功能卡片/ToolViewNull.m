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

@interface ToolViewNull(){
    __weak IBOutlet UIView *subView;
    __weak IBOutlet UILabel *label;
}

@end

@implementation ToolViewNull

- (instancetype)init
{
    self = [DFUITools loadNib:@"ToolViewNull"];
    if (self) {
        float sW = [DFUITools screen_2_W];
        
        if([DFUITools screen_2_W] == 320.0){
            label.font = [UIFont systemFontOfSize:10];
        }else{
            label.font = [UIFont systemFontOfSize:14];
        }
        label.text = kJL_TXT("暂无数据，请先连接设备。");
        self.frame = CGRectMake(0, kJL_HeightStatusBar+44, sW, 200);
        [JLUI_Effect addShadowOnView:subView];
    }
    return self;
}



@end
