//
//  IndexPlate.m
//  AiRuiSheng
//
//  Created by DFung on 2017/3/8.
//  Copyright © 2017年 DFung. All rights reserved.
//

#import "IndexPlate.h"
#import "FMPickView.h"


@interface IndexPlate (){
    CALayer     *mLayer;
    CGFloat     view_W;
    CGFloat     view_H;
    NSInteger   mIndex;
    CGFloat     gap;
    CGFloat     gap_txt;
    
    UIImageView *mImageView;
}

@end


@implementation IndexPlate


- (instancetype)initWithIndex:(NSInteger)index WithHeight:(float)height
{
    self = [super init];
    if (self) {

        self.frame = CGRectMake(0, 0, index*10.0*kMIN_GAP+kFMPickViewGAP, height);
        mIndex = index;
        view_W = index*10.0*kMIN_GAP+kFMPickViewGAP;
        view_H = height;
        gap = 7.0;
        gap_txt = 30.0;
        
        [DFAction delay:0.05 Task:^{
            [self setupUI];
            UIImage *image = [self snapshotImage];
            [self->mLayer removeFromSuperlayer];
            self->mLayer = nil;
            
            CGRect rect = CGRectMake(0, 0, self->view_W, self->view_H);
            self->mImageView = [[UIImageView alloc] initWithFrame:rect];
            self->mImageView.contentMode = UIViewContentModeScaleToFill;
            self->mImageView.image = image;
            [self addSubview:self->mImageView];
        }];
    }
    return self;
}


-(void)setupUI{

    [mLayer removeFromSuperlayer];

    //创建自定义的layer
    mLayer =[CALayer layer];
    mLayer.backgroundColor= [UIColor clearColor].CGColor;
    mLayer.frame=CGRectMake(0, 0, view_W, view_H);
    mLayer.allowsEdgeAntialiasing = YES;
    mLayer.delegate = self;
    [self.layer addSublayer:mLayer];
    
    [mLayer setNeedsDisplay];//重载-drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx；
}


-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    /*--- 描绘刻度 ---*/
    for (NSInteger i = 0; i <= mIndex*10; i++)
    {
        /*--- 小刻度 ---*/
        if (i%5 != 0 && i>4) {
            [self drawScale10:i*kMIN_GAP+kFMPickViewGAP/2.0 Context:ctx];
        }
        
        /*--- 大刻度 ---*/
        if (i%5 == 0 && i!=0) {
            [self drawScale20:i*kMIN_GAP+kFMPickViewGAP/2.0 Context:ctx];
            
            /*--- 刻度数字 ---*/
            float fp = (float)i/10.0+_startPiont;
            NSString *text = [NSString stringWithFormat:@"%.1f",fp];
            [self drawLabel:i*kMIN_GAP+kFMPickViewGAP/2.0 Text:text Layer:layer];
        }
    }
}




#pragma mark --> 画大刻度
-(void)drawScale20:(float)x Context:(CGContextRef)ctx{
    // 创建一个新的空图形路径。
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x, 0.0);
    CGContextAddLineToPoint(ctx, x, view_H-gap_txt);
    // 设置图形的线宽
    CGContextSetLineWidth(ctx, 1.5);
    CGContextSetShouldAntialias(ctx, NO);
    // 设置图形描边颜色
    CGContextSetStrokeColorWithColor(ctx, kDF_RGBA(80, 80, 80, 1.0).CGColor);
    // 根据当前路径，宽度及颜色绘制线
    CGContextStrokePath(ctx);
}

#pragma mark --> 画小刻度
-(void)drawScale10:(float)x Context:(CGContextRef)ctx{
    // 创建一个新的空图形路径。
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x, gap);
    CGContextAddLineToPoint(ctx, x, view_H-gap_txt-gap);
    // 设置图形的线宽
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetShouldAntialias(ctx, NO);
    // 设置图形描边颜色
    CGContextSetStrokeColorWithColor(ctx, kDF_RGBA(134, 134, 134, 1.0).CGColor);
    // 根据当前路径，宽度及颜色绘制线
    CGContextStrokePath(ctx);
}

#pragma mark --> 在刻度上标记文本
-(void)drawLabel:(float)x Text:(NSString*)text Layer:(CALayer*)layer{
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = text;
    textLayer.fontSize = 11.5;
    textLayer.contentsScale = 3.5;
    textLayer.alignmentMode = @"center";
    textLayer.frame = CGRectMake(x-25.0, view_H-15, 50.0f, 18.0f);
    textLayer.backgroundColor = [UIColor clearColor].CGColor;
    textLayer.foregroundColor = kDF_RGBA(90.0, 90.0, 90.0, 1.0).CGColor;
    [layer addSublayer:textLayer];
}

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(mLayer.bounds.size, mLayer.opaque, 0);
    [mLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
