//
//  VolcesBusManager.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/7.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class VolcesBusManager: NSObject {
    private var ttsMgr: VolcesTTSMgr?
    private var translateMgr: VolcesTranslateMgr?
    private var tmpTtsPcmData: Data?
    private var coderOpus: TranslateOpusHelper?
    private var coderJav2: TranslateAV2Helper?
    private var timer: Timer?
    private var countTime: TimeInterval = 0
    private var maxCountTime: TimeInterval = 5
    private var cachetimer: Timer?
    private var cacheCountTime: TimeInterval = 0
    private let lock = NSLock()
    private var subSendData: Data = Data()
    private var audioType: JL_SpeakDataType = .OPUS
    private var toAudioType: JL_SpeakDataType = .OPUS
    private var isUseA2dp: Bool = false
    var targetData: BehaviorRelay<Data> = BehaviorRelay(value: Data())
    var subtitleText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var isTTSing: PublishRelay<Bool> = PublishRelay()
    
    
    
    init(_ languageType: JL_SpeakDataType, _ toLanguage: JL_SpeakDataType , _ from: TranslateLanguage, _ to: [TranslateLanguage], _ isUseA2dp: Bool,_ resultBlock: @escaping (Bool) -> Void) {
        super.init()
        audioType = languageType
        toAudioType = toLanguage
        self.isUseA2dp = isUseA2dp
        tmpTtsPcmData = Data()
        ttsMgr = VolcesTTSMgr()
        translateMgr = VolcesTranslateMgr()
        
        if languageType == .OPUS || toLanguage == .OPUS {
            coderOpus = TranslateOpusHelper({ [weak self] pcmData in
                self?.startTranslate(pcmData)
            }, { [weak self] opusData in
                guard let self = self else { return }
                self.outPutData(opusData)
            })
        }
        if languageType == .JLA_V2 || toLanguage == .JLA_V2 {
            coderJav2 = TranslateAV2Helper({ [weak self] pcmData in
                JLLogManager.logLevel(.INFO, content: "call translate pcm data:\(pcmData.count)")
                self?.startTranslate(pcmData)
            }, { [weak self] jlav2Data in
                guard let self = self else { return }
                self.targetData.accept(jlav2Data)
//                let path = _R.path.jlaV2Path + "/test.jla"
//                _R.appendToFile(filePath: path, data: jlav2Data)
            })
        }
        
        let chain = JLTaskChain()
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            ttsMgr?.start({ initStatus in
                JLLogManager.logLevel(.INFO, content: "tts init status:\(initStatus)")
                if initStatus {
                    completion(nil, nil)
                } else {
                    completion(nil,NSError(domain: "tts init error", code: 0, userInfo: nil))
                }
            }, { [weak self] pcmData, isEnd in
                self?.tmpTtsPcmData?.append(pcmData)
                JLLogManager.logLevel(.INFO, content: "tts pcm data:\(pcmData.count) ,isEnd:\(isEnd)")
                if isEnd {
                    self?.isTTSing.accept(false)
                    let dt = Data(self?.tmpTtsPcmData ?? Data())
                    if self?.isUseA2dp == true {
                        self?.outPutData(dt)
                        self?.tmpTtsPcmData = Data()
                        return
                    }
                    if self?.toAudioType == .JLA_V2 {
                        self?.coderJav2?.pcmToEnCodeData(dt)
                    }
                    if self?.toAudioType == .OPUS {
                        self?.coderOpus?.pcmToEnCodeData(dt)
                    }
                    if self?.toAudioType == .PCM {
                        self?.targetData.accept(dt)
                    }
                    self?.tmpTtsPcmData = Data()
                }
            })
        }
        
        chain.addTask {
            [weak self] _,
            completion in
            self?.translateMgr?.start(
                from,
                to,
                { [weak self] response in
                    guard let self = self else { return }
                    self.subtitleText.accept(response.subtitle.text)
                    JLLogManager.logLevel(.INFO, content: "translate subtitle:\(response.subtitle.text) definite:\(response.subtitle.definite)，language:\(response.subtitle.language)")
                    if ttsMgr?.isConnected == true &&
                        response.subtitle.definite &&
                        response.subtitle.language == to[0].rawValue {
                        ttsMgr?.sendText(response.subtitle.text)
                        isTTSing.accept(true)
                    }
                },
                result: { initStatus in
                JLLogManager.logLevel(.INFO, content: "translate init status:\(initStatus)")
                if initStatus {
                    completion(nil, nil)
                } else {
                    completion(nil,NSError(domain: "translate init error", code: 0, userInfo: nil))
                }
            })
        }
        
        chain.run(withInitialInput: nil) {  _ , err in
            if (err != nil) {
                JLLogManager.logLevel(.ERROR, content: "init error:\(String(describing: err))")
            }
            resultBlock(err == nil)
        }
    }
    
    func startTranslateData(_ decodeData: Data) {
        if (audioType == .OPUS) {
            coderOpus?.decodeDataToPcm(decodeData)
        }
        if (audioType == .JLA_V2) {
            coderJav2?.decodeDataToPcm(decodeData)
        }
        if (audioType == .PCM) {
            translateMgr?.sendAudioData(decodeData)
        }
    }
    
    func endTranslate() {
       translateMgr?.endAudioData()
    }
    
    func onDestory() {
        translateMgr?.stop()
        ttsMgr?.stop()
        translateMgr = nil
        ttsMgr = nil
        tmpTtsPcmData = nil
        targetData.accept(Data())
        subtitleText.accept("")
        isTTSing.accept(false)
    }
    
    private func outPutData(_ opusData: Data) {
        lock.lock()
        subSendData.append(opusData)
        lock.unlock()
        if subSendData.count >= 600 {
            targetData.accept(subSendData)
            JLLogManager.logLevel(.DEBUG, content: "opus data:\(subSendData.count)")
            lock.lock()
            subSendData = Data()
            lock.unlock()
        }
        self.cachetimer?.invalidate()
        self.cacheCountTime = 0
        self.cachetimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(cacheTimeOutAction), userInfo: nil, repeats: true)
        self.cachetimer?.fire()
    }
    private func startTranslate(_ pcm: Data) {
        translateMgr?.sendAudioData(pcm)
        timer?.invalidate()
        countTime = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(countTimerAction), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc private func countTimerAction() {
        countTime += 1
        if countTime >= maxCountTime {
            endTranslate()
        }
    }
    
    @objc private func cacheTimeOutAction() {
        cacheCountTime += 1
        if cacheCountTime >= maxCountTime {
            cachetimer?.invalidate()
            cachetimer = nil
            targetData.accept(subSendData)
            JLLogManager.logLevel(.DEBUG, content: "opus last data:\(subSendData.count)")
            cacheCountTime = 0
            lock.lock()
            subSendData = Data()
            lock.unlock()
        }
    }
    
}
