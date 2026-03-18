//
//  TimerHelper.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/7.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class TimerHelper: NSObject {
    private static let shared = TimerHelper()
    private var timerDict: [String: Timer] = [:]
    private var timerCompletions: [String: (String) -> Void] = [:]
    private var timerRepeats: [String: Bool] = [:] // 存储定时器的重复状态
    private static var timerIDCounter: Int = 0

    // 创建单次定时器
    @discardableResult
    static func createTimer(timeOut: Double, completion: @escaping (String) -> Void) -> String {
        let timerID = "timer_\(timerIDCounter)"
        timerIDCounter += 1

        let timer = Timer.scheduledTimer(
            timeInterval: timeOut,
            target: shared,
            selector: #selector(timerAction(_:)),
            userInfo: timerID,
            repeats: false
        )

        shared.timerDict[timerID] = timer
        shared.timerCompletions[timerID] = completion
        shared.timerRepeats[timerID] = false // 单次定时器
        return timerID
    }

    // 创建重复定时器
    static func setInterval(interval: TimeInterval, completion: @escaping (String) -> Void) -> String {
        let timerID = "setInterval_timer_\(timerIDCounter)"
        timerIDCounter += 1

        let timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: shared,
            selector: #selector(timerAction(_:)),
            userInfo: timerID,
            repeats: true
        )

        shared.timerDict[timerID] = timer
        shared.timerCompletions[timerID] = completion
        shared.timerRepeats[timerID] = true // 重复定时器
        return timerID
    }

    // 停止定时器
    static func stopTimer(timerID: String) {
        guard let timer = shared.timerDict[timerID] else { return }
        timer.invalidate()
        shared.timerDict[timerID] = nil
        shared.timerCompletions[timerID] = nil
        shared.timerRepeats[timerID] = nil
    }

    static func stopTimer(timerID: inout String) {
        stopTimer(timerID: timerID)
        timerID = ""
    }

    static func stopAllTimers() {
        for timerID in shared.timerDict.keys {
            stopTimer(timerID: timerID)
        }
    }

    // 定时器触发回调
    @objc private func timerAction(_ timer: Timer) {
        guard let timerID = timer.userInfo as? String else { return }

        // 执行回调
        if let completion = timerCompletions[timerID] {
            completion(timerID)
        }

        // 如果是单次定时器，触发后停止
        if let repeats = TimerHelper.shared.timerRepeats[timerID], !repeats {
            TimerHelper.stopTimer(timerID: timerID)
        }
    }
}
