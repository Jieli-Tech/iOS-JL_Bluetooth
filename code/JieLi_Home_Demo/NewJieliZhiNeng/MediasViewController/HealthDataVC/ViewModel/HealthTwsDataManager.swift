//
//  HealthTwsDataManager.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/16.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit
import JL_BLEKit

enum HealthTestingStatusType {
    case start
    case failed
    case end
}

class HealthTwsDataManager: NSObject {
    static let shared = HealthTwsDataManager()
    
    /// 测试进度
    let progressStatus = PublishSubject<(Float, Int)>()
    /// 测试状态
    let testingStatus = BehaviorSubject<(HealthMetricType, HealthTestingStatusType)>(value: (.heartRate, .end))
    
    
    private var healthManager: JLTwsHealthManager?
    private var config: JLTwsHealthConfig?
    
    private var testingTimer: Timer?
    private var testingCount: Int = 0
    private var testingTimeout: Int = 0
    private var currentTestingType: HealthMetricType = .heartRate

    private override init() {
        super.init()
    }
    
    func initHealthManager(_ complention: @escaping (Bool) -> Void) {
        guard let manager = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else { return }
        healthManager = JLTwsHealthManager(manager, delegate: self)
        healthManager?.cmdGetHealthConfig { [weak self] model, err in
            guard let self = self else { return }
            if err == nil {
                config = model
                complention(true)
            }else{
                complention(false)
            }
        }
    }
    
    func startHeartRateTesting() {
        let chain = JLTaskChain()
        ///检查状态
        chain.addTask { [weak self] _, complention in
            guard let self = self else { return }
            
        }
        //开始测量
        chain.addTask { [weak self] _, complention in
            guard let self = self else { return }
            
        }
        //获取结果
        chain.run(withInitialInput: nil) { timeout, error in
            if (error != nil) {
                JLLogManager.logLevel(.ERROR, content: "Error: \(error?.localizedDescription ?? "")")
                self.testingStatus.onNext((.heartRate, .failed))
            }else{
                self.testingTimeout = timeout as? Int ?? 0
                self.currentTestingType = .heartRate
                self.startTimeout()
                self.testingStatus.onNext((.heartRate, .start))
            }
        }
    }
    
    func cancelHeartRateTesting() {
        stopTimeout()
    }
    
    func startSpO2Testing() {
        let chain = JLTaskChain()
        ///检查状态
        chain.addTask { [weak self] _, complention in
            guard let self = self else { return }
            
        }
        //开始测量
        chain.addTask { [weak self] _, complention in
            guard let self = self else { return }
           
        }
        //获取结果
        chain.run(withInitialInput: nil) { timeout, error in
            if (error != nil) {
                JLLogManager.logLevel(.ERROR, content: "Error: \(error?.localizedDescription ?? "")")
                self.testingStatus.onNext((.spo2, .failed))
            }else{
                self.testingTimeout = timeout as? Int ?? 0
                self.currentTestingType = .spo2
                self.startTimeout()
                self.testingStatus.onNext((.spo2, .start))
            }
        }
    }
    
    func cancelSpO2Testing() {
        stopTimeout()
    }
    
    private func startTimeout() {
        testingTimer?.invalidate()
        testingCount = 0
        testingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeoutCount), userInfo: nil, repeats: true)
        testingTimer?.fire()
    }
    
    @objc private func timeoutCount() {
        testingCount += 1
        progressStatus.onNext((Float(testingCount) / Float(testingTimeout), testingCount))
        if testingCount == testingTimeout {
            stopTimeout()
            if currentTestingType == .heartRate {
                self.testingStatus.onNext((.heartRate, .failed))
            }else if currentTestingType == .spo2 {
                self.testingStatus.onNext((.spo2, .failed))
            }
        }
    }
    
    private func stopTimeout() {
        testingTimer?.invalidate()
        testingTimer = nil
        testingCount = 0
    }

}


extension HealthTwsDataManager: JLTwsHealthManagerDelegate {
    
    func twsHealthSensorStatus(_ heartRateStatus: Bool, bloodOxygenStatus: Bool, stepStatus: Bool, inEarSensorStatus: Bool) {
        
    }
    
    func twsHealthBloodOxygenTimeOut(_ timeOut: Int) {
        
    }
    
    func twsHealthHeartRate(_ heartRate: JLTwsHeartRateModel) {
        guard let status = try?testingStatus.value() else { return }

    }
    
    func twsHealthBloodOxygen(_ spO2: JLTwsSpO2Model) {
         guard let status = try?testingStatus.value() else { return }
        if status.0 == .spo2 && status.1 == .start {
            progressStatus.onNext((1.0, testingCount))
            stopTimeout()
            let entryData = Spo2EntryData(
                date: Date(),
                minPercent: Double(spO2.minSpO2),
                maxPercent: Double(spO2.maxSpO2),
                averagePercent: Double(spO2.avgSpO2)
            )
            HealthDataBase.shared.insertSpO2(entryData)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem(block: { [weak self] in
                guard let self = self else { return }
                self.testingStatus.onNext((.spo2, .end))
            }))
        }
    }
    
    func twsHealthConfigModel(_ model: JLTwsHealthConfig) {
        
    }
    
    func twsHealthHeartRateTimeOut(_ timeOut: Int) {
        
    }
    
    func twsHealthSpO2TimeOut(_ timeOut: Int) {
        
    }
    
    func twsHealthHeartRateCheckError(_ errorCode: Int) {
        JLLogManager.logLevel(.ERROR, content: "twsHealthHeartRateCheckError Error: \(errorCode)")
        stopTimeout()
        testingStatus.onNext((.heartRate, .failed))
    }
    
    func twsHealthBloodOxygenCheckError(_ errorCode: Int) {
        JLLogManager.logLevel(.ERROR, content: "twsHealthBloodOxygenCheckError Error: \(errorCode)")
        stopTimeout()
        testingStatus.onNext((.spo2, .failed))
    }
    
}
