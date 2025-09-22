//
//  TranslateQueue.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/25.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JL_BLEKit

class TranslateQueue: NSObject {
    var type: JLTranslateAudioSourceType = .typeESCODown
    private var queueData = Data()
    private var sendDataObj: JLTranslateAudio?
    private let lock = NSLock()
    private var cacheSize = 400
    private let maxSize = 2000
    private var popBlock: ((JLTranslateAudio,Data) -> Void)?
    private var timerId:String = ""
    
    init(type: JLTranslateAudioSourceType, queueData: Data = Data(), cacheSize: Int = 400, popBlock: ((JLTranslateAudio,Data) -> Void)?) {
        self.type = type
        self.queueData = queueData
        self.cacheSize = cacheSize
        self.popBlock = popBlock
    }
    
    
    func push(data: JLTranslateAudio) {
        sendDataObj = data
        lock.lock()
        queueData.append(data.data)
        lock.unlock()
        
        timerId = TimerHelper.createTimer(timeOut: 1) { [weak self] _ in
            guard let `self` = self else { return }
            cacheSize = 1000
        }
        if queueData.count > cacheSize {
            if let dt = pop(),let obj = sendDataObj {
                popBlock?(obj, dt)
                lock.lock()
                queueData.removeFirst(dt.count)
                lock.unlock()
            }
        }
    }
    
    private func pop() -> Data? {
        lock.lock()
        defer { lock.unlock() } // Ensure the lock is always released
        // Check if there is enough data to pop
        if queueData.count < 160 {
            JLLogManager.logSomething("Not enough data to pop")
            return nil
        }
        
        let num = queueData.count / 120
        let size = min(num * 160, queueData.count) // Ensure size does not exceed queueData.count
        
        JLLogManager.logSomething("Calculated size: \(size), queueData.count: \(queueData.count)")
        
        // Extract and remove the data
        let data = (queueData as NSData).subf(0, t: size)
        
        // Update cacheSize
        if cacheSize < maxSize {
            cacheSize += 160
        } else {
            cacheSize = maxSize
        }
        TimerHelper.stopTimer(timerID: &timerId)
        return data
    }
}
