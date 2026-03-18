//
//  TranslateVMEx.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/20.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JL_BLEKit
import JLAudioUnitKit
import UIKit

// MARK: - 编解码协议实现

extension TranslateVM: JLAV2CodecDelegate {
    func encodecData(_ data: Data?, error _: (any Error)?) {
        guard let data = data else { return }
        callBackDataToDevice(data: data)
    }
}

extension TranslateVM: JLOpusEncoderDelegate {
    func opusEncoder(_: JLOpusEncoder, data: Data?, error _: (any Error)?) {
        guard let data = data else { return }
        callBackDataToDevice(data: data)
    }
}

// MARK: - 翻译管理代理

extension TranslateVM: JLTranslationManagerDelegate {
    func onInitSuccess(_: String) {}

    func onModeChange(_: String, mode: JLTranslateSetMode) {
        handleModeChange(mode)
    }

    func onReceiveAudioData(_: String, audioData data: JLTranslateAudio) {
        handleReceivedAudioData(data)
    }

    func onError(_: String, error err: any Error) {
        let errorMsg = "error:\(String(describing: err))"
        JLLogManager.logLevel(.ERROR, content: errorMsg)
        toastMessage.accept(errorMsg)
    }

    func onSendAudioQueueOver(_: String) {
        sendQueueStatus.accept(true)
        JLLogManager.logLevel(.DEBUG, content: "Translate Log Send Queue Over")
    }
}

// MARK: - 设备音频管理代理

extension TranslateVM: JLDevAudioManagerDelegate {
    func devAudioManager(_ manager: JLDevAudioManager, audio data: Data) {
        // 原实现为空，暂不需要处理设备传来的原始音频
    }

    func devAudioManager(_: JLDevAudioManager, startByDeviceWithParam _: JLRecordParams) {
        handleDeviceRecordStart()
    }

    func devAudioManager(_: JLDevAudioManager, stopByDeviceWithParam _: JLSpeechRecognition) {
        handleDeviceRecordStop()
    }

    func devAudioManager(_: JLDevAudioManager, status: JL_SpeakType) {
        handleDeviceRecordStatus(status)
    }
}
