//
//  TranslateVM+Delegate.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/20.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JL_BLEKit
import JLAudioUnitKit
import AVFoundation
import UIKit

// MARK: - 翻译管理代理

extension TranslateVM: JLTranslationManagerDelegate {
    func onInitSuccess(_: String) {}

    func onModeChange(_: String, mode: JLTranslateSetMode) {
        handleModeChange(mode)
    }

    func onReceiveAudioData(_: String, audioData data: JLTranslateAudio) {
        if simultaneousState.value == .working {
            handleMasterSimultaneousAudio(data)
            return
        }
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

// MARK: - 面对面翻译（左耳+右耳）代理

extension TranslateVM: JLTranslationManagerSimultaneousDelegate {
    func translationManager(_ manager: JLTranslationManager, simultaneousStateChanged state: Int) {
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 面对面翻译（左耳+右耳）状态变更: \(state)")
    }

    func translationManager(_ manager: JLTranslationManager, slaveDidReady slave: JLTranslateDeviceInfo) {
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 面对面翻译（左耳+右耳）从机已就绪: \(slave.uuid ?? "")")
        toastMessage.accept("从机已就绪")
    }

    func translationManager(_ manager: JLTranslationManager, slaveDidDisconnect slave: JLTranslateDeviceInfo, error: Error?) {
        let msg = "从机断开: \(error?.localizedDescription ?? "未知错误")"
        JLLogManager.logLevel(.ERROR, content: "Translate Log \(msg)")
        toastMessage.accept(msg)
    }

    func translationManager(_ manager: JLTranslationManager, didReceiveSlaveAudio audio: JLTranslateAudio) {
        JLLogManager.logLevel(.COMPLETE, content: "Translate Log 收到从机音频数据: sourceType=\(audio.sourceType.rawValue), 长度=\(audio.data.count)")
        handleSlaveSimultaneousAudio(audio)
    }

    func translationManager(_ manager: JLTranslationManager, simultaneousDidFail error: Error) {
        JLLogManager.logLevel(.ERROR, content: "Translate Log 面对面翻译（左耳+右耳）错误: \(error.localizedDescription)")
        toastMessage.accept("面对面翻译（左耳+右耳）错误: \(error.localizedDescription)")
        simultaneousState.accept(.error(error.localizedDescription))
    }
}

// MARK: - 设备音频管理代理

extension TranslateVM: JLDevAudioManagerDelegate {
    func devAudioManager(_ manager: JLDevAudioManager, audio data: Data) {}

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

// MARK: - 音频播放代理

extension TranslateVM: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playingFileURL = nil
        audioPlayer = nil
        JLLogManager.logLevel(.DEBUG, content: "Translate Log 录音播放完成")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        playingFileURL = nil
        audioPlayer = nil
        if let error = error {
            JLLogManager.logLevel(.ERROR, content: "Translate Log 录音播放解码错误: \(error.localizedDescription)")
        }
    }
}
