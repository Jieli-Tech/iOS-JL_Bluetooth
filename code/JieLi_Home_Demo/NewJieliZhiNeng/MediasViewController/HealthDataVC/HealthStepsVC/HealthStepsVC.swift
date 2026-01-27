//
//  HealthStepsVC.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/16.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class HealthStepsVC: BasicViewController {
    private let dateSwitchView = HealthDateSwitchView()
    private let stepsChartView = HealthDataChartView()
    private let stepsCountView = HealthDataCountView()
    private let settingsView = HealthStepsSettingView()
    private let disposeBag = DisposeBag()
    
    override func initUI() {
        super.initUI()
        naviView.titleLab.text = LanguageCls.localizableTxt("Steps_2")
        // 日期切换与快速信息
        dateSwitchView.backgroundColor = .white
        view.addSubview(dateSwitchView)
        dateSwitchView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.lessThanOrEqualTo(110)
            make.top.equalTo(naviView.snp.bottom)
        }

        view.addSubview(stepsChartView)
        stepsChartView.configure(metric: .steps)
        stepsChartView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(dateSwitchView.snp.bottom)
            make.height.equalTo(210)
        }

        view.addSubview(stepsCountView)
        stepsCountView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(stepsChartView.snp.bottom).offset(16)
            make.height.equalTo(64)
        }
        
        
        
    }
    
    override func initData() {
        super.initData()
        
        stepsChartView.onSelectedModelChange = { [weak self] metric, model in
            guard let self = self, metric == .spo2 else { return }
            switch model {
            case let .spo2(entry):
                print("Selected SpO2: min=\(Int(entry.minPercent)) max=\(Int(entry.maxPercent)) at \(entry.date)")
            default:
                break
            }
        }
        
        dateSwitchView.settingBtnClick = { [weak self] in
            guard let self = self else { return }
            showSetting()
        }
        
        let entries = mockStepData()

        var allSteps = 0.0
        for entry in entries {
            allSteps += entry.steps
        }
        stepsCountView.setStep(all: Int(allSteps))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stepsChartView.setStepsData(mockStepData())
    }
    
    private func showSetting() {
        let windows = UIApplication.shared.windows
        if let window = windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(settingsView)
            settingsView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        settingsView.isHidden = false
    }

}

// MARK: - Mock Data
private extension HealthStepsVC {
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
}
