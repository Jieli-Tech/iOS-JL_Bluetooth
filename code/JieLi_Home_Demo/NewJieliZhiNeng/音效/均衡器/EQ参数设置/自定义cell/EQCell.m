//
//  EQCell.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/6/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "EQCell.h"
#import "BezierView.h"
#import "EQDefaultCache.h"

@implementation EQCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
   
}

- (instancetype)init
{
    self = [DFUITools loadNib:@"EQCell"];
    if (self) {
        self.bzLine = [[BezierView alloc] initWithFrame:CGRectMake(110, 0, [UIScreen mainScreen].bounds.size.width-120, 50)];
//        self.bzLine.backgroundColor = [UIColor blueColor];
        [self addSubview:_bzLine];
    }
    return self;
}

-(void)setEqLine:(int)index{
    NSArray *points = [[EQDefaultCache sharedInstance] getPointArray:index];
    [self.bzLine drawWithList:points];
}

+(NSString*)ID{
    return @"EQCell";
}

@end
