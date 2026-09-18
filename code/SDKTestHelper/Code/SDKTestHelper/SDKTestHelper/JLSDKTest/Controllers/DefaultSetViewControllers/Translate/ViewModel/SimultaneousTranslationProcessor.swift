//
//  SimultaneousTranslationProcessor.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/7/7.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import JL_BLEKit
import JLAudioUnitKit
import Foundation

/// 面对面翻译（左耳+右耳）音频流水线处理器
///
/// 完整流水线：
///   编码音频(Opus/JLA_V2) → 解码 → PCM → 保存WAV → ASR(语音识别) → 翻译 → TTS(语音合成) → 编码 → 输出
///
/// 每个实例处理一个方向（主机→从机 或 从机→主机），共5个阶段：
///   Stage 1: 解码 (Opus/JLA_V2 → PCM)
///   Stage 2: 保存PCM到WAV文件
///   Stage 3: ASR语音识别 (PCM → 文字)
///   Stage 4: 翻译 + TTS语音合成 (文字 → 翻译 → 合成PCM音频)
///   Stage 5: 编码 (PCM → Opus/JLA_V2) 并输出
///
/// Stage 3-5 复用 VolcesBusManager 的内部管线。
class SimultaneousTranslationProcessor: NSObject {

    // MARK: - 流水线输出

    /// 编码后的翻译音频数据，可直接发送给对端设备
    let outputEncodedData = BehaviorRelay<Data>(value: Data())

    /// 翻译文字字幕（源语言识别结果，仅最终确定文本）
    let originSubtitleText = BehaviorRelay<String>(value: "")

    /// 流式中间结果（ASR 实时识别，用于临时展示，最终文本到达后覆盖）
    let originStreamingText = BehaviorRelay<String>(value: "")

    /// 翻译文字字幕（目标语言翻译结果）
    let translatedSubtitleText = BehaviorRelay<String>(value: "")

    /// 流水线是否正在处理中
    let isProcessing = BehaviorRelay<Bool>(value: false)

    // MARK: - 统计数据

    /// 累计收到编码音频包数
    let statsOpusReceived = BehaviorRelay<Int>(value: 0)
    /// 累计收到编码音频字节数
    let statsOpusReceivedBytes = BehaviorRelay<Int>(value: 0)
    /// 累计解码 PCM 字节数
    let statsPcmDecodedBytes = BehaviorRelay<Int>(value: 0)
    /// 累计翻译文本字节数
    let statsTranslatedTextBytes = BehaviorRelay<Int>(value: 0)
    /// 累计 TTS 输出音频字节数
    let statsTtsOutputBytes = BehaviorRelay<Int>(value: 0)
    /// 累计发出的编码音频包数
    let statsOpusSent = BehaviorRelay<Int>(value: 0)
    /// 累计发出的编码音频字节数
    let statsOpusSentBytes = BehaviorRelay<Int>(value: 0)
    /// 当前正在 TTS 合成的文本
    let currentTtsText = BehaviorRelay<String>(value: "")

    // MARK: - 配置

    private let audioType: JL_SpeakDataType
    private let sourceLanguage: TranslateLanguage
    private let targetLanguage: TranslateLanguage
    private let role: String
    private var wavEncoder: JLPcmToWav?

    // MARK: - 流水线组件

    /// Stage 1: 解码器
    private var opusDecoder: TranslateOpusHelper?
    private var av2Decoder: TranslateAV2Helper?

    /// Stage 3-5: ASR → 翻译 → TTS → 编码 (复用 VolcesBusManager)
    private var busManager: VolcesBusManager?

    // MARK: - 状态

    private let disposeBag = DisposeBag()
    private var targetBag: Disposable?
    private var isDestroyed = false
    private var errorCallback: ((Error) -> Void)?

    // MARK: - 初始化

    /// 创建面对面翻译（左耳+右耳）流水线处理器
    /// - Parameters:
    ///   - audioType: 音频编解码类型 (OPUS / JLA_V2)
    ///   - sourceLanguage: 源语言（说话人的语言）
    ///   - targetLanguage: 目标语言（翻译后的语言）
    ///   - isUseA2dp: 是否使用 A2DP 播放
    ///   - wavFilePath: 解码后 PCM 保存的 WAV 文件路径
    ///   - role: 角色标识（用于日志区分，如 "Master" / "Slave"）
    ///   - completion: 初始化完成回调
    init(audioType: JL_SpeakDataType,
         sourceLanguage: TranslateLanguage,
         targetLanguage: TranslateLanguage,
         isUseA2dp: Bool,
         wavFilePath: String,
         role: String,
         completion: @escaping (Bool) -> Void) {

        self.audioType = audioType
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.role = role

        super.init()

        JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(role)] 初始化面对面翻译（左耳+右耳）流水线 - audioType: \(audioType.rawValue), 源语言: \(sourceLanguage.rawValue) → 目标语言: \(targetLanguage.rawValue)")

        // Stage 2: 初始化 WAV 编码器用于保存解码后的 PCM
        setupWavEncoder(filePath: wavFilePath)

        // Stage 1: 初始化解码器
        setupDecoder()

        // Stage 3-5: 初始化 VolcesBusManager (ASR → 翻译 → TTS → 编码)
        setupBusManager(isUseA2dp: isUseA2dp, completion: completion)
    }

    // MARK: - Stage 1: 解码器

    private func setupDecoder() {
        switch audioType {
        case .OPUS:
            opusDecoder = TranslateOpusHelper(
                { [weak self] pcmData in
                    self?.onPcmDecoded(pcmData)
                },
                { _ in },  // 编码回调不使用（编码由 VolcesBusManager 内部处理）
                { [weak self] left, right in
                    guard let self = self, let leftData = left else { return }
                    JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(self.role)] Opus 立体声解码 - left: \(leftData.count), right: \(right?.count ?? 0)")
                    self.onPcmDecoded(leftData)
                }
            )
            JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(role)] Stage 1 就绪: Opus 解码器")

        case .JLA_V2:
            av2Decoder = TranslateAV2Helper(
                { [weak self] pcmData in
                    self?.onPcmDecoded(pcmData)
                },
                { _ in }  // 编码回调不使用
            )
            JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(role)] Stage 1 就绪: JLA_V2 解码器")

        case .PCM:
            JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(role)] Stage 1: PCM 直通模式，无需解码器")

        @unknown default:
            JLLogManager.logLevel(.WARN, content: "Translate Log [\(role)] 未知 audioType: \(audioType.rawValue)")
        }
    }

    // MARK: - Stage 2: WAV 保存

    private func setupWavEncoder(filePath: String) {
        wavEncoder = JLPcmToWav(
            outputPath: filePath,
            sampleRate: 16000,
            numChannels: 1,
            bitsPerSample: 16
        )
        JLLogManager.logLevel(.COMPLETE, content: "Translate Log [\(role)] Stage 2 就绪: WAV 保存路径 = \(filePath)")
    }

    // MARK: - Stage 3-5: VolcesBusManager (ASR → 翻译 → TTS → 编码)

    private func setupBusManager(isUseA2dp: Bool, completion: @escaping (Bool) -> Void) {
        busManager = VolcesBusManager(
            audioType,
            audioType,         // toLanguage: 输出编码格式与输入相同
            sourceLanguage,
            [targetLanguage],
            isUseA2dp,
            false              // 面对面翻译（左耳+右耳）不使用 Opus 立体声
        ) { [weak self] status in
            guard let self = self else { return }
            JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(self.role)] Stage 3-5 就绪: VolcesBusManager 初始化 \(status ? "成功" : "失败")")
            if status {
                self.subscribeBusManagerOutput()
            }
            completion(status)
        }

        busManager?.onErrorCallBack { [weak self] error in
            guard let self = self else { return }
            JLLogManager.logLevel(.ERROR, content: "Translate Log [\(self.role)] 翻译服务错误: \(error.localizedDescription)")
            self.errorCallback?(error)
        }

        // 订阅原文（中间过程流式展示，最终确定文本永久保留）
        busManager?.definiteTextOrigin
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: originSubtitleText)
            .disposed(by: disposeBag)

        // 流式中间结果：实时展示当前正在识别的原文
        busManager?.subtitleText
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: originStreamingText)
            .disposed(by: disposeBag)

        busManager?.definiteTextTranslate
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .do(onNext: { [weak self] text in
                // 累计翻译文本字节数
                self?.statsTranslatedTextBytes.accept((self?.statsTranslatedTextBytes.value ?? 0) + text.utf8.count)
            })
            .bind(to: translatedSubtitleText)
            .disposed(by: disposeBag)

        // 订阅 TTS 合成完成的文本（用于 UI 展示当前正在翻译的内容）
        busManager?.targetPcmData
            .map { $0.1.joined(separator: " | ") }
            .distinctUntilChanged()
            .bind(to: currentTtsText)
            .disposed(by: disposeBag)
    }

    /// 订阅 VolcesBusManager 的编码输出（Stage 5 结果）
    private func subscribeBusManagerOutput() {
        targetBag?.dispose()
        targetBag = busManager?.targetData
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] encodedData in
                guard let self = self, !self.isDestroyed else { return }
                JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(self.role)] Stage 5 完成: 编码输出 \(encodedData.count) bytes")
                // 累计 TTS 输出 / Opus 发出统计
                self.statsTtsOutputBytes.accept(self.statsTtsOutputBytes.value + encodedData.count)
                self.statsOpusSent.accept(self.statsOpusSent.value + 1)
                self.statsOpusSentBytes.accept(self.statsOpusSentBytes.value + encodedData.count)
                self.outputEncodedData.accept(encodedData)
            })
    }

    // MARK: - 公共接口

    /// 输入编码音频数据，启动完整流水线
    /// - Parameter encodedData: 编码后的音频数据 (Opus 或 JLA_V2 格式)
    func processEncodedAudio(_ encodedData: Data) {
        guard !isDestroyed else {
            JLLogManager.logLevel(.WARN, content: "Translate Log [\(role)] 流水线已销毁，忽略输入数据")
            return
        }

        // 累计 Opus 接收统计
        statsOpusReceived.accept(statsOpusReceived.value + 1)
        statsOpusReceivedBytes.accept(statsOpusReceivedBytes.value + encodedData.count)

        JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(role)] → 输入编码音频 \(encodedData.count) bytes, audioType: \(audioType.rawValue)")

        // Stage 1: 解码
        switch audioType {
        case .OPUS:
            opusDecoder?.decodeDataToPcm(encodedData)
        case .JLA_V2:
            av2Decoder?.decodeDataToPcm(encodedData)
        case .PCM:
            // PCM 直通：跳过解码，直接进入后续阶段
            onPcmDecoded(encodedData)
        default:
            JLLogManager.logLevel(.WARN, content: "Translate Log [\(role)] 不支持的 audioType: \(audioType.rawValue)")
        }
    }

    /// 设置错误回调
    func onError(_ callback: @escaping (Error) -> Void) {
        errorCallback = callback
    }

    /// 结束当前翻译段落（发送 End 标记给 ASR 服务）
    func endSegment() {
        busManager?.endTranslate()
        JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(role)] 结束翻译段落")
    }

    /// 销毁流水线，释放所有资源
    func destroy() {
        guard !isDestroyed else { return }
        isDestroyed = true

        JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(role)] 销毁面对面翻译（左耳+右耳）流水线")

        targetBag?.dispose()
        targetBag = nil

        opusDecoder?.onDestory()
        opusDecoder = nil
        av2Decoder?.onDestory()
        av2Decoder = nil

        // 完成 WAV 文件写入
        do {
            try wavEncoder?.finish()
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log [\(role)] WAV 完成编码错误: \(error.localizedDescription)")
        }
        wavEncoder = nil

        busManager?.onDestory()
        busManager = nil

        outputEncodedData.accept(Data())
        isProcessing.accept(false)
        // 重置统计
        statsOpusReceived.accept(0)
        statsOpusReceivedBytes.accept(0)
        statsPcmDecodedBytes.accept(0)
        statsTranslatedTextBytes.accept(0)
        statsTtsOutputBytes.accept(0)
        statsOpusSent.accept(0)
        statsOpusSentBytes.accept(0)
        currentTtsText.accept("")
        originSubtitleText.accept("")
        originStreamingText.accept("")
        translatedSubtitleText.accept("")
        errorCallback = nil
    }

    // MARK: - 内部处理

    /// 解码完成回调 (Stage 1 → Stage 2 + Stage 3)
    private func onPcmDecoded(_ pcmData: Data) {
        guard !isDestroyed, !pcmData.isEmpty else { return }

        // 累计 PCM 解码统计
        statsPcmDecodedBytes.accept(statsPcmDecodedBytes.value + pcmData.count)

        JLLogManager.logLevel(.COMPLETE, content: "Translate Log [\(role)] Stage 1 完成: 解码 PCM \(pcmData.count) bytes")

        // Stage 2: 保存解码后的 PCM 到 WAV 文件
        savePcmToWav(pcmData)

        // Stage 3-5: 送入 ASR → 翻译 → TTS → 编码 流水线
        busManager?.startTranslatePcmData(pcmData)
        isProcessing.accept(true)
    }

    /// Stage 2: 保存 PCM 数据
    private func savePcmToWav(_ pcmData: Data) {
        guard let encoder = wavEncoder else {
            JLLogManager.logLevel(.WARN, content: "Translate Log [\(role)] Stage 2: WAV 编码器未初始化，跳过保存")
            return
        }
        do {
            try encoder.appendPCMData(pcmData)
            // JLLogManager.logLevel(.DEBUG, content: "Translate Log [\(role)] Stage 2: PCM 已写入 WAV, \(pcmData.count) bytes")
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log [\(role)] Stage 2: WAV 写入错误: \(error.localizedDescription)")
        }
    }
}
