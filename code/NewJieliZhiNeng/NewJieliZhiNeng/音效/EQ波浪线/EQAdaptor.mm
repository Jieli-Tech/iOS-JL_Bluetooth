//
//  EQAdaptor.m
//  newAPP
//
//  Created by EzioChan on 2020/6/5.
//  Copyright © 2020 Ezio. All rights reserved.
//

#import "EQAdaptor.h"
#include "EQPlotCore.h"
#include "EQPlotCore_br26.h"
#import "NSArray+Compare.h"
#import <UIKit/UIKit.h>

class EQPlotCore_br26;

@interface EQAdaptor(){
    RESULT rblock;
    int hight;
    int width;
    NSArray *cf;
    NSArray *eqA;
    @private
    EQPlotCore_br26 *br30;
    SOS_Para *para;
}

@end

@implementation EQAdaptor

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        cf = @[@(20),@(32),@(64),@(125),@(250),@(500),@(1000),@(2000),@(4000),@(8000),@(16000),@(22000)];
        para = new SOS_Para[10];
    }
    return self;
}

/// 设置宽高
/// @param w 宽
/// @param h 高
-(void)setSize:(int)w hight:(int)h{
    hight = h;
    width = w;
}
-(void)setCfArray:(NSArray *)cfArray{
    NSMutableArray *ma = [NSMutableArray new];
    float tolerance = log10(32)-log10(20);
    float kn0 = log10([cfArray.firstObject floatValue])-tolerance;
    float knLast = log10([cfArray.lastObject floatValue])+tolerance;
    float first = pow(10, kn0);
    float last = pow(10, knLast);
    [ma addObject:@(first)];
    for (int i = 0; i<cfArray.count; i++) {
        [ma addObject:cfArray[i]];
    }
    [ma addObject:@(last)];
    cf = ma;
    //NSLog(@"cf:%@",cf);
}

-(void)initWithArray:(NSArray *)eq withHight:(int)h width:(int)w
{
//    if (eq.count>eqA.count) {
//        cf = @[@(20),@(32),@(64),@(125),@(250),@(500),@(1000),@(2000),@(4000),@(8000),@(16000),@(22000)];
//    }
    eqA = eq;
    if (eqA.count>(cf.count-2)) {
        return;
    }
    NSArray *kt = @[@(20),@(32),@(64),@(125),@(250),@(500),@(1000),@(2000),@(4000),@(8000),@(16000),@(22000)];
    
    for (int k = 0; k<10; k++) {
        SOS_Para so1 = SOS_Para();
        so1.CenterFrequency = [kt[k+1] floatValue];//中心频率
        so1.fEnable = true;//？
        so1.Gain = 0;//增益
        so1.QVaule = 1.5f;//Q值
        so1.type = bandpass;//
        para[k] = so1;
    }
    for (int i = 0;i<eq.count;i++) {
        float k = [eq[i] floatValue];
        SOS_Para so1 = SOS_Para();
        so1.CenterFrequency = [cf[i+1] floatValue];//中心频率
        so1.fEnable = true;//？
        so1.Gain = k;//增益
        so1.QVaule = 1.5f;//Q值
        so1.type = bandpass;//
        para[i] = so1;
    }
    hight = h;
    width = w;
    float x1[w];
    float maxX = [[cf valueForKeyPath:@"@max.floatValue"] floatValue];
    float minX = [[cf valueForKeyPath:@"@min.floatValue"] floatValue];
    float b = (log10(maxX)-log10(minX))/(w+1);
    for (int i = 0; i<w; i++) {
        float c = pow(10, log10(minX)+i*b);
        x1[i] = c;
//        printf("c:%f\n",c);
    }
    br30 = new EQPlotCore_br26(x1, w, para, 10);
    
    
}

-(void)calculaterForOne:(int)num withIndex:(int)index eqArray:(NSArray *)eq result:(RESULT)result{
    
//    NSLog(@"setUpEqArray 1111%@ eqArray%@,eqA:%@",cf,eq,eqA);
    if (![eq isEqualToArray:eqA]) {
        [self initWithArray:eq withHight:hight width:width];
    }
    
    if (br30 == NULL) {
        [self initWithArray:eq withHight:hight width:width];
    }
//    [self initWithArray:eq withHight:hight width:width];
    [self calculaterForOne:num withIndex:index result:result];
    
}


-(void)calculaterForAll:(int)num withIndex:(int)index eqArray:(NSArray *)eq result:(RESULT)result{
    if ([eq isSame:eqA]) {
        return;
    }else{
//        NSLog(@"setUpEqArray 1111%@ eqArray%@,eqA:%@",cf,eq,eqA);
        [self initWithArray:eq withHight:hight width:width];
        [self calculaterForOne:num withIndex:index result:result];
//        eqA = eq;
    }
}


-(void)calculaterForOne:(int)num withIndex:(int)index result:(RESULT)result{
    rblock = result;
    SOS_Para so1 = SOS_Para();
    so1.CenterFrequency = [cf[index+1] floatValue];//中心频率
    so1.fEnable = true;//？
    so1.Gain = num;//增益
    so1.QVaule = 1.5f;//Q值
    so1.type = bandpass;//
    para[index] = so1;
//    NSLog(@"%d",num);
    __weak typeof (self) wself = self;
    
    float y[self->width];
    memset(y, 0, sizeof(y));
    if (self->br30 != NULL) {
        self->br30->GetEQPlotData(y, &self->para[index], index, 0.0);
    }
    NSArray *newArray = [wself setUpPoints:y];
//    dispatch_async(dispatch_get_main_queue(), ^{
        self->rblock(newArray);
//    });
    
}





-(NSArray *)setUpPoints:(float *)y{
    
//    for (int k=0 ;k<width;k++) {
//        printf("%f \t",y[k]);
//    }
    NSMutableArray *newArray = [NSMutableArray new];
    int w = width;
    for (int i = 0; i<w; i++) {
        CGFloat h1;
        if (y[i]<0) {
            h1 = hight-hight*(24-12+y[i])/24;
        }else{
            h1 = hight-hight*(12+y[i])/24;
        }
        CGPoint point = CGPointMake(i, h1);
        [newArray addObject:[NSValue valueWithCGPoint:point]];
    }
    return newArray;
}

-(void)dealloc{
    if (br30 != NULL) {
        delete br30;
    }
   
}


-(NSArray *)getCenterFrequencys{
    return cf;
}



@end
