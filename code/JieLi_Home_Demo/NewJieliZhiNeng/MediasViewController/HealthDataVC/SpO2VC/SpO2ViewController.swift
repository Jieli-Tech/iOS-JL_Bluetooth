//
//  SpO2ViewController.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/16.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

/// 血氧饱和度页面：包含测量数据显示（图表 + 汇总），以及仅时间戳的历史记录列表
class SpO2ViewController: BasicViewController {
    private let dateSwitchView = HealthDateSwitchView()
    private let spo2ChartView = HealthDataChartView()
    private let spo2CountView = HealthDataCountView()
    private let historyLab = UILabel()
    private let historyTableView = UITableView()

    private let itemsArray = BehaviorRelay<[Spo2EntryData]>(value: [])
    private let disposeBag = DisposeBag()

    override func initUI() {
        super.initUI()
        naviView.titleLab.text = R.Language.lan("SpO2")

        // 日期切换与快速信息
        dateSwitchView.backgroundColor = .white
        view.addSubview(dateSwitchView)
        dateSwitchView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.lessThanOrEqualTo(110)
            make.top.equalTo(naviView.snp.bottom)
        }

        // 图表视图（显示 SpO2），保持与心率页面一致的高度与边距
        view.addSubview(spo2ChartView)
        spo2ChartView.configure(metric: .spo2)
        spo2ChartView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dateSwitchView.snp.bottom)
            make.height.equalTo(210)
        }

        // 汇总统计视图（最小-最大/平均），与心率页面一致的布局
        view.addSubview(spo2CountView)
        spo2CountView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(spo2ChartView.snp.bottom).offset(16)
            make.height.equalTo(64)
        }

        // 历史记录标题
        historyLab.text = R.Language.lan("History")
        historyLab.textColor = .eHex("#242424")
        historyLab.font = R.Font.medium(14)
        view.addSubview(historyLab)
        historyLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(24)
            make.top.equalTo(spo2CountView.snp.bottom).offset(16)
        }

        // 历史记录列表：仅显示时间戳，UI 风格与心率页面一致
        historyTableView.backgroundColor = .clear
        historyTableView.separatorStyle = .none
        historyTableView.rowHeight = UITableView.automaticDimension
        historyTableView.estimatedRowHeight = 64
        historyTableView.register(SpO2HistoryCell.self, forCellReuseIdentifier: "SpO2HistoryCell")
        view.addSubview(historyTableView)
        historyTableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(historyLab.snp.bottom).offset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    override func initData() {
        super.initData()

        // 图表选中回调：遵循统一回调逻辑
        spo2ChartView.onSelectedModelChange = { [weak self] metric, model in
            guard let self = self, metric == .spo2 else { return }
            switch model {
            case let .spo2(entry):
                print("Selected SpO2: min=\(Int(entry.minPercent)) max=\(Int(entry.maxPercent)) at \(entry.date)")
            default:
                break
            }
        }

        // 列表绑定，仅显示时间戳
        itemsArray.bind(to: historyTableView.rx.items(cellIdentifier: "SpO2HistoryCell", cellType: SpO2HistoryCell.self)) { index, entry, cell in
            cell.configure(with: entry)
        }.disposed(by: disposeBag)

        // 模拟 SpO2 数据并绑定到图表与列表
        let entries = mockSpO2Data()
        spo2ChartView.setSpo2Data(entries)
        itemsArray.accept(entries)

        // 汇总统计（最小/最大/平均）
        let minVal = Int(entries.map { $0.minPercent }.min() ?? 95)
        let maxVal = Int(entries.map { $0.maxPercent }.max() ?? 100)
        let avgVal = Int(entries.map { ($0.minPercent + $0.maxPercent)/2.0 }.reduce(0, +) / Double(entries.count))
        spo2CountView.setSpO2(min: minVal, max: maxVal, avg: avgVal)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spo2ChartView.setSpo2Data(mockSpO2Data())
    }

}

// MARK: - Mock Data
private extension SpO2ViewController {
    /// 当天多个时刻的 SpO2 模拟数据（百分比），与 24h 时间轴对齐
    func mockSpO2Data() -> [Spo2EntryData] {
        let calendar = Calendar.current
        let now = Date()
        var comps = calendar.dateComponents([.year, .month, .day], from: now)

        func makeDate(_ h: Int, _ m: Int) -> Date {
            comps.hour = h
            comps.minute = m
            return calendar.date(from: comps) ?? now
        }

        // 示例数据：不同时间点的 SpO2 区间（仍以区间承载，但历史 Cell 不展示范围）
        return [
            Spo2EntryData(date: makeDate(6, 30),  minPercent: 95, maxPercent: 98, averagePercent: 96),
            Spo2EntryData(date: makeDate(9, 45),  minPercent: 96, maxPercent: 99, averagePercent: 97),
            Spo2EntryData(date: makeDate(12, 15), minPercent: 94, maxPercent: 97, averagePercent: 95),
            Spo2EntryData(date: makeDate(18, 0),  minPercent: 92, maxPercent: 95, averagePercent: 93),
            Spo2EntryData(date: makeDate(22, 20), minPercent: 93, maxPercent: 96, averagePercent: 94)
        ]
    }
}
