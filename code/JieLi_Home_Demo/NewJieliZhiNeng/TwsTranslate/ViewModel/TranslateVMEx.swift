//
//  TranslateVMEx.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/20.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JLAudioUnitKit
import JL_BLEKit

// MARK: - 编解码协议实现
extension TranslateVM: JLAV2CodecDelegate {
    func encodecData(_ data: Data?, error: (any Error)?) {
        guard let data = data else { return }
        targetData.accept(data)
        callBackDataToDevice(data: data)
    }
}

extension TranslateVM: JLOpusEncoderDelegate {
    func opusEncoder(_ encoder: JLOpusEncoder, data: Data?, error: (any Error)?) {
        guard let data = data else { return }
        targetData.accept(data)
        callBackDataToDevice(data: data)
    }
}


extension TranslateVM : JLTranslationManagerDelegate {
    func onInitSuccess(_: String) {
    }
    func onModeChange(_: String, mode: JLTranslateSetMode) {
        currentMode = mode
        subjectCurrentMode.accept(mode)
        JLLogManager.logLevel(.DEBUG, content: "modeType:\(String(describing: mode.modeType))")
        
        //录音翻译模式
        if mode.modeType == .recordTranslate {
            if self.translateHelper?.recordtype == .byDevice {
                if isLocal {
                    return
                }
                let isUseA2dp = self.translateHelper?.trIsPlayWithA2dp() ?? false
               configTranslate(currentMode.dataType, isUseA2dp, currentMode.dataType) { [weak self] state in
                    guard let self = self else { return }
                    addObsTranslateData()
                }
            }
            
            if self.translateHelper?.recordtype == .byPhone {
                audioData = JLTranslateAudio()
                audioData?.audioType = mode.dataType
                audioData?.sourceType = .typePhoneMic
                startRecord(audioType: mode.dataType)
                if isLocal {
                    return
                }
                configTranslate(.PCM,false, currentMode.dataType) { [weak self] state in
                    guard let self = self else { return }
                    addObsTranslateData()
                }
            }
        }
        // 通话翻译模式
        if mode.modeType == .callTranslate {
            if isLocal {
                return
            }
            configTranslateCall(currentMode.dataType) { [weak self] state in
                guard let self = self else { return }
                addObsTranslateData()
                addObsCallTranslateData()
            }
        }
        //音频模式
        if mode.modeType == .audioTranslate {
            recordAndPlay()
            if isLocal {
                return
            }
            configTranslate(currentMode.dataType, true, currentMode.dataType) { _ in
            }
        }
        // 仅录音
        if mode.modeType == .onlyRecord {
            pareparRecordOnly(currentMode.dataType)
        }
        // 面对面翻译
        if mode.modeType == .faceToFaceTranslate {
            // TODO: 面对面翻译
        }
        
        if (mode.modeType == .idle) {
            translateMgr?.onDestory()
            callTranslateMgr?.onDestory()
            JLAudioPlayer.shared.stop()
            JLAudioRecoder.shared.stop()
        }
        
    }
    
    func onReceiveAudioData(_: String, audioData data: JLTranslateAudio) {
        JLLogManager.logLevel(.COMPLETE, content: "收到翻译音频数据")
        let mode = currentMode
        audioData = data
        if mode.modeType == .recordTranslate {
            // TODO: 翻译后再处理数据
            // 赋值记录当前设备原语音数据信息，用于数据回传，若果为仅录音模式，则可以不需要此记录
            // 将翻译好的数据传给设备，这里未将数据进行翻译
            // 后续可以进行翻译，这里需要将翻译后的数据压缩成 OPUS 后才能传入
            //                JLLogManager.logLevel(.COMPLETE, content: "收到翻译音频数据:\(data.sourceType)")
            if mode.dataType == .OPUS {
                if isLocal {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: DispatchWorkItem(block: { [weak self] in
                        guard let self = self else { return }
                        if writeWithoutResponse {
                            translateHelper?.trWriteAudioV2(data, translate: data.data)
                        }else{
                            translateHelper?.trWrite(data, translate: data.data)
                        }
                    }))
                    return
                }
                input(data: data)
            }
        }
        if mode.modeType == .onlyRecord {
            // TODO: 存储录音数据
            input(data: data)
        }
        if mode.modeType == .callTranslate {
            // TODO: 翻译后再处理数据
            // 赋值记录当前设备原语音数据信息，用于数据回传，若果为仅录音模式，则可以不需要此记录
            if !isLocal {
                input(data: data)
            }else{
                callTranslateSendBack(data: data)
            }
        }
        if mode.modeType == .audioTranslate {
            if isLocal { return }
            input(data: data)
        }
    }
    
    
    func onError(_: String, error err: any Error) {
        JLLogManager.logLevel(.ERROR, content: "error:\(String(describing: err))")
        contextVC?.view.makeToast("error:\(String(describing: err))", position: .center)
    }
}
