//
//  EventCycleManager.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/19.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import Foundation

class EventCycleManager {
    // 定义事件类型
    typealias Event = () -> Void
    
    // 私有属性
    private var eventA: Event?
    private var eventB: Event?
    private var timer: Timer?
    private var isRunning = false
    private var shouldExecuteA = true
    
    // 初始化方法
    init(eventA: @escaping Event, eventB: @escaping Event) {
        self.eventA = eventA
        self.eventB = eventB
    }
    
    // 开始周期
    func startCycle() {
        guard !isRunning else { return }
        isRunning = true
        shouldExecuteA = true
        executeNextEvent()
    }
    
    // 结束周期（执行事件B后停止）
    func endCycle() {
        guard isRunning else { return }
        stopTimer()
        eventB?()
        isRunning = false
    }
    
    // 销毁
    func destroy() {
        stopTimer()
        eventA = nil
        eventB = nil
    }
    
    // 私有方法：执行下一个事件
    private func executeNextEvent() {
        guard isRunning else { return }
        
        if shouldExecuteA {
            eventA?()
            let randomInterval = TimeInterval.random(in: 0...180) // 0到3分钟（180秒）的随机时间
            scheduleNextEvent(after: randomInterval)
        } else {
            eventB?()
            let randomInterval = TimeInterval.random(in: 0...60) // 0到1分钟（60秒）的随机时间
            scheduleNextEvent(after: randomInterval)
        }
        
        shouldExecuteA.toggle()
    }
    
    // 私有方法：安排下一个事件
    private func scheduleNextEvent(after interval: TimeInterval) {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.executeNextEvent()
        }
    }
    
    // 私有方法：停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        destroy()
    }
}

