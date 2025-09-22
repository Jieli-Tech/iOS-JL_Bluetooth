#import "TongTouPick.h"
#import "TongTouPlate.h"

@interface TongTouPick()<UIScrollViewDelegate>{
    
    UIScrollView    *sView;
    TongTouPlate      *iPlate;
    NSInteger       fm_num;

    CGFloat         view_W;
    CGFloat         view_H;
    NSInteger       fm_sPoint_1;
    NSInteger       fm_sPoint;
    NSInteger       fm_ePoint;
    int             mType; // 0:修改左耳通透增益值 1：修改右耳通透增益值
}

@end

static const int ec_max = 200;

@implementation TongTouPick

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
        
        fm_num = fm_ePoint - fm_sPoint;
        iPlate = [[TongTouPlate alloc] initWithIndex:fm_num WithHeight:view_H];
        iPlate.startPiont = fm_sPoint;
        
        sView = [[UIScrollView alloc] init];
        sView.frame = CGRectMake(0, 0, view_W, view_H);
        sView.showsVerticalScrollIndicator = NO;
        sView.showsHorizontalScrollIndicator = NO;
        sView.alwaysBounceHorizontal = YES;
        sView.contentSize = CGSizeMake(fm_num*kTongTou_SCALE*kTongTou_GAP+kTongTouPickGAP, 0);
        sView.contentInset = UIEdgeInsetsMake(0, view_W/2.0-kTongTouPickGAP/2.0, 0, view_W/2.0-kTongTouPickGAP/2.0);
        sView.backgroundColor = [UIColor clearColor];
        sView.delegate = self;
        [sView addSubview:iPlate];
        [self addSubview:sView];
        
        
        UIImageView *redImage = [[UIImageView alloc] initWithFrame:CGRectMake(view_W/2.0-1.0, -15.0, 2.0, 49)];
        redImage.contentMode = UIViewContentModeScaleAspectFit;
        redImage.backgroundColor = kColor_0000;
        [self addSubview:redImage];
    }
    return self;
}

-(void)setType:(int)type{
    mType = type;
}
-(void)setMaxValue:(int)maxValue{
    _maxValue = maxValue;
    iPlate.maxValue = maxValue;
}


#pragma mark UIScrollViewDelegate
static BOOL isSpeed = NO;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + view_W/2.0-kTongTouPickGAP/2.0;
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
        float s_x = scrollView.contentOffset.x + view_W/2.0-kTongTouPickGAP/2.0;
        [self fixedOffset_1:s_x];
        int k = (int)[self calcutePoint:s_x];
        kJLLog(JLLOG_DEBUG,@"无速度：%.2f,%d",s_x,k);
        if (k>self.maxValue) {
            int currentValue;
            if(self.maxValue%ec_max<ec_max){
                currentValue = (self.maxValue/ec_max)+1;
            }else{
                currentValue = self.maxValue/ec_max;
            }
            [self setTongTouPoint:currentValue];
        }
    }
    
}

#pragma mark --> (有速度)偏移UI
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + view_W/2.0-kTongTouPickGAP/2.0;
    [self fixedOffset_1:s_x];
    
//    kJLLog(JLLOG_DEBUG,@"有速度：%.2f",s_x);
    int k = (int)[self calcutePoint:s_x];
    kJLLog(JLLOG_DEBUG,@"有速度：%.2f,%d",s_x,k);
    if (k>self.maxValue) {
        int currentValue;
        if(self.maxValue%ec_max<ec_max){
            currentValue = (self.maxValue/ec_max)+1;
        }else{
            currentValue = self.maxValue/ec_max;
        }
        [self setTongTouPoint:currentValue];
    }
}




//-(void)fixedOffset:(int)point{
//    int minGap = kTongTou_GAP;
//
//    int rest = point%minGap;
//    int mPoint = 0;
//    if (rest > minGap/2) {
//        mPoint = (point - rest)+minGap;
//    }else{
//        mPoint = (point - rest);
//    }
//    [sView setContentOffset:CGPointMake(mPoint+kTongTouPickGAP/2.0-view_W/2.0, 0) animated:YES];
//    float fm_point = mPoint/kTongTou_GAP + fm_sPoint;
//
//    /*--- 描述刻度LB ---*/
//    //NSString *text_num = [NSString stringWithFormat:@"%.1f",fm_point];
//    //kJLLog(JLLOG_DEBUG,@"0 ==> fmLabel.text:%@",text_num);
//
//    //if (fm_point < 0.0f || fm_point > 20.0f) return;
//
//    if([_delegate respondsToSelector:@selector(onTongTouPick:didSelect:)]){
//        NSInteger outPoint = (NSInteger)fm_point*ec_max.0;
//        [_delegate onTongTouPick:self didSelect:outPoint];
//    }
//}

-(NSInteger)calcutePoint:(int)point{
    int minGap = kTongTou_GAP;

    int rest = point%minGap;
    int mPoint = 0;
    if (rest > minGap/2) {
        mPoint = (point - rest)+minGap;
    }else{
        mPoint = (point - rest);
    }
    float fm_point = mPoint/kTongTou_GAP + fm_sPoint_1;
    //NSString *text_num = [NSString stringWithFormat:@"%.1f",fm_point];
    //kJLLog(JLLOG_DEBUG,@"1 ==> fmLabel.text:%@",text_num);
    
    /*--- 描述刻度LB ---*/
    if (fm_point < 0.0f || fm_point > 80.0f) return 0;
    kJLLog(JLLOG_DEBUG,@"fixedOffset_0:%.2f",fm_point*ec_max);
    return fm_point*ec_max;
}

-(void)fixedOffset_1:(int)point{
    int minGap = kTongTou_GAP;

    int rest = point%minGap;
    int mPoint = 0;
    if (rest > minGap/2) {
        mPoint = (point - rest)+minGap;
    }else{
        mPoint = (point - rest);
    }
    float fm_point = mPoint/kTongTou_GAP + fm_sPoint_1;
    //NSString *text_num = [NSString stringWithFormat:@"%.1f",fm_point];
    //kJLLog(JLLOG_DEBUG,@"1 ==> fmLabel.text:%@",text_num);
    
    /*--- 描述刻度LB ---*/
//    if (fm_point < 0.0f || fm_point > 80.0f) return;
    //kJLLog(JLLOG_DEBUG,@"fixedOffset_1:%.2f",fm_point*ec_max);
    if(mType == 0){
        if([_delegate respondsToSelector:@selector(onTongTouPick:didChangeLeft:)]){
            NSInteger outPoint = (NSInteger)fm_point*ec_max;
            if (outPoint>self.maxValue) {
                outPoint = self.maxValue;
                
            }
            if (outPoint<0){
                outPoint = 0;
            }
            [_delegate onTongTouPick:self didChangeLeft:outPoint];

        }
    }
    if(mType == 1){
        if([_delegate respondsToSelector:@selector(onTongTouPick:didChangeRight:)]){
            NSInteger outPoint = (NSInteger)fm_point*ec_max;
            if (outPoint>self.maxValue) {
                outPoint = self.maxValue;
            }
            [_delegate onTongTouPick:self didChangeRight:outPoint];
        }
    }

}

-(void)setTongTouPoint:(NSInteger)point{
    [self setTongTouPoint:point withAnimated:YES];
}

-(void)setTongTouPoint:(NSInteger)point withAnimated:(BOOL)animate{
    
    if (point < fm_sPoint) {
        point = fm_sPoint;
    }
    if (point > fm_ePoint) {
        point = fm_ePoint;
    }

    float mPoint = (point - fm_sPoint)*kTongTou_GAP;
    kJLLog(JLLOG_DEBUG,@"mPoint:%.2f",mPoint);
    [sView setContentOffset:CGPointMake(mPoint+kTongTouPickGAP/2.0-view_W/2.0, 0) animated:animate];
}


@end
