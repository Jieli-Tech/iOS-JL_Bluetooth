//
//  AlarmBottomView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/7.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AlarmBottomView.h"

#define selectedColor [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0]
#define unselectColor [UIColor colorWithRed:175.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0]
@interface AlarmBottomView (){
    NSArray *itemArray;
    UIView *bottomView;
    NSMutableArray *btnArray;
}

@end

@implementation AlarmBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)initWithUI{
    CGFloat width = self.frame.size.width/itemArray.count;
    CGFloat height = self.frame.size.height;
    btnArray = [NSMutableArray new];
    for (int i = 0; i<itemArray.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(width*i, 0, width,height)];
        [btn setTitle:itemArray[i] forState:UIControlStateNormal];
        btn.tag = i;
        if (i == 0) {
            [btn setTitleColor:selectedColor forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:unselectColor forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [btnArray addObject:btn];
        [self addSubview:btn];
    }
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(width/2-10, height-10, 20, 3)];
    bottomView.backgroundColor = selectedColor;
    bottomView.layer.cornerRadius = 1.5;
    bottomView.layer.masksToBounds = YES;
    [self addSubview:bottomView];
}

- (void)setButtonsArray:(NSArray *)buttonsArray{
    itemArray = _buttonsArray = buttonsArray;
    for (UIButton *btn in btnArray) {
        [btn removeFromSuperview];
    }
    if (bottomView) {
        [bottomView removeFromSuperview];
        bottomView = nil;
    }
    [self initWithUI];
}

-(void)btnAction:(UIButton *)btn{
    CGFloat width = self.frame.size.width/itemArray.count;
    CGFloat height = self.frame.size.height;
    for (UIButton *item in btnArray) {
        [item setTitleColor:unselectColor forState:UIControlStateNormal];
    }
    [btn setTitleColor:selectedColor forState:UIControlStateNormal];
    bottomView.frame = CGRectMake(width*btn.tag+width/2-10, height-10, 20, 3);
    if ([_delegate respondsToSelector:@selector(bottomDidSelected:)]) {
        [_delegate bottomDidSelected:btn.tag];
    }
}
-(void)btnSelect:(NSInteger)index{
    CGFloat width = self.frame.size.width/itemArray.count;
    CGFloat height = self.frame.size.height;
    for (UIButton *item in btnArray) {
        if (item.tag == index) {
            [item setTitleColor:selectedColor forState:UIControlStateNormal];
        }else{
            [item setTitleColor:unselectColor forState:UIControlStateNormal];
        }
    }
    bottomView.frame = CGRectMake(width*index+width/2-10, height-10, 20, 3);
}

@end
