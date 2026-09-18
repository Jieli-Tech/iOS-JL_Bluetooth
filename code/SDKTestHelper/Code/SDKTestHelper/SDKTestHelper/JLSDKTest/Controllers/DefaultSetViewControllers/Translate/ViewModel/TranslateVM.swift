//
//  TranslateVM.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/25.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JL_BLEKit
import JLAudioUnitKit
import AVFoundation
import UIKit

enum TranslateLanType {
    case call
    case sync
    case face
    case callRecord
}

/// 面对面翻译（左耳+右耳） UI 状态
enum SimultaneousUIState: Equatable {
    case idle
    case entering
    case working
    case exiting
    case error(String)
}

/// 通话翻译 UI 状态
enum CallTranslateUIState: Equatable {
    case idle
    case entering
    case working
    case exiting
    case error(String)
}

/// 录音翻译 UI 状态
enum RecordTranslateUIState: Equatable {
    case idle
    case entering
    case working
    case exiting
    case error(String)
}

/// 面对面翻译（手机+耳机）页面整体状态
enum FaceToFaceUIState: Equatable {
    case idle
    case entering
    case working
    case error(String)
}

/// 面对面翻译（手机+耳机）单侧录音状态（手机端 / 耳机端各自独立）
enum FaceRecordSideState: Equatable {
    case idle
    case entering
    case recording
    case error(String)
}

/// 面对面翻译（手机+耳机）录音来源标识
enum FaceToFaceRecordSource: Equatable {
    case none
    case user
    case device
}

/// 面对面翻译（左耳+右耳）语言配置 — 按物理左右耳预设译向
///
/// 用户在外层 UI 按左耳/右耳指定源语言与目标语言；
/// 进入面对面翻译（左耳+右耳）模式后，根据设备实际的主/从角色归属，
/// 自动将左耳/右耳预设映射到对应的翻译管道，避免译向错乱。
struct SimultaneousLanguageConfig {
    var leftOrigin: TranslateLanguage      // 左耳源语言（用户预设）
    var leftTarget: TranslateLanguage      // 左耳目标语言（用户预设）
    var rightOrigin: TranslateLanguage     // 右耳源语言（用户预设）
    var rightTarget: TranslateLanguage     // 右耳目标语言（用户预设）
}

/// 通话立体声翻译回写策略
enum CallStereoDeliverMode: Int {
    case none = 0       // 都不发
    case upOnly = 1     // 只发上游(ESCOUp)
    case downOnly = 2   // 只发下游(ESCODown)
    case both = 3       // 都发
}

/// 翻译模块 ViewModel
@objcMembers class TranslateVM: NSObject {
    typealias LanguageGroup = (TranslateLanguage, [TranslateLanguage])

    // MARK: - 单例

    public static let shared = TranslateVM()

    // MARK: - 核心配置属性

    var twsConfigModel: JLDeviceConfigTws?
    var audioData: JLTranslateAudio?
    var writeWithoutResponse: Bool = false
    var saveFilePath: String?

    // MARK: - 状态属性 (RxSwift)

    public let toastMessage = PublishRelay<String>()
    var convertedPcmData = BehaviorRelay<Data>(value: Data())
    var subjectCurrentMode = PublishRelay<JLTranslateSetMode>()
    var recordPcmData = BehaviorRelay<Data>(value: Data())
    var sendQueueStatus = BehaviorRelay<Bool>(value: true)
    var isRecordByDevice = BehaviorRelay<Bool>(value: false)
    dynamic var isMute: Bool = false
    var isDeliverTranslation: Bool = false
    /// 通话立体声翻译回写策略
    var callStereoDeliverMode: CallStereoDeliverMode = .downOnly
    var simultaneousState = BehaviorRelay<SimultaneousUIState>(value: .idle)
    var callTranslateState = BehaviorRelay<CallTranslateUIState>(value: .idle)
    var recordTranslateState = BehaviorRelay<RecordTranslateUIState>(value: .idle)
    var faceToFaceState = BehaviorRelay<FaceToFaceUIState>(value: .idle)
    var phoneRecordState = BehaviorRelay<FaceRecordSideState>(value: .idle)
    var deviceRecordState = BehaviorRelay<FaceRecordSideState>(value: .idle)
    var phoneRecordSource = BehaviorRelay<FaceToFaceRecordSource>(value: .none)
    var deviceRecordSource = BehaviorRelay<FaceToFaceRecordSource>(value: .none)

    // MARK: - 录音文件管理

    var recordFilesDirectory: URL {
        let dir = URL(fileURLWithPath: _R.path.document).appendingPathComponent("CallRecords")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        return dir
    }

    var recordFiles = BehaviorRelay<[CallRecordFile]>(value: [])
    var audioPlayer: AVAudioPlayer?
    var playingFileURL: URL?

    var upPcmBuffer = Data()
    var downPcmBuffer = Data()
    var upWavEncoder: JLPcmToWav?
    var downWavEncoder: JLPcmToWav?
    var onlyRecordWavEncoder: JLPcmToWav?
    var stereoUpWavEncoder: JLPcmToWav?
    var stereoDownWavEncoder: JLPcmToWav?
    var isOnlyRecordSaving: Bool = true

    // MARK: - 内部配置

    var translateLanguage: LanguageGroup = (TranslateLanguage.zh, [TranslateLanguage.en])
    var translateCallLanguage: LanguageGroup = (TranslateLanguage.en, [TranslateLanguage.zh])
    var currentMode: JLTranslateSetMode = .init()
    var callConfigBlock: JLTranslationManagerSetBlock?
    var isDeviceSpeak: Bool = false
    var simultaneousConfig = SimultaneousLanguageConfig(
        leftOrigin: .zh,
        leftTarget: .en,
        rightOrigin: .en,
        rightTarget: .zh
    )

    // MARK: - 核心管理器

    var translateHelper: JLTranslationManager?
    var translateMgr: VolcesBusManager?
    var callTranslateMgr: VolcesBusManager?
    var localCallSide: CallTranslateSideModel?
    var remoteCallSide: CallTranslateSideModel?
    var recordSide: CallTranslateSideModel?
    var facePhoneMgr: VolcesBusManager?
    var faceDeviceMgr: VolcesBusManager?
    var facePhoneSide: CallTranslateSideModel?
    var faceDeviceSide: CallTranslateSideModel?
    var facePhoneDataBag: Disposable?
    var faceDevicePcmBag: Disposable?
    var masterProcessor: SimultaneousTranslationProcessor?
    var slaveProcessor: SimultaneousTranslationProcessor?
    var audioManager: JLDevAudioManager?

    // MARK: - 编解码工具

    var coderOpus: TranslateOpusHelper?
    var coderJav2: TranslateAV2Helper?
    // MARK: - 私有属性

    var queueList: [TranslateQueue] = []
    private let disposeBag = DisposeBag()
    var isInitCfg = false
    private var isCallObs: NSKeyValueObservation?

    private var transDataBag: Disposable?
    private var devPcmLeftBag: Disposable?
    private var devPcmRightBag: Disposable?
    private var callDataBag: Disposable?
    private var subscribeTarget: Disposable?
    private var masterTargetBag: Disposable?
    private var slaveTargetBag: Disposable?

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
        disposeCallTranslateSides()
        recordSide?.dispose()
        recordSide = nil
        facePhoneMgr?.onDestory()
        facePhoneMgr = nil
        faceDeviceMgr?.onDestory()
        faceDeviceMgr = nil
        facePhoneSide?.dispose()
        facePhoneSide = nil
        faceDeviceSide?.dispose()
        faceDeviceSide = nil
        facePhoneDataBag?.dispose()
        facePhoneDataBag = nil
        faceDevicePcmBag?.dispose()
        faceDevicePcmBag = nil
        masterProcessor?.destroy()
        masterProcessor = nil
        slaveProcessor?.destroy()
        slaveProcessor = nil
        translateHelper?.trDestory()
        translateHelper = nil
        coderOpus?.onDestory()
        coderOpus = nil
        coderJav2?.onDestory()
        coderJav2 = nil
        cleanupSimultaneousDecoders()
        masterTargetBag?.dispose()
        masterTargetBag = nil
        slaveTargetBag?.dispose()
        slaveTargetBag = nil
        subscribeTarget?.dispose()
        isCallObs?.invalidate()
        resetCurrentMode()
        simultaneousState.accept(.idle)
        callTranslateState.accept(.idle)
        recordTranslateState.accept(.idle)
        faceToFaceState.accept(.idle)
        phoneRecordState.accept(.idle)
        deviceRecordState.accept(.idle)
        phoneRecordSource.accept(.none)
        deviceRecordSource.accept(.none)
        JLLogManager.logLevel(.DEBUG, content: "Translate view model clear all!!")
    }

    // MARK: - 模式控制 API

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
        case .callRecord:
            setupModeForCallRecord(block)
        }

        JLLogManager.logLevel(.DEBUG, content: "Translate Log设置翻译模式: \(currentMode.modeType)")
    }

    public func exitMode(_ block: JLTranslationManagerSetBlock? = nil) {
        if simultaneousState.value == .working || simultaneousState.value == .entering {
            exitSimultaneousMode { [weak self] in
                self?.translateHelper?.trExitMode(block)
            }
            return
        }
        if callTranslateState.value == .working || callTranslateState.value == .entering {
            exitCallTranslateMode()
            return
        }
        translateHelper?.trExitMode(block)
        JLLogManager.logLevel(.DEBUG, content: "Translate Log退出翻译模式")
        disposeDataBags()
    }

    // MARK: - 面对面翻译（左耳+右耳）模式控制

    func enterSimultaneousMode(_ completion: @escaping (Bool, Error?) -> Void) {
        guard let helper = translateHelper else {
            completion(false, NSError(domain: "翻译管理器未初始化", code: -1))
            return
        }
        guard helper.trIsSupportSimultaneousMode() else {
            completion(false, NSError(domain: "设备不支持面对面翻译（左耳+右耳）模式", code: -1))
            return
        }
        simultaneousState.accept(.entering)

        // 先启动 WAV 录音文件（路径由 VM 管理）
        startSimultaneousWavRecord()
        // 再初始化流水线处理器
        initSimultaneousProcessors()

        helper.simultaneousDelegate = self
        helper.trEnterSimultaneousMode { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.simultaneousState.accept(.working)
                JLLogManager.logLevel(.DEBUG, content: "Translate Log 进入面对面翻译（左耳+右耳）模式成功")
            } else {
                self.simultaneousState.accept(.error(error?.localizedDescription ?? "未知错误"))
                self.destroySimultaneousProcessors()
                helper.simultaneousDelegate = nil
                JLLogManager.logLevel(.ERROR, content: "Translate Log 进入面对面翻译（左耳+右耳）模式失败: \(error?.localizedDescription ?? "未知错误")")
            }
            completion(success, error)
        }
    }

    func exitSimultaneousMode(_ completion: @escaping () -> Void) {
        simultaneousState.accept(.exiting)
        translateHelper?.simultaneousDelegate = nil
        translateHelper?.trExitSimultaneousMode { [weak self] in
            self?.stopSimultaneousWavRecord()
            self?.destroySimultaneousProcessors()
            self?.simultaneousState.accept(.idle)
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 退出面对面翻译（左耳+右耳）模式完成")
            completion()
        }
    }

    // MARK: - 通话翻译模式控制

    func enterCallTranslateMode() {
        guard translateHelper?.trIsWorking() != true else { return }
        // 通话翻译模式：强制下发译文，只走服务器识别并下发
        isDeliverTranslation = true
        callTranslateState.accept(.entering)
        translateHelper?.trStartTranslate(currentMode)
    }

    func exitCallTranslateMode(_ completion: @escaping () -> Void = {}) {
        callTranslateState.accept(.exiting)
        disposeCallTranslateSides()
        translateHelper?.trExitMode { [weak self] _, _ in
            self?.callTranslateState.accept(.idle)
            completion()
        }
    }

    /// 根据两个 VolcesBusManager 创建己方/对方 side model
    private func buildCallTranslateSides() {
        localCallSide?.dispose()
        remoteCallSide?.dispose()
        if let local = translateMgr {
            localCallSide = CallTranslateSideModel(
                roleText: R.localStr.localSide(),
                sourceLanguage: translateLanguage.0,
                targetLanguage: translateLanguage.1.first ?? .en,
                manager: local
            )
        }
        if let remote = callTranslateMgr {
            remoteCallSide = CallTranslateSideModel(
                roleText: R.localStr.remoteSide(),
                sourceLanguage: translateCallLanguage.0,
                targetLanguage: translateCallLanguage.1.first ?? .zh,
                manager: remote
            )
        }
    }

    private func disposeCallTranslateSides() {
        localCallSide?.dispose()
        localCallSide = nil
        remoteCallSide?.dispose()
        remoteCallSide = nil
    }

    // MARK: - 录音翻译模式控制

    func enterRecordTranslateMode() {
        guard translateHelper?.trIsWorking() != true else { return }
        recordTranslateState.accept(.entering)
        translateHelper?.trStartTranslate(currentMode)
    }

    func exitRecordTranslateMode(_ completion: @escaping () -> Void = {}) {
        recordTranslateState.accept(.exiting)
        recordSide?.dispose()
        recordSide = nil
        translateHelper?.trExitMode { [weak self] _, _ in
            self?.recordTranslateState.accept(.idle)
            completion()
        }
    }

    private func buildRecordTranslateSide() {
        recordSide?.dispose()
        if let mgr = translateMgr {
            recordSide = CallTranslateSideModel(
                roleText: R.localStr.recordTranslate(),
                sourceLanguage: translateLanguage.0,
                targetLanguage: translateLanguage.1.first ?? .en,
                manager: mgr
            )
        }
    }

    private func handleRecordTranslateConfigured(_ success: Bool) {
        if success {
            buildRecordTranslateSide()
            addObsTranslateData()
            recordTranslateState.accept(.working)
        } else {
            recordTranslateState.accept(.error("录音翻译初始化失败"))
        }
    }

    // MARK: - 面对面翻译（手机+耳机）模式控制

    func enterFaceToFaceMode() {
        guard translateHelper?.trIsWorking() != true else { return }
        faceToFaceState.accept(.entering)
        phoneRecordState.accept(.idle)
        deviceRecordState.accept(.idle)
        phoneRecordSource.accept(.none)
        deviceRecordSource.accept(.none)
        setupFaceToFaceObservers()
        translateHelper?.trStartTranslate(currentMode)
    }

    func exitFaceToFaceMode(_ completion: @escaping () -> Void = {}) {
        stopPhoneFaceToFace()
        stopDeviceFaceToFace()
        disposeFaceToFaceSides()
        translateHelper?.trExitMode { [weak self] _, _ in
            self?.faceToFaceState.accept(.idle)
            completion()
        }
    }

    /// 预注册设备音频管理，建立设备端主动启停的监听（进入模式即生效）
    func setupFaceToFaceObservers() {
        guard let manager = BleManager.shared.currentCmdMgr else { return }
        audioManager = JLDevAudioManager.share(self, withManager: manager)
    }

    func disposeFaceToFaceSides() {
        facePhoneSide?.dispose()
        facePhoneSide = nil
        faceDeviceSide?.dispose()
        faceDeviceSide = nil
    }

    /// 根据设备实际左右耳归属，将左/右耳预设映射到主/从翻译管道
    ///
    /// - Parameter forMaster: true 取主机译向，false 取从机译向
    /// - Returns: (源语言, 目标语言) 元组
    ///
    /// 规则：主机是左耳 → 主机用左耳预设、从机用右耳预设；
    ///       主机是右耳 → 主机用右耳预设、从机用左耳预设。
    /// 当设备位置未上报（unknown）时，保守退化为：主机→左耳预设，从机→右耳预设。
    func simultaneousLanguagePair(forMaster: Bool) -> (source: TranslateLanguage, target: TranslateLanguage) {
        let masterLoc = translateHelper?.masterDevice?.location ?? .unknown
        let masterIsLeft = (masterLoc == .left)
        if forMaster {
            return masterIsLeft
                ? (simultaneousConfig.leftOrigin, simultaneousConfig.leftTarget)
                : (simultaneousConfig.rightOrigin, simultaneousConfig.rightTarget)
        } else {
            return masterIsLeft
                ? (simultaneousConfig.rightOrigin, simultaneousConfig.rightTarget)
                : (simultaneousConfig.leftOrigin, simultaneousConfig.leftTarget)
        }
    }

    private func initSimultaneousProcessors() {
        let isUseA2dp = translateHelper?.trIsPlayWithA2dp() ?? false
        let dateStr = Date().getDateStr
        let dir = recordFilesDirectory

        let masterWavPath = dir.appendingPathComponent("Simultaneous_\(dateStr)_Master.wav").path
        let slaveWavPath = dir.appendingPathComponent("Simultaneous_\(dateStr)_Slave.wav").path

        // 根据设备实际左右耳归属，将左耳/右耳预设映射到主/从翻译管道
        let masterPair = simultaneousLanguagePair(forMaster: true)
        let slavePair = simultaneousLanguagePair(forMaster: false)
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 译向映射 master(\(masterPair.source)→\(masterPair.target)) slave(\(slavePair.source)→\(slavePair.target))")

        // 主机流水线：解码 → 保存 → ASR(语音识别) → 翻译 → TTS(语音合成) → 编码 → 发给从机
        masterProcessor = SimultaneousTranslationProcessor(
            audioType: currentMode.dataType,
            sourceLanguage: masterPair.source,
            targetLanguage: masterPair.target,
            isUseA2dp: isUseA2dp,
            wavFilePath: masterWavPath,
            role: "Master"
        ) { [weak self] status in
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 主机翻译流水线初始化状态: \(status)")
            if !status {
                self?.toastMessage.accept("主机翻译服务初始化失败")
            }
        }
        masterProcessor?.onError { [weak self] _ in
            self?.exitSimultaneousMode {}
        }

        // 从机流水线：解码 → 保存 → ASR(语音识别) → 翻译 → TTS(语音合成) → 编码 → 发给主机
        slaveProcessor = SimultaneousTranslationProcessor(
            audioType: currentMode.dataType,
            sourceLanguage: slavePair.source,
            targetLanguage: slavePair.target,
            isUseA2dp: isUseA2dp,
            wavFilePath: slaveWavPath,
            role: "Slave"
        ) { [weak self] status in
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 从机翻译流水线初始化状态: \(status)")
            if !status {
                self?.toastMessage.accept("从机翻译服务初始化失败")
            }
        }
        slaveProcessor?.onError { [weak self] _ in
            self?.exitSimultaneousMode {}
        }

        // 主机翻译结果（编码音频）→ 下发给从机设备
        masterTargetBag = masterProcessor?.outputEncodedData
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] data in
                self?.callBackMasterTranslatedDataToSlave(data: data)
            })

        // 从机翻译结果（编码音频）→ 下发给主机设备
        slaveTargetBag = slaveProcessor?.outputEncodedData
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] data in
                self?.callBackSlaveTranslatedDataToMaster(data: data)
            })
    }

    private func destroySimultaneousProcessors() {
        masterTargetBag?.dispose()
        masterTargetBag = nil
        slaveTargetBag?.dispose()
        slaveTargetBag = nil
        masterProcessor?.destroy()
        masterProcessor = nil
        slaveProcessor?.destroy()
        slaveProcessor = nil
    }

    func mute(isMute: Bool) {
        self.isMute = isMute
    }

    // MARK: - 配置逻辑 (Setup Methods)

    private func setupModeForCall(_ block: JLTranslationManagerSetBlock?) {
        let isSupportOpusStereo = (currentMode.modeType == .callTranslateStereo)
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

    private func setupModeForCallRecord(_ block: JLTranslationManagerSetBlock?) {
        currentMode.modeType = .callRecord
        currentMode.channel = 1
        currentMode.dataType = .OPUS
        currentMode.sampleRate = 16000
        translateHelper?.trStartTranslate(currentMode, block: block)
    }

    // MARK: - 模式变更后的具体配置 (Config Methods)

    func configRecordTranslate() {
        if translateHelper?.recordtype == .byDevice {
            let isUseA2dp = translateHelper?.trIsPlayWithA2dp() ?? false
            configTranslate(currentMode.dataType, isUseA2dp, currentMode.dataType) { [weak self] success in
                self?.handleRecordTranslateConfigured(success)
            }
            JLLogManager.logLevel(.DEBUG, content: "Translate Log byDevice 进入同步翻译. configRecordTranslate")
        } else if translateHelper?.recordtype == .byPhone {
            audioData = JLTranslateAudio()
            audioData?.audioType = currentMode.dataType
            audioData?.sourceType = .typePhoneMic
            startRecord(audioType: currentMode.dataType)

            let isUseA2dp = translateHelper?.trIsPlayWithA2dp() ?? false
            configTranslate(.PCM, isUseA2dp, currentMode.dataType) { [weak self] success in
                self?.handleRecordTranslateConfigured(success)
            }
            JLLogManager.logLevel(.DEBUG, content: "Translate Log byPhone 进入同步翻译. configRecordTranslate")
        }
    }

    func configCallTranslate() {
        configTranslateCall(currentMode.dataType) { [weak self] success in
            guard let self = self else { return }
            if success {
                if self.currentMode.modeType == .callTranslateStereo {
                    self.startCallTranslateStereoSave()
                }
                self.buildCallTranslateSides()
                self.addObsTranslateData()
                self.addObsCallTranslateData()
                JLLogManager.logLevel(.COMPLETE, content: "Translate Log [CallPlayback] 通话翻译 manager 就绪，已订阅 targetData，准备下发")
                self.callConfigBlock?(.success, nil)
                self.callTranslateState.accept(.working)
            } else {
                self.callTranslateState.accept(.error("通话翻译初始化失败"))
            }
        }
    }

    func configAudioTranslate() {
        recordAndPlay()
        configTranslate(currentMode.dataType, true, currentMode.dataType) { _ in }
    }

    func configFaceToFaceTranslate() {
        faceToFaceState.accept(.working)
        setupFaceToFaceObservers()
    }

    func cleanupForIdle() {
        translateMgr?.onDestory()
        callTranslateMgr?.onDestory()
        disposeCallTranslateSides()
        recordSide?.dispose()
        recordSide = nil
        facePhoneMgr?.onDestory()
        facePhoneMgr = nil
        faceDeviceMgr?.onDestory()
        faceDeviceMgr = nil
        facePhoneSide?.dispose()
        facePhoneSide = nil
        faceDeviceSide?.dispose()
        faceDeviceSide = nil
        facePhoneDataBag?.dispose()
        facePhoneDataBag = nil
        faceDevicePcmBag?.dispose()
        faceDevicePcmBag = nil
        JLAudioPlayer.shared.stop()
        JLAudioRecoder.shared.stop()
        stopCallRecord()
        stopCallTranslateStereoSave()
        stopOnlyRecordSave()
        stopPlaying()
        callTranslateState.accept(.idle)
        recordTranslateState.accept(.idle)
        faceToFaceState.accept(.idle)
        phoneRecordState.accept(.idle)
        deviceRecordState.accept(.idle)
        phoneRecordSource.accept(.none)
        deviceRecordSource.accept(.none)
    }

    // MARK: - 语言自动配对

    /// 设置原文语言：自动保证原文与译文不同，并同步镜像通话翻译的对方语言
    func setSourceLanguage(_ source: TranslateLanguage) {
        var target = translateLanguage.1.first ?? .en
        if target == source {
            target = Self.counterpartLanguage(of: source)
        }
        translateLanguage = (source, [target])
        translateCallLanguage = (target, [source])
    }

    /// 设置译文语言：自动保证原文与译文不同，并同步镜像通话翻译的对方语言
    func setTargetLanguage(_ target: TranslateLanguage) {
        var source = translateLanguage.0
        if source == target {
            source = Self.counterpartLanguage(of: target)
        }
        translateLanguage = (source, [target])
        translateCallLanguage = (target, [source])
    }

    /// 取一门与指定语言不同的自动配对语言（中文↔英文优先，日文回落为中文）
    static func counterpartLanguage(of language: TranslateLanguage) -> TranslateLanguage {
        switch language {
        case .zh: return .en
        case .en: return .zh
        case .ja: return .zh
        }
    }

    // MARK: - 翻译服务配置 (Service Config)

    func configTranslate(_ audioType: JL_SpeakDataType, _ isUseA2dp: Bool, _ targetType: JL_SpeakDataType, _ resultBlock: @escaping (Bool) -> Void) {
        initTranslateMgr(audioType, isUseA2dp, targetType, translateLanguage, resultBlock)
    }

    func initTranslateMgr(_ audioType: JL_SpeakDataType, _ isUseA2dp: Bool, _ targetType: JL_SpeakDataType, _ languages: LanguageGroup, _ resultBlock: @escaping (Bool) -> Void) {
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

    func configTranslateCall(_ audioType: JL_SpeakDataType, _ resultBlock: @escaping (Bool) -> Void) {
        let chain = JLTaskChain()
        // 以用户实际选中的模式为准，而不是设备能力标志；否则手动选「通话立体声翻译」时仍会被当成单声道
        let isSupportOpusStereo = (currentMode.modeType == .callTranslateStereo)

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

    // MARK: - 订阅管理

    func addObsTranslateData() {
        disposeDataBags()
        transDataBag = translateMgr?.targetData.subscribe(onNext: { [weak self] data in
            JLLogManager.logLevel(.COMPLETE, content: "Translate Log [CallPlayback] translateMgr.targetData 收到 \(data.count) bytes → callBackDataToDevice")
            self?.callBackDataToDevice(data: data)
        })
        // 双声道约定：左声道=下行(对方语音)→对方翻译链路；右声道=上行(己方语音)→己方翻译链路
        devPcmLeftBag = translateMgr?.devPcmLeftData.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            self.callTranslateMgr?.startTranslatePcmData(data)
            self.appendCallTranslateStereoSavePcm(data, isUp: false)
        })
        devPcmRightBag = translateMgr?.devPcmRightData.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            self.translateMgr?.startTranslatePcmData(data)
            self.appendCallTranslateStereoSavePcm(data, isUp: true)
        })
    }

    func addObsCallTranslateData() {
        callDataBag?.dispose()
        callDataBag = callTranslateMgr?.targetData
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] data in
                JLLogManager.logLevel(.COMPLETE, content: "Translate Log [CallPlayback] callTranslateMgr.targetData 收到 \(data.count) bytes → handleCallData")
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
        let modeType = translateHelper?.translateMode.modeType
        if modeType != .callTranslate && modeType != .callTranslateStereo { return }

        let isCall = (modeType == .callTranslate || modeType == .callTranslateStereo)
        if !isDeliverTranslation && !isCall {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 通话译文下发已禁用，跳过下发数据")
            return
        }

        // 立体声模式按回写策略决定是否下发对方译文(ESCODown)
        if modeType == .callTranslateStereo {
            let deliverDown = (callStereoDeliverMode == .downOnly || callStereoDeliverMode == .both)
            if !deliverDown {
                JLLogManager.logLevel(.DEBUG, content: "Translate Log [CallPlayback] 立体声模式跳过对方译文(ESCODown)，策略=\(callStereoDeliverMode.rawValue)")
                return
            }
        }

        // 新建对象，避免与 callBackDataToDevice 共用同一 audioData 造成 sourceType 并发互相覆盖
        let audio = JLTranslateAudio()
        audio.audioType = audioData.audioType
        audio.sourceType = .typeESCODown
        JLLogManager.logLevel(.COMPLETE, content: "Translate Log [CallPlayback] handleCallData 下发对方译文：sourceType=\(audio.sourceType.rawValue), audioType=\(audio.audioType.rawValue), data=\(data.count) bytes, writeWithoutResponse=\(writeWithoutResponse)")
        sendQueueStatus.accept(false)
        if writeWithoutResponse {
            translateHelper?.trWriteAudioV2(audio, translate: data)
        } else {
            translateHelper?.trWrite(audio, translate: data)
        }
    }

    // MARK: - 辅助方法

    func calculateDuration(_ dataBytes: Int) -> Double {
        return TranslateTools.calculateDuration(
            dataBytes: dataBytes,
            sampleRate: 16000,
            bitDepth: 16,
            channels: 1
        )
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

            let callRelatedModes: [JLTranslateSetModeType] = [.callTranslate, .callTranslateStereo, .callRecord]
            if self.translateHelper?.isCalling == true,
               !callRelatedModes.contains(self.translateHelper?.translateMode.modeType ?? .idle) {
                self.translateHelper?.trExitMode { _, err in
                    if let err = err {
                        self.toastMessage.accept("退出通话失败:\(err)")
                    }
                }
            }
            if self.translateHelper?.isCalling == false,
               self.translateHelper?.translateMode.modeType == .callRecord {
                self.translateHelper?.trExitMode { _, err in
                    if let err = err {
                        self.toastMessage.accept("退出通话录音失败:\(err)")
                    }
                }
            }
        })
    }

    @objc private func onVolcesTranslateError() {
        toastMessage.accept("network_exception_tips")
    }
}
