//
//  ECPickerView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/10.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "ECPickerView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ECPickerView()<UIScrollViewDelegate>{
    NSMutableArray *scrViewArray;
    NSMutableArray *numberArray;
    NSInteger oldIndex;
    NSDateFormatter *formatter;
    NSTimeInterval oldTimer;
    CAGradientLayer *gradient;
}


@end


@implementation ECPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithData];
        [self reloadData];
    }
    return self;
}

-(void)setDatasourse:(id<ECPickerViewDataSourse>)datasourse{
    if (_datasourse != datasourse) {
        _datasourse = datasourse;
        if (_datasourse) {
            [self reloadData];
            [self moveToNowTime];
        }
    }
}

-(void)scrollToDate:(NSDate *)date{
    NSString *dateStr = [formatter stringFromDate:date];
    NSArray *newArr = [dateStr componentsSeparatedByString:@":"];
    for (int i = 0; i<newArr.count; i++) {
        int number = [newArr[i] intValue];
        UIScrollView *scrollview = scrViewArray[i];
        CGFloat hight = [_datasourse pickerView:self setHightForCell:i indexPath:0];
        [scrollview setContentOffset:CGPointMake(0, number*hight) animated:YES];
        [scrollview setBouncesZoom:NO];
    }
}

-(void)moveToNowTime{
    [self scrollToDate:[NSDate new]];
}

-(void)initWithData{
    scrViewArray = [NSMutableArray new];
    numberArray = [NSMutableArray new];
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    oldTimer = [[NSDate new] timeIntervalSince1970];
}


-(void)reloadData{
    _numberOfSections = [_datasourse numberOfItemsInSection:self];
    CGFloat width = self.frame.size.width/_numberOfSections;
    CGFloat height = self.frame.size.height;
    for (NSMutableArray *item in numberArray) {
        for (UIView *view in item) {
            [view removeFromSuperview];
        }
    }
    [numberArray removeAllObjects];
    
    for (UIScrollView *view in scrViewArray) {
        [view removeFromSuperview];
    }
    [scrViewArray removeAllObjects];
    for (int i = 0; i<self.numberOfSections; i++) {
        NSMutableArray *viewItemArr = [NSMutableArray new];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(i*width, 0, width, height)];
        scrollView.tag = i;
        scrollView.delegate = self;
        scrollView.pagingEnabled = NO;//分页滚动
        [scrollView setBounces:NO];//到了边缘以后不回弹
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        
        NSArray *itemArray = [_datasourse pickerView:self withSection:i];
        CGFloat countHight = 0;
        CGFloat itemHight1 = 0;
        for (int k = 0; k<itemArray.count; k++) {
            CGFloat itemHight = [_datasourse pickerView:self setHightForCell:i indexPath:k];
            itemHight1 = itemHight;
            countHight+=itemHight;
            UIView *view = [_datasourse pickerView:self withSection:i indexPath:k];
            view.frame = CGRectMake(0, k*itemHight+height/2-itemHight/2, width, itemHight);
            [viewItemArr addObject:view];
            [scrollView addSubview:view];
        }
        scrollView.contentSize = CGSizeMake(width, countHight+height-itemHight1);
        
        [self addSubview:scrollView];
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(i*width+width/2-(25/2), height/2-24, 25, 2)];
        view1.backgroundColor = kColor_0000;
        [self addSubview:view1];
        
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(i*width+width/2-(25/2), height/2+22, 25, 2)];
        view2.backgroundColor = kColor_0000;
        [self addSubview:view2];
        
        [numberArray addObject:viewItemArr];
        [scrViewArray addObject:scrollView];
    }
    CGFloat itemHight0 = [_datasourse pickerView:self setHightForCell:0 indexPath:0];
    UILabel *labCenter = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2-5, height/2-itemHight0/2-5, 10, itemHight0)];
    labCenter.font = [UIFont systemFontOfSize:40];
    labCenter.textColor = [UIColor blackColor];
    labCenter.text = @":";
    [self addSubview:labCenter];
    
    [self setNeedsDisplay];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"%s",__func__);
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat hight = [_datasourse pickerView:self setHightForCell:scrollView.tag indexPath:0];
    if ((int)scrollView.contentOffset.y%(int)hight != 0) {
        int k = scrollView.contentOffset.y/hight;
        float t = scrollView.contentOffset.y/hight;
        NSString *f1 = [NSString stringWithFormat:@"%.4f",t];
        NSArray *tmpA = [f1 componentsSeparatedByString:@"."];
        NSString *f2 = tmpA[1];
        float f2f = [f2 floatValue]/10000;
        if (f2f >= 0.5) {
            k+=1;
        }
        [scrollView setContentOffset:CGPointMake(0, k*hight) animated:YES];
        scrollView.bouncesZoom = NO;
        [self labTextSet:scrollView];
    }
    [self shaker:scrollView withShake:YES];
    if ([_delegate respondsToSelector:@selector(cpickerViewMoveToItemEndAnimation:)]) {
        [_delegate cpickerViewMoveToItemEndAnimation:[self didSelectWithScroller]];
    }
    
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}

-(void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView{
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self labTextSet:scrollView];
    if ([_delegate respondsToSelector:@selector(cpickerViewMoveToItem:)]) {
          [_delegate cpickerViewMoveToItem:[self didSelectWithScroller]];
      }
    NSTimeInterval t1 = [[NSDate new] timeIntervalSince1970];
    if (t1-oldTimer>0.1) {
         [self shaker:scrollView withShake:YES];
        oldTimer = t1;
    }
        
  
   
    
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    CGFloat hight = [_datasourse pickerView:self setHightForCell:scrollView.tag indexPath:0];
    if ((int)scrollView.contentOffset.y%(int)hight != 0) {
        int k = scrollView.contentOffset.y/hight;
        float t = scrollView.contentOffset.y/hight;
        NSString *f1 = [NSString stringWithFormat:@"%.4f",t];
        NSArray *tmpA = [f1 componentsSeparatedByString:@"."];
        NSString *f2 = tmpA[1];
        float f2f = [f2 floatValue]/10000;
        if (f2f >= 0.5) {
            k+=1;
        }
        [scrollView setContentOffset:CGPointMake(0, k*hight) animated:YES];
        scrollView.bouncesZoom = NO;
        
        [self labTextSet:scrollView];
    }
    
    [self shaker:scrollView withShake:YES];
    if ([_delegate respondsToSelector:@selector(cpickerViewMoveToItemEndAnimation:)]) {
        [_delegate cpickerViewMoveToItemEndAnimation:[self didSelectWithScroller]];
    }
    
}


-(void)labTextSet:(UIScrollView *)scrollView{
    NSArray *labArray = numberArray[scrollView.tag];
    CGFloat hight = [_datasourse pickerView:self setHightForCell:scrollView.tag indexPath:0];
    int k = scrollView.contentOffset.y/hight;
    float t = scrollView.contentOffset.y/hight;
    NSString *f1 = [NSString stringWithFormat:@"%.4f",t];
    NSArray *tmpA = [f1 componentsSeparatedByString:@"."];
    NSString *f2 = tmpA[1];
    float f2f = [f2 floatValue]/10000;
    if (f2f >= 0.5) {
        k+=1;
    }
    if (k>-1 && k<labArray.count) {
        for (int i = 0; i<labArray.count; i++) {
            if (i==k) {
                UILabel *lab = labArray[k];
                lab.font = [UIFont systemFontOfSize:40.0];
            }else{
                int t = abs(k-i);
                UILabel *lab = labArray[i];
                lab.font = [UIFont systemFontOfSize:(26.0-t)];
            }
        }
    }
}

-(void)shaker:(UIScrollView *)scrollView withShake:(BOOL)shake{
    CGFloat hight = [_datasourse pickerView:self setHightForCell:scrollView.tag indexPath:0];
    int k = scrollView.contentOffset.y/hight;
    if (oldIndex != k) {
        oldIndex = k;
        AudioServicesPlaySystemSoundWithCompletion(1157, nil);
        if (shake) {
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *impactFeedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
                [impactFeedBack prepare];
                [impactFeedBack impactOccurred];
            }
        }
        
    }
}



-(NSArray *)didSelectWithScroller{
    NSMutableArray *newItem = [NSMutableArray new];
    for (int i = 0;i<scrViewArray.count;i++){
        UIScrollView *scrollView = scrViewArray[i];
        NSArray *labArray = numberArray[scrollView.tag];
        CGFloat hight = [_datasourse pickerView:self setHightForCell:scrollView.tag indexPath:0];
        int k = scrollView.contentOffset.y/hight;
        if (k>-1 && k<labArray.count) {
            UILabel *lab = labArray[k];
            [newItem addObject:lab.text];
        }
    }
    return newItem;
}


#pragma mark /// draw
-(void)drawRect:(CGRect)rect{
    [gradient removeFromSuperlayer];
    gradient = nil;
    gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0].CGColor,
                       (id)[UIColor colorWithRed:1 green:1 blue:1.0 alpha:0.0].CGColor,
                       (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0].CGColor, nil];
    [self.layer addSublayer:gradient];
}

@end

