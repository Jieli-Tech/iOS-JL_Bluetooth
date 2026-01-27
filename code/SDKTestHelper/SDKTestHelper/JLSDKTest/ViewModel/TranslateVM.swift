//
//  TranslateVM.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/25.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JL_BLEKit
import JLAudioUnitKit
import UIKit

enum TranslateLanType {
    case call
    case sync
    case face
}

/// 翻译模块 ViewModel
@objcMembers class TranslateVM: NSObject {
    typealias LanguageGroup = (TranslateLanguage, [TranslateLanguage])

    // MARK: - 单例

    public static let shared = TranslateVM()
    
    // MARK: - 核心配置属性
    
    var twsConfigModel: JLDeviceConfigTws?
    var audioData: JLTranslateAudio? // 接收到的音频数据块
    var isLocal: Bool = false // 是否使用本地回复测试
    var writeWithoutResponse: Bool = false // 是否启用非交互式下发音频数据
    var saveFilePath: String? // 保存文件路径
    
    // MARK: - 状态属性 (RxSwift)
    
    /// UI 提示消息 (Toast)
    public let toastMessage = PublishRelay<String>()
    
    /// 转换后的 PCM 数据
    var convertedPcmData = BehaviorRelay<Data>(value: Data())
    
    /// 当前模式通知
    var subjectCurrentMode = PublishRelay<JLTranslateSetMode>()
    
    /// 录音 PCM 数据
    var recordPcmData = BehaviorRelay<Data>(value: Data())
    
    /// 发送队列状态 (true: 空闲/完成, false: 发送中)
    var sendQueueStatus = BehaviorRelay<Bool>(value: true)
    
    /// 是否由设备端录音
    var isRecordByDevice = BehaviorRelay<Bool>(value: false)
    
    /// 是否静音
    dynamic var isMute: Bool = false

    // MARK: - 内部配置
    
    var translateLanguage: LanguageGroup = (TranslateLanguage.zh, [TranslateLanguage.en]) // 译文对照
    var translateCallLanguage: LanguageGroup = (TranslateLanguage.en, [TranslateLanguage.zh]) // 通话翻译
    var currentMode: JLTranslateSetMode = .init() // 当前翻译模式
    var callConfigBlock: JLTranslationManagerSetBlock? // 通话翻译初始化完成回调
    var isDeviceSpeak: Bool = false // 是否使用设备语音录音（面对面翻译）

    // MARK: - 核心管理器
    
    var translateHelper: JLTranslationManager? // 翻译助手 (主控)
    var translateMgr: VolcesBusManager? // 翻译管理器 (处理己方内容/主通道)
    var callTranslateMgr: VolcesBusManager? // 通话翻译管理器 (处理对方内容)
    var audioManager: JLDevAudioManager? // 设备录音相关管理器

    // MARK: - 编解码工具
    
    private var coderOpus: TranslateOpusHelper? // Opus编解码器
    private var coderJav2: TranslateAV2Helper? // JLA_V2编解码器
    private lazy var jlav2Packager: JLAV2Codec = {
        return JLAV2Codec(delegate: self)
    }()
    
    private lazy var opusPackager: JLOpusEncoder = {
        return JLOpusEncoder(format: JLOpusEncodeConfig.default(), delegate: self)
    }()

    // MARK: - 私有属性
    private var queueList: [TranslateQueue] = [] // 翻译队列列表
    private let disposeBag = DisposeBag() // RxSwift资源管理
    private var isInitCfg = false // 配置是否初始化完成
    private var isCallObs: NSKeyValueObservation? // 通话状态观察器
    
    // 订阅句柄
    private var transDataBag: Disposable? // 翻译数据订阅
    private var devPcmLeftBag: Disposable? // 左声道订阅
    private var devPcmRightBag: Disposable? // 右声道订阅
    private var callDataBag: Disposable? // 通话数据订阅
    private var subscribeTarget: Disposable? // 目标订阅
    
    // MARK: - 初始化与销毁

    override init() {
        super.init()
        resetCurrentMode()
        setupAudioRecorder()
        setupNotifications()
    }
    
    private func resetCurrentMode() {
        currentMode.modeType = .idle
        currentMode.channel = 1
        currentMode.dataType = .OPUS
        currentMode.sampleRate = 16000
    }
    
    private func setupAudioRecorder() {
        JLAudioRecoder.shared.pcmUpdateHandler = { [weak self] data in
            self?.recordPcmData.accept(data)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onVolcesTranslateError), name: NSNotification.Name(rawValue: "kNotificationVolcesTranslateError"), object: nil)
    }

    /// 初始化翻译管理器
    func initTranslateMgr(_ manager: JL_ManagerM) {
        translateHelper = JLTranslationManager(delegate: self, manager: manager) { [weak self] _, _ in
            guard let self = self else { return }
            self.handleIsCalling()
            self.subjectCurrentMode.accept(self.currentMode)
        }
    }

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
        resetCurrentMode()
    }
    
    // MARK: - 模式控制 API

    
    /// 设置翻译模式
    public func setMode(type: TranslateLanType, _ devType: JLTranslateRecordType = .byPhone, _ block: JLTranslationManagerSetBlock? = nil) {
        if translateHelper?.trIsWorking() == true {
            return
        }
        mute(isMute: false)
        
        switch type {
        case .call:
            setupModeForCall(block)
        case .sync:
            setupModeForSync(block)
        case .face:
            setupModeForFace(devType, block)
        }
        
        JLLogManager.logLevel(.DEBUG, content: "Translate Log设置翻译模式: \(currentMode.modeType)")
    }

    /// 退出模式
    public func exitMode(_ block: JLTranslationManagerSetBlock? = nil) {
        translateHelper?.trExitMode(block)
        JLLogManager.logLevel(.DEBUG, content: "Translate Log退出翻译模式")
        disposeDataBags()
    }

    /// 是否静音 (不发数据给设备)
    func mute(isMute: Bool) {
        self.isMute = isMute
    }
    
    // MARK: - 数据处理逻辑 (被 Delegate 调用)
    
    /// 处理接收到的音频数据
    /// - Parameter data: 音频数据对象
    func handleReceivedAudioData(_ data: JLTranslateAudio) {
        JLLogManager.logLevel(.COMPLETE, content: "Translate Log收到翻译音频数据: \(currentMode.modeType)")
        audioData = data
        
        // 如果是本地测试模式，直接处理回传或忽略
        if isLocal {
            handleLocalAudioData(data)
            return
        }
        
        // 根据模式分发处理
        switch currentMode.modeType {
        case .recordTranslate:
             if currentMode.dataType == .OPUS {
                 inputToTranslationManager(data)
             }
        case .onlyRecord:
            // TODO: 存储录音数据
            inputToTranslationManager(data)
        case .callTranslate, .callTranslateStereo, .faceToFaceTranslate, .audioTranslate:
            inputToTranslationManager(data)
        default:
            break
        }
    }
    
    /// 处理模式变更
    func handleModeChange(_ mode: JLTranslateSetMode) {
        currentMode = mode
        subjectCurrentMode.accept(mode)
        if isLocal { return }
        JLLogManager.logLevel(.DEBUG, content: "Translate Log Mode Changed to: \(mode.modeType)")
        
        switch mode.modeType {
        case .recordTranslate:
            configRecordTranslate()
        case .callTranslate,.callTranslateStereo:
            configCallTranslate()
        case .audioTranslate:
            configAudioTranslate()
        case .onlyRecord:
            pareparRecordOnly(currentMode.dataType)
        case .faceToFaceTranslate:
            configFaceToFaceTranslate()
        case .idle:
            cleanupForIdle()
        default:
            break
        }
    }
    
    // MARK: - 内部逻辑实现
    
    /// 将数据输入到对应的翻译管理器进行处理
    private func inputToTranslationManager(_ data: JLTranslateAudio) {
        // 解码模式 (OnlyRecord)
        if currentMode.modeType == .onlyRecord {
            decodeAudioData(data)
            return
        }
        
        // 通话翻译模式
        if currentMode.modeType == .callTranslate {
            if data.sourceType == .typeESCOUp {
                translateMgr?.startTranslateData(data.data)
            } else if data.sourceType == .typeESCODown {
                callTranslateMgr?.startTranslateData(data.data)
            }
            return
        }
        // 通话翻译立体声
        if currentMode.modeType == .callTranslateStereo {
            if data.sourceType == .typeESCOMax {
                translateMgr?.startTranslateData(data.data) // 立体声
            }
            return
        }
        
        // 其他模式通用处理
        translateMgr?.startTranslateData(data.data)
    }
    
    private func decodeAudioData(_ data: JLTranslateAudio) {
        if currentMode.dataType == .OPUS {
            coderOpus?.decodeDataToPcm(data.data)
        } else if currentMode.dataType == .JLA_V2 {
            coderJav2?.decodeDataToPcm(data.data)
        }
    }
    
    private func handleLocalAudioData(_ data: JLTranslateAudio) {
        if currentMode.modeType == .callTranslate {
             callTranslateSendBack(data: data)
             return
        }
        
        if currentMode.modeType == .recordTranslate && currentMode.dataType == .OPUS {
            // 延迟回写
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                self.sendQueueStatus.accept(false)
                let method = self.writeWithoutResponse ? self.translateHelper?.trWriteAudioV2 : self.translateHelper?.trWrite
                method?(data, data.data)
            }
        }
    }

    /// 回传数据给设备
    func callBackDataToDevice(data: Data) {
        if isMute || data.isEmpty {
            JLLogManager.logLevel(.DEBUG, content: "Translate LogMuted or Empty Data")
            return
        }
        
        let isA2DP = translateHelper?.trIsPlayWithA2dp() ?? false
        let isCall = translateHelper?.translateMode.modeType == .callTranslate
        
        if isA2DP && !isCall {
            // A2DP 播放模式 (目前注释掉)
            // JLAudioPlayer.shared.enqueuePCMData(data)
        } else {
            guard let audioData = audioData else { return }
            if isCall {
                audioData.sourceType = .typeESCOUp
            }
            sendQueueStatus.accept(false)
            if writeWithoutResponse {
                translateHelper?.trWriteAudioV2(audioData, translate: data)
            } else {
                translateHelper?.trWrite(audioData, translate: data)
            }
        }
    }
    
    // MARK: - 配置逻辑 (Setup Methods)
    
    private func setupModeForCall(_ block: JLTranslationManagerSetBlock?) {
        let isSupportOpusStereo = twsConfigModel?.isSupportOpusStereo ?? false
        currentMode.modeType = isSupportOpusStereo ? .callTranslateStereo : .callTranslate
        currentMode.channel = isSupportOpusStereo ? 2 : 1
        currentMode.dataType = isSupportOpusStereo ? .OPUS : .JLA_V2
        currentMode.sampleRate = 16000
        callConfigBlock = block
        translateHelper?.trStartTranslate(currentMode)
    }
    
    private func setupModeForSync(_ block: JLTranslationManagerSetBlock?) {
        currentMode.modeType = .recordTranslate
        currentMode.channel = 1
        currentMode.dataType = .OPUS
        currentMode.sampleRate = 16000
        translateHelper?.recordtype = .byPhone
        translateHelper?.trStartTranslate(currentMode, block: block)
    }
    
    private func setupModeForFace(_ devType: JLTranslateRecordType, _ block: JLTranslationManagerSetBlock?) {
        currentMode.modeType = .faceToFaceTranslate
        currentMode.channel = 1
        currentMode.dataType = .OPUS
        currentMode.sampleRate = 16000
        translateHelper?.recordtype = devType
        translateHelper?.trStartTranslate(currentMode, block: block)
    }

    // MARK: - 模式变更后的具体配置 (Config Methods)
    
    private func configRecordTranslate() {
        if translateHelper?.recordtype == .byDevice {
            let isUseA2dp = translateHelper?.trIsPlayWithA2dp() ?? false
            configTranslate(currentMode.dataType, isUseA2dp, currentMode.dataType) { [weak self] _ in
                self?.addObsTranslateData()
            }
            JLLogManager.logLevel(.DEBUG, content: "Translate Log byDevice 进入同步翻译. configRecordTranslate")
        } else if translateHelper?.recordtype == .byPhone {
            audioData = JLTranslateAudio()
            audioData?.audioType = currentMode.dataType
            audioData?.sourceType = .typePhoneMic
            startRecord(audioType: currentMode.dataType)
            
            let isUseA2dp = translateHelper?.trIsPlayWithA2dp() ?? false
            configTranslate(.PCM, isUseA2dp, currentMode.dataType) { [weak self] _ in
                self?.addObsTranslateData()
            }
            JLLogManager.logLevel(.DEBUG, content: "Translate Log byPhone 进入同步翻译. configRecordTranslate")
        }
    }
    
    private func configCallTranslate() {
        configTranslateCall(currentMode.dataType) { [weak self] _ in
            guard let self = self else { return }
            self.addObsTranslateData()
            self.addObsCallTranslateData()
            self.callConfigBlock?(.success, nil)
        }
    }
    
    private func configAudioTranslate() {
        recordAndPlay()
        configTranslate(currentMode.dataType, true, currentMode.dataType) { _ in }
    }
    
    private func configFaceToFaceTranslate() {
        guard let type = translateHelper?.recordtype else { return }
        if type == .byDevice {
            audioData = JLTranslateAudio()
            audioData?.audioType = currentMode.dataType
            audioData?.sourceType = .typeDeviceMic
            
            let isUseA2dp = translateHelper?.trIsPlayWithA2dp() ?? false
            configTranslate(currentMode.dataType, isUseA2dp, currentMode.dataType) { [weak self] _ in
                self?.addObsTranslateData()
            }
        }
    }
    
    private func cleanupForIdle() {
        translateMgr?.onDestory()
        callTranslateMgr?.onDestory()
        JLAudioPlayer.shared.stop()
        JLAudioRecoder.shared.stop()
    }
    
    // MARK: - 翻译服务配置 (Service Config)

    /// 配置翻译服务
    func configTranslate(_ audioType: JL_SpeakDataType, _ isUseA2dp: Bool, _ targetType: JL_SpeakDataType, _ resultBlock: @escaping (Bool) -> Void) {
        initTranslateMgr(audioType, isUseA2dp, targetType, translateLanguage, resultBlock)
    }
    
    private func initTranslateMgr(_ audioType: JL_SpeakDataType, _ isUseA2dp: Bool, _ targetType: JL_SpeakDataType, _ languages: LanguageGroup, _ resultBlock: @escaping (Bool) -> Void) {
        translateMgr = VolcesBusManager(audioType, targetType, languages.0, languages.1, isUseA2dp) { [weak self] status in
            guard let self = self else { return }
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 初始化翻译状态:\(status) tranMgr:\(String(describing: self.translateMgr))")
            self.isInitCfg = status
            resultBlock(status)
        }
        translateMgr?.onErrorCallBack { [weak self] _ in
            self?.exitMode()
        }
    }

    /// 配置通话翻译服务
    func configTranslateCall(_ audioType: JL_SpeakDataType, _ resultBlock: @escaping (Bool) -> Void) {
        let chain = JLTaskChain()
        let isSupportOpusStereo = twsConfigModel?.isSupportOpusStereo ?? false
        
        // 任务1: 初始化 translateMgr (己方)
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            self.translateMgr = VolcesBusManager(audioType, audioType, self.translateLanguage.0, self.translateLanguage.1, false, isSupportOpusStereo) { status in
                JLLogManager.logLevel(.DEBUG, content: "Translate Log 初始化通话翻译状态 translateMgr:\(status)")
                status ? completion(nil, nil) : completion(nil, NSError(domain: "translateMgr init error", code: -1, userInfo: nil))
            }
        }
        
        if currentMode.modeType == .callTranslate || currentMode.modeType == .callTranslateStereo {
            chain.addTask { [weak self] _, completion in
                guard let self = self else { return }
                self.callTranslateMgr = VolcesBusManager(audioType, audioType, self.translateCallLanguage.0, self.translateCallLanguage.1, false) { status in
                    JLLogManager.logLevel(.DEBUG, content: "Translate Log初始化通话翻译状态 callTranslateMgr:\(status)")
                    status ? completion(nil, nil) : completion(nil, NSError(domain: "callTranslateMgr init error", code: -1, userInfo: nil))
                }
                self.callTranslateMgr?.onErrorCallBack { [weak self] _ in
                    self?.exitMode()
                }
            }
        }
        
        chain.run(withInitialInput: nil) { [weak self] _, err in
            guard let self = self else { return }
            if let err = err {
                JLLogManager.logLevel(.ERROR, content: "Translate Loginit error:\(String(describing: err))")
                self.isInitCfg = false
            } else {
                self.isInitCfg = true
            }
            resultBlock(err == nil)
        }
    }
    
    // MARK: - 录音与播放
    
    func startRecord(audioType: JL_SpeakDataType) {
        do {
            try JLAudioRecoder.shared.startRecording { [weak self] data in
                guard let self = self else { return }
                if self.isLocal {
                    if audioType == .OPUS {
                        self.opusPackager.opusEncode(data)
                    } else if audioType == .JLA_V2 {
                        self.jlav2Packager.encode(data)
                    }
                } else {
                    self.translateMgr?.startTranslateData(data)
                }
            }
            JLLogManager.logLevel(.DEBUG, content: "Translate Log开始录音")
        } catch {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log开始录音失败:\(error.localizedDescription)")
        }
    }
    
    func recordAndPlay() {
        do {
            try JLAudioRecoder.shared.startRecording { data in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    JLAudioPlayer.shared.enqueuePCMData(data)
                }
            }
            JLLogManager.logLevel(.DEBUG, content: "Translate Log开始录音")
        } catch {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log开始录音失败:\(error.localizedDescription)")
        }
    }
    
    func pareparRecordOnly(_ audioType: JL_SpeakDataType) {
        if audioType == .OPUS {
            coderOpus = TranslateOpusHelper({ [weak self] data in
                 self?.convertedPcmData.accept(data)
            }, { _ in })
        } else if audioType == .JLA_V2 {
            coderJav2 = TranslateAV2Helper({ [weak self] data in
                self?.convertedPcmData.accept(data)
            }, { _ in })
        }
    }
    
    // MARK: - 面对面翻译控制
    
    func startRecordFaceToFace(_ isFinishBlock: @escaping (Bool) -> Void) {
        if isDeviceSpeak {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log设备正在说话")
            isFinishBlock(false)
            return
        }
        
        setupFaceToFaceAudioData()
        stopRecordFaceToFace()
        
        if isLocal {
            isFinishBlock(true)
            return
        }
        
        let isUseA2dp = translateHelper?.trIsPlayWithA2dp() ?? false
        configTranslate(.PCM, isUseA2dp, currentMode.dataType) { [weak self] success in
            guard let self = self, success else {
                isFinishBlock(false)
                return
            }
            self.addObsTranslateData()
            self.translateMgr?.isSendSoon = false
            self.startAudioRecording(completion: isFinishBlock)
        }
    }
    
    private func setupFaceToFaceAudioData() {
        audioData = JLTranslateAudio()
        audioData?.audioType = currentMode.dataType
        audioData?.sourceType = .typePhoneMic
    }
    
    private func startAudioRecording(completion: @escaping (Bool) -> Void) {
        do {
            try JLAudioRecoder.shared.startRecording { [weak self] data in
                self?.translateMgr?.startTranslatePcmData(data)
            }
            JLLogManager.logLevel(.DEBUG, content: "Translate Log面对面开始录音")
            completion(true)
        } catch {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log面对面开始录音失败:\(error.localizedDescription)")
            completion(false)
        }
    }

    func stopRecordFaceToFace() {
        JLAudioRecoder.shared.stop()
        translateMgr?.endTranslate()
        translateMgr?.onDestory()
    }

    func startRecordByDevFaceToFace(_ isFinishBlock: @escaping (Bool) -> Void) {
        if isDeviceSpeak {
            isFinishBlock(false)
            return
        }
        
        let isUseA2dp = translateHelper?.trIsPlayWithA2dp() ?? false
        let newGroup = (translateLanguage.1[0], [translateLanguage.0])
        
        initTranslateMgr(.OPUS, isUseA2dp, currentMode.dataType, newGroup) { [weak self] success in
            guard let self = self, success else {
                isFinishBlock(false)
                return
            }
            self.addObsTranslateData()
            self.translateMgr?.isSendSoon = false
            self.triggerDeviceRecording(completion: isFinishBlock)
        }
    }
    
    private func triggerDeviceRecording(completion: @escaping (Bool) -> Void) {
        guard let manager = BleManager.shared.currentCmdMgr else {
            completion(false)
            return
        }
        
        audioManager = JLDevAudioManager.share(self, withManager: manager)
        let params = JLRecordParams()
        params.mDataType = .OPUS
        params.mVadWay = .byDevice
        params.mSampleRate = .rate16K
        
        audioManager?.cmdStartRecord(manager, params: params) { [weak self] result, _, _ in
            if result == .success {
                self?.isDeviceSpeak = true
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func stopRecordByDevFaceToFace() {
        guard isDeviceSpeak else { return }
        isDeviceSpeak = false
        
        if let manager = BleManager.shared.currentCmdMgr {
            audioManager = JLDevAudioManager.share(self, withManager: manager)
            audioManager?.cmdStopRecord(manager, reason: .normal)
        }
        translateMgr?.endTranslate()
        translateMgr?.onDestory()
    }

    // MARK: - 订阅管理
    
    func addObsTranslateData() {
        // 订阅主通道数据
        disposeDataBags()
        transDataBag = translateMgr?.targetData.subscribe(onNext: { [weak self] data in
            self?.callBackDataToDevice(data: data)
        })
        devPcmLeftBag = translateMgr?.devPcmLeftData.subscribe(onNext: { [weak self] data in
            self?.translateMgr?.startTranslatePcmData(data)
        })
        devPcmRightBag = translateMgr?.devPcmRightData.subscribe(onNext: { [weak self] data in
            self?.callTranslateMgr?.startTranslatePcmData(data)
        })
    }
    
    func addObsCallTranslateData() {
        callDataBag?.dispose()
        callDataBag = callTranslateMgr?.targetData.subscribe(onNext: { [weak self] data in
            self?.handleCallData(data)
        })
    }
    
    private func disposeDataBags() {
        transDataBag?.dispose()
        callDataBag?.dispose()
        devPcmLeftBag?.dispose()
        devPcmRightBag?.dispose()
    }
    
    private func handleCallData(_ data: Data) {
        guard let audioData = audioData else { return }
        if translateHelper?.translateMode.modeType != .callTranslate { return } // 非通话翻译模式
        audioData.sourceType = .typeESCODown
        sendQueueStatus.accept(false)
        if writeWithoutResponse {
            translateHelper?.trWriteAudioV2(audioData, translate: data)
        } else {
            translateHelper?.trWrite(audioData, translate: data)
        }
    }

    // MARK: - 辅助方法
    
    /// 计算PCM的时长
    func calculateDuration(_ dataBytes: Int) -> Double {
        return TranslateTools.calculateDuration(
            dataBytes: dataBytes,
            sampleRate: 16000,
            bitDepth: 16,
            channels: 1
        )
    }
    
    /// 通话翻译回传 (Local Test)
    func callTranslateSendBack(data: JLTranslateAudio) {
        if let queue = queueList.first(where: { $0.type == data.sourceType }) {
            queue.push(data: data)
        } else {
            let queue = TranslateQueue(type: data.sourceType) { [weak self] audio, data in
                guard let self = self else { return }
                self.sendQueueStatus.accept(false)
                self.translateHelper?.trWrite(audio, translate: data)
            }
            queueList.append(queue)
            queue.push(data: data)
        }
    }
    
    private func handleIsCalling() {
        isCallObs = translateHelper?.observe(\.isCalling, options: [.new], changeHandler: { [weak self] _, change in
            guard let self = self, let value = change.newValue else { return }
            let tips = value ? "通话中" : "不在通话中"
            
            if Thread.isMainThread {
                self.toastMessage.accept(tips)
            } else {
                DispatchQueue.main.async {
                    self.toastMessage.accept(tips)
                }
            }
            
            if self.translateHelper?.isCalling == true, self.translateHelper?.translateMode.modeType != .callTranslate {
                self.translateHelper?.trExitMode { _, err in
                    if let err = err {
                        self.toastMessage.accept("退出通话失败:\(err)")
                    }
                }
            }
        })
    }
    
    @objc private func onVolcesTranslateError() {
        toastMessage.accept("network_exception_tips")
    }
    
    // MARK: - Device Audio Manager Delegate Logic
    
    func handleDeviceRecordStart() {
        isRecordByDevice.accept(true)
        if translateMgr == nil {
            let newGroup = (translateLanguage.1[0], [translateLanguage.0])
            initTranslateMgr(currentMode.dataType, false, currentMode.dataType, newGroup) { [weak self] status in
                if status {
                    self?.addObsTranslateData()
                    self?.translateMgr?.isSendSoon = false
                }
            }
        }
    }
    
    func handleDeviceRecordStop() {
        isRecordByDevice.accept(false)
    }
    
    func handleDeviceRecordStatus(_ status: JL_SpeakType) {
        switch status {
        case .do:
            isRecordByDevice.accept(true)
        case .done:
            isRecordByDevice.accept(false)
            translateMgr?.endTranslate()
            translateMgr?.onDestory()
        case .doing:
            break
        case .doneFail:
            isRecordByDevice.accept(false)
        @unknown default:
            isRecordByDevice.accept(false)
        }
    }
}
