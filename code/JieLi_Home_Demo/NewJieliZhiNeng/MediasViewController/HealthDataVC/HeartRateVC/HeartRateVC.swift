//
//  HeartRateVC.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/14.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit
import SnapKit

class HeartRateVC: BasicViewController {

    private let dateSwitchView = HealthDateSwitchView()
    private let heartRateChartView = HealthDataChartView()
    private let heartRateCountView = HealthDataCountView()
    private let heartRateTestingView = HealthTestAlertView()
    private let historyLab = UILabel()
    private let historyTableView = UITableView()
    
    private let itemsArray = BehaviorRelay<[HeartRateEntryData]>(value: [])
    private let disposeBag = DisposeBag()
   
    override func initUI() {
        super.initUI()
        naviView.titleLab.text = R.Language.lan("Heart Rate")
        dateSwitchView.backgroundColor = .white
        dateSwitchView.setHeartRate()
        view.addSubview(dateSwitchView)
        dateSwitchView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.lessThanOrEqualTo(110)
            make.top.equalTo(naviView.snp.bottom)
        }

        // 图表视图
        view.addSubview(heartRateChartView)
        heartRateChartView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dateSwitchView.snp.bottom)
            make.height.equalTo(210)
        }
        heartRateChartView.configure(metric: .heartRate)
        // 模拟心率数据并绑定
        heartRateChartView.setHeartRateData(mockHeartRateData())

        heartRateCountView.initWithType(type: .heartRate)
        view.addSubview(heartRateCountView)
        heartRateCountView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(heartRateChartView.snp.bottom).offset(16)
            make.height.equalTo(64)
        }
        
        historyLab.text = R.Language.lan("History")
        historyLab.textColor = .eHex("#242424")
        historyLab.font = R.Font.medium(14)
        
        view.addSubview(historyLab)
        historyLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(24)
            make.top.equalTo(heartRateCountView.snp.bottom).offset(16)
        }
        
        historyTableView.backgroundColor = .clear
        historyTableView.separatorStyle = .none
        historyTableView.rowHeight = UITableView.automaticDimension
        historyTableView.estimatedRowHeight = 64
        historyTableView.register(HeartRateHistoryCell.self, forCellReuseIdentifier: "HeartRateHistoryCell")
        view.addSubview(historyTableView)
        historyTableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(historyLab.snp.bottom).offset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        heartRateTestingView.isHidden = true        
    }
    
    
    override func initData() {
        super.initData()
        heartRateChartView.onSelectedModelChange = { [weak self] metric,model in
            guard let self = self, metric == .heartRate else { return }
            switch model {
            case let .heartRate(entry):
                JLLogManager.logLevel(.DEBUG, content: "Selected Heart Rate: \(entry.minBpm) - \(entry.maxBpm) bpm at \(entry.date)")
                dateSwitchView.setHeartRateValue(value: String(Int(entry.averageBpm)), time: entry.date)
            default:
                break
            }
            
        }
        
        itemsArray.bind(to: historyTableView.rx.items(cellIdentifier: "HeartRateHistoryCell", cellType: HeartRateHistoryCell.self)) { index, entry, cell in
            cell.configure(with: entry)
        }.disposed(by: disposeBag)
        
        historyTableView.rx.modelSelected(HeartRateEntryData.self).subscribe(onNext: { [weak self] entry in
            guard let self = self else { return }
            
        }).disposed(by: disposeBag)
        

        dateSwitchView.startBtnClick = { [weak self] in
            guard let self = self else { return }
            showTestingView()
        }
        
        itemsArray.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.historyTableView.reloadData()
            if self.historyTableView.numberOfRows(inSection: 0) > 0 {
                self.historyTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            if itemsArray.value.count == 0 {
                self.historyLab.isHidden = true
                self.historyTableView.isHidden = true
            }else{
                self.historyLab.isHidden = false
                self.historyTableView.isHidden = false
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        requestDataBase()
    }
    
    
    
    private func requestDataBase() {
        let itemList = HealthDataBase.shared.queryHeartRate(onDay: Date())
        itemsArray.accept(itemList)
        heartRateChartView.setHeartRateData(itemList)
        if itemList.count == 0 {
            return
        }
        //找出当天的最低心率以及最大心率，还有平均心率
        let minBpm = itemList.map({ $0.minBpm }).min() ?? 0
        let maxBpm = itemList.map({ $0.maxBpm }).max() ?? 0
        let averageBpm = itemList.map({ Int($0.averageBpm) }).reduce(0, +) / itemList.count
        heartRateCountView.setHeartRate(min: Int(minBpm), max: Int(maxBpm), avg: averageBpm)
        //获取到当天最接近当前时间值的数据
        let now = Date()
        let closestEntry = itemList.min(by: { abs($0.date.timeIntervalSince(now)) < abs($1.date.timeIntervalSince(now)) })
        if let entry = closestEntry {
            dateSwitchView.setHeartRateValue(value: String(Int(entry.averageBpm)), time: entry.date)
        }
    }

    private func showTestingView() {
        let windows = UIApplication.shared.windows
        if let window = windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(heartRateTestingView)
            heartRateTestingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        heartRateTestingView.isHidden = false
    }

}

// MARK: - Mock Data
private extension HeartRateVC {
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
            HeartRateEntryData(date: makeDate(2, 0),  minBpm: 65,  maxBpm: 78, averageBpm: 72),
            HeartRateEntryData(date: makeDate(11, 0),  minBpm: 98,  maxBpm: 122, averageBpm: 110),
            HeartRateEntryData(date: makeDate(12, 0), minBpm: 88,  maxBpm: 102, averageBpm: 95),
            HeartRateEntryData(date: makeDate(17, 30),minBpm: 140, maxBpm: 165, averageBpm: 152),
            HeartRateEntryData(date: makeDate(18, 30),minBpm: 128, maxBpm: 146, averageBpm: 137),
            HeartRateEntryData(date: makeDate(22, 0), minBpm: 78,  maxBpm: 88, averageBpm: 83)
        ]
    }
}
