//
//  TranslateVM.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/25.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JLAudioUnitKit
import JL_BLEKit

/// 翻译模块
class TranslateVM: NSObject {
    
    // MARK: - 单例与配置属性
    static let shared = TranslateVM()
    var audioData: JLTranslateAudio?             // 接收到的音频数据块
    var isLocal: Bool = true                     // 是否使用本地回复测试
    var writeWithoutResponse: Bool = false       // 是否启用非交互式下发音频数据
    var saveFilePath: String?                    // 保存文件路径
    var contextVC: UIViewController?             // 上下文视图控制器
    var currentMode: JLTranslateSetMode = JLTranslateSetMode()  // 当前翻译模式
    
    // MARK: - 数据中继器
    var targetData: BehaviorRelay<Data> = BehaviorRelay(value: Data())
    var subTitleText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var callUploadData: BehaviorRelay<Data> = BehaviorRelay(value: Data())
    var callUploadText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var convertedPcmData: BehaviorRelay<Data> = BehaviorRelay(value: Data())
    var subjectCurrentMode: PublishRelay<JLTranslateSetMode> = PublishRelay()
    
    // MARK: - 核心管理器
    var translateHelper: JLTranslationManager?   // 翻译助手
    var translateMgr: VolcesBusManager?          // 翻译管理器
    var callTranslateMgr: VolcesBusManager?      // 通话翻译管理器
    
    // MARK: - 编解码工具
    private var coderOpus: TranslateOpusHelper?  // Opus编解码器
    private var coderJav2: TranslateAV2Helper?   // JLA_V2编解码器
    private lazy var jlav2Packager: JLAV2Codec = {  // JLAV2编码打包器
        let packager = JLAV2Codec(delegate: self)
        return packager
    }()
    private lazy var opusPackager: JLOpusEncoder = {  // Opus编码器
        let packager = JLOpusEncoder(format: JLOpusFormat.defaultFormats(), delegate: self)
        return packager
    }()
    
    // MARK: - 私有属性
    private var queueList: [TranslateQueue] = []  // 翻译队列列表
    private let disposeBag = DisposeBag()         // RxSwift资源管理
    private var isInitCfg = false                 // 配置是否初始化完成
    private var isCallObs: NSKeyValueObservation? // 通话状态观察器
    private var transDataBag: Disposable?         // 翻译数据订阅
    private var subTitleTextBag: Disposable?      // 字幕文本订阅
    private var callDataBag: Disposable?          // 通话数据订阅
    private var callTextBag: Disposable?          // 通话文本订阅
    private var subscribeTarget: Disposable?      // 目标订阅
    private var callSubscribe: Disposable?        // 通话订阅
    
    
    /// 初始化
    override init() {
        super.init()
        currentMode.modeType = .idle
        currentMode.channel = 1
        currentMode.dataType = .OPUS
        currentMode.sampleRate = 16000
    }
    
    func initTranslateMgr(_ manager: JL_ManagerM) {
        translateHelper = JLTranslationManager(delegate: self, manager: manager) { [weak self] state, err in
            guard let `self` = self else { return }
            handleIsCalling()
            subjectCurrentMode.accept(currentMode)
        }
    }
    /// 销毁
    func clear() {
        queueList.removeAll()
        JLAudioRecoder.shared.stop()
        translateMgr?.onDestory()
        callTranslateMgr?.onDestory()
        translateHelper?.trDestory()
        translateHelper = nil
        coderOpus?.onDestory()
        coderOpus = nil
        coderJav2?.onDestory()
        coderJav2 = nil
        subscribeTarget?.dispose()
        isCallObs?.invalidate()
        currentMode.modeType = .idle
        currentMode.channel = 1
        currentMode.dataType = .OPUS
        currentMode.sampleRate = 16000
    }
    
    //MARK: - 模式管理
    /// 设置模式
    func stepMode() {
        if self.translateHelper?.trIsWorking() == true {
            
            return
        }
        self.translateHelper?.trStartTranslate(currentMode) { _, _ in
        }
    }
    
    /// 退出模式
    func exitMode() {
        self.translateHelper?.trExitMode()
    }
   
    //MARK: - 数据处理
    /// 输入数据
    func input(data: JLTranslateAudio) {
        if currentMode.modeType == .onlyRecord {
            if currentMode.dataType == .OPUS {
                coderOpus?.decodeDataToPcm(data.data)
            }
            if currentMode.dataType == .JLA_V2 {
                coderJav2?.decodeDataToPcm(data.data)
            }
            return
        }
        if currentMode.modeType == .callTranslate {
            //通话时，己方的语音内容
            if data.sourceType == .typeESCOUp {
                translateMgr?.startTranslateData(data.data)
            }
            //通话时，对方的语音内容
            if data.sourceType == .typeESCODown {
                callTranslateMgr?.startTranslateData(data.data)
            }
        }
        
        if currentMode.modeType == .audioTranslate {
            
        }
        if currentMode.modeType == .recordTranslate {
            translateMgr?.startTranslateData(data.data)
        }
    }
    
    /// 回传数据给设备
    func callBackDataToDevice(data: Data) {
        if translateHelper?.trIsPlayWithA2dp() ?? false
            && translateHelper?.translateMode.modeType != .callTranslate {
            JLAudioPlayer.shared.enqueuePCMData(data)
        } else {
            if let audioData = self.audioData {
                //判断一下是不是callTranslate,若是就要强制指定下发的语言
                if translateHelper?.translateMode.modeType == .callTranslate {
                    audioData.sourceType = .typeESCOUp
                }
                if writeWithoutResponse {
                    translateHelper?.trWriteAudioV2(audioData, translate: data)
                }else{
                    translateHelper?.trWrite(audioData, translate: data)
                }
            }
        }
    }
    
    //MARK: - 翻译配置
    /// 配置翻译
    /// - Parameters:
    ///   - audioType: 加密语音内容类型
    ///   - isUseA2dp: 是否使用a2dp
    ///   - targetType: 语音内容类型
    ///   - resultBlock: 回调
    func configTranslate(_ audioType: JL_SpeakDataType, _ isUseA2dp:Bool, _ targetType: JL_SpeakDataType,_ resultBlock: @escaping (Bool) -> Void) {
        translateMgr = VolcesBusManager(audioType, targetType, .zh, [.en], isUseA2dp,{ [weak self] status in
            guard let self = self else { return }
            JLLogManager.logLevel(.COMPLETE, content: "初始化翻译状态:\(status)")
            if status {
                resultBlock(true)
                self.isInitCfg = true
            } else {
                resultBlock(false)
                self.isInitCfg = false
            }
        })
    }
    
    
    /// 配置通话翻译
    /// - Parameters:
    ///   - audioType: 加密语音内容类型
    ///   - resultBlock: 回调
    func configTranslateCall(_ audioType: JL_SpeakDataType, _ resultBlock: @escaping (Bool) -> Void) {
        let chain = JLTaskChain()
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            translateMgr = VolcesBusManager(audioType, audioType,.zh, [.en], false, { status in
                JLLogManager.logLevel(.COMPLETE, content: "初始化通话翻译状态 translateMgr:\(status)")
                if status {
                    completion(nil, nil)
                } else {
                    completion(nil, NSError(domain: "translateMgr init error", code: -1, userInfo: nil))
                }
            })
        }
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            callTranslateMgr = VolcesBusManager(audioType, audioType,.en, [.zh], false, { status in
                JLLogManager.logLevel(.COMPLETE, content: "初始化通话翻译状态 callTranslateMgr :\(status)")
                if status {
                    completion(nil, nil)
                } else {
                    completion(nil, NSError(domain: "callTranslateMgr init error", code: -1, userInfo: nil))
                }
            })
        }
        chain.run(withInitialInput: nil) { [weak self] _, err in
            guard let self = self else { return }
            if (err != nil) {
                JLLogManager.logLevel(.ERROR, content: "init error:\(String(describing: err))")
                self.isInitCfg = false
            } else {
                self.isInitCfg = true
            }
            resultBlock(err == nil)
        }
    }
    
    /// 通话翻译
    /// 只下发回原本的数据内容
    func callTranslateSendBack(data: JLTranslateAudio) {
        if let queue = queueList.first(where: { $0.type == data.sourceType }) {
            queue.push(data: data)
        } else {
            let queue = TranslateQueue(type: data.sourceType) { [weak self] audio, data in
                guard let self = self else { return }
                translateHelper?.trWrite(audio, translate: data)
            }
            queueList.append(queue)
            queue.push(data: data)
        }
    }
    
    /// 测试翻译
    func testTranslate() {
        callTranslateMgr = VolcesBusManager(.PCM, .PCM,.en, [.zh], false, { [weak self] status in
            guard let self = self else { return }
            if status {
                JLLogManager.logLevel(.DEBUG, content: "testTranslate init success")
                try? JLAudioRecoder.shared.startRecording { pcmData in
                    self.callTranslateMgr?.startTranslateData(pcmData)
                }
            } else {
                JLLogManager.logLevel(.ERROR, content: "testTranslate init error")
            }
        })
    }
    
    /// opus测试
    func sendOpusTest(_ data: Data) {
        if !isInitCfg {
            return
        }
        translateMgr?.startTranslateData(data)
    }
    
    //MARK: - 录音与播放
    /// 手机录音往下发
    /// 这个是录音翻译时，由 APP 端录音，然后下发给设备
    func startRecord(audioType: JL_SpeakDataType) {
        do {
            try JLAudioRecoder.shared.startRecording { [weak self] data in
                guard let self = self else { return }
                if isLocal {
                    if audioType == .OPUS {
                        opusPackager.opusEncode(data)
                    } else if audioType == .JLA_V2 {
                        jlav2Packager.encode(data)
                    }
                } else {
                    self.translateMgr?.startTranslateData(data)
                }
            }
            JLLogManager.logLevel(.DEBUG, content: "开始录音")
        } catch {
            JLLogManager.logLevel(.DEBUG, content: "开始录音失败:\(error.localizedDescription)")
        }
    }
    
    
    /// 手动录音
    /// 用来采麦并且本地播放，通过 A2DP 下发内容给设备
    func recordAndPlay(){
        do {
            try JLAudioRecoder.shared.startRecording { data in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem(block: {
                    JLAudioPlayer.shared.enqueuePCMData(data)
                }))
            }
            JLLogManager.logLevel(.DEBUG, content: "开始录音")
        } catch {
            JLLogManager.logLevel(.DEBUG, content: "开始录音失败:\(error.localizedDescription)")
        }
    }
    
    /// 录音模式
    /// 只有录音，设备端录音，然后给到这边解码转成 PCM
    func pareparRecordOnly(_ audioType: JL_SpeakDataType) {
        if audioType == .OPUS {
            coderOpus = TranslateOpusHelper({ [weak self] pcmData in
                guard let self = self else {return}
                convertedPcmData.accept(pcmData)
//                _R.appendToFile(filePath: self.saveFilePath, data: pcmData)
            }, { opusData in
                
            })
        }
        if audioType == .JLA_V2 {
            coderJav2 = TranslateAV2Helper({ [weak self] pcmData in
                guard let self = self else { return }
                convertedPcmData.accept(pcmData)
//                _R.appendToFile(filePath: self.saveFilePath, data: pcmData)
            }, { jav2Data in
                
            })
        }
    }

    //MARK: - 订阅管理
    func addObsTranslateData(){
        transDataBag?.dispose()
        transDataBag = translateMgr?.targetData.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            targetData.accept(data)
            callBackDataToDevice(data: data)
        })
        subTitleTextBag?.dispose()
        subTitleTextBag = translateMgr?.subtitleText.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            subTitleText.accept(data)
        })
    }
    func addObsCallTranslateData() {
        callDataBag?.dispose()
        callDataBag = callTranslateMgr?.targetData.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            callUploadData.accept(data)
            if let audioData = self.audioData {
                //判断一下是不是callTranslate,若是就要强制指定下发的语言
                if translateHelper?.translateMode.modeType == .callTranslate {
                    audioData.sourceType = .typeESCODown
                }
                if writeWithoutResponse {
                    translateHelper?.trWriteAudioV2(audioData, translate: data)
                }else{
                    translateHelper?.trWrite(audioData, translate: data)
                }
            }
        })
        callTextBag?.dispose()
        callTextBag = callTranslateMgr?.subtitleText.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            callUploadText.accept(data)
        })
    }
    
    private func handleIsCalling() {
        isCallObs = translateHelper?.observe(\.isCalling,options: [.new], changeHandler: { [weak self] mgr, change in
            guard let `self` = self else { return }
            guard let value = change.newValue else { return }
            let tips = value ? "通话中" : "不在通话中"
            let currentThead = Thread.current
            if !currentThead.isMainThread {
                DispatchQueue.main.async {
                    self.contextVC?.view.makeToast(tips, position: .center)
                }
            } else {
                self.contextVC?.view.makeToast(tips, position: .center)
            }
            if translateHelper?.isCalling == true && translateHelper?.translateMode.modeType != .callTranslate {
                self.translateHelper?.trExitMode({ _, err in
                    if let err = err {
                        self.contextVC?.view.makeToast("退出通话失败:\(err)", position: .center)
                    }
                })
            }
        })
    }

}
