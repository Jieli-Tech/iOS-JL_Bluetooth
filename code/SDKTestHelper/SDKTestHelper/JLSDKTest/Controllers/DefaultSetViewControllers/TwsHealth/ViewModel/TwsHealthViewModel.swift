//
//  TwsHealthViewModel.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/10.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JL_BLEKit
import RxSwift
import RxCocoa

class TwsHealthViewModel: NSObject, JLTwsHealthManagerDelegate {
    let healthConfigSubject = BehaviorSubject<JLTwsHealthConfig?>(value: nil)
    let sensorStatusSubject = BehaviorSubject<(heart: Bool, spO2: Bool, step: Bool, inEar: Bool)?>(value: nil)
    let heartRateSubject = PublishSubject<JLTwsHeartRateModel>()
    let spO2Subject = PublishSubject<JLTwsSpO2Model>()
    let stepSubject = PublishSubject<JLTwsStepModel>()
    let dailyHeartSubject = PublishSubject<JLTwsHealthHeartRateModel>()
    let opFeedbackSubject = PublishSubject<String>()

    private let bag = DisposeBag()
    private var manager: JLTwsHealthManager?

    override init() {
        super.init()
        if let cmdMgr = BleManager.shared.currentCmdMgr {
            manager = JLTwsHealthManager(cmdMgr, delegate: self)
        }
    }

    // MARK: - Public API
    func readHealthConfig() {
        manager?.cmdGetHealthConfig { [weak self] mode, error in
            guard let self = self else { return }
            if let e = error {
                self.opFeedbackSubject.onNext("读取能力失败: \(e.localizedDescription)")
            } else {
                self.healthConfigSubject.onNext(mode)
            }
        }
    }

    func checkSensorStatus() {
        manager?.cmdCheckSensorStatus({ [weak self] heart, spO2, step, inEar, error in
            guard let self = self else { return }
            if let e = error {
                self.opFeedbackSubject.onNext("查询状态失败: \(e.localizedDescription)")
            } else {
                self.sensorStatusSubject.onNext((heart, spO2, step, inEar))
            }
        })
    }

    func startHeartRate() { opAction(.startHeartRate) }
    func cancelHeartRate() { opAction(.cancelHeartRate) }
    func startSpO2() { opAction(.startBloodOxygen ) }
    func cancelSpO2() { opAction(.cancelBloodOxygen ) }
    func startStep() { opAction(.startStep) }
    func cancelStep() { opAction(.cancelStep) }
    func startDailyHeartSync() { opAction(.startDailyHeartSync) }
    func endDailyHeartSync() { opAction(.endDailyHeartSync) }

    func queryRealStep() { manager?.queryRealStep() }
    func loopQuery(intervalSec: TimeInterval) { manager?.loopQueryRealStep(intervalSec) }
    func cancelLoopQuery() { manager?.cancelLoopQueryRealStep() }

    private func opAction(_ type: JLTwsHealthOpType) {
        manager?.twsHealthOpAction(with: type) { [weak self] error in
            guard let self = self else { return }
            if let e = error {
                self.opFeedbackSubject.onNext("操作失败: \(e.localizedDescription)")
            } else {
                self.opFeedbackSubject.onNext("操作成功")
            }
        }
    }

    // MARK: - Delegate
    func twsHealthConfigModel(_ model: JLTwsHealthConfig) {
        healthConfigSubject.onNext(model)
    }
    func twsHealthSensorStatus(_ heartRateStatus: Bool, bloodOxygenStatus: Bool, stepStatus: Bool, inEarSensorStatus: Bool) {
        sensorStatusSubject.onNext((heartRateStatus, bloodOxygenStatus, stepStatus, inEarSensorStatus))
    }
    func twsHealthHeartRate(_ heartRate: JLTwsHeartRateModel) {
        heartRateSubject.onNext(heartRate)
    }
    func twsHealthBloodOxygen(_ spO2: JLTwsSpO2Model) {
        spO2Subject.onNext(spO2)
    }
    func twsHealthStep(_ step: JLTwsStepModel) {
        stepSubject.onNext(step)
    }
    func twsHealthDailyHeartRate(_ dailyHeartRate: JLTwsHealthHeartRateModel) {
        dailyHeartSubject.onNext(dailyHeartRate)
    }
    func twsHealthStartHeartRate() { opFeedbackSubject.onNext("心率监测已开启") }
    func twsHealthCancelHeartRate() { opFeedbackSubject.onNext("心率监测已取消") }
    func twsHealthStartBloodOxygen() { opFeedbackSubject.onNext("血氧监测已开启") }
    func twsHealthCancelBloodOxygen() { opFeedbackSubject.onNext("血氧监测已取消") }
    func twsHealthStartStep() { opFeedbackSubject.onNext("步数监测已开启") }
    func twsHealthCancelStep() { opFeedbackSubject.onNext("步数监测已取消") }
    func twsHealthStartDailyHeartSync() { opFeedbackSubject.onNext("全天心率同步已开启") }
    func twsHealthEndDailyHeartSync() { opFeedbackSubject.onNext("全天心率同步已结束") }
}
