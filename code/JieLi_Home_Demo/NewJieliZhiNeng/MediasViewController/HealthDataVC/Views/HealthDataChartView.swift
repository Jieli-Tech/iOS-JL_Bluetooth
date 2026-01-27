//
//  HealthDataChartView.swift
//  JLPiHome
//
//  A reusable health metrics chart component built on DGCharts.
//  Shows Heart Rate, Steps, and Blood Oxygen charts, supports
//  reactive data updates and user interactions.
//
//  Created by EzioChan on 2025/10/15.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit
import DGCharts
import SnapKit
import RxSwift
import RxCocoa
import RxRelay


/*
 private let heartRateChartView = HealthDataChartView()
 private let spo2ChartView = HealthDataChartView()
 private let stepChartView = HealthDataChartView()
 
 
 // 图表视图
 view.addSubview(heartRateChartView)
 heartRateChartView.snp.makeConstraints { make in
     make.left.right.equalToSuperview()
     make.top.equalTo(dateSwitchView.snp.bottom).offset(8)
     make.height.equalTo(100)
 }
 
 // 模拟心率数据并绑定
 heartRateChartView.setHeartRateData(mockHeartRateData())
 
 // 图表视图
 view.addSubview(spo2ChartView)
 spo2ChartView.snp.makeConstraints { make in
     make.left.right.equalToSuperview()
     make.top.equalTo(heartRateChartView.snp.bottom).offset(8)
     make.height.equalTo(100)
 }
 // 将该图表配置为显示 SpO2（默认是心率，需要切换）
 spo2ChartView.configure(metric: .spo2)

 // 模拟 SpO2 数据并绑定
 spo2ChartView.setSpo2Data(mockSpo2Data())

 // 图表视图
 view.addSubview(stepChartView)
 stepChartView.snp.makeConstraints { make in
     make.left.right.equalToSuperview()
     make.top.equalTo(spo2ChartView.snp.bottom).offset(8)
     make.height.equalTo(240)
 }
 
 // 将该图表配置为显示 步数（默认是心率，需要切换）
 stepChartView.configure(metric: .steps)

 // 模拟 步数 数据并绑定
 stepChartView.setStepsData(mockStepData())
 
 
 /// 当天多个时刻的心率模拟数据（bpm），与 24h 时间轴对齐
 func mockHeartRateData() -> [HeartRateEntryData] {
     let calendar = Calendar.current
     let now = Date()
     var comps = calendar.dateComponents([.year, .month, .day], from: now)
     
     func makeDate(_ h: Int, _ m: Int) -> Date {
         comps.hour = h
         comps.minute = m
         return calendar.date(from: comps) ?? now
     }
     
     // 参考示例：清晨到晚间的多点心率（区间最小/最大值）
     return [
         HeartRateEntryData(date: makeDate(4, 0),  minBpm: 65,  maxBpm: 78, averageBpm: 70),
         HeartRateEntryData(date: makeDate(6, 0),  minBpm: 98,  maxBpm: 122, averageBpm: 110),
         HeartRateEntryData(date: makeDate(12, 0), minBpm: 88,  maxBpm: 102, averageBpm: 94),
         HeartRateEntryData(date: makeDate(17, 30),minBpm: 140, maxBpm: 165, averageBpm: 155),
         HeartRateEntryData(date: makeDate(18, 30),minBpm: 128, maxBpm: 146, averageBpm: 137),
         HeartRateEntryData(date: makeDate(22, 0), minBpm: 78,  maxBpm: 88, averageBpm: 83)
     ]
 }
 
 func mockSpo2Data()->[Spo2EntryData] {
     // 当天多个时刻的血氧模拟数据（百分比 0-100），与 24h 时间轴对齐
     let calendar = Calendar.current
     let now = Date()
     var comps = calendar.dateComponents([.year, .month, .day], from: now)
     
     func makeDate(_ h: Int, _ m: Int) -> Date {
         comps.hour = h
         comps.minute = m
         return calendar.date(from: comps) ?? now
     }
     
     // 覆盖正常(95–100%)、偏低(90–94%)、警告(≤90%)等区间，便于验证区间柱渲染与图例说明
     return [
         Spo2EntryData(date: makeDate(5, 30),  minPercent: 96, maxPercent: 98, averagePercent: 97), // 正常
         Spo2EntryData(date: makeDate(8, 0),   minPercent: 93, maxPercent: 96, averagePercent: 94), // 偏低→正常
         Spo2EntryData(date: makeDate(12, 15), minPercent: 92, maxPercent: 94, averagePercent: 93), // 偏低
         Spo2EntryData(date: makeDate(15, 45), minPercent: 88, maxPercent: 90, averagePercent: 89), // 警告
         Spo2EntryData(date: makeDate(20, 0),  minPercent: 95, maxPercent: 99, averagePercent: 97), // 正常
         Spo2EntryData(date: makeDate(23, 30), minPercent: 94, maxPercent: 96, averagePercent: 95)  // 偏低→正常
     ]
 }
 
 /// 当天多个时刻的步数模拟数据（步），与 24h 时间轴对齐
 func mockStepData() -> [StepsEntryData] {
     let calendar = Calendar.current
     let now = Date()
     var comps = calendar.dateComponents([.year, .month, .day], from: now)
     
     func makeDate(_ h: Int, _ m: Int) -> Date {
         comps.hour = h
         comps.minute = m
         return calendar.date(from: comps) ?? now
     }
     
     // 参考示例：清晨到晚间的多点步数（区间最小/最大值）
     return [
         StepsEntryData(date: makeDate(4, 0),steps: 200),
         StepsEntryData(date: makeDate(6, 0),steps: 100),
         StepsEntryData(date: makeDate(12, 0),steps: 20),
         StepsEntryData(date: makeDate(17, 30),steps: 500),
         StepsEntryData(date: makeDate(18, 30),steps: 100),
         StepsEntryData(date: makeDate(20, 0),steps: 400),
         StepsEntryData(date: makeDate(22, 0),steps: 300)
     ]
 }
 */

// MARK: - Rounded Bar Renderer (inline to avoid target membership issues)
import CoreGraphics
/// A BarChartRenderer that paints bars with rounded corners.
/// - cornerRadiusPoints: optional fixed radius in points. If nil, uses auto capsule radius = min(barWidth/2, barHeight/2).
///
/// Marked as fileprivate to avoid exposing it to the Objective-C bridging header,
/// which prevents "cannot find interface declaration for 'BarChartRenderer'" errors
/// when generating <ProjectName>-Swift.h.
fileprivate final class RoundedBarChartRenderer: BarChartRenderer {
    /// Fixed corner radius in points. When nil, renderer will use auto capsule radius based on the bar's pixel size.
    var cornerRadiusPoints: CGFloat?

    override func drawDataSet(context: CGContext, dataSet: BarChartDataSetProtocol, index: Int) {
        guard let dataProvider = dataProvider else { return }

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)

        let borderWidth = dataSet.barBorderWidth
        let borderColor = dataSet.barBorderColor
        let drawBorder = borderWidth > 0.0

        context.saveGState()
        defer { context.restoreGState() }

        // Pre-calc entry range according to phaseX
        let entryCount = dataSet.entryCount
        let drawCount = Int(ceil(Double(entryCount) * animator.phaseX))
        let range = (0..<entryCount).clamped(to: 0..<drawCount)

        // Bar width
        let barWidth = dataProvider.barData?.barWidth ?? 0.5
        let barHalf = barWidth / 2.0

        // Draw bar shadow first (full height, rounded)
        if dataProvider.isDrawBarShadowEnabled {
            for i in range {
                guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
                let x = e.x
                var shadowRect = CGRect(x: CGFloat(x - barHalf), y: 0, width: CGFloat(barWidth), height: 0)
                trans.rectValueToPixel(&shadowRect)

                guard viewPortHandler.isInBoundsLeft(shadowRect.origin.x + shadowRect.size.width) else { continue }
                guard viewPortHandler.isInBoundsRight(shadowRect.origin.x) else { break }

                shadowRect.origin.y = viewPortHandler.contentTop
                shadowRect.size.height = viewPortHandler.contentHeight

                context.setFillColor(dataSet.barShadowColor.cgColor)
                let radius = computeRadius(for: shadowRect)
                let path = UIBezierPath(roundedRect: shadowRect, cornerRadius: radius)
                context.addPath(path.cgPath)
                context.fillPath()
            }
        }

        // Build pixel rects for bars (supports stacked)
        var pixelRects: [CGRect] = []
        pixelRects.reserveCapacity(drawCount)

        let phaseY = Double(animator.phaseY)

        for i in range {
            guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
            let x = e.x

            if let vals = e.yValues, !vals.isEmpty {
                // Stacked bars
                var posY: Double = 0.0
                for v in vals {
                    let y0 = posY
                    let y1 = posY + v * phaseY
                    posY = y1
                    let rect = rectInPixelSpace(leftX: x - barHalf, rightX: x + barHalf, yStart: y0, yEnd: y1, transformer: trans)
                    pixelRects.append(rect)
                }
            } else {
                // Single bar: draw from 0 to y
                let y = e.y
                let y0 = min(0.0, y)
                let y1 = y > 0.0 ? (y * phaseY) : 0.0
                let rect = rectInPixelSpace(leftX: x - barHalf, rightX: x + barHalf, yStart: y0, yEnd: y1, transformer: trans)
                pixelRects.append(rect)
            }
        }

        // Fill bars with rounded corners
        let isSingleColor = dataSet.colors.count == 1
        if isSingleColor {
            context.setFillColor(dataSet.color(atIndex: 0).cgColor)
        }

        for j in pixelRects.indices {
            let barRect = pixelRects[j]
            guard viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width) else { continue }
            guard viewPortHandler.isInBoundsRight(barRect.origin.x) else { break }

            if !isSingleColor {
                context.setFillColor(dataSet.color(atIndex: j).cgColor)
            }

            let radius = computeRadius(for: barRect)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: radius)
            context.addPath(path.cgPath)
            context.fillPath()

            if drawBorder {
                context.setStrokeColor(borderColor.cgColor)
                context.setLineWidth(borderWidth)
                context.addPath(path.cgPath)
                context.strokePath()
            }
        }
    }

    /// Computes the corner radius to use for the given bar rect in pixel space.
    private func computeRadius(for rect: CGRect) -> CGFloat {
        let auto = min(rect.width / 2.0, rect.height / 2.0)
        if let fixed = cornerRadiusPoints { return min(fixed, auto) }
        return auto
    }

    /// Build a pixel-space rect from value-space coordinates using transformer
    private func rectInPixelSpace(leftX: Double, rightX: Double, yStart: Double, yEnd: Double, transformer: Transformer) -> CGRect {
        var lt = CGPoint(x: CGFloat(leftX), y: CGFloat(yEnd))
        var lb = CGPoint(x: CGFloat(leftX), y: CGFloat(yStart))
        var rt = CGPoint(x: CGFloat(rightX), y: CGFloat(yEnd))
        var rb = CGPoint(x: CGFloat(rightX), y: CGFloat(yStart))
        transformer.pointValueToPixel(&lt)
        transformer.pointValueToPixel(&lb)
        transformer.pointValueToPixel(&rt)
        transformer.pointValueToPixel(&rb)

        let leftPx = min(lt.x, lb.x)
        let rightPx = max(rt.x, rb.x)
        let topPx = min(lt.y, rt.y)
        let bottomPx = max(lb.y, rb.y)
        return CGRect(x: leftPx, y: topPx, width: rightPx - leftPx, height: bottomPx - topPx)
    }
}

/// 健康数据类型
enum HealthMetricType {
    case heartRate
    case steps
    case spo2
}

/// 心率数据点（单位：bpm）
struct HeartRateEntryData {
    let date: Date
    /// 该时间段内心率最小值
    let minBpm: Double
    /// 该时间段内心率最大值
    let maxBpm: Double
    /// 该时间段内心率平均值
    let averageBpm: Double
}

/// 步数数据点（单位：步）
struct StepsEntryData {
    let date: Date
    let steps: Double
}

/// 血氧数据点（单位：百分比 0-100）
struct Spo2EntryData {
    let date: Date
    /// 该时间段内血氧最小值（0-100）
    let minPercent: Double
    /// 该时间段内血氧最大值（0-100）
    let maxPercent: Double
    /// 该时间段内血氧平均值（0-100）
    let averagePercent: Double
}
/// 统一的选中数据模型：根据图表类型返回对应的模型数据
enum HealthSelectedModel {
    case heartRate(HeartRateEntryData)
    case steps(StepsEntryData)
    case spo2(Spo2EntryData)
}

/// 时间轴格式化器，使用 24h 格式
final class TimeAxisFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // value 以小时为单位（0-24），转为 HH:mm
        let hours = Int(value)
        let minutes = Int(round((value - Double(hours)) * 60))
        let hStr = String(format: "%02d", hours)
        let mStr = String(format: "%02d", minutes)
        return "\(hStr):\(mStr)"
    }
}

/// 百分比轴格式化器，用于 SpO2
final class PercentAxisFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(format: "%.0f%%", value)
    }
}

/// 可复用的医疗健康数据统计图表组件
class HealthDataChartView: BasicView, ChartViewDelegate {
    // MARK: - UI
    private let stackView = UIStackView()
    private let heartChart = BarChartView()
    private let stepsChart = BarChartView()
    private let spo2Chart = BarChartView()
    private let spo2Legend = UILabel() // SpO2 图例说明（正常/偏低/警告）
    /// 当前显示的图表类型（默认心率）
    private var displayedMetric: HealthMetricType = .heartRate
    /// 当前显示的图表引用（根据 displayedMetric 指向 heart/steps/spo2）
    private var displayedChart: BarLineChartViewBase {
        switch displayedMetric {
        case .heartRate: return heartChart
        case .steps: return stepsChart
        case .spo2: return spo2Chart
        }
    }
    /// 选中栏的垂直刻度线（通过 XAxis LimitLine 绘制）
    private var verticalHighlightLine: ChartLimitLine?
    /// 圆角半径（单位：pt）。nil 表示自动胶囊圆角：取 min(柱像素宽度/2, 柱像素高度/2)
    var barCornerRadiusPoints: CGFloat? = nil

    // MARK: - Reactive Data
    private let heartRelay = BehaviorRelay<[HeartRateEntryData]>(value: [])
    private let stepsRelay = BehaviorRelay<[StepsEntryData]>(value: [])
    private let spo2Relay = BehaviorRelay<[Spo2EntryData]>(value: [])

    // MARK: - Caches
    private var dataCache: [String: ChartData] = [:]

    // MARK: - Callbacks
    /// 单一回调：返回当前图表类型与当前选中的模型数据（无选中时返回 nil）
    var onSelectedModelChange: ((_ metric: HealthMetricType, _ model: HealthSelectedModel?) -> Void)?

    // MARK: - Lifecycle
    override func initUI() {
        super.initUI()
        setupViews()
        setupLayout()
        setupChartsStyle()
        bindData()
    }

    // MARK: - Public APIs
    func setHeartRateData(_ entries: [HeartRateEntryData]) {
        heartRelay.accept(entries)
        // 确保空数据也能显示时间刻度：为当前显示图表设置占位数据
        if displayedMetric == .heartRate && entries.isEmpty {
            heartChart.data = placeholderStackedRangeData(label: R.Language.lan("Heart Rate"), barWidth: 0.40)
            heartChart.notifyDataSetChanged()
        }
    }

    func setStepsData(_ entries: [StepsEntryData]) {
        stepsRelay.accept(entries)
        if displayedMetric == .steps && entries.isEmpty {
            stepsChart.data = placeholderBarData(label: R.Language.lan("Steps_2"), barWidth: 0.35)
            stepsChart.notifyDataSetChanged()
        }
    }

    func setSpo2Data(_ entries: [Spo2EntryData]) {
        spo2Relay.accept(entries)
        if displayedMetric == .spo2 && entries.isEmpty {
            spo2Chart.data = placeholderStackedRangeData(label: R.Language.lan("SpO2"), barWidth: 0.50)
            spo2Chart.notifyDataSetChanged()
        }
    }

    /// 配置显示的图表类型（仅显示单一图）
    func configure(metric: HealthMetricType) {
        displayedMetric = metric
        // 重新构建视图层级，仅保留当前图表
        rebuildVisibleChart()
        // 根据类型显示/隐藏 SpO2 图例说明，并切换约束，避免冲突
        if metric == .spo2 {
            // 显示图例：stackView 不再贴底，保留最小高度；图例在下方占位
            stackView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(8)
                make.height.greaterThanOrEqualTo(180)
            }
            spo2Legend.isHidden = false
            spo2Legend.snp.remakeConstraints { make in
                make.top.equalTo(stackView.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(16)
                make.bottom.equalToSuperview()
            }
        } else {
            // 隐藏图例：stackView 贴底，充分利用容器高度
            stackView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(8)
                make.bottom.equalToSuperview().inset(8)
            }
            spo2Legend.isHidden = true
            // 移除图例约束，避免与贴底的 stackView 冲突
            spo2Legend.snp.removeConstraints()
        }
    }

    /// 清空所有数据与缓存
    func reset() {
        heartRelay.accept([])
        stepsRelay.accept([])
        spo2Relay.accept([])
        dataCache.removeAll()
        [heartChart, stepsChart, spo2Chart].forEach { $0.data = nil }
        clearVerticalHighlightLine()
    }

    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .white
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        addSubview(stackView)

        // 只添加当前需要显示的单一图表
        [heartChart, stepsChart, spo2Chart].forEach { chart in
            // 设置通用交互属性
            chart.delegate = self
            chart.dragEnabled = false
            chart.pinchZoomEnabled = false
            chart.doubleTapToZoomEnabled = false
            chart.highlightPerTapEnabled = true
            chart.highlightPerDragEnabled = true
            chart.chartDescription.enabled = false
            chart.setScaleEnabled(false)
            chart.noDataText = R.Language.lan("No data")
            chart.legend.enabled = false
            chart.rightAxis.enabled = true
            chart.leftAxis.enabled = false

            // 注入圆角柱渲染器
            let rounded = RoundedBarChartRenderer(dataProvider: chart, animator: chart.chartAnimator, viewPortHandler: chart.viewPortHandler)
            rounded.cornerRadiusPoints = barCornerRadiusPoints
            chart.renderer = rounded
        }

        // 只显示单一图表
        stackView.addArrangedSubview(displayedChart)

        spo2Legend.text = R.Language.lan("Normal 95 – 100%       Low 90 – 94%       Warning ≤90%")
        spo2Legend.textColor = .eHex("#A0A0A0")
        spo2Legend.textAlignment = .center
        spo2Legend.font = R.Font.regular(10)
        addSubview(spo2Legend)
        // 默认心率图隐藏 SpO2 图例
        spo2Legend.isHidden = (displayedMetric != .spo2)
    }

    private func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
            make.height.greaterThanOrEqualTo(180)
        }
        spo2Legend.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }

    private func setupChartsStyle() {
        // 通用 X 轴样式：底部时间轴（移除所有纵向虚线）
        [heartChart, stepsChart, spo2Chart].forEach { chart in
            let xAxis = chart.xAxis
            xAxis.labelPosition = .bottom
            xAxis.drawGridLinesEnabled = false // 移除纵向虚线
            xAxis.gridLineDashLengths = nil
            xAxis.labelTextColor = .eHex("#919191")
            xAxis.labelFont = R.Font.regular(10) // 缩小字体，避免重叠
            xAxis.valueFormatter = TimeAxisFormatter()
            xAxis.axisMinimum = 0
            xAxis.axisMaximum = 24
            xAxis.labelCount = 6 // 00:00, 06:00, 12:00, 18:00, 00:00
//            xAxis.setLabelCount(6, force: true)  //强制 6 个刻度，确保间距一致
            xAxis.granularityEnabled = true
//            xAxis.granularity = 6 // 最小间隔为 6 小时，避免自动插入额外刻度
            xAxis.avoidFirstLastClippingEnabled = true // 防止首尾刻度被裁剪

            // X 轴底线：0.5pt 灰色虚线
            xAxis.drawAxisLineEnabled = true
            xAxis.axisLineColor = .eHex("#D0D0D0")
            xAxis.axisLineWidth = 0.5
            xAxis.axisLineDashPhase = 0
            xAxis.axisLineDashLengths = [3, 3]

            // 适当增加底部偏移，避免刻度标签被裁剪
//            chart.setExtraOffsets(left: 8, top: 0, right: 0, bottom: 0)

            // 使用右侧纵轴，横向刻度线统一为虚线，隐藏右侧纵向轴线
            let rightAxis = chart.rightAxis
            rightAxis.drawAxisLineEnabled = false // 隐藏图表右侧的纵向轴线
            rightAxis.drawGridLinesEnabled = true
            rightAxis.gridLineDashLengths = [3, 3] // 横向刻度线统一为虚线样式
            rightAxis.labelTextColor = .eHex("#919191")
        }

        // 心率轴范围初始值（将由数据动态调整）
        heartChart.rightAxis.axisMinimum = 40
        heartChart.rightAxis.axisMaximum = 200
        heartChart.rightAxis.labelCount = 5 // 40, 80, 120, 160, 200
        heartChart.rightAxis.granularityEnabled = true
        heartChart.rightAxis.granularity = 40

        // 步数轴范围：动态（右侧纵轴），最小为 0
        stepsChart.rightAxis.axisMinimum = 0

        // 血氧轴范围固定（百分比格式）
        spo2Chart.rightAxis.axisMinimum = 85
        spo2Chart.rightAxis.axisMaximum = 100
        spo2Chart.rightAxis.labelCount = 5 // 85, 90, 95, 100（DGCharts会尽量匹配）
        spo2Chart.rightAxis.granularityEnabled = true
        spo2Chart.rightAxis.granularity = 5
        spo2Chart.rightAxis.valueFormatter = PercentAxisFormatter()
    }

    private func bindData() {
        heartRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] entries in
                guard let self = self else { return }
                if self.displayedMetric == .heartRate {
                    if entries.isEmpty {
                        // 空数据：设置透明占位数据，保证时间轴刻度显示
                        self.heartChart.data = self.placeholderStackedRangeData(label: R.Language.lan("Heart Rate"), barWidth: 0.40)
                        self.heartChart.notifyDataSetChanged()
                    } else {
                        // 使用“堆叠柱”渲染区间棒：第一段为 min（透明），第二段为 (max - min)
                        let stackedEntries = entries.map { e in
                            BarChartDataEntry(x: self.hourX(e.date), yValues: [e.minBpm, max(0, e.maxBpm - e.minBpm)])
                        }
                        self.heartChart.data = self.buildStackedRangeBarData(entries: stackedEntries,
                                                                             colorsHex: ["#00000000", "#FF5F5F"],
                                                                             label: R.Language.lan("Heart Rate"),
                                                                             barWidth: 0.40)
                    }
                }
            }).disposed(by: disposeBag)

        stepsRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] entries in
                guard let self = self else { return }
                if self.displayedMetric == .steps {
                    if entries.isEmpty {
                        self.stepsChart.data = self.placeholderBarData(label: R.Language.lan("Steps_2"), barWidth: 0.35)
                        self.stepsChart.notifyDataSetChanged()
                    } else {
                        let yMax = max(1000, (entries.map { $0.steps }.max() ?? 0))
                        self.stepsChart.rightAxis.axisMaximum = ceil(yMax / 200) * 200 // 向上取整到 200 的倍数
                        self.stepsChart.data = self.buildBarData(entries: entries.map { BarChartDataEntry(x: self.hourX($0.date), y: $0.steps) },
                                                                 colorHex: "#2CC043",
                                                                 label: R.Language.lan("Steps_2"),
                                                                 barWidth: 0.35)
                    }
                }
            }).disposed(by: disposeBag)

        spo2Relay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] entries in
                guard let self = self else { return }
                if self.displayedMetric == .spo2 {
                    if entries.isEmpty {
                        self.spo2Chart.data = self.placeholderStackedRangeData(label: R.Language.lan("SpO2"), barWidth: 0.50)
                        self.spo2Chart.notifyDataSetChanged()
                    } else {
                        // 使用“堆叠柱”渲染区间棒：第一段为 min（透明），第二段为 (max - min)
                        let stackedEntries = entries.map { e in
                            BarChartDataEntry(x: self.hourX(e.date), yValues: [e.minPercent, max(0, e.maxPercent - e.minPercent)])
                        }
                        self.spo2Chart.data = self.buildStackedRangeBarData(entries: stackedEntries,
                                                                            colorsHex: ["#00000000", "#FF7A16"],
                                                                            label: R.Language.lan("SpO2"),
                                                                            barWidth: 0.50)
                    }
                }
            }).disposed(by: disposeBag)
    }

    // MARK: - Helpers
    private func hourX(_ date: Date) -> Double {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        let h = Double(comps.hour ?? 0)
        let m = Double(comps.minute ?? 0)
        return h + m / 60.0
    }

    private func buildBarData(entries: [BarChartDataEntry], colorHex: String, label: String, barWidth: Double) -> BarChartData {
        // 缓存键：label + 点数量 + 首尾 X 值
        let key = "\(label)-\(entries.count)-\(entries.first?.x ?? -1)-\(entries.last?.x ?? -1)"
        if let cached = dataCache[key] as? BarChartData {
            cached.barWidth = barWidth
            return cached
        }

        let reduced = downsample(entries: entries, maxTarget: 600) // 性能：降采样，大数据量优化
        let set = BarChartDataSet(entries: reduced, label: label)
        // 使用右侧轴绘制（纵向刻度线显示在右侧）
        set.axisDependency = YAxis.AxisDependency.right
        set.colors = [.eHex(colorHex)]
        set.drawValuesEnabled = false
        // 保持选中状态下柱子原色：不叠加任何蒙版
        set.highlightEnabled = true      // 保留交互事件（点击/滑动），但不改变视觉
        set.highlightColor = .clear      // 选中遮罩颜色透明
        set.highlightAlpha = 0.0         // 选中遮罩完全不显示
        let data = BarChartData(dataSet: set)
        data.barWidth = barWidth
        dataCache[key] = data
        return data
    }

    /// 空数据占位（普通柱）：使用透明颜色与 0 值，保证时间轴显示但不渲染可见柱
    private func placeholderBarData(label: String, barWidth: Double) -> BarChartData {
        let set = BarChartDataSet(entries: [BarChartDataEntry(x: 0.0, y: 0.0)], label: label)
        set.axisDependency = .right
        set.colors = [.clear]
        set.drawValuesEnabled = false
        set.highlightEnabled = false
        let data = BarChartData(dataSet: set)
        data.barWidth = barWidth
        return data
    }

    /// 空数据占位（堆叠柱）：两段均为透明 0 值，保证时间轴显示
    private func placeholderStackedRangeData(label: String, barWidth: Double) -> BarChartData {
        let set = BarChartDataSet(entries: [BarChartDataEntry(x: 0.0, yValues: [0.0, 0.0])], label: label)
        set.axisDependency = .right
        set.colors = [.clear, .clear]
        set.drawValuesEnabled = false
        set.highlightEnabled = false
        let data = BarChartData(dataSet: set)
        data.barWidth = barWidth
        return data
    }

    /// 构建“区间柱”的堆叠柱数据：yValues = [min, (max-min)]，第一个堆叠设置为透明以只显示区间段
    private func buildStackedRangeBarData(entries: [BarChartDataEntry], colorsHex: [String], label: String, barWidth: Double) -> BarChartData {
        // 缓存键：STACKED + label + 点数量 + 首尾 X 值
        let key = "STACKED-\(label)-\(entries.count)-\(entries.first?.x ?? -1)-\(entries.last?.x ?? -1)"
        if let cached = dataCache[key] as? BarChartData {
            cached.barWidth = barWidth
            return cached
        }

        let reduced = downsample(entries: entries, maxTarget: 600)
        let set = BarChartDataSet(entries: reduced, label: label)
        set.axisDependency = .right
        // 两段颜色：第一段透明，第二段主题色
        let colors = colorsHex.map { hex -> NSUIColor in
            if hex == "#00000000" { return NSUIColor.clear }
            return NSUIColor.eHex(hex)
        }
        set.colors = colors
        set.drawValuesEnabled = false
        // 保持数据集的高亮事件，但不改变柱子颜色：将高亮填充透明
        set.highlightEnabled = true
        set.highlightColor = .eHex("#FFAA6A")
        set.highlightAlpha = 0.0
        let data = BarChartData(dataSet: set)
        data.barWidth = barWidth
        dataCache[key] = data
        return data
    }

    private func buildCandleData(entries: [CandleChartDataEntry], colorHex: String, label: String) -> CandleChartData {
        // 缓存键：label + 点数量 + 首尾 X 值
        let key = "CANDLE-\(label)-\(entries.count)-\(entries.first?.x ?? -1)-\(entries.last?.x ?? -1)"
        if let cached = dataCache[key] as? CandleChartData {
            return cached
        }

        let reduced = downsampleCandle(entries: entries, maxTarget: 600)
        let set = CandleChartDataSet(entries: reduced, label: label)
        set.axisDependency = .right
        let color = NSUIColor.eHex(colorHex)
        set.shadowColor = color
        set.shadowColorSameAsCandle = true
        set.shadowWidth = 1.5
        set.decreasingColor = color
        set.increasingColor = color
        set.neutralColor = color
        set.increasingFilled = true
        set.decreasingFilled = true
        set.drawValuesEnabled = false
        set.highlightEnabled = true
        set.highlightColor = .eHex("#FFAA6A")
        set.barSpace = 0.35 // 细一点的区间棒

        let data = CandleChartData(dataSet: set)
        dataCache[key] = data
        return data
    }
    
    /// 查找指定 x 位置对应的最近模型数据（基于 24h 轴）。
    /// 新增空白区判断：当触点距离最近柱中心超过柱宽的一半时，返回 nil。
    private func selectedModel(for metric: HealthMetricType, atX x: Double) -> HealthSelectedModel? {
        // 获取当前指标对应的柱宽（单位同 X 轴：小时）。
        // 若数据尚未绑定，使用 bindData 中设置的默认值作为兜底。
        let barWidth: Double = {
            switch metric {
            case .heartRate:
                return (heartChart.data as? BarChartData)?.barWidth ?? 0.40
            case .steps:
                return (stepsChart.data as? BarChartData)?.barWidth ?? 0.35
            case .spo2:
                return (spo2Chart.data as? BarChartData)?.barWidth ?? 0.50
            }
        }()

        // 容差：避免边界浮点误差导致误判
        let threshold = barWidth / 2.0 + 1e-6

        switch metric {
        case .heartRate:
            let arr = heartRelay.value
            guard !arr.isEmpty else { return nil }
            var best = 0
            var delta = abs(hourX(arr[0].date) - x)
            for i in 1..<arr.count {
                let d = abs(hourX(arr[i].date) - x)
                if d < delta { delta = d; best = i }
            }
            // 选中空白区域：距离最近柱中心大于柱宽一半，返回 nil
            guard delta <= threshold else { return nil }
            return .heartRate(arr[best])

        case .steps:
            let arr = stepsRelay.value
            guard !arr.isEmpty else { return nil }
            var best = 0
            var delta = abs(hourX(arr[0].date) - x)
            for i in 1..<arr.count {
                let d = abs(hourX(arr[i].date) - x)
                if d < delta { delta = d; best = i }
            }
            guard delta <= threshold else { return nil }
            return .steps(arr[best])

        case .spo2:
            let arr = spo2Relay.value
            guard !arr.isEmpty else { return nil }
            var best = 0
            var delta = abs(hourX(arr[0].date) - x)
            for i in 1..<arr.count {
                let d = abs(hourX(arr[i].date) - x)
                if d < delta { delta = d; best = i }
            }
            guard delta <= threshold else { return nil }
            return .spo2(arr[best])
        }
    }

    /// 简单降采样以提高渲染性能（保留最多 maxTarget 个点）
    private func downsample(entries: [BarChartDataEntry], maxTarget: Int) -> [BarChartDataEntry] {
        guard entries.count > maxTarget && maxTarget > 0 else { return entries }
        let step = max(1, entries.count / maxTarget)
        var result: [BarChartDataEntry] = []
        result.reserveCapacity(entries.count / step)
        for i in stride(from: 0, to: entries.count, by: step) {
            result.append(entries[i])
        }
        return result
    }

    private func downsampleCandle(entries: [CandleChartDataEntry], maxTarget: Int) -> [CandleChartDataEntry] {
        guard entries.count > maxTarget && maxTarget > 0 else { return entries }
        let step = max(1, entries.count / maxTarget)
        var result: [CandleChartDataEntry] = []
        result.reserveCapacity(entries.count / step)
        for i in stride(from: 0, to: entries.count, by: step) {
            result.append(entries[i])
        }
        return result
    }

    private func nearestValue(in chart: BarLineChartViewBase, from data: ChartData?, atX x: Double) -> Double? {
        guard let data = data else { return nil }
        // 仅处理单一 DataSet 的情形
        guard let set = data.dataSets.first else { return nil }
        let entry = set.entryForXValue(x, closestToY: .nan)
        return entry?.y
    }

    /// 清除当前的垂直高亮刻度线
    private func clearVerticalHighlightLine() {
        guard let chart = displayedChart as BarLineChartViewBase? else { return }
        if let line = verticalHighlightLine {
            chart.xAxis.removeLimitLine(line)
            verticalHighlightLine = nil
        }
    }

    /// 在选中栏位置绘制垂直刻度线（XAxis LimitLine）
    private func updateVerticalHighlightLine(atX x: Double) {
        let chart = displayedChart
        // 移除已有的高亮线
        if let line = verticalHighlightLine {
            chart.xAxis.removeLimitLine(line)
        }
        // 新建并添加高亮线
        let line = ChartLimitLine(limit: x)
        line.lineColor = .eHex("#FFAA6A")
        line.lineWidth = 0.8
        line.lineDashLengths = nil
        line.label = "" // 不显示文字
        chart.xAxis.addLimitLine(line)
        chart.xAxis.drawLimitLinesBehindDataEnabled = false
        verticalHighlightLine = line
        chart.setNeedsDisplay()
    }

    // MARK: - ChartViewDelegate
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        guard let chart = chartView as? BarLineChartViewBase else { return }
        let lowest = chart.lowestVisibleX
        let highest = chart.highestVisibleX
        let midX = (lowest + highest) / 2.0
        // 统一：当前显示图类型 + 最近的模型数据
        let model = selectedModel(for: displayedMetric, atX: midX)
        onSelectedModelChange?(displayedMetric, model)
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let metric: HealthMetricType
        if chartView === heartChart { metric = .heartRate }
        else if chartView === stepsChart { metric = .steps }
        else { metric = .spo2 }
        let model = selectedModel(for: metric, atX: entry.x)
        onSelectedModelChange?(metric, model)

        // 绘制选中栏的垂直刻度线
        updateVerticalHighlightLine(atX: entry.x)
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        // 清除垂直刻度线
        clearVerticalHighlightLine()
        // 回传取消选中状态
        let metric: HealthMetricType
        if chartView === heartChart { metric = .heartRate }
        else if chartView === stepsChart { metric = .steps }
        else { metric = .spo2 }
        onSelectedModelChange?(metric, nil)
    }

    /// 重建 stackView 的可见图表，仅保留 displayedChart
    private func rebuildVisibleChart() {
        // 移除所有已添加的图表
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0); $0.removeFromSuperview() }
        // 添加当前显示的图表
        stackView.addArrangedSubview(displayedChart)
        // 更新布局与显示
        setNeedsLayout()
        layoutIfNeeded()
    }
}
