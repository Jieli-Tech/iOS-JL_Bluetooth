//
//  SoundInfoManager.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/31.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JL_BLEKit
import AVFoundation

class SoundInfoManager: NSObject {
    static let share = SoundInfoManager()
    private weak var manager: JL_ManagerM?
    private var currentVolume: UInt8 = 0
    
    private override init() {
        super.init()
        do {
            AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", context: nil)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            JLLogManager.logLevel(.ERROR, content: "监听音量失败:\(error)")
        }
    }
    
    func addListen() {
        do {
            AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", context: nil)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            JLLogManager.logLevel(.ERROR, content: "监听音量失败:\(error)")
        }
    }
    
    deinit {
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            let currentVolume = AVAudioSession.sharedInstance().outputVolume
            guard let manager = manager else { return }
            let model = manager.outputDeviceModel()
            let maxVol = model.maxVol
            let per = round(currentVolume * Float(maxVol))
            let soundMgr = manager.mSystemVolume
            let vol = UInt8(per)
            if self.currentVolume == vol { return }
            self.currentVolume = vol
            JLLogManager.logLevel(.DEBUG, content: "音量:\(self.currentVolume)")
            
            soundMgr.cmdSetSystemVolume(vol) { status, _, _ in
                if status != .success {
                    JLLogManager.logLevel(.ERROR, content: "设置音量失败:\(status)")
                }
            }
        }
    }
    
    func addSendToDev(_ manager: JL_ManagerM) {
       self.manager = manager
    }
    
    func removeSendToDev() {
        self.manager = nil
    }
    
}
