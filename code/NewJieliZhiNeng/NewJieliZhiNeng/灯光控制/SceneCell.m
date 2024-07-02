//
//  SceneCell.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/9/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "SceneCell.h"
#import "JL_RunSDK.h"

@implementation SceneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
    
    if([DFUITools screen_W] == 320.0){
        _labelTop.constant = 55;
    }else{
        _labelTop.constant = 82;
    }
}

@end
