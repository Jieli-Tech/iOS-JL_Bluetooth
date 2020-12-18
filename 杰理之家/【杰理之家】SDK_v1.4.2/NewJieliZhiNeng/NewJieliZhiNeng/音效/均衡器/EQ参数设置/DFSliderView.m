//
//  DFSliderView.m
//  TestUIDemo
//
//  Created by 杰理科技 on 2020/5/30.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DFSliderView.h"
#import "DFLabelView.h"
#import "JL_RunSDK.h"

#define kSliderGap_HEAD  30.0
#define kSliderGap_FOOT  50.0
#define kSliderLabel_H   30.0
//#define kSliderGap       50.0

@interface DFSliderView(){
    float               sW;
    float               sH;
    UIScrollView        *subScrollView;
    DFSliderViewBlock   eqBlock;
    DFSliderViewUIChangeBlock eqUIBlock;
    
    DFLabelView         *lb_view;
    
    NSMutableArray      *eq_down_array;
    int                 eq_number_change;
        
    NSArray             *nowFrequencyArray;
    float               mSliderGap;
    
    UIView              *bottomView;
    JL_RunSDK           *bleSDK;
}

@end

@implementation DFSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        sW = frame.size.width;
        sH = frame.size.height;
        mSliderGap = 50.0;
        
        bleSDK = [JL_RunSDK sharedMe];
        
        UILabel *lb_1 = [[UILabel alloc] init];
        lb_1.numberOfLines = 0;
        [self addSubview:lb_1];
        
        NSDictionary *setDict = @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 10],
                                  NSForegroundColorAttributeName:kDF_RGBA(139, 139, 139, 1)};
        
        NSMutableAttributedString *string_1 = [[NSMutableAttributedString alloc] initWithString:@" +8db" attributes:setDict];
        lb_1.attributedText = string_1;
        
        UILabel *lb_0 = [[UILabel alloc] init];
        lb_0.numberOfLines = 0;
        [self addSubview:lb_0];
        NSMutableAttributedString *string_0 = [[NSMutableAttributedString alloc] initWithString:@" 0db"  attributes:setDict];
        lb_0.attributedText = string_0;
        
        UILabel *lb_2 = [[UILabel alloc] init];
        lb_2.numberOfLines = 0;
        [self addSubview:lb_2];
        NSMutableAttributedString *string_2 = [[NSMutableAttributedString alloc] initWithString:@" -8db" attributes:setDict];
        lb_2.attributedText = string_2;
        
        lb_1.bounds = CGRectMake(0, 0, 35, 8);
        lb_0.bounds = CGRectMake(0, 0, 35, 8);
        lb_2.bounds = CGRectMake(0, 0, 35, 8);
        
        lb_1.center = CGPointMake(20,kSliderGap_HEAD+5);
        lb_0.center = CGPointMake(20,(sH-kSliderGap_HEAD-kSliderGap_FOOT)/2.0+kSliderGap_HEAD);
        lb_2.center = CGPointMake(20,sH-kSliderGap_FOOT-5);
        
        subScrollView = [UIScrollView new];
        subScrollView.frame = CGRectMake(40.0, 0, sW-40.0, sH-kSliderGap_FOOT+kSliderLabel_H);
        subScrollView.alwaysBounceHorizontal = YES;
        subScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:subScrollView];
        
        
        nowFrequencyArray = @[@(32),@(64),@(125),@(250),@(500),@(1000),@(2000),@(4000),@(8000),@(16000)];
        [self addSliderWithFrequencyArray:nowFrequencyArray];


        lb_view = [[DFLabelView alloc] init];
        lb_view.alpha = 0;
        lb_view.tag = 333;
        [subScrollView addSubview:lb_view];
        
        bottomView = [UIView new];
        bottomView.frame = CGRectMake(-10, sH-20-1.0, sW+10.0, 1.0);
        bottomView.backgroundColor = kDF_RGBA(237.0, 237.0, 237.0, 1.0);
        [self addSubview:bottomView];
        
        [self addNote];
    }
    return self;
}

-(void)setBottomColor:(UIColor*)color{
    bottomView.backgroundColor = color;
}

-(void)addSliderWithFrequencyArray:(NSArray*)array{
    
    eq_number_change = 0;
    eq_down_array = [NSMutableArray new];
    for (int i = 0; i < array.count; i++) {
        [eq_down_array addObject:@(0)];
    }
    
    NSInteger ct = array.count;
    
    float needLen = mSliderGap*ct;
    float scrollView_W = subScrollView.frame.size.width;
    if (needLen < scrollView_W) {
        mSliderGap = scrollView_W/((float)ct);
        //NSLog(@"Slider Gap ---> %.1f",mSliderGap);
    }

    subScrollView.contentSize = CGSizeMake(array.count*mSliderGap,sH-kSliderGap_HEAD-kSliderGap_FOOT);
    for (int i = 0 ; i < array.count; i++) {
        UISlider *sld = [UISlider new];
        sld.bounds = CGRectMake(0, 0, sH-kSliderGap_HEAD-kSliderGap_FOOT, 15);
        sld.center = CGPointMake(22.5+mSliderGap*i, (sH-kSliderGap_HEAD-kSliderGap_FOOT)/2.0+kSliderGap_HEAD);
        sld.transform = CGAffineTransformRotate(sld.transform, -M_PI/2.0);
        sld.maximumValue = +8.0;
        sld.minimumValue = -8.0;
        sld.value = 0;
        sld.tag = i+1;
        
        JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        
        if(_eqType == 0){
            if(model.karaokeEQType == JL_KaraokeEQTypeYES){
                sld.minimumTrackTintColor = kDF_RGBA(187, 187, 187, 1);
                sld.userInteractionEnabled = NO;
                subScrollView.userInteractionEnabled = NO;
            }
            if(model.karaokeEQType == JL_KaraokeEQTypeNO){
                sld.minimumTrackTintColor = kColor_0000;
                sld.userInteractionEnabled = YES;
                subScrollView.userInteractionEnabled = YES;
            }
        }
        if(_eqType==1){
            sld.minimumTrackTintColor = kColor_0000;
            sld.userInteractionEnabled = YES;
            subScrollView.userInteractionEnabled = YES;
        }

        sld.maximumTrackTintColor = kDF_RGBA(225, 225, 225, 1);
        
        [sld setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_btn_slider_nor"] forState:UIControlStateNormal];
        [sld setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_btn_slider_pre"] forState:UIControlStateHighlighted];
        
        [sld addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpOutside];
        [sld addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpInside];
        [sld addTarget:self action:@selector(sliderUIUpdateDown:) forControlEvents:UIControlEventTouchDown];
        [sld addTarget:self action:@selector(sliderUIUpdateUp:) forControlEvents:UIControlEventTouchUpOutside];
        [sld addTarget:self action:@selector(sliderUIUpdateChanged:) forControlEvents:UIControlEventValueChanged];
        [subScrollView addSubview:sld];
        
        
        NSString *txt = nil;
        float fre = [array[i] floatValue]/1000.0;
        if (fre >= 1.0f) {
            txt = [NSString stringWithFormat:@"%dK",(int)fre];
        }else{
            txt = [NSString stringWithFormat:@"%d",[array[i] intValue]];
        }
        
        UILabel *lb = [UILabel new];
        lb.center = CGPointMake(22.5+mSliderGap*i, sH-kSliderGap_HEAD-kSliderGap_FOOT+kSliderLabel_H/2.0+kSliderGap_HEAD);
        lb.bounds = CGRectMake(0, 0, 50, 20);
        lb.textAlignment = NSTextAlignmentCenter;
        lb.textColor = kDF_RGBA(139, 139, 139, 1);
        lb.font = [UIFont systemFontOfSize:12];
        lb.text = txt;
        lb.tag  = 0;
        [subScrollView addSubview:lb];
    }
}

-(void)cleanSliderUI{
    for (UIView *view in subScrollView.subviews) {
        if (view.tag != 333) {
            [view removeFromSuperview];
        }
    }
}


static BOOL isDismiss = YES;
-(void)sliderUIUpdateDown:(UISlider*)slider{
    NSString *txt = [NSString stringWithFormat:@"%d",(int)slider.value];
    double progress = ((int)slider.value+8.0)/16.0;
    double slider_l = sH-kSliderGap_HEAD-kSliderGap_FOOT;
    float p_min = kSliderGap_HEAD-15.0;
    float p_max = kSliderGap_HEAD+slider_l - 35.0;

    isDismiss = NO;
    if (lb_view == nil) {
        lb_view = [[DFLabelView alloc] init];
        lb_view.alpha = 0;
        lb_view.tag = 333;
        [subScrollView addSubview:lb_view];
    }
    
    lb_view.alpha = 1.0;
    lb_view.center = CGPointMake(slider.center.x, p_max-(p_max-p_min)*progress);
    lb_view.mLabel.text = txt;
    [self bringSubviewToFront:lb_view];

        
    eq_number_change = (int)slider.value;
    [eq_down_array removeAllObjects];
    for (int i = 0; i < nowFrequencyArray.count; i++) {
        int vl = (int)[self sliderForTag:i+1].value;
        [eq_down_array addObject:@(vl)];
    }
    
//    int v1 = (int) [self sliderForTag:1].value;
//    int v2 = (int) [self sliderForTag:2].value;
//    int v3 = (int) [self sliderForTag:3].value;
//    int v4 = (int) [self sliderForTag:4].value;
//    int v5 = (int) [self sliderForTag:5].value;
//    int v6 = (int) [self sliderForTag:6].value;
//    int v7 = (int) [self sliderForTag:7].value;
//    int v8 = (int) [self sliderForTag:8].value;
//    int v9 = (int) [self sliderForTag:9].value;
//    int v10= (int) [self sliderForTag:10].value;
//    eq_down_array = @[@(v1),@(v2),@(v3),@(v4),@(v5),@(v6),@(v7),@(v8),@(v9),@(v10)];
}


-(void)sliderUIUpdateUp:(UISlider*)slider{
    [UIView animateWithDuration:0.4 animations:^{
        isDismiss = YES;
        self->lb_view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (isDismiss) {
            [self->lb_view removeFromSuperview];
            self->lb_view = nil;
        }
    }];
}

-(void)sliderUIUpdateChanged:(UISlider*)slider{
    NSString *txt = [NSString stringWithFormat:@"%d",(int)slider.value];
    double progress = ((int)slider.value+8.0)/16.0;
    double slider_l = sH-kSliderGap_HEAD-kSliderGap_FOOT;
    float p_min = kSliderGap_HEAD-15.0;
    float p_max = kSliderGap_HEAD+slider_l - 40.0;
    
    lb_view.center = CGPointMake(slider.center.x, p_max-(p_max-p_min)*progress);
    lb_view.mLabel.text = txt;

    int index = (int)slider.tag-1;
    int vl = (int)slider.value;
    
    slider.value = (float)vl;
    
    if (vl != eq_number_change) {
        if (eqUIBlock) { eqUIBlock(eq_down_array,vl,index);}
    }
    eq_number_change = vl;
}


/*--- 监测Slider变化 ---*/
-(void)sliderAction:(UISlider*)slider{

    [UIView animateWithDuration:0.4 animations:^{
        isDismiss = YES;
        self->lb_view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (isDismiss) {
            [self->lb_view removeFromSuperview];
            self->lb_view = nil;
        }
    }];
    
    
    NSMutableArray *outArr = [NSMutableArray new];
    for (int i = 0; i < nowFrequencyArray.count; i++) {
        int vl = (int)[self sliderForTag:i+1].value;
        [outArr addObject:@(vl)];
    }
    
//    int v1 = (int) [self sliderForTag:1].value;
//    int v2 = (int) [self sliderForTag:2].value;
//    int v3 = (int) [self sliderForTag:3].value;
//    int v4 = (int) [self sliderForTag:4].value;
//    int v5 = (int) [self sliderForTag:5].value;
//    int v6 = (int) [self sliderForTag:6].value;
//    int v7 = (int) [self sliderForTag:7].value;
//    int v8 = (int) [self sliderForTag:8].value;
//    int v9 = (int) [self sliderForTag:9].value;
//    int v10= (int) [self sliderForTag:10].value;
//    NSArray *eqArr = @[@(v1),@(v2),@(v3),@(v4),@(v5),@(v6),@(v7),@(v8),@(v9),@(v10)];
    if (eqBlock) { eqBlock(outArr);}
}

/*--- 监测Slider的Tag变化 ---*/
-(UISlider*)sliderForTag:(NSInteger)tag{
    for (UIView *sl in subScrollView.subviews) {
        if ([sl isKindOfClass:[UISlider class]]) {
            UISlider *sub_sl = (UISlider *) sl;
            if (sub_sl.tag == tag) {
                return sub_sl;
            }
        }
    }
    return nil;
}

-(UILabel*)labelBlueOnSlider:(UISlider*)slider Tag:(NSInteger)tag{
    for (UIView *lb in slider.subviews) {
        if ([lb isKindOfClass:[UILabel class]]) {
            UILabel *sub_lb = (UILabel *) lb;
            if (sub_lb.tag == tag) {
                return sub_lb;
            }
        }
    }
    return nil;
}

-(void)setSliderEqArray:(NSArray*)eqArray EqFrequecyArray:(NSArray * _Nullable)eqFre EqType:(JL_EQType)eqType{
    
    if (eqType == JL_EQType10) {
        NSArray *freArr = @[@(32),@(64),@(125),@(250),@(500),@(1000),@(2000),@(4000),@(8000),@(16000)];
        if (![freArr isEqualToArray:nowFrequencyArray]) {
            [self cleanSliderUI];
            [self addSliderWithFrequencyArray:freArr];
            nowFrequencyArray = freArr;
        }
    }
    
    if (eqType == JL_EQTypeMutable) {
        if (![eqFre isEqualToArray:nowFrequencyArray] && eqFre.count>0) {
            [self cleanSliderUI];
            [self addSliderWithFrequencyArray:eqFre];
            nowFrequencyArray = eqFre;
        }
    }
    
    
    for (int i = 0; i < eqArray.count; i++) {
        int eq = [eqArray[i] intValue];
        UISlider *slider = [self sliderForTag:i+1];
        int eq_now = (int)slider.value;
        if(eq == eq_now && eq == 0){
            slider.value = (float)eq;
        }
        if (eq_now != eq) {
            slider.value = (float)eq;
        }
    }
}

-(void)outputEqArray:(DFSliderViewBlock __nullable)block
            ChangeUI:(DFSliderViewUIChangeBlock __nullable)blockUI{
    eqBlock = block;
    eqUIBlock = blockUI;
}

-(void)noteDeviceChange:(NSNotification*)note{
    [self sliderAction:nil];
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}
@end
