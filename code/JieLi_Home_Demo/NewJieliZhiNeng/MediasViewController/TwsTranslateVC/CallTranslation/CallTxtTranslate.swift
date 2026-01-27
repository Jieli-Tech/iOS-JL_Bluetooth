//
//  CallTxtTranslate.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/22.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit


class TextTranslateMgr: NSObject {
    static let share = TextTranslateMgr()
    private var translateListCache: [CallTxtTranslate] = []
    
    func startTranslate(groupID: String, origin: String, Date:Date, callBack:@escaping (CallRecord) -> Void) {
        let ctt = CallTxtTranslate()
        ctt.timeoutBlock = { [weak self] item in
            guard let self = self else { return }
            translateListCache.removeAll(where: { $0.currentDate == item.currentDate })
        }
        translateListCache.append(ctt)
        ctt.startTranslate(groupID: groupID, origin: origin, Date: Date, callBack: callBack)
    }
    
}

fileprivate class CallTxtTranslate: NSObject {
    private let convertTTSMgr = VolcesTTSMgr()
    private let translateMgr = VolcesTranslateMgr()
    private let convertTTStep2Mgr = VolcesTTSMgr()
    
    private var currentTranslate: String = ""
    private var currentOrigin: String = ""
    private var groupID: String = ""
    private var audioOrigin: Data = Data()
    private var audioTranslate: Data = Data()
    private var uuidStr = UUID().uuidString
    private typealias CallRecordCallBack = (CallRecord) -> Void
    private var callBackBlock: CallRecordCallBack? = nil
    var timeoutBlock: (CallTxtTranslate)->Void = {_ in }
    var currentDate: Date = Date()
    
    func startTranslate(groupID: String, origin: String, Date:Date, callBack:@escaping (CallRecord) -> Void) {
        self.currentTranslate = ""
        self.audioOrigin = Data()
        self.audioTranslate = Data()
        self.currentOrigin = origin
        self.groupID = groupID
        self.currentDate = Date
        self.callBackBlock = callBack
        
        let chain = JLTaskChain()
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            convertTTSMgr.start { initStatus in
                JLLogManager.logLevel(.DEBUG, content: "original text convert to tts initOK")
                if initStatus {
                    completion(nil, nil)
                }else{
                    completion(nil, NSError(domain: "original text convert to tts init error", code: 0, userInfo: nil))
                }
            } _: { pcmData, _, status, err in
                self.audioOrigin.append(pcmData)
                if status {
                    JLLogManager.logLevel(.DEBUG, content: "original text convert to tts finish:\(self.audioOrigin.count)")
                    self.translateMgr.sendAudioData(self.audioOrigin)
                    self.translateMgr.endAudioData()
                }
            }
        }
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            convertTTStep2Mgr.start { initStatus in
                JLLogManager.logLevel(.DEBUG, content: "translte text convert to tts initOK")
                if initStatus {
                    completion(nil, nil)
                }else{
                    completion(nil, NSError(domain: "translte text convert to tts init error", code: 0, userInfo: nil))
                }
            } _: { pcmData, _, status, err in
                self.audioTranslate.append(pcmData)
                if status {
                    self.startTimer()
                    let model = CallRecord(groupID: self.groupID, startTime: self.currentDate.timeIntervalSince1970, originText: self.currentOrigin, translateText: self.currentTranslate, direction: .mySide,audioData: self.audioTranslate, audioDataOrigin: self.audioOrigin)
                    JLLogManager.logLevel(.DEBUG, content: "translte text convert to tts initOK")
                    self.callBackBlock?(model)
                }
            }
        }
        chain.addTask { [weak self] _ , completion in
            guard let self = self else { return }
            let languages = TranslateTools.getLanguages(.call)
            translateMgr.start(languages.0, [languages.1]) { [weak self] response in
                guard let self = self else { return }
                JLLogManager.logLevel(.INFO, content: "translate response:\(response)")
                if response.subtitle.definite, response.subtitle.language == languages.1.rawValue {
                    JLLogManager.logLevel(.INFO, content: " definite:\(response.subtitle.definite)，language:\(response.subtitle.language),seq:\(response.subtitle.sequence),beginTime:\(response.subtitle.beginTime),endTime:\(response.subtitle.endTime),text:\(response.subtitle.text)")
                    self.currentTranslate.append(response.subtitle.text)
                    self.convertTTStep2Mgr.sendText([response.subtitle.text])
                    self.startTimer()
                }
            } result: { initStatus in
                JLLogManager.logLevel(.INFO, content: "translate init status:\(initStatus), from:\(languages.0), to:\(languages.1)")
                completion(nil, nil)
            }
        }
        chain.run(withInitialInput: nil) { _, err in
            if err != nil {
                JLLogManager.logLevel(.ERROR, content: "reset error:\(String(describing: err))")
                return
            }
            self.convertTTSMgr.sendText([origin])
            self.startTimer()
        }
    }
    
    private func onDestory() {
        translateMgr.stop()
        convertTTSMgr.stop()
        convertTTStep2Mgr.stop()
        TimerHelper.stopTimer(timerID: uuidStr)
    }
    
    private func startTimer() {
        TimerHelper.stopTimer(timerID: uuidStr)
        uuidStr = TimerHelper.createTimer(timeOut: 20) { _ in
            self.onDestory()
            self.callBackBlock = nil
            self.timeoutBlock(self)
        }
    }
    
    
}
