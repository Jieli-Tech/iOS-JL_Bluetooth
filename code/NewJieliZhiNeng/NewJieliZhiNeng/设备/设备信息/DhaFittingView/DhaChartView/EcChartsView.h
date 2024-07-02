//
//  EcChartsView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/4.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EcChartsView : UIView

@property(nonatomic,strong)NSArray *xAxisList;

@property(nonatomic,assign)NSInteger maxIndex;

@property(nonatomic,assign)NSInteger shouldTag;

@property(nonatomic,strong)NSArray *barValues;


-(void)setLineArrays:(NSArray * _Nullable )arr1 Array2:(NSArray  * _Nullable )arr2;



@end

NS_ASSUME_NONNULL_END
