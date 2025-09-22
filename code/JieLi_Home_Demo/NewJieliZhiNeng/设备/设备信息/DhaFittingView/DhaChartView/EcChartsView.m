//
//  EcChartsView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/4.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "EcChartsView.h"
#import <Charts/Charts-Swift.h>

@interface EcChartsView()<ChartViewDelegate,IChartAxisValueFormatter>{
    CombinedChartView *cbView;
}
@end

@implementation EcChartsView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        cbView = [CombinedChartView new];
        [self addSubview:cbView];
        [cbView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(0);
            make.left.equalTo(self.mas_left).offset(0);
            make.right.equalTo(self.mas_right).offset(0);
            make.bottom.equalTo(self.mas_bottom).offset(0);
        }];
        self.maxIndex = 6;
        self.shouldTag = -1;
        
        cbView.delegate = self;
        cbView.drawOrder = @[@(CombinedChartDrawOrderBar),@(CombinedChartDrawOrderLine)];
        cbView.noDataText = @"暂无数据"; // 无数据时显示的文字
        cbView.pinchZoomEnabled = NO; // 触控放大
        cbView.doubleTapToZoomEnabled = NO; // 双击放大
        cbView.scaleXEnabled = NO; // X 轴缩放
        cbView.scaleYEnabled = NO; // Y 轴缩放
        cbView.scaleEnabled = NO; // 缩放
        cbView.highlightPerTapEnabled = NO; // 单击高亮
        cbView.highlightPerDragEnabled = NO; // 拖拽高亮
        cbView.dragEnabled = NO; // 拖拽图表
        cbView.dragDecelerationEnabled = YES; // 拖拽后是否有惯性效果
        cbView.dragDecelerationFrictionCoef = 0.5; // 拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
        cbView.legend.enabled = NO; // 隐藏图例
        
        
        /* 设置 X 轴显示的值的属性 */
        ChartXAxis *xAxis = cbView.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom; // 显示位置
        xAxis.drawGridLinesEnabled = NO; // 网格绘制
        xAxis.axisLineColor = [UIColor colorFromHexString:@"#ABABAB"]; // X 轴颜色
        xAxis.axisLineWidth = 0.5f; // X 轴线宽
        xAxis.labelFont = [UIFont systemFontOfSize:13]; // 字号
        xAxis.labelTextColor = [UIColor colorFromHexString:@"#ABABAB"]; // 颜色
        xAxis.axisBackgroundColor = [UIColor colorFromHexString:@"#805BEB"];
        xAxis.labelRotationAngle = 0; // 文字倾斜角度
        xAxis.centerAxisLabelsEnabled = YES;
        xAxis.labelCount = 7;
        xAxis.granularity = 1.0;
        xAxis.axisMinimum = 0; // X轴最小值
        xAxis.axisMaximum = self.maxIndex;
        xAxis.valueFormatter = self;
        xAxis.axisLineColor = [UIColor clearColor];
        
        cbView.rightAxis.drawLabelsEnabled = false;
        cbView.rightAxis.drawGridLinesEnabled = NO;
        cbView.rightAxis.enabled = NO;
        
        ChartYAxis *leftAxis = cbView.leftAxis;
        leftAxis.labelPosition = YAxisLabelPositionOutsideChart; // 显示位置
        leftAxis.drawGridLinesEnabled = YES; // 网格绘制
        leftAxis.gridColor = [UIColor colorFromHexString:@"#ABABAB"]; // 网格颜色
        leftAxis.gridLineDashLengths = @[@2,@4];
        leftAxis.labelFont = [UIFont systemFontOfSize:13]; // 字号
        leftAxis.labelTextColor = [UIColor colorFromHexString:@"#ABABAB"]; // 颜色
        leftAxis.axisMinimum = 0; // 最小值
        leftAxis.axisMaximum = 100; // 最大值（不设置会根据数据自动设置）
        leftAxis.decimals = 2;
        leftAxis.axisLineColor = [UIColor clearColor];
        
        }
    return self;
}


-(void)setBarValues:(NSArray *)barValues{
    _barValues = barValues;
    
    NSMutableArray<BarChartDataEntry *> *entries1 = [[NSMutableArray alloc] init];
    NSMutableArray<BarChartDataEntry *> *entries2 = [[NSMutableArray alloc] init];
    for (int index = 0; index < barValues.count; index++)
    {
        [entries1 addObject:[[BarChartDataEntry alloc] initWithX:index+0.5 y:100.0]];
        
        NSNumber *number = barValues[index];
        if (self.shouldTag == index) {
            [entries2 addObject:[[BarChartDataEntry alloc] initWithX:index+0.5 y:[number floatValue] icon:[UIImage imageNamed:@"Theme.bundle/icon_dha_tips.png"]]];
        }else{
            [entries2 addObject:[[BarChartDataEntry alloc] initWithX:index+0.5 y:[number floatValue]]];
        }
        
    }
    BarChartDataSet *dataSet = [[BarChartDataSet alloc] initWithEntries:entries1];
    dataSet.barGradientColors = @[@[[UIColor colorFromHexString:@"#E9EBF0"],[UIColor colorFromHexString:@"#E9EBF0"]]];
    dataSet.axisDependency = AxisDependencyLeft; // 根据左边数据显示
    dataSet.drawValuesEnabled = NO; // 是否显示数据
    
    
    BarChartDataSet *dataSet2 = [[BarChartDataSet alloc] initWithEntries:entries2];
    dataSet2.barGradientColors = @[@[[UIColor colorFromHexString:@"#A896DD"],[UIColor colorFromHexString:@"#805BEB"]]];
    dataSet2.axisDependency = AxisDependencyLeft; // 根据左边数据显示
    dataSet2.drawValuesEnabled = NO; // 是否显示数据
    dataSet2.iconsOffset = CGPointMake(0, 13);
    
    BarChartData *data = [[BarChartData alloc] initWithDataSets:@[dataSet,dataSet2]];
    data.barWidth = 0.65f; // 柱状图宽度（数值范围 0 ~ 1）
    
    CombinedChartData *charData = [[CombinedChartData alloc] init];
    charData.barData = data;
    charData.lineData = nil;
    cbView.data = charData;
    [cbView notifyDataSetChanged];
    
}

-(void)setShouldTag:(NSInteger)shouldTag{
    _shouldTag = shouldTag;
    cbView.xAxis.axisHaveBgC = @[@(shouldTag+1)];
}


-(void)setLineArrays:(NSArray * _Nullable )arr1 Array2:(NSArray  * _Nullable )arr2{
    NSMutableArray<BarChartDataEntry *> *entries1 = [[NSMutableArray alloc] init];
    for (int index = 0; index < self.xAxisList.count; index++)
    {
        [entries1 addObject:[[BarChartDataEntry alloc] initWithX:index+0.5 y:100.0]];
    }
    BarChartDataSet *dataSet = [[BarChartDataSet alloc] initWithEntries:entries1 label:@"bgBar"];
    dataSet.barGradientColors = @[@[[UIColor colorFromHexString:@"#E9EBF0"],[UIColor colorFromHexString:@"#E9EBF0"]]];
    dataSet.axisDependency = AxisDependencyLeft; // 根据左边数据显示
    dataSet.drawValuesEnabled = NO; // 是否显示数据
    BarChartData *data = [[BarChartData alloc] initWithDataSets:@[dataSet]];
    data.barWidth = 0.65; // 柱状图宽度（数值范围 0 ~ 1）
    
    LineChartData *d1 = [[LineChartData alloc] init];
    
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    NSMutableArray *entries2 = [[NSMutableArray alloc] init];
    
    if (arr1) {
        for (int index = 0; index < arr1.count; index++)
        {
            NSNumber *number = arr1[index];
            [entries addObject:[[ChartDataEntry alloc] initWithX:index + 0.5 y:[number floatValue]]];
        }
        LineChartDataSet *set = [[LineChartDataSet alloc] initWithEntries:entries label:@"Line DataSet"];
        [set setColor:[UIColor colorFromHexString:@"#8DB3FA"]];
        set.lineWidth = 2.0;
        [set setCircleColor:[UIColor colorFromHexString:@"#4E89F4"]];
        set.circleRadius = 4.0;
        set.circleHoleRadius = 0;
        set.fillColor = [UIColor colorFromHexString:@"#4E89F4"];
        set.mode = LineChartModeLinear;
        set.drawValuesEnabled = NO;
        [d1 addDataSet:set];
    }
    
    if (arr2) {
        for (int index = 0; index < arr2.count; index++)
        {
            NSNumber *number = arr2[index];
            [entries2 addObject:[[ChartDataEntry alloc] initWithX:index + 0.5 y:[number floatValue]]];
        }
        
        LineChartDataSet *set2 = [[LineChartDataSet alloc] initWithEntries:entries2 label:@"Line DataSet2"];
        [set2 setColor:[UIColor colorFromHexString:@"#F7C189"]];
        set2.lineWidth = 2.0;
        [set2 setCircleColor:[UIColor colorFromHexString:@"#FF9E39"]];
        set2.circleRadius = 4.0;
        set2.circleHoleRadius = 0;
        set2.fillColor = [UIColor colorFromHexString:@"#FF9E39"];
        set2.mode = LineChartModeLinear;
        set2.drawValuesEnabled = NO;
        [d1 addDataSet:set2];
    }
    
    
    CombinedChartData *charData = [[CombinedChartData alloc] init];
    charData.barData = data;
    charData.lineData = d1;
    cbView.data = charData;
    [cbView notifyDataSetChanged];
}





- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight{
    
}
/// Called when a user stops panning between values on the chart
- (void)chartViewDidEndPanning:(ChartViewBase * _Nonnull)chartView{
    
}
- (void)chartValueNothingSelected:(ChartViewBase * _Nonnull)chartView{
    
}
- (void)chartScaled:(ChartViewBase * _Nonnull)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    
}
- (void)chartTranslated:(ChartViewBase * _Nonnull)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
    
}
- (void)chartView:(ChartViewBase * _Nonnull)chartView animatorDidStop:(ChartAnimator * _Nonnull)animator{
    
}


-(NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis{
    return self.xAxisList[(int)value%self.xAxisList.count];
}


@end
