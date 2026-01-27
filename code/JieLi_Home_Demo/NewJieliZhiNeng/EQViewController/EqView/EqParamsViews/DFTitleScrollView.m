//
//  DFTitleScrollView.m
//  TestUIDemo
//
//  Created by 杰理科技 on 2020/5/27.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DFTitleScrollView.h"


#define kFONT_BIG       22
#define kFONT_MIDDLE    15
#define kFONT_SMALL     14

#define kITEM_WIDTH     70.0
#define kBOTTOM_GAP     10.0

@interface DFTitleScrollView()<UIScrollViewDelegate>{
    UIScrollView    *mScrollView;
    NSArray         *dataArray;
    NSMutableArray  *labelArray;
    float           sW;
    float           sH;
    
    DFTitleScrollViewBlock mBlock;
}

@end

@implementation DFTitleScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        sW = frame.size.width;
        sH = frame.size.height;
        self.backgroundColor = [UIColor clearColor];
        
        mScrollView = [UIScrollView new];
        mScrollView.frame = CGRectMake(0, 0, sW, sH-kBOTTOM_GAP);
        mScrollView.showsVerticalScrollIndicator = NO;
        mScrollView.showsHorizontalScrollIndicator = NO;
        mScrollView.alwaysBounceHorizontal = YES;
        mScrollView.backgroundColor = [UIColor clearColor];
        mScrollView.delegate = self;
        [self addSubview:mScrollView];
    }
    return self;
}

-(void)reloadDataArray:(NSArray*)array{
    if (array.count == 0) return;
    labelArray = [NSMutableArray new];
    dataArray  = array;
    
    mScrollView.contentSize = CGSizeMake(dataArray.count*kITEM_WIDTH, 0);
    mScrollView.contentInset = UIEdgeInsetsMake(0, sW/2.0-kITEM_WIDTH/2.0, 0, sW/2.0-kITEM_WIDTH/2.0);
    [mScrollView setContentOffset:CGPointMake(-(sW/2.0-kITEM_WIDTH/2.0), 0) animated:NO];
    
    for (int i = 0; i < dataArray.count; i++) {
        NSString *text = array[i];
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(kITEM_WIDTH*i, 0, kITEM_WIDTH, sH-kBOTTOM_GAP);
        label.font = FontMedium(20);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = text;
        [mScrollView addSubview:label];
        [labelArray addObject:label];
    }
    [self updateLabelUI:0];
}
-(void)setTitleScrollViewSelectIndex:(DFTitleScrollViewBlock)block{
    mBlock = block;
}

-(void)setSubIndex:(NSInteger)index{
    if (index < 0) index = 0;
    if (index > dataArray.count-1) index = dataArray.count-1;
    [mScrollView setContentOffset:CGPointMake(kITEM_WIDTH*index-(sW/2.0-kITEM_WIDTH/2.0), 0) animated:YES];
}


#pragma mark UIScrollViewDelegate
static BOOL isSpeed = NO;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + sW/2.0 - kITEM_WIDTH/2.0;
    //kJLLog(JLLOG_DEBUG,@"---> %.2f",s_x);
    [self fixedOffset_1:s_x];
}

static NSInteger last_Point = 0;
-(void)fixedOffset_1:(int)point{
    int rest = point%(int)kITEM_WIDTH;
    int mPoint = 0;
    if (rest > kITEM_WIDTH/2.0) {
        mPoint = (point - rest)+kITEM_WIDTH;
    }else{
        mPoint = (point - rest);
    }
    //kJLLog(JLLOG_DEBUG,@"-------> %d",mPoint);

    NSInteger index = mPoint/kITEM_WIDTH;
    if (index < 0 || index > dataArray.count-1) return;
    
    
    /*--- 震动体验 ---*/
    if (last_Point != mPoint) {
        AudioServicesPlaySystemSound(1519);
        last_Point = mPoint;
        [self updateLabelUI:index];
    }
}

-(void)updateLabelUI:(NSInteger)index{
    NSInteger index_now  = index;
    NSInteger index_last = index-1;
    NSInteger index_next = index+1;

    for (int i = 0; i < labelArray.count; i++) {
        if (i == index_now) {
            UILabel *label_now = labelArray[index_now];
            [self setlabel_0:label_now];
            continue;
        }

        if (i == index_last) {
            UILabel *label_last = labelArray[index_last];
            [self setlabel_1:label_last];
            continue;
        }

        if (i == index_next) {
            UILabel *label_next = labelArray[index_next];
            [self setlabel_1:label_next];
            continue;
        }
        UILabel *label = labelArray[i];
        [self setlabel_2:label];
    }
}

-(void)setlabel_0:(UILabel*)label{
    NSString *txt = label.text;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:txt attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: kFONT_BIG],NSForegroundColorAttributeName: kColor_0000}];
    label.attributedText = string;
}

-(void)setlabel_1:(UILabel*)label{
    NSString *txt = label.text;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:txt attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: kFONT_MIDDLE],NSForegroundColorAttributeName: [UIColor colorWithRed:101/255.0 green:101/255.0 blue:101/255.0 alpha:1.0]}];

    label.attributedText = string;
}
-(void)setlabel_2:(UILabel*)label{
    NSString *txt = label.text;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:txt attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: kFONT_SMALL],NSForegroundColorAttributeName: [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0]}];
    label.attributedText = string;
}


#pragma mark -->（无减速）完成拖拽(手指刚刚松开)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    isSpeed = NO;
    [self performSelector:@selector(scrollAction:) withObject:scrollView afterDelay:0.1];
}

#pragma mark -->（有减速）完成拖拽(手指松开后执行动画的方法)
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    isSpeed = YES;
}

#pragma mark --> (无速度)偏移UI
-(void)scrollAction:(UIScrollView*)scrollView{
    if (isSpeed == NO) {
        float s_x = scrollView.contentOffset.x + sW/2.0-kITEM_WIDTH/2.0;
        [self fixedOffset:s_x];
        //kJLLog(JLLOG_DEBUG,@"无速度：%.2f",s_x);
    }
}

#pragma mark --> (有速度)偏移UI
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + sW/2.0-kITEM_WIDTH/2.0;
    [self fixedOffset:s_x];
    //kJLLog(JLLOG_DEBUG,@"有速度：%.2f",s_x);
}


-(void)fixedOffset:(int)point{
    int rest = point%(int)kITEM_WIDTH;
    int mPoint = 0;
    if (rest > kITEM_WIDTH/2.0) {
        mPoint = (point - rest)+kITEM_WIDTH;
    }else{
        mPoint = (point - rest);
    }
    float position = mPoint-sW/2.0+kITEM_WIDTH/2.0;
    [mScrollView setContentOffset:CGPointMake(position, 0) animated:YES];
    
    NSInteger index = mPoint/kITEM_WIDTH;
    if (mBlock) { mBlock(index); }
}






@end
