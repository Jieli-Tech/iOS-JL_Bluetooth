//
//  JLEcTools.swift
//  JLBluetoothBasic
//
//  Created by EzioChan on 2021/8/26.
//  Copyright © 2021 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

import Foundation

@objc public class JLTimeOut: NSObject {
    public typealias timeoutBlock = (_ to: JLTimeOut) -> Void
    private var timer: Timer?
    private var number = 0
    private var maxNumber = 0
    private var timeBlock: timeoutBlock?

    public func start(_ time: Int, _ clouse: @escaping () -> Void, _ timeOut: @escaping timeoutBlock) {
        maxNumber = time
        number = 0
        timeBlock = timeOut
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        timer?.fire()
        clouse()
    }

    @objc public func resetTime() {
        number = 0
    }

    @objc public func timerAction() {
        number += 1
        if number >= maxNumber {
            if let p = timeBlock {
                p(self)
            }
            timer?.invalidate()
        }
    }

    @objc public func cancel() {
        timer?.invalidate()
        number = 0
    }
}
