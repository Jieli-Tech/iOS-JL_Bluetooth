//
//  BezierView.m
//  newAPP
//
//  Created by EzioChan on 2020/5/27.
//  Copyright © 2020 Ezio. All rights reserved.
//

#import "BezierView.h"


@interface BezierView(){
 
    NSArray *pointArray;
    
}
@end

@implementation BezierView


- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGPoint point0 = [pointArray.firstObject CGPointValue];
    //起点
//    CGContextMoveToPoint(context, 0, self.frame.size.height);
//    CGContextAddLineToPoint(context, point0.x, point0.y);
    CGContextMoveToPoint(context, point0.x, point0.y);
    for (NSValue *value in pointArray) {
        CGPoint point = [value CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
//    CGPoint pointEnd = CGPointMake(self.frame.size.width, self.frame.size.height);
//    CGContextAddLineToPoint(context, pointEnd.x, pointEnd.y);
    //绘制前设置边框和填充颜色
    [kColor_0000 setStroke];
    [[UIColor clearColor] setFill];
    CGContextDrawPath(context, kCGPathFillStroke);
       
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}


-(void)drawWithList:(NSArray *)points{
    pointArray = points;
    [self setNeedsDisplay];
}


@end
