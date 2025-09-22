//
//  Headphonecell.m
//  IntelligentBox
//
//  Created by kaka on 2019/7/24.
//  Copyright © 2019 Zhuhia Jieli Technology. All rights reserved.
//

#import "Headphonecell.h"
#import "JL_RunSDK.h"

@implementation Headphonecell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)init
{
    self = [DFUITools loadNib:@"Headphonecell"];
    if (self) {
        
    }
    return self;
}


+(NSString*)ID{
    return @"HPCELL";
}

@end
