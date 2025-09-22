//
//  BezierView.m
//  newAPP
//
//  Created by EzioChan on 2020/5/27.
//  Copyright © 2020 Ezio. All rights reserved.
//

#import "BezierView.h"


@interface BezierView(){
 
    UIBezierPath *path;
}
@end

@implementation BezierView


- (void)drawRect:(CGRect)rect {
    [path stroke];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = self.bounds;
        layer.lineWidth = 1;
        layer.strokeColor = [UIColor redColor].CGColor;
        layer.fillColor = UIColor.grayColor.CGColor;
        layer.backgroundColor = [UIColor blackColor].CGColor;

        path = [UIBezierPath bezierPath];
        
        CGPoint a = CGPointMake(10, 80);
        CGPoint b = CGPointMake(40, 5);
        
        CGPoint c = CGPointMake(70, 65);
        CGPoint c1 = CGPointMake(55, 35);
        CGPoint d = CGPointMake(100, 35);
        CGPoint d1 = CGPointMake(85, 50);
        
        CGPoint e = CGPointMake(130, 65);
        CGPoint e1 = CGPointMake(115, 50);
        
        CGPoint f = CGPointMake(160, 45);
        CGPoint f1 = CGPointMake(290/2, (45+65)/2);
        
        CGPoint g = CGPointMake(190, 55);
        CGPoint g1 = CGPointMake((190+160)/2, (55+45)/2);
        
        CGPoint h = CGPointMake(220, 0);
        CGPoint h1 = CGPointMake((220+190)/2, (2+55)/2);
        
        CGPoint h2 = CGPointMake((250+220)/2, 80);
        [path moveToPoint:a];// a
//        [path moveToPoint:b];// b
//        [path moveToPoint:c];// c
//        [path moveToPoint:d];// d
        
        
//        [path moveToPoint:CGPointMake(50, 65)];// e
//        [path moveToPoint:];// f
//        [path moveToPoint:];// g
//        [path moveToPoint:];// h
//        [path addCurveToPoint:d controlPoint1:b controlPoint2:c];
//        [path addCurveToPoint:f controlPoint1:d controlPoint2:e];
            
        [path addQuadCurveToPoint:c1 controlPoint:b];
        [path addQuadCurveToPoint:d1 controlPoint:c];
        [path addQuadCurveToPoint:e1 controlPoint:d];
        [path addQuadCurveToPoint:f1 controlPoint:e];
        [path addQuadCurveToPoint:g1 controlPoint:f];
        [path addQuadCurveToPoint:h1 controlPoint:g];
        [path addQuadCurveToPoint:h2 controlPoint:h];
//        [path addQuadCurveToPoint:e controlPoint:d];
//        [path addQuadCurveToPoint:CGPointMake(20, 5) controlPoint:CGPointMake(30, 65)];//bc
//        [path addQuadCurveToPoint:CGPointMake(30, 5) controlPoint:CGPointMake(40, 35)];//cd

        path.lineWidth = 2;
        path.lineCapStyle = kCGLineCapButt;
        path.flatness = 30;

        layer.path = path.CGPath;
        [self.layer addSublayer:layer];
        [self setNeedsDisplay];
        
    }
    return self;
}


-(void)drawWithList:(NSArray *)pointArray{
    
    
}


@end
