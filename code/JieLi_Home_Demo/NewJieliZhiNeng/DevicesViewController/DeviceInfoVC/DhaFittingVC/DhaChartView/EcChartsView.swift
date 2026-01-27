import UIKit
import DGCharts
import SnapKit

@objcMembers
class EcChartsView: UIView {

    // MARK: - Public properties (ObjC 兼容)
    var xAxisList: [String] = [] {
        didSet { updateXAxisFormatter() }
    }

    var maxIndex: Int = 6 {
        didSet { updateXAxisRange() }
    }

    // 高亮的 x 轴索引（用于在柱状条上展示 icon 提示）
    var shouldTag: Int = -1 {
        didSet { refreshBarIcons() }
    }

    // 外部设置的柱状图数据（第二组真实值，第一组为背景填充）
    var barValues: [NSNumber] = [] {
        didSet { setBarValues(barValues) }
    }

    // MARK: - Private
    private let combinedView = CombinedChartView()

    // 记录当前的组合数据，以便局部刷新（比如只更新 icon）
    private var currentBarDataSetBg: BarChartDataSet?
    private var currentBarDataSetVal: BarChartDataSet?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupChart()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupChart()
    }

    // MARK: - Public API (保持 ObjC 调用兼容的 selector)
    // ObjC 原型: - (void)setLineArrays:(NSArray * _Nullable)arr1 Array2:(NSArray * _Nullable)arr2;
    @objc(setLineArrays:Array2:)
    func setLineArrays(_ arr1: [NSNumber]?, Array2 arr2: [NSNumber]?) {
        let count = max(xAxisList.count, maxIndex + 1)
        var entries1: [ChartDataEntry] = []
        var entries2: [ChartDataEntry] = []

        // 折线1
        if let a1 = arr1 {
            for i in 0..<count {
                let y = i < a1.count ? a1[i].doubleValue : 0.0
                entries1.append(ChartDataEntry(x: Double(i), y: y))
            }
        }

        // 折线2
        if let a2 = arr2 {
            for i in 0..<count {
                let y = i < a2.count ? a2[i].doubleValue : 0.0
                entries2.append(ChartDataEntry(x: Double(i), y: y))
            }
        }

        var lineDataSets: [LineChartDataSet] = []
        if !entries1.isEmpty {
            let ds1 = LineChartDataSet(entries: entries1, label: "")
            ds1.axisDependency = YAxis.AxisDependency.left
            ds1.setColor(UIColor.white)
            ds1.lineWidth = 3
            ds1.circleRadius = 0
            ds1.drawCirclesEnabled = false
            ds1.drawValuesEnabled = false
            lineDataSets.append(ds1)
        }

        if !entries2.isEmpty {
            let ds2 = LineChartDataSet(entries: entries2, label: "")
            ds2.axisDependency = YAxis.AxisDependency.left
            ds2.setColor(hex("#67D0F0"))
            ds2.lineWidth = 3
            ds2.circleRadius = 0
            ds2.drawCirclesEnabled = false
            ds2.drawValuesEnabled = false
            lineDataSets.append(ds2)
        }

        let combined = combinedView.data as? CombinedChartData ?? CombinedChartData()
        combined.lineData = lineDataSets.isEmpty ? nil : LineChartData(dataSets: lineDataSets)
        combinedView.data = combined
        combinedView.notifyDataSetChanged()
    }

    // MARK: - Private setup
    private func setupChart() {
        addSubview(combinedView)
        combinedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 交互设置（与 ObjC 版本保持一致）
        combinedView.delegate = self
        combinedView.drawOrder = [CombinedChartView.DrawOrder.bar.rawValue,
                                   CombinedChartView.DrawOrder.line.rawValue]
        combinedView.noDataText = ""
        combinedView.chartDescription.enabled = false
        combinedView.pinchZoomEnabled = false
        combinedView.doubleTapToZoomEnabled = false
        combinedView.scaleXEnabled = false
        combinedView.scaleYEnabled = false
        combinedView.dragEnabled = false
        combinedView.highlightPerTapEnabled = false
        combinedView.highlightPerDragEnabled = false
        combinedView.dragDecelerationEnabled = false
        combinedView.dragDecelerationFrictionCoef = CGFloat(0x10) / 100.0

        combinedView.legend.enabled = false

        // X 轴
        let xAxis = combinedView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 14)
        xAxis.labelTextColor = hex("#FFFFFF")
        xAxis.axisLineColor = .clear // 不显示 x 轴线
        xAxis.gridColor = .clear
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 1
        xAxis.labelRotationAngle = 0

        // 左轴
        let left = combinedView.leftAxis
        left.labelTextColor = hex("#FFFFFF")
        left.axisLineColor = .clear
        left.gridColor = hex("#545454")
        left.gridLineDashLengths = [2, 4]
        left.axisMinimum = 0

        // 右轴不使用
        combinedView.rightAxis.enabled = false

        // 初始范围与 formatter
        updateXAxisRange()
        updateXAxisFormatter()
    }

    private func updateXAxisRange() {
        let xAxis = combinedView.xAxis
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = Double(maxIndex)
        xAxis.labelCount = maxIndex + 1
        combinedView.notifyDataSetChanged()
    }

    private func updateXAxisFormatter() {
        combinedView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisList)
        combinedView.notifyDataSetChanged()
    }

    private func refreshBarIcons() {
        // 仅更新柱状条的 icon 标记
        guard let dsVal = currentBarDataSetVal else { return }
        let count = dsVal.entries.count
        for i in 0..<count {
            if i == shouldTag {
                dsVal.entries[i].icon = UIImage(named: "Theme.bundle/icon_dha_tips.png")
            } else {
                dsVal.entries[i].icon = nil
            }
        }
        dsVal.iconsOffset = CGPoint(x: 0, y: 18)
        combinedView.data?.notifyDataChanged()
        combinedView.notifyDataSetChanged()
    }

    // 与 ObjC 的 setBarValues 行为一致：
    // - 背景柱状条固定为 100（用于背景填充）
    // - 实际数值柱状条来自传入的数组
    private func setBarValues(_ values: [NSNumber]) {
        let count = max(xAxisList.count, maxIndex + 1)
        var entriesBg: [BarChartDataEntry] = []
        var entriesVal: [BarChartDataEntry] = []

        for i in 0..<count {
            entriesBg.append(BarChartDataEntry(x: Double(i), y: 100.0))
            let y = i < values.count ? values[i].doubleValue : 0.0
            let entry = BarChartDataEntry(x: Double(i), y: y)
            if i == shouldTag {
                entry.icon = UIImage(named: "Theme.bundle/icon_dha_tips.png")
            }
            entriesVal.append(entry)
        }

        let dsBg = BarChartDataSet(entries: entriesBg, label: "")
        dsBg.axisDependency = YAxis.AxisDependency.left
        dsBg.colors = [hex("#2E92DA")]
        dsBg.drawValuesEnabled = false

        let dsVal = BarChartDataSet(entries: entriesVal, label: "")
        dsVal.axisDependency = YAxis.AxisDependency.left
        dsVal.colors = [hex("#67D0F0")]
        dsVal.drawValuesEnabled = false
        dsVal.iconsOffset = CGPoint(x: 0, y: 18)

        currentBarDataSetBg = dsBg
        currentBarDataSetVal = dsVal

        let barData = BarChartData(dataSets: [dsBg, dsVal])
        barData.barWidth = 0.4

        let combined = combinedView.data as? CombinedChartData ?? CombinedChartData()
        combined.barData = barData
        combinedView.data = combined
        combinedView.notifyDataSetChanged()
    }

    // MARK: - Helpers
    private func hex(_ string: String) -> UIColor {
        var str = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if str.hasPrefix("#") { str.removeFirst() }
        guard str.count == 6 || str.count == 8 else { return .white }
        var rgba: UInt64 = 0
        Scanner(string: str).scanHexInt64(&rgba)
        let r, g, b, a: UInt64
        if str.count == 8 {
            a = (rgba & 0xFF000000) >> 24
            r = (rgba & 0x00FF0000) >> 16
            g = (rgba & 0x0000FF00) >> 8
            b = (rgba & 0x000000FF)
        } else {
            a = 255
            r = (rgba & 0xFF0000) >> 16
            g = (rgba & 0x00FF00) >> 8
            b = (rgba & 0x0000FF)
        }
        return UIColor(red: CGFloat(r) / 255.0,
                       green: CGFloat(g) / 255.0,
                       blue: CGFloat(b) / 255.0,
                       alpha: CGFloat(a) / 255.0)
    }
}

// MARK: - ChartViewDelegate
extension EcChartsView: ChartViewDelegate { }