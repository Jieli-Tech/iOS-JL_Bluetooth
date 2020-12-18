//
//  EQView.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "EQView.h"
#import "ItemsView.h"

@interface EQView()<ItemsViewDelegate>{
    ItemsView    *itemsView;
    UIView *eqView;
    NSArray *eqArray;
    UISlider *sl;
    int v1;
    int v2;
    int v3;
    int v4;
    int v5;
    int v6;
    int v7;
    int v8;
    int v9;
    int v10;
}

@end
@implementation EQView

-(id)initByFrame:(CGRect)rect{
    self = [super initWithFrame:rect];
    if (self) {
        self.frame = rect;
        [self initUI];
        [self updateDevice:nil];
        [self addNote];
    }
    return self;
}

/*--- 初始化界面 ---*/
-(void) initUI{
    /*--- 顶部模式选择 ---*/
    itemsView = [[ItemsView alloc] init];
    if([DFUITools screen_2_W] == 320.0){
        itemsView.frame = CGRectMake(5, 5, self.frame.size.width-14, 160);
    }else{
        itemsView.frame = CGRectMake(5, 20, self.frame.size.width-14, 160);
    }
    itemsView.delegate = self;
    [self addSubview:itemsView];
    
    /*--- UISlider调节 ---*/
    [self drawEQSlider];
}

-(void)drawEQSlider{
    eqView = [[UIView alloc] init];
    if([DFUITools screen_2_W] ==320){
        eqView.frame = CGRectMake(30, itemsView.frame.origin.y+itemsView.frame.size.height-50, [DFUITools screen_2_W]-60, [DFUITools screen_2_H]-154);
    }else{
        eqView.frame = CGRectMake(32, itemsView.frame.origin.y+itemsView.frame.size.height-30, [DFUITools screen_2_W]-64, [DFUITools screen_2_H]-154);
    }
    [self addSubview:eqView];
    
    CGFloat sH = [DFUITools screen_2_H];
    CGFloat sW = [DFUITools screen_2_W];
    
    /*--- 由于只兼容iPhone尺寸 ---*/
    if (sW > 414.0) sW = 320.0;
    if (sH > 812.0) sH = 480.0;
    
    NSArray *lbTexts = @[@"32",@"64",@"125",@"250",@"500",@"1K",@"2K",@"4K",@"8K",@"16K"];
    
    CGFloat c_h;
    if([UIScreen mainScreen].bounds.size.height >=896.0){
        c_h = 550; // iphone XR
    }else if([UIScreen mainScreen].bounds.size.height ==812.0){
        c_h = 480; // iphone X
    }else{
        if([DFUITools screen_2_W] ==320){
            c_h = sH - 250;
        }else{
            c_h = sH - 300;
        }
    }
    
    for (int i = 0; i < 10; i++) {
        UILabel *lb = [UILabel new];
        lb.bounds = CGRectMake(0, 0, sW/10.0, 20.0);
        float sl_h = c_h-20.0;
        //float sl_w = sW/10.0;
        
        sl = [UISlider new];
        if([DFUITools screen_2_W] ==320){
            sl.bounds = CGRectMake(0, 0, sl_h-54, 15);
        }else{
            sl.bounds = CGRectMake(0, 0, sl_h-54, 1);
        }
        sl.center = CGPointMake((sW/12.0/2.0)+(sW/12.0)*i, (sl_h)/2.0+20.0);
        sl.transform = CGAffineTransformMakeRotation(-M_PI_2);
        
        if (@available(iOS 13.0, *)) {
            UIColor *maxSliderColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:93/255.0 green:94/255.0 blue:109/255.0 alpha:1.0];
                }
            }];
            UIColor *minSliderColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:128/255.0 green:91/255.0 blue:235/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:103/255.0 green:110/255.0 blue:218/255.0 alpha:1.0];
                }
            }];
            sl.maximumTrackTintColor = maxSliderColor;
            sl.minimumTrackTintColor = minSliderColor;
        } else {
            // Fallback on earlier versions
            sl.maximumTrackTintColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
            sl.minimumTrackTintColor = [UIColor colorWithRed:128/255.0 green:91/255.0 blue:235/255.0 alpha:1.0];
        }
        sl.maximumValue = 12;
        sl.minimumValue = -12;
        sl.value = 0;
        sl.tag = i+1;
        [sl addTarget:self action:@selector(sliderAction:)
     forControlEvents:UIControlEventTouchUpInside];
        [eqView addSubview:sl];
        [sl setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_btn_slider_nor"] forState:UIControlStateNormal];
        [sl setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_btn_slider_pre"] forState:UIControlStateHighlighted];
        
        lb.center = CGPointMake((sW/12.0/2.0)+(sW/12.0)*i, sl_h+8);
        lb.textColor = [UIColor colorWithRed:138/255.0 green:138/255.0 blue:138/255.0 alpha:1.0];
        lb.font= [UIFont fontWithName:@"PingFang SC" size: 11.0];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.text= lbTexts[i];
        lb.tag = i+1;
        [eqView addSubview:lb];
    }
    
    [self drawEQLabel];
}

/*--- 绘制 +12db 0db -12db ---*/
-(void)drawEQLabel{
    CGFloat sH = [DFUITools screen_2_H];
    CGFloat sW = [DFUITools screen_2_W];
    
    /*--- 由于只兼容iPhone尺寸 ---*/
    if (sW > 414.0) sW = 320.0;
    if (sH > 812.0) sH = 480.0;
    CGFloat c_h;
    if([UIScreen mainScreen].bounds.size.height >=896.0){
        c_h = 550; // iphone XR
    }else if([UIScreen mainScreen].bounds.size.height ==812.0){
        c_h = 480; // iphone X
    }else{
        if([DFUITools screen_2_W] ==320){
            c_h = sH - 250;
        }else{
            c_h = sH - 300;
        }
    }
    float sl_h = c_h-20.0;
   // float sl_w = sW/10.0;
    
    UILabel *topLabel = [[UILabel alloc] init];
    if([DFUITools screen_2_W] ==320){
        topLabel.frame = CGRectMake(4,163,35,9.5);
    }else{
        topLabel.frame = CGRectMake(4,203,35,9.5);
    }
    topLabel.numberOfLines = 0;
    [self addSubview:topLabel];
    NSMutableAttributedString *topStr = [[NSMutableAttributedString alloc] initWithString:@"+12db" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 12],NSForegroundColorAttributeName: [UIColor colorWithRed:139/255.0 green:139/255.0 blue:139/255.0 alpha:1.0]}];
    topLabel.attributedText = topStr;
    
    UILabel *midLabel = [[UILabel alloc] init];
    if([DFUITools screen_2_W] ==320){
        midLabel.frame = CGRectMake(11,(sl_h)/2.0+125.0,35,9.5);
    }else{
        midLabel.frame = CGRectMake(11,(sl_h)/2.0+165.0,35,9.5);
    }
    midLabel.numberOfLines = 0;
    [self addSubview:midLabel];
    NSMutableAttributedString *midStr = [[NSMutableAttributedString alloc] initWithString:@"0db" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 12],NSForegroundColorAttributeName: [UIColor colorWithRed:139/255.0 green:139/255.0 blue:139/255.0 alpha:1.0]}];
    midLabel.attributedText = midStr;
    
    UILabel *bottomLabel = [[UILabel alloc] init];
    if([DFUITools screen_2_W] ==320){
        bottomLabel.frame = CGRectMake(4,sl_h+100.0,35,9.5);
    }else{
        bottomLabel.frame = CGRectMake(4,sl_h+130.0,35,9.5);
    }
    bottomLabel.numberOfLines = 0;
    [self addSubview:bottomLabel];
    NSMutableAttributedString *bottomStr = [[NSMutableAttributedString alloc] initWithString:@"-12db" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 12],NSForegroundColorAttributeName: [UIColor colorWithRed:139/255.0 green:139/255.0 blue:139/255.0 alpha:1.0]}];
    bottomLabel.attributedText = bottomStr;
}

/*--- 监测Slider变化 ---*/
-(void)sliderAction:(UISlider*)slider{
    v1 = (int) [self sliderForTag:1].value;
    v2 = (int) [self sliderForTag:2].value;
    v3= (int) [self sliderForTag:3].value;
    v4 = (int) [self sliderForTag:4].value;
    v5 = (int) [self sliderForTag:5].value;
    v6 = (int) [self sliderForTag:6].value;
    v7 = (int) [self sliderForTag:7].value;
    v8 = (int) [self sliderForTag:8].value;
    v9 = (int) [self sliderForTag:9].value;
    v10 = (int) [self sliderForTag:10].value;
    NSArray *eqArray =@[@(v1),@(v2),@(v3),@(v4),@(v5),@(v6),@(v7),@(v8),@(v9),@(v10)];
    [JL_Manager cmdSetSystemEQ:JL_EQModeCUSTOM Params:eqArray];
}

/*--- 监测Slider的Tag变化 ---*/
-(UISlider*)sliderForTag:(NSInteger)tag{
    for (UIView *sl in eqView.subviews) {
        if ([sl isKindOfClass:[UISlider class]]) {
            UISlider *sub_sl = (UISlider *) sl;
            if (sub_sl.tag == tag) {
                return sub_sl;
            }
        }
    }
    return nil;
}

/*--- 监测EQ模式的变化 ---*/
-(void)onItemsView:(ItemsView *)view didSelect:(NSString *)info{
    if([info isEqualToString:kJL_TXT("自然")]){
        NSArray *normalArray =@[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
        [JL_Manager cmdSetSystemEQ:JL_EQModeNORMAL Params:normalArray];
    }
    if([info isEqualToString:kJL_TXT("摇滚")]){
        NSArray *rockArray =@[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
        [JL_Manager cmdSetSystemEQ:JL_EQModeROCK Params:rockArray];
    }
    if([info isEqualToString:kJL_TXT("流行")]){
        NSArray *popArray =@[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
        [JL_Manager cmdSetSystemEQ:JL_EQModePOP Params:popArray];
    }
    if([info isEqualToString:kJL_TXT("经典")]){
        NSArray *classicArray =@[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
        [JL_Manager cmdSetSystemEQ:JL_EQModeCLASSIC Params:classicArray];
    }
    if([info isEqualToString:kJL_TXT("爵士")]){
        NSArray *jazzArray =@[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
        [JL_Manager cmdSetSystemEQ:JL_EQModeJAZZ Params:jazzArray];
    }
    if([info isEqualToString:kJL_TXT("乡村")]){
        NSArray *countryArray =@[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
        [JL_Manager cmdSetSystemEQ:JL_EQModeCOUNTRY Params:countryArray];
    }
    if([info isEqualToString:kJL_TXT("自定义")]){
        NSArray *customArray =@[@(v1),@(v2),@(v3),@(v4),@(v5),@(v6),@(v7),@(v8),@(v9),@(v10)];
        [JL_Manager cmdSetSystemEQ:JL_EQModeCUSTOM Params:customArray];
    }
}

/*--- 处理EQ的UISlider的逻辑变化 ---*/
-(void)handleEQSlider{
    JLDeviceModel *devel = [JL_Manager outputDeviceModel];
      [self->itemsView setItemsMode:devel.eqMode];

      int i = 0;
      NSArray *arr = devel.eqArray;
      for (NSNumber *vl in arr) {
          int value = [vl intValue];
          UISlider *sl = [self sliderForTag:i+1];
          sl.value = (float)value;
          i++;
      }
      
      if (devel.eqMode == JL_EQModeCUSTOM &&
          arr.count == 10)
      {
          v1 = [arr[0] intValue];
          v2 = [arr[1] intValue];
          v3 = [arr[2] intValue];
          v4 = [arr[3] intValue];
          v5 = [arr[4] intValue];
          v6 = [arr[5] intValue];
          v7 = [arr[6] intValue];
          v8 = [arr[7] intValue];
          v9 = [arr[8] intValue];
          v10= [arr[9] intValue];
      }
}

-(void)updateDevice:(NSNotification *)note{
    [self handleEQSlider];
}

-(void)noteEqUpdate:(NSNotification*)note{
     [self handleEQSlider];
}

-(void)addNote{

    [JLDeviceModel observeModelProperty:@"eqArray" Action:@selector(noteEqUpdate:) Own:self];
    [JL_Tools add:kUI_JL_UPDATE_STATUS Action:@selector(updateDevice:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

@end
