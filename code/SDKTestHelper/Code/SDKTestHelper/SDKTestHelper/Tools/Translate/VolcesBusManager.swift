//
//  VolcesBusManager.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/7.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JL_BLEKit
import JLAudioUnitKit

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
    private var subSendData: Data = .init()
    
    private var audioType: JL_SpeakDataType = .OPUS
    private var toAudioType: JL_SpeakDataType = .OPUS
    private var isUseA2dp: Bool = false
    private var isSupportOpusStereo: Bool = false
    private var errorCallback: ((Error) -> Void)?
    
    var targetData: BehaviorRelay<Data> = BehaviorRelay(value: Data())
    var targetPcmData: BehaviorRelay<(Data, [String])> = BehaviorRelay(value: (Data(), []))
    var subtitleText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var definiteTextOrigin: BehaviorRelay<String> = BehaviorRelay(value: "")
    var definiteTextTranslate: BehaviorRelay<String> = BehaviorRelay(value: "")
    var devPcmLeftData: PublishRelay<Data> = PublishRelay()
    var devPcmRightData: PublishRelay<Data> = PublishRelay()
    var isTTSing: PublishRelay<Bool> = PublishRelay()
    var isSendSoon: Bool = true // 识别后语音后立即翻译成 tts 下发


    init(_ languageType: JL_SpeakDataType, _ toLanguage: JL_SpeakDataType, _ from: TranslateLanguage, _ to: [TranslateLanguage], _ isUseA2dp: Bool, _ isOpusStereo: Bool = false, _ resultBlock: @escaping (Bool) -> Void) {
        super.init()
        audioType = languageType
        toAudioType = toLanguage
        self.isUseA2dp = isUseA2dp
        tmpTtsPcmData = Data()
        isSupportOpusStereo = isOpusStereo
        ttsMgr = VolcesTTSMgr()
        translateMgr = VolcesTranslateMgr()

        if languageType == .OPUS || toLanguage == .OPUS {
            coderOpus = TranslateOpusHelper({ [weak self] pcmData in
                guard let self = self else { return }
                if !isSupportOpusStereo {
                    self.startTranslate(pcmData)
                }
            }, { [weak self] opusData in
                guard let self = self else { return }
                    self.outPutData(opusData)
            }, { [weak self] pcmData, pcmData2 in
                guard let self = self else { return }
                if self.isSupportOpusStereo == true {
                    if let left = pcmData {
                        self.devPcmLeftData.accept(left)
                    }
                    if let right = pcmData2 {
                        self.devPcmRightData.accept(right)
                    }
                }
            })
            if isSupportOpusStereo {
                let ops = JLOpusFormat.defaultFormats()
                ops.hasDataHeader = false
                ops.channels = 2
                ops.dataSize = 80
                coderOpus?.resetDecoderByFormat(ops)
            }
        }
        if languageType == .JLA_V2 || toLanguage == .JLA_V2 {
            coderJav2 = TranslateAV2Helper({ [weak self] pcmData in
//                JLLogManager.logLevel(.INFO, content: "call translate pcm data:\(pcmData.count)")
                self?.startTranslate(pcmData)
            }, { [weak self] jlav2Data in
                guard let self = self else { return }
                self.targetData.accept(jlav2Data)
//                let path = _R.path.jlaV2Path + "/test.jla"
//                _R.appendToFile(filePath: path, data: jlav2Data)
            })
        }

        let chain = JLTaskChain()
        initTranslateMgr(chain: chain, from: from, to: to)
        chain.run(withInitialInput: nil) { _, err in
            if err != nil {
                JLLogManager.logLevel(.ERROR, content: "init error:\(String(describing: err))")
            }
            resultBlock(err == nil)
        }
    }

    func startTranslateData(_ decodeData: Data) {
        if audioType == .OPUS {
            coderOpus?.decodeDataToPcm(decodeData)
        }
        if audioType == .JLA_V2 {
            coderJav2?.decodeDataToPcm(decodeData)
        }
        if audioType == .PCM {
            translateMgr?.sendAudioData(decodeData)
        }
    }

    func startTranslatePcmData(_ pcmData: Data) {
        translateMgr?.sendAudioData(pcmData)
    }

    func sendPcmDataToDevice(_ pcmData: Data) {
        if isUseA2dp == true {
            JLAudioPlayer.shared.enqueuePCMData(pcmData)
        }
        if toAudioType == .JLA_V2 {
            coderJav2?.pcmToEnCodeData(pcmData)
        }
        if toAudioType == .OPUS {
            coderOpus?.pcmToEnCodeData(pcmData)
        }
        if toAudioType == .PCM {
            targetData.accept(pcmData)
        }
    }

    func onErrorCallBack(_ callback: @escaping (Error) -> Void) {
        errorCallback = callback
    }

    func sendTextToTTS(_ texts: [String]) {
        ttsMgr?.sendText(texts)
        isTTSing.accept(true)
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
        errorCallback = nil
    }
    
    private func initTranslateMgr(chain:JLTaskChain, from: TranslateLanguage, to: [TranslateLanguage]) {
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            ttsMgr?.start({ initStatus in
                JLLogManager.logLevel(.INFO, content: "tts init status:\(initStatus)")
                if initStatus {
                    completion(nil, nil)
                } else {
                    completion(nil, NSError(domain: "tts init error", code: 0, userInfo: nil))
                }
            }, { [weak self] pcmData, _, isEnd, err in
                self?.tmpTtsPcmData?.append(pcmData)
                JLLogManager.logLevel(.INFO, content: "tts pcm data:\(self?.tmpTtsPcmData?.count ?? 0) ,isEnd:\(isEnd)")
                if let err = err {
                    self?.errorCallback?(err)
                    return
                }
                if isEnd {
                    self?.isTTSing.accept(false)
                    let dt = Data(self?.tmpTtsPcmData ?? Data())
                    let translateText = self?.ttsMgr?.translateText ?? []
                    JLLogManager.logLevel(.DEBUG, content: "tts didFinish:\(translateText)")
                    self?.targetPcmData.accept((dt, translateText))
                    if self?.isSendSoon == true {
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
                    if response.subtitle.language == from.rawValue {
                        self.subtitleText.accept(response.subtitle.text)
                    }
                    JLLogManager.logLevel(.INFO, content: "translate subtitle:\(response.subtitle.text) definite:\(response.subtitle.definite)，language:\(response.subtitle.language)")
                    if ttsMgr?.isConnected == true,
                       response.subtitle.definite
                    {
                        if response.subtitle.language == to[0].rawValue {
                            sendTextToTTS([response.subtitle.text, definiteTextOrigin.value])
                            self.definiteTextTranslate.accept(response.subtitle.text)
                            if to[0] == from {
                                self.definiteTextOrigin.accept(response.subtitle.text)
                            }
                        } else if response.subtitle.language == from.rawValue {
                            self.definiteTextOrigin.accept(response.subtitle.text)
                        }
                    }
                },
                result: { initStatus in
                    JLLogManager.logLevel(.INFO, content: "translate init status:\(initStatus)")
                    if initStatus {
                        completion(nil, nil)
                    } else {
                        completion(nil, NSError(domain: "translate init error", code: 0, userInfo: nil))
                    }
                }
            )
        }
    }
    
    private func outPutData(_ opusData: Data) {
        lock.lock()
        subSendData.append(opusData)
        lock.unlock()
        if subSendData.count >= 600 {
            targetData.accept(Data(subSendData))
            JLLogManager.logLevel(.DEBUG, content: "opus data:\(subSendData.count)")
            lock.lock()
            subSendData = Data()
            lock.unlock()
        }
        cachetimer?.invalidate()
        cacheCountTime = 0
        cachetimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(cacheTimeOutAction), userInfo: nil, repeats: true)
        cachetimer?.fire()
    }
    

    func startTranslate(_ pcm: Data) {
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

