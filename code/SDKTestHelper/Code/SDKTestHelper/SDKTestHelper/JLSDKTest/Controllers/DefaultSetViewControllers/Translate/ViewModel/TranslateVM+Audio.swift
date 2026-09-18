//
//  TranslateVM+Audio.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/9.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import JL_BLEKit
import JLAudioUnitKit

// MARK: - 音频数据处理

extension TranslateVM {

    // MARK: 数据接收与分发

    /// 处理接收到的音频数据
    func handleReceivedAudioData(_ data: JLTranslateAudio) {
        JLLogManager.logLevel(.COMPLETE, content: "Translate Log 收到翻译音频数据: modeType=\(currentMode.modeType.rawValue), dataType=\(currentMode.dataType.rawValue), sourceType=\(data.sourceType.rawValue), 数据长度=\(data.data.count)")
        audioData = data

        // 仅录音模式：始终进入数据处理路径
        if currentMode.modeType == .onlyRecord {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 进入 onlyRecord 路径，准备调用 inputToTranslationManager")
            inputToTranslationManager(data)
            return
        }

        // 根据模式分发处理
        switch currentMode.modeType {
        case .recordTranslate:
             if currentMode.dataType == .OPUS {
                 JLLogManager.logLevel(.DEBUG, content: "Translate Log 进入 recordTranslate + OPUS 路径")
                 inputToTranslationManager(data)
             }
        case .callTranslate, .callTranslateStereo, .faceToFaceTranslate, .audioTranslate:
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 进入其他翻译模式路径")
            inputToTranslationManager(data)
        case .callRecord:
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 进入 callRecord 路径")
            handleCallRecordAudioData(data)
        default:
            JLLogManager.logLevel(.WARN, content: "Translate Log 未处理的 modeType: \(currentMode.modeType.rawValue)")
            break
        }
    }

    /// 处理模式变更
    func handleModeChange(_ mode: JLTranslateSetMode) {
        currentMode = mode
        subjectCurrentMode.accept(mode)

        // onlyRecord 模式：需要初始化解码器（设备仍会上传音频数据）
        if mode.modeType == .onlyRecord {
            startOnlyRecordSave()
            pareparRecordOnly(currentMode.dataType)
        }

        JLLogManager.logLevel(.DEBUG, content: "Translate Log Mode Changed to: \(mode.modeType)")

        switch mode.modeType {
        case .recordTranslate:
            configRecordTranslate()
        case .callTranslate,.callTranslateStereo:
            configCallTranslate()
        case .audioTranslate:
            configAudioTranslate()
        case .onlyRecord:
            // 解码器已在上面初始化
            break
        case .faceToFaceTranslate:
            configFaceToFaceTranslate()
        case .callRecord:
            configCallRecordTranslate()
        case .idle:
            cleanupForIdle()
        default:
            break
        }
    }

    // MARK: 内部逻辑

    /// 将数据输入到对应的翻译管理器进行处理
    func inputToTranslationManager(_ data: JLTranslateAudio) {
        JLLogManager.logLevel(.DEBUG, content: "Translate Log inputToTranslationManager 被调用，sourceType: \(data.sourceType.rawValue), modeType: \(currentMode.modeType.rawValue)")
        // 解码模式 (OnlyRecord)
        if currentMode.modeType == .onlyRecord {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 进入 onlyRecord 解码路径")
            decodeAudioData(data)
            return
        }

        // 通话翻译模式
        if currentMode.modeType == .callTranslate {
            if data.sourceType == .typeESCOUp {
                JLLogManager.logLevel(.DEBUG, content: "Translate Log [CallPlayback] inputToTranslationManager: typeESCOUp → translateMgr(己方), \(data.data.count) bytes")
                translateMgr?.startTranslateData(data.data)
            } else if data.sourceType == .typeESCODown {
                JLLogManager.logLevel(.DEBUG, content: "Translate Log [CallPlayback] inputToTranslationManager: typeESCODown → callTranslateMgr(对方), \(data.data.count) bytes")
                callTranslateMgr?.startTranslateData(data.data)
            }
            return
        }
        // 通话翻译立体声
        if currentMode.modeType == .callTranslateStereo {
            if data.sourceType == .typeESCOMax {
                JLLogManager.logLevel(.DEBUG, content: "Translate Log [CallPlayback] inputToTranslationManager: typeESCOMax → translateMgr 立体声解码, \(data.data.count) bytes")
                translateMgr?.startTranslateData(data.data)
            }
            return
        }

        // 面对面翻译（手机+耳机）：设备端上传音频 → faceDeviceMgr
        if currentMode.modeType == .faceToFaceTranslate {
            if data.sourceType == .typeDeviceMic {
                JLLogManager.logLevel(.DEBUG, content: "Translate Log [CallPlayback] inputToTranslationManager: typeDeviceMic → faceDeviceMgr, \(data.data.count) bytes")
                faceDeviceMgr?.startTranslateData(data.data)
            }
            return
        }

        // 其他模式通用处理
        translateMgr?.startTranslateData(data.data)
    }

    func decodeAudioData(_ data: JLTranslateAudio) {
        JLLogManager.logLevel(.DEBUG, content: "Translate Log decodeAudioData 被调用，dataType: \(currentMode.dataType.rawValue), modeType: \(currentMode.modeType.rawValue), 数据长度: \(data.data.count)")
        if currentMode.dataType == .OPUS {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 进入 OPUS 解码分支")
            coderOpus?.decodeDataToPcm(data.data)
        } else if currentMode.dataType == .JLA_V2 {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 进入 JLA_V2 解码分支")
            coderJav2?.decodeDataToPcm(data.data)
        } else if currentMode.dataType == .PCM && currentMode.modeType == .onlyRecord {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 仅录音 PCM 直存，长度: \(data.data.count)")
            saveOnlyRecordPcmData(data.data)
        } else {
            JLLogManager.logLevel(.WARN, content: "Translate Log decodeAudioData 未匹配任何分支，dataType: \(currentMode.dataType.rawValue), modeType: \(currentMode.modeType.rawValue)")
        }
    }

    // MARK: 数据回传

    /// 回传数据给设备
    func callBackDataToDevice(data: Data) {
        if isMute || data.isEmpty {
            JLLogManager.logLevel(.DEBUG, content: "Translate LogMuted or Empty Data")
            return
        }

        let modeType = translateHelper?.translateMode.modeType
        let isCall = modeType == .callTranslate || modeType == .callTranslateStereo

        // 立体声模式按回写策略决定是否下发己方译文(ESCOUp)
        if modeType == .callTranslateStereo {
            let deliverUp = (callStereoDeliverMode == .upOnly || callStereoDeliverMode == .both)
            if !deliverUp {
                JLLogManager.logLevel(.DEBUG, content: "Translate Log [CallPlayback] 立体声模式跳过己方译文(ESCOUp)，策略=\(callStereoDeliverMode.rawValue)")
                return
            }
        }

        // 通话翻译模式强制下发译文，忽略 isDeliverTranslation
        if !isDeliverTranslation && !isCall {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 译文下发已禁用，跳过下发数据")
            return
        }

        let isA2DP = translateHelper?.trIsPlayWithA2dp() ?? false

        if isA2DP && !isCall {
            // A2DP 播放模式 (目前注释掉)
        } else {
            guard let baseAudio = audioData else { return }
            // 新建对象，避免与 handleCallData 共用同一 audioData 造成 sourceType 并发互相覆盖
            let audio = JLTranslateAudio()
            audio.audioType = baseAudio.audioType
            audio.sourceType = isCall ? .typeESCOUp : baseAudio.sourceType
            JLLogManager.logLevel(.COMPLETE, content: "Translate Log [CallPlayback] callBackDataToDevice 下发己方译文：sourceType=\(audio.sourceType.rawValue), audioType=\(audio.audioType.rawValue), data=\(data.count) bytes, writeWithoutResponse=\(writeWithoutResponse)")
            sendQueueStatus.accept(false)
            if writeWithoutResponse {
                translateHelper?.trWriteAudioV2(audio, translate: data)
            } else {
                translateHelper?.trWrite(audio, translate: data)
            }
        }
    }

    /// 面对面翻译（左耳+右耳）：回传主机翻译结果给从机
    func callBackMasterTranslatedDataToSlave(data: Data) {
        if isMute || data.isEmpty {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 主机译文为空或静音，跳过下发")
            return
        }
        let audioData = JLTranslateAudio()
        audioData.audioType = currentMode.dataType
        audioData.sourceType = .typeDeviceMic
        sendQueueStatus.accept(false)
        if writeWithoutResponse {
            translateHelper?.trWriteAudioV2(audioData, translate: data)
        } else {
            translateHelper?.trWriteAudio(toSlave: audioData, translate: data)
        }
//        JLLogManager.logLevel(.DEBUG, content: "Translate Log 主机译文下发给从机，长度: \(data.count)")
    }

    /// 面对面翻译（左耳+右耳）：回传从机翻译结果给主机
    func callBackSlaveTranslatedDataToMaster(data: Data) {
        if isMute || data.isEmpty {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 从机译文为空或静音，跳过下发")
            return
        }
        let audioData = JLTranslateAudio()
        audioData.audioType = currentMode.dataType
        audioData.sourceType = .typePhoneMic
        sendQueueStatus.accept(false)
        if writeWithoutResponse {
            translateHelper?.trWriteAudioV2(audioData, translate: data)
        } else {
            translateHelper?.trWrite(audioData, translate: data)
        }
//        JLLogManager.logLevel(.DEBUG, content: "Translate Log 从机译文下发给主机，长度: \(data.count)")
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

    // MARK: 面对面翻译（左耳+右耳）音频处理

    /// 处理主机音频数据 → 送入主机流水线处理器
    /// 流水线：解码 → 保存WAV → ASR(语音识别) → 翻译 → TTS(语音合成) → 编码 → 输出(发给从机)
    func handleMasterSimultaneousAudio(_ data: JLTranslateAudio) {
//        JLLogManager.logLevel(.DEBUG, content: "Translate Log 处理面对面翻译（左耳+右耳）主机音频，sourceType: \(data.sourceType.rawValue), 长度: \(data.data.count)")
        masterProcessor?.processEncodedAudio(data.data)
    }

    /// 处理从机音频数据 → 送入从机流水线处理器
    /// 流水线：解码 → 保存WAV → ASR(语音识别) → 翻译 → TTS(语音合成) → 编码 → 输出(发给主机)
    func handleSlaveSimultaneousAudio(_ data: JLTranslateAudio) {
//        JLLogManager.logLevel(.DEBUG, content: "Translate Log 处理面对面翻译（左耳+右耳）从机音频，sourceType: \(data.sourceType.rawValue), 长度: \(data.data.count)")
        slaveProcessor?.processEncodedAudio(data.data)
    }

    /// 清理面对面翻译（左耳+右耳）解码器（兼容旧接口，实际解码器已移入 SimultaneousTranslationProcessor）
    func prepareSimultaneousDecoders(audioType: JL_SpeakDataType) {
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 面对面翻译（左耳+右耳）解码器已由 SimultaneousTranslationProcessor 内部管理，无需外部初始化")
    }

    /// 清理面对面翻译（左耳+右耳）解码器（兼容旧接口，实际解码器已移入 SimultaneousTranslationProcessor）
    func cleanupSimultaneousDecoders() {
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 面对面翻译（左耳+右耳）解码器已由 SimultaneousTranslationProcessor 内部管理，无需外部清理")
    }

    // MARK: 编解码器准备

    func pareparRecordOnly(_ audioType: JL_SpeakDataType) {
        JLLogManager.logLevel(.DEBUG, content: "Translate Log pareparRecordOnly 被调用，audioType: \(audioType.rawValue)")
        if audioType == .OPUS {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 初始化 OPUS 解码器")
            coderOpus = TranslateOpusHelper({ [weak self] data in
                 JLLogManager.logLevel(.DEBUG, content: "Translate Log Opus 单声道回调触发，PCM长度: \(data.count)")
                 self?.convertedPcmData.accept(data)
                 self?.saveOnlyRecordPcmData(data)
            }, { _ in
                 JLLogManager.logLevel(.DEBUG, content: "Translate Log Opus 编码回调（通常不用于录音）")
            }, { [weak self] left, right in
                 JLLogManager.logLevel(.DEBUG, content: "Translate Log Opus 立体声回调触发，left: \(left?.count ?? 0), right: \(right?.count ?? 0)")
                 guard let self = self, let leftData = left else { return }
                 self.convertedPcmData.accept(leftData)
                 self.saveOnlyRecordPcmData(leftData)
                 if let rightData = right {
                     self.saveOnlyRecordPcmData(rightData)
                 }
            })
        } else if audioType == .JLA_V2 {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 初始化 JLA_V2 解码器")
            coderJav2 = TranslateAV2Helper({ [weak self] data in
                JLLogManager.logLevel(.DEBUG, content: "Translate Log JLA_V2 解码回调触发，PCM长度: \(data.count)")
                self?.convertedPcmData.accept(data)
                self?.saveOnlyRecordPcmData(data)
            }, { _ in })
        } else if audioType == .PCM {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 仅录音 PCM 直存模式，无需初始化解码器")
        }
    }

    // MARK: 录音与播放

    func startRecord(audioType: JL_SpeakDataType) {
        do {
            try JLAudioRecoder.shared.startRecording { [weak self] data in
                self?.translateMgr?.startTranslateData(data)
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
}
