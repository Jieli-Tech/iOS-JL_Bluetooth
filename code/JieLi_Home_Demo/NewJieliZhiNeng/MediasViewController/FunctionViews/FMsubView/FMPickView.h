//
//  FMPickView.h
//  AiRuiSheng
//
//  Created by DFung on 2017/3/8.
//  Copyright © 2017年 DFung. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFMPickViewGAP  30.0

@class FMPickView;
@protocol FMPickViewDelegate <NSObject>
@optional
-(void)onFMPickView:(FMPickView*)view didChange:(NSInteger)fmPoint;
-(void)onFMPickView:(FMPickView*)view didSelect:(NSInteger)fmPoint;
@end

@interface FMPickView : UIView
@property(nonatomic,weak)id<FMPickViewDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame
                   StartPoint:(NSInteger)sPoint
                     EndPoint:(NSInteger)ePoint;

-(void)setFMPoint:(NSInteger)point;
@end
