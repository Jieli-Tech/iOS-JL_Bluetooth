//
//  DhaChartView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/1.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
// 使用 Swift 版本的 EcChartsView，需要导入 Swift 生成的兼容头（与目标的模块名一致）
#import "杰理之家-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface DhaChartView : UIView

@property(nonatomic,strong)UILabel *hearLab1;
@property(nonatomic,strong)UILabel *leftLabl;
@property(nonatomic,strong)UILabel *rightLabl;
@property(nonatomic,strong)EcChartsView *chartsView;
@property(nonatomic,strong)UILabel *freqLab;


@end

NS_ASSUME_NONNULL_END
