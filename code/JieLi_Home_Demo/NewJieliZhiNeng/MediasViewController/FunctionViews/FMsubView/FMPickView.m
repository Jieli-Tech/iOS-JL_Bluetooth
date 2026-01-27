//
//  FMPickView.m
//  AiRuiSheng
//
//  Created by DFung on 2017/3/8.
//  Copyright © 2017年 DFung. All rights reserved.
//

#import "FMPickView.h"
#import "IndexPlate.h"


@interface FMPickView()<UIScrollViewDelegate>{

    UIScrollView    *sView;
    IndexPlate      *iPlate;
    NSInteger       fm_num;

    CGFloat         view_W;
    CGFloat         view_H;
    NSInteger       fm_sPoint_1;
    NSInteger       fm_sPoint;
    NSInteger       fm_ePoint;
//    UILabel         *fmLabel;
}

@end


@implementation FMPickView

- (instancetype)initWithFrame:(CGRect)frame
                   StartPoint:(NSInteger)sPoint
                     EndPoint:(NSInteger)ePoint
{
    self = [super init];
    if (self) {
        self.frame = frame;
        //self.backgroundColor = [UIColor lightGrayColor];
        view_W = frame.size.width;
        view_H = frame.size.height;
        fm_sPoint_1 = sPoint;
        fm_sPoint = sPoint;
        fm_ePoint = ePoint;
        
        fm_num = ePoint - sPoint;
        iPlate = [[IndexPlate alloc] initWithIndex:fm_num WithHeight:view_H];
        iPlate.startPiont = sPoint;
        
        sView = [[UIScrollView alloc] init];
        sView.frame = CGRectMake(0, 0, view_W, view_H);
        sView.showsVerticalScrollIndicator = NO;
        sView.showsHorizontalScrollIndicator = NO;
        sView.alwaysBounceHorizontal = YES;
        sView.contentSize = CGSizeMake(fm_num*10.0*kMIN_GAP+kFMPickViewGAP, 0);
        sView.backgroundColor = [UIColor clearColor];
        sView.contentInset = UIEdgeInsetsMake(0, view_W/2.0-5*kMIN_GAP-kFMPickViewGAP/2.0, 0, view_W/2.0-kFMPickViewGAP/2.0);
        sView.delegate = self;
        [sView addSubview:iPlate];
        [self addSubview:sView];
        
        //fmLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_W/2.0-50.0, -20.0, 100.0, 30.0)];
        //fmLabel.font = [UIFont boldSystemFontOfSize:27];
        //fmLabel.textColor = [UIColor whiteColor];
        //fmLabel.textAlignment = NSTextAlignmentCenter;
        //[self addSubview:fmLabel];
        
        UIImageView *redImage = [[UIImageView alloc] initWithFrame:CGRectMake(view_W/2.0-8.0, -15.0, 16.0, view_H)];
        redImage.image = [UIImage imageNamed:@"Theme.bundle/mul_slider_nol"];
        redImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:redImage];
    }
    return self;
}




#pragma mark UIScrollViewDelegate
static BOOL isSpeed = NO;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + view_W/2.0-kFMPickViewGAP/2.0;
    [self fixedOffset_1:s_x];
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
        float s_x = scrollView.contentOffset.x + view_W/2.0-kFMPickViewGAP/2.0;
        [self fixedOffset:s_x];
        //kJLLog(JLLOG_DEBUG,@"无速度：%.2f",s_x);
    }
}

#pragma mark --> (有速度)偏移UI
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + view_W/2.0-kFMPickViewGAP/2.0;
    [self fixedOffset:s_x];
    //kJLLog(JLLOG_DEBUG,@"有速度：%.2f",s_x);
}


-(void)fixedOffset:(int)point{
    int rest = point%10;
    int mPoint = 0;
    if (rest > 5) {
        mPoint = (point - rest)+10;
    }else{
        mPoint = (point - rest);
    }
    [sView setContentOffset:CGPointMake(mPoint+kFMPickViewGAP/2.0-view_W/2.0, 0) animated:YES];
    NSInteger fm_point = mPoint/kMIN_GAP + fm_sPoint*10;
    
    /*--- 描述刻度LB ---*/
    float f_fm_point = (float)fm_point;
    
    if (f_fm_point<875.0f || f_fm_point>1080.0f) return;
    
    f_fm_point = f_fm_point/10;
    //NSString *text_num = [NSString stringWithFormat:@"%.1f",f_fm_point];
    //fmLabel.text = text_num;
    //kJLLog(JLLOG_DEBUG,@"==> fmLabel.text:%@",text_num);
    
    if([_delegate respondsToSelector:@selector(onFMPickView:didSelect:)]){
        [_delegate onFMPickView:self didSelect:fm_point];
    }
}

-(void)fixedOffset_1:(int)point{
    int rest = point%10;
    int mPoint = 0;
    if (rest > 5) {
        mPoint = (point - rest)+10;
    }else{
        mPoint = (point - rest);
    }
    NSInteger fm_point = mPoint/kMIN_GAP + fm_sPoint_1*10;
    
    /*--- 描述刻度LB ---*/
    float f_fm_point = (float)fm_point;
    if (f_fm_point<875.0f || f_fm_point>1080.0f) return;
        
    if([_delegate respondsToSelector:@selector(onFMPickView:didChange:)]){
        [_delegate onFMPickView:self didChange:f_fm_point];
    }
}


-(void)setFMPoint:(NSInteger)point{
    if (point < 875) return;
    
    if (point < fm_sPoint*10) {
        point = fm_sPoint*10;
    }
    if (point > fm_ePoint*10) {
        point = fm_ePoint*10;
    }

    float mPoint = (point - fm_sPoint*10)*kMIN_GAP;
    [sView setContentOffset:CGPointMake(mPoint+kFMPickViewGAP/2.0-view_W/2.0, 0) animated:YES];

    /*--- 描述刻度LB ---*/
    float f_fm_point = (float)point;
    f_fm_point = f_fm_point/10;
    //NSString *text_num = [NSString stringWithFormat:@"%.1f",f_fm_point];
    //fmLabel.text = text_num;
}

@end
