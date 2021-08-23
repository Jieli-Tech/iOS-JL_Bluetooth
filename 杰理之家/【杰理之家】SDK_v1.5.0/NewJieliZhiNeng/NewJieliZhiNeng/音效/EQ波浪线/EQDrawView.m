//
//  EQDrawView.m
//  newAPP
//
//  Created by EzioChan on 2020/6/3.
//  Copyright © 2020 Ezio. All rights reserved.
//

#import "EQDrawView.h"
#import "EQAdaptor.h"
#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"
#import "EQDefaultCache.h"

#define kColor_EQ_NOENABLE  {187.0/255.0,  187.0/255.0, 187.0/255.0, 1.00, 187.0/255.0, 187.0/255.0, 187.0/255.0, 1.00}

@interface EQDrawView(){
    EQAdaptor *eqS;
    
    NSArray *pointArr;
    NSArray *eqBase;
    
    float sW;
    float sH;
}
@end

@implementation EQDrawView


- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawPoints:pointArr];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor whiteColor];
        
        eqS = [[EQAdaptor alloc] init];
        [eqS setSize:self.frame.size.width hight:self.frame.size.height-11];
        [self addNote];
    }
    return self;
}


-(void)drawPoints:(NSArray *)pointArray{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGPoint point0 = [pointArray.firstObject CGPointValue];
    //起点
    CGContextMoveToPoint(context, 0, self.frame.size.height);
    CGContextAddLineToPoint(context, point0.x, point0.y);
    for (NSValue *value in pointArray) {
        CGPoint point = [value CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGPoint pointEnd = CGPointMake(self.frame.size.width, self.frame.size.height);
    CGContextAddLineToPoint(context, pointEnd.x, pointEnd.y);
    //绘制前设置边框和填充颜色
    [kColor_0000 setStroke];
    [[UIColor clearColor] setFill];
    
    
    
    CGContextClip(context);
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
      
    if(model.karaokeEQType == JL_KaraokeEQTypeYES){
        CGFloat colors[] = kColor_EQ_NOENABLE;
        CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors) / (sizeof(colors[0]) * 4));
        CGColorSpaceRelease(rgb);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0,0.0), CGPointMake(0.0, self.frame.size.height), kCGGradientDrawsBeforeStartLocation);
        CGGradientRelease(gradient);
    }
    if(model.karaokeEQType == JL_KaraokeEQTypeNO){
        CGFloat colors[] = kColor_0003;
        CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors) / (sizeof(colors[0]) * 4));
        CGColorSpaceRelease(rgb);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0,0.0), CGPointMake(0.0, self.frame.size.height), kCGGradientDrawsBeforeStartLocation);
        CGGradientRelease(gradient);
    }

    
    
    CGFloat width = self.frame.size.width;
    CGFloat hieht = self.frame.size.height;
    CGFloat scale_tw ;
    CGFloat fontSize = 9;
    
    NSArray *cfArray = [eqS getCenterFrequencys];
    float xl = log10([cfArray.lastObject floatValue])-log10([cfArray.firstObject floatValue]);
    float divX = (width)/xl;
    float startX = -log10([cfArray.firstObject floatValue])*divX ;
    for (int i=0;i < eqBase.count; i++) {
        CGFloat width2 = log10([cfArray[i+1] floatValue])*divX + startX;
        int eq = [eqBase[i] intValue];
        NSString *predictionTxt = [NSString stringWithFormat:@"%d",eq];
        CGSize size =[predictionTxt sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
        scale_tw = size.width;
        NSDictionary * textAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                                         NSForegroundColorAttributeName:[UIColor whiteColor],
                                         NSParagraphStyleAttributeName: [NSParagraphStyle defaultParagraphStyle]};
        [predictionTxt drawInRect:CGRectMake(width2-scale_tw/2, hieht-11, scale_tw, 10) withAttributes:textAttribute];
        //划线
        int cW = width2;
//        NSLog(@"%f,%d",width2,cW);
        CGPoint ppt = [pointArray[cW] CGPointValue];
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetAlpha(context,1.0);
        CGFloat hight = ppt.y;
        //NSLog(@"%f",hight);
        UIRectFill(CGRectMake(width2, hight, 0.5, self.frame.size.height-hight-11));
    }
       
    
}

/// 传入eq
/// @param eqArray eq
-(void)setUpEqArray:(NSArray *)eqArray{
    //NSLog(@"setUpEqArray ----> %@",eqArray);
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:eqArray];
    eqBase = newArray;
    [eqS calculaterForOne:[eqArray[0] floatValue] withIndex:0 eqArray:eqArray result:^(NSArray * _Nonnull pointArray) {
        self->pointArr = pointArray;
        [self setNeedsDisplay];
    }];
}



/// 传入要修改的某个值
/// @param eqArray EQ数组
/// @param number 增益
/// @param index 序号
-(void)setUpEqArray1:(NSArray *)eqArray withNum:(int) number withIndex:(int) index{
    if (!eqArray) {
        NSLog(@"eqArray:%@ number:%d,index:%d",eqArray,number,index);
        return;
    }
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:eqArray];
    newArray[index] = @(number);
    eqBase = newArray;
    [eqS calculaterForOne:number withIndex:index eqArray:eqArray result:^(NSArray * _Nonnull pointArray) {
        self->pointArr = pointArray;
        [self setNeedsDisplay];
    }];
}

/// 传入要修改的某个值(自定义)
/// @param cfArray 中心频率数组
/// @param eqArray EQ数组
/// @param number 增益
/// @param index 序号
-(void)setUpCenterFrequency:(NSArray * __nullable)cfArray EqArray:(NSArray *)eqArray withNum:(int) number withIndex:(int) index{
    if (!eqArray) {
        NSLog(@"eqArray:%@ number:%d,index:%d",eqArray,number,index);
        return;
    }
    if (cfArray.count > 0) [eqS setCfArray:cfArray];
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:eqArray];
    newArray[index] = @(number);
    eqBase = newArray;
    [eqS calculaterForOne:number withIndex:index eqArray:eqArray result:^(NSArray * _Nonnull pointArray) {
        self->pointArr = pointArray;
        [self setNeedsDisplay];
    }];
}


/// 传入EQ整个数组
/// @param eqArray eq
/// @param mode 类型
-(void)setUpEqArrayAll:(NSArray *)eqArray withType:(JL_EQMode)mode{
    
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:eqArray];
    eqBase = newArray;
    [eqS calculaterForOne:[eqArray[0] floatValue] withIndex:0 eqArray:eqArray result:^(NSArray * _Nonnull pointArray) {
        self->pointArr = pointArray;
        [self setNeedsDisplay];
    }];
    [[EQDefaultCache sharedInstance] saveEq:eqArray withName:mode];
    [[EQDefaultCache sharedInstance] saveCustom:eqArray mode:mode];
//    [eqS calculaterForAll:[eqArray[0] floatValue] withIndex:0 eqArray:eqArray result:^(NSArray * _Nonnull pointArray) {
//        self->pointArr = pointArray;
//        [self setNeedsDisplay];
//        [[EQDefaultCache sharedInstance] saveEq:eqArray withName:mode];
//        [[EQDefaultCache sharedInstance] saveCustom:eqArray mode:mode];
//    }];
    
}

/// 传入EQ整个数组
/// @param eqArray eq
/// @param cfArray center frequency
/// @param mode 类型
-(void)setUpEqArrayAll:(NSArray *)eqArray centerFrequency:(NSArray *__nullable)cfArray withType:(JL_EQMode)mode{
    
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:eqArray];
    eqBase = newArray;
    if(cfArray.count > 0){
        [eqS setCfArray:cfArray];
    }else{
        NSArray *cf = @[@(32),@(64),@(125),@(250),@(500),@(1000),@(2000),@(4000),@(8000),@(16000)];
        [eqS setCfArray:cf];
    }
    [eqS calculaterForAll:[eqArray[0] floatValue] withIndex:0 eqArray:eqArray result:^(NSArray * _Nonnull pointArray) {
        self->pointArr = pointArray;
        [self setNeedsDisplay];
        [[EQDefaultCache sharedInstance] saveEq:eqArray withName:mode];
        [[EQDefaultCache sharedInstance] saveCustom:eqArray mode:mode];
    }];
//    [eqS calculaterForOne:[eqArray[0] floatValue] withIndex:0 eqArray:eqArray result:^(NSArray * _Nonnull pointArray) {
//        self->pointArr = pointArray;
//        [self setNeedsDisplay];
//    }];
//    [[EQDefaultCache sharedInstance] saveEq:eqArray withName:mode];
//    [[EQDefaultCache sharedInstance] saveCustom:eqArray mode:mode];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
      
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    if(model.karaokeEQType == JL_KaraokeEQTypeYES){
        CGFloat colors[] = kColor_EQ_NOENABLE;
        CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors) / (sizeof(colors[0]) * 4));
        CGColorSpaceRelease(rgb);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0,0.0), CGPointMake(0.0, self.frame.size.height), kCGGradientDrawsBeforeStartLocation);
        CGGradientRelease(gradient);
    }
    if(model.karaokeEQType == JL_KaraokeEQTypeNO){
        CGFloat colors[] = kColor_0003;
        CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors) / (sizeof(colors[0]) * 4));
        CGColorSpaceRelease(rgb);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0,0.0), CGPointMake(0.0, self.frame.size.height), kCGGradientDrawsBeforeStartLocation);
        CGGradientRelease(gradient);
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}
@end
