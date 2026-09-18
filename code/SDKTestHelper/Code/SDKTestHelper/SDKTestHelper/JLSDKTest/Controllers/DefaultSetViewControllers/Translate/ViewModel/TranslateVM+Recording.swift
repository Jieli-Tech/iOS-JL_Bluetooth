//
//  TranslateVM+Recording.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/9.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import JL_BLEKit
import JLAudioUnitKit
import AVFoundation

// MARK: - 录音文件管理

extension TranslateVM {

    // MARK: 通话录音模式

    /// 配置通话录音模式
    func configCallRecordTranslate() {
        prepareCallRecordDecoder()
        startCallRecord()
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 进入通话录音模式")
    }

    /// 准备通话录音解码器
    func prepareCallRecordDecoder() {
        coderOpus?.onDestory()
        coderOpus = nil
        coderJav2?.onDestory()
        coderJav2 = nil

        if currentMode.dataType == .OPUS {
            coderOpus = TranslateOpusHelper({ [weak self] pcm in
                self?.convertedPcmData.accept(pcm)
                let sourceType: CallRecordSourceType = (self?.audioData?.sourceType == .typeESCOUp) ? .up : .down
                self?.appendCallRecordPcmData(pcm, sourceType: sourceType)
                JLLogManager.logLevel(.DEBUG, content: "Translate Log 通话录音 Opus 解码完成，PCM长度: \(pcm.count)")
            }, { _ in })
        } else if currentMode.dataType == .JLA_V2 {
            coderJav2 = TranslateAV2Helper({ [weak self] pcm in
                self?.convertedPcmData.accept(pcm)
                let sourceType: CallRecordSourceType = (self?.audioData?.sourceType == .typeESCOUp) ? .up : .down
                self?.appendCallRecordPcmData(pcm, sourceType: sourceType)
                JLLogManager.logLevel(.DEBUG, content: "Translate Log 通话录音 JLA_V2 解码完成，PCM长度: \(pcm.count)")
            }, { _ in })
        }
    }

    /// 处理通话录音音频数据
    func handleCallRecordAudioData(_ data: JLTranslateAudio) {
        let sourceType = data.sourceType
        let sourceName = sourceType == .typeESCOUp ? "己方(上行)" : (sourceType == .typeESCODown ? "对方(下行)" : "未知")
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 通话录音数据 - 来源: \(sourceName), 类型: \(data.audioType), 长度: \(data.data.count)")
        decodeAudioData(data)
    }

    /// 开始通话录音（初始化流式WAV编码器）
    func startCallRecord() {
        let dateStr = Date().getDateStr
        let dir = recordFilesDirectory

        let upPath = dir.appendingPathComponent("CallRecord_\(dateStr)_Up.wav").path
        let downPath = dir.appendingPathComponent("CallRecord_\(dateStr)_Down.wav").path

        upPcmBuffer = Data()
        downPcmBuffer = Data()

        upWavEncoder = JLPcmToWav(outputPath: upPath, sampleRate: 16000, numChannels: 1, bitsPerSample: 16)
        downWavEncoder = JLPcmToWav(outputPath: downPath, sampleRate: 16000, numChannels: 1, bitsPerSample: 16)

        JLLogManager.logLevel(.DEBUG, content: "Translate Log 通话录音开始 - 上行: \(upPath), 下行: \(downPath)")
    }

    /// 追加通话录音PCM数据
    func appendCallRecordPcmData(_ pcmData: Data, sourceType: CallRecordSourceType) {
        switch sourceType {
        case .up:
            upPcmBuffer.append(pcmData)
            do {
                try upWavEncoder?.appendPCMData(pcmData)
            } catch {
                JLLogManager.logLevel(.ERROR, content: "Translate Log 上行WAV编码错误: \(error.localizedDescription)")
            }
        case .down:
            downPcmBuffer.append(pcmData)
            do {
                try downWavEncoder?.appendPCMData(pcmData)
            } catch {
                JLLogManager.logLevel(.ERROR, content: "Translate Log 下行WAV编码错误: \(error.localizedDescription)")
            }
        case .stereo:
            upPcmBuffer.append(pcmData)
            do {
                try upWavEncoder?.appendPCMData(pcmData)
            } catch {
                JLLogManager.logLevel(.ERROR, content: "Translate Log 立体声WAV编码错误: \(error.localizedDescription)")
            }
        case .simultaneousMaster, .simultaneousSlave:
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 面对面翻译（左耳+右耳）音频不通过通话录音路径保存")
            break
        }
    }

    /// 结束通话录音（完成WAV编码）
    func stopCallRecord() {
        do {
            try upWavEncoder?.finish()
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 上行WAV完成编码错误: \(error.localizedDescription)")
        }
        do {
            try downWavEncoder?.finish()
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 下行WAV完成编码错误: \(error.localizedDescription)")
        }
        upWavEncoder = nil
        downWavEncoder = nil
        upPcmBuffer = Data()
        downPcmBuffer = Data()

        fetchRecordFiles()
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 通话录音结束，WAV文件已保存")
    }

    // MARK: 通话立体声翻译 PCM 调试保存

    /// 开始保存通话立体声翻译解析出的上下行 PCM（调试用）
    func startCallTranslateStereoSave() {
        let dateStr = Date().getDateStr
        let dir = recordFilesDirectory

        let upPath = dir.appendingPathComponent("CallTranslateStereo_\(dateStr)_Up.wav").path
        let downPath = dir.appendingPathComponent("CallTranslateStereo_\(dateStr)_Down.wav").path

        stereoUpWavEncoder = JLPcmToWav(outputPath: upPath, sampleRate: 16000, numChannels: 1, bitsPerSample: 16)
        stereoDownWavEncoder = JLPcmToWav(outputPath: downPath, sampleRate: 16000, numChannels: 1, bitsPerSample: 16)

        JLLogManager.logLevel(.DEBUG, content: "Translate Log 立体声PCM保存开始 - 上行: \(upPath), 下行: \(downPath)")
    }

    /// 追加通话立体声翻译的上下行 PCM
    func appendCallTranslateStereoSavePcm(_ pcmData: Data, isUp: Bool) {
        let encoder = isUp ? stereoUpWavEncoder : stereoDownWavEncoder
        do {
            try encoder?.appendPCMData(pcmData)
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 立体声\(isUp ? "上行" : "下行")WAV编码错误: \(error.localizedDescription)")
        }
    }

    /// 结束保存通话立体声翻译 PCM
    func stopCallTranslateStereoSave() {
        do {
            try stereoUpWavEncoder?.finish()
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 立体声上行WAV完成编码错误: \(error.localizedDescription)")
        }
        do {
            try stereoDownWavEncoder?.finish()
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 立体声下行WAV完成编码错误: \(error.localizedDescription)")
        }
        stereoUpWavEncoder = nil
        stereoDownWavEncoder = nil
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 立体声PCM保存结束")
    }

    // MARK: 仅录音模式

    /// 保存仅录音解码后的 PCM 数据
    func saveOnlyRecordPcmData(_ data: Data) {
        if onlyRecordWavEncoder == nil {
            let dateStr = Date().getDateStr
            let wavPath = recordFilesDirectory.appendingPathComponent("OnlyRecord_\(dateStr).wav").path
            onlyRecordWavEncoder = JLPcmToWav(outputPath: wavPath, sampleRate: 16000, numChannels: 1, bitsPerSample: 16)
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 仅录音编码器延迟初始化: \(wavPath)")
        }

        JLLogManager.logLevel(.DEBUG, content: "Translate Log saveOnlyRecordPcmData 被调用，数据长度: \(data.count), isOnlyRecordSaving: \(isOnlyRecordSaving), encoder是否存在: \(onlyRecordWavEncoder != nil)")

        guard isOnlyRecordSaving else {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log isOnlyRecordSaving 为 false，数据不写入（但编码器已就绪）")
            return
        }
        guard let encoder = onlyRecordWavEncoder else {
            JLLogManager.logLevel(.WARN, content: "Translate Log 仅录音编码器为空，无法保存")
            return
        }
        do {
            try encoder.appendPCMData(data)
            JLLogManager.logLevel(.DEBUG, content: "Translate Log PCM 数据已写入 WAV，长度: \(data.count)")
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 仅录音 WAV 编码错误: \(error.localizedDescription)")
        }
    }

    /// 启动仅录音模式PCM保存
    func startOnlyRecordSave() {
        if onlyRecordWavEncoder == nil {
            let dateStr = Date().getDateStr
            let wavPath = recordFilesDirectory.appendingPathComponent("OnlyRecord_\(dateStr).wav").path
            onlyRecordWavEncoder = JLPcmToWav(outputPath: wavPath, sampleRate: 16000, numChannels: 1, bitsPerSample: 16)
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 仅录音保存已启动（新建编码器）: \(wavPath)")
        } else {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 仅录音保存已启动（使用已有编码器）")
        }
        isOnlyRecordSaving = true
    }

    /// 停止仅录音模式PCM保存
    func stopOnlyRecordSave() {
        isOnlyRecordSaving = false
        do {
            try onlyRecordWavEncoder?.finish()
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 仅录音WAV保存完成错误: \(error.localizedDescription)")
        }
        onlyRecordWavEncoder = nil
        if currentMode.modeType == .onlyRecord {
            fetchRecordFiles()
        }
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 仅录音保存已停止")
    }

    // MARK: 文件管理 (CRUD)

    /// 获取录音文件列表
    func fetchRecordFiles() {
        let dir = recordFilesDirectory
        do {
            let files = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey], options: .skipsHiddenFiles)
            let wavFiles = files.filter { $0.pathExtension == "wav" }
            var recordFileList: [CallRecordFile] = []
            for fileURL in wavFiles {
                let attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                let fileSize = (attrs[.size] as? UInt64) ?? 0
                let createDate = (attrs[.creationDate] as? Date) ?? Date()
                let sourceType = CallRecordSourceType.from(fileName: fileURL.lastPathComponent)
                let duration = TranslateTools.calculateDuration(dataBytes: Int(fileSize) - 44, sampleRate: 16000, bitDepth: 16, channels: 1)

                let recordFile = CallRecordFile(
                    url: fileURL,
                    name: fileURL.lastPathComponent,
                    size: fileSize,
                    createDate: createDate,
                    sourceType: sourceType,
                    duration: duration
                )
                recordFileList.append(recordFile)
            }
            recordFileList.sort { $0.createDate > $1.createDate }
            recordFiles.accept(recordFileList)
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 获取录音文件列表失败: \(error.localizedDescription)")
            recordFiles.accept([])
        }
    }

    /// 删除录音文件
    func deleteRecordFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            fetchRecordFiles()
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 删除录音文件: \(url.lastPathComponent)")
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 删除录音文件失败: \(error.localizedDescription)")
        }
    }

    /// 批量删除录音文件
    func deleteRecordFiles(at urls: [URL]) {
        var failedCount = 0
        for url in urls {
            do {
                try FileManager.default.removeItem(at: url)
                JLLogManager.logLevel(.DEBUG, content: "Translate Log 批量删除录音文件: (url.lastPathComponent)")
            } catch {
                failedCount += 1
                JLLogManager.logLevel(.ERROR, content: "Translate Log 批量删除录音文件失败: (url.lastPathComponent) - (error.localizedDescription)")
            }
        }
        fetchRecordFiles()
        if failedCount > 0 {
            JLLogManager.logLevel(.WARN, content: "Translate Log 批量删除完成，(failedCount)个文件删除失败")
        }
    }

    /// 播放录音文件
    func playRecordFile(at url: URL) {
        stopPlaying()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            playingFileURL = url
            audioPlayer?.play()
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 播放录音文件: \(url.lastPathComponent)")
        } catch {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 播放录音文件失败: \(error.localizedDescription)")
        }
    }

    /// 停止播放
    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
        playingFileURL = nil
    }

    // MARK: 面对面翻译（左耳+右耳）音频保存

    /// 启动面对面翻译（左耳+右耳）音频保存（WAV 路径和编码器已移入 SimultaneousTranslationProcessor 内部管理）
    func startSimultaneousWavRecord() {
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 面对面翻译（左耳+右耳） WAV 录音由 SimultaneousTranslationProcessor 内部管理")
    }

    /// 停止面对面翻译（左耳+右耳）音频保存（WAV 编码器已移入 SimultaneousTranslationProcessor 内部管理）
    func stopSimultaneousWavRecord() {
        fetchRecordFiles()
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 面对面翻译（左耳+右耳）录音结束，文件列表已刷新")
    }

    /// 追加主机面对面翻译（左耳+右耳） PCM 数据（已移入 SimultaneousTranslationProcessor 内部管理）
    func appendMasterSimultaneousPcm(_ pcmData: Data) {
        // 由 SimultaneousTranslationProcessor 内部处理
    }

    /// 追加从机面对面翻译（左耳+右耳） PCM 数据（已移入 SimultaneousTranslationProcessor 内部管理）
    func appendSlaveSimultaneousPcm(_ pcmData: Data) {
        // 由 SimultaneousTranslationProcessor 内部处理
    }

    // MARK: 面对面翻译（手机+耳机）

    func startPhoneFaceToFace() {
        guard phoneRecordState.value != .recording else { return }
        phoneRecordSource.accept(.user)
        phoneRecordState.accept(.entering)

        let isUseA2dp = translateHelper?.trIsPlayWithA2dp() ?? false
        let phoneSource = translateLanguage.0
        let phoneTarget = translateLanguage.1.first ?? .en

        facePhoneMgr = VolcesBusManager(.PCM, currentMode.dataType, phoneSource, [phoneTarget], isUseA2dp) { [weak self] status in
            guard let self = self else { return }
            if !status {
                self.phoneRecordState.accept(.error("手机端翻译服务初始化失败"))
                return
            }
            self.facePhoneMgr?.isSendSoon = true
            self.addObsFacePhoneData()
            self.facePhoneSide = CallTranslateSideModel(
                roleText: R.localStr.phoneSide(),
                sourceLanguage: phoneSource,
                targetLanguage: phoneTarget,
                manager: self.facePhoneMgr!
            )
            self.startPhoneMic()
            self.phoneRecordState.accept(.recording)
        }
    }

    func stopPhoneFaceToFace() {
        JLAudioRecoder.shared.stop()
        facePhoneMgr?.endTranslate()
        facePhoneMgr?.onDestory()
        facePhoneMgr = nil
        facePhoneSide?.dispose()
        facePhoneSide = nil
        facePhoneDataBag?.dispose()
        facePhoneDataBag = nil
        phoneRecordSource.accept(.none)
        phoneRecordState.accept(.idle)
    }

    private func startPhoneMic() {
        do {
            try JLAudioRecoder.shared.startRecording { [weak self] data in
                self?.facePhoneMgr?.startTranslatePcmData(data)
            }
        } catch {
            phoneRecordState.accept(.error(error.localizedDescription))
        }
    }

    func addObsFacePhoneData() {
        facePhoneDataBag?.dispose()
        facePhoneDataBag = facePhoneMgr?.targetData
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                let audio = JLTranslateAudio()
                audio.audioType = self.currentMode.dataType
                audio.sourceType = .typePhoneMic
                self.sendQueueStatus.accept(false)
                if self.writeWithoutResponse {
                    self.translateHelper?.trWriteAudioV2(audio, translate: data)
                } else {
                    self.translateHelper?.trWrite(audio, translate: data)
                }
            })
    }

    func startDeviceFaceToFace() {
        guard deviceRecordState.value != .recording else { return }
        deviceRecordSource.accept(.user)
        deviceRecordState.accept(.entering)

        prepareDeviceFaceToFacePipeline { [weak self] success in
            guard let self = self else { return }
            if !success {
                self.deviceRecordState.accept(.error("耳机端翻译服务初始化失败"))
                return
            }
            self.triggerDeviceRecording { ok in
                self.deviceRecordState.accept(ok ? .recording : .error("耳机端录音启动失败"))
            }
        }
    }

    func stopDeviceFaceToFace() {
        // 用户按钮停止时，无论是用户触发还是设备主动发起，都应下发停止录音命令
        if isRecordByDevice.value || isDeviceSpeak {
            isDeviceSpeak = false
            if let manager = BleManager.shared.currentCmdMgr {
                audioManager = JLDevAudioManager.share(self, withManager: manager)
                audioManager?.cmdStopRecord(manager, reason: .normal)
            }
        }
        isRecordByDevice.accept(false)
        faceDeviceMgr?.endTranslate()
        faceDeviceMgr?.onDestory()
        faceDeviceMgr = nil
        faceDeviceSide?.dispose()
        faceDeviceSide = nil
        faceDevicePcmBag?.dispose()
        faceDevicePcmBag = nil
        deviceRecordSource.accept(.none)
        deviceRecordState.accept(.idle)
    }

    func addObsFaceDeviceData() {
        faceDevicePcmBag?.dispose()
        faceDevicePcmBag = faceDeviceMgr?.targetPcmData
            .map { $0.0 }
            .filter { !$0.isEmpty }
            .subscribe(onNext: { pcm in
                JLAudioPlayer.shared.enqueuePCMData(pcm)
            })
    }

    private func prepareDeviceFaceToFacePipeline(_ completion: @escaping (Bool) -> Void) {
        let isUseA2dp = translateHelper?.trIsPlayWithA2dp() ?? false
        let deviceSource = translateLanguage.1.first ?? .en
        let deviceTarget = translateLanguage.0

        faceDeviceMgr = VolcesBusManager(.OPUS, currentMode.dataType, deviceSource, [deviceTarget], isUseA2dp) { [weak self] status in
            guard let self = self else { return }
            if !status {
                completion(false)
                return
            }
            self.faceDeviceMgr?.isSendSoon = false
            self.addObsFaceDeviceData()
            self.faceDeviceSide = CallTranslateSideModel(
                roleText: R.localStr.earbudSide(),
                sourceLanguage: deviceSource,
                targetLanguage: deviceTarget,
                manager: self.faceDeviceMgr!
            )
            completion(true)
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

    // MARK: 设备录音代理逻辑

    func handleDeviceRecordStart() {
        isRecordByDevice.accept(true)
        guard currentMode.modeType == .faceToFaceTranslate else { return }
        if deviceRecordSource.value == .user {
            return
        }
        deviceRecordSource.accept(.device)
        if faceDeviceMgr == nil {
            prepareDeviceFaceToFacePipeline { [weak self] success in
                self?.deviceRecordState.accept(success ? .recording : .error("耳机端翻译服务初始化失败"))
            }
        } else {
            deviceRecordState.accept(.recording)
        }
    }

    func handleDeviceRecordStop() {
        isRecordByDevice.accept(false)
        guard currentMode.modeType == .faceToFaceTranslate else { return }
        if deviceRecordSource.value == .user {
            return
        }
        deviceRecordSource.accept(.device)
        deviceRecordState.accept(.idle)
        faceDeviceMgr?.endTranslate()
        faceDeviceMgr?.onDestory()
        faceDeviceMgr = nil
        faceDeviceSide?.dispose()
        faceDeviceSide = nil
        faceDevicePcmBag?.dispose()
        faceDevicePcmBag = nil
        deviceRecordSource.accept(.none)
    }

    func handleDeviceRecordStatus(_ status: JL_SpeakType) {
        switch status {
        case .do:
            isRecordByDevice.accept(true)
        case .done:
            isRecordByDevice.accept(false)
            if currentMode.modeType == .faceToFaceTranslate {
                deviceRecordState.accept(.idle)
                faceDeviceMgr?.endTranslate()
                faceDeviceMgr?.onDestory()
                faceDeviceMgr = nil
                faceDeviceSide?.dispose()
                faceDeviceSide = nil
                faceDevicePcmBag?.dispose()
                faceDevicePcmBag = nil
                deviceRecordSource.accept(.none)
            } else {
                translateMgr?.endTranslate()
                translateMgr?.onDestory()
            }
        case .doing:
            break
        case .doneFail:
            isRecordByDevice.accept(false)
            if currentMode.modeType == .faceToFaceTranslate {
                deviceRecordState.accept(.idle)
                deviceRecordSource.accept(.none)
            }
        @unknown default:
            isRecordByDevice.accept(false)
        }
    }
}
