//
//  TranslateVM.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/25.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JLAudioUnitKit

class TranslateVM: NSObject {
   
    static let shared = TranslateVM()
    var targetData: BehaviorRelay<Data> = BehaviorRelay(value: Data())
    
    private var queueList:[TranslateQueue] = []
    private weak var translateHelper: JLTranslationManager?
    private let disposeBag = DisposeBag()
    private var tarnslateMgr:VolcesBusManager?
    private var isInitCfg = false
    private lazy var jlav2Packager: JLAV2Codec = {
        let packager = JLAV2Codec(delegate: self)
        return packager
    }()
    private lazy var opusPackager: JLOpusEncoder = {
        let packager = JLOpusEncoder(format: JLOpusFormat.defaultFormats(), delegate: self)
        return packager
    }()
    

    func input(data: JLTranslateAudio, _ mgr:JLTranslationManager) {
        translateHelper = mgr
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

    func clear() {
        queueList.removeAll()
        JLAudioRecoder.shared.stop()
        tarnslateMgr?.onDestory()
        translateHelper?.trDestory()
    }

    func configTranslate(_ audioType: JL_SpeakDataType, _ isUseA2dp:Bool, _ resultBlock: @escaping (Bool) -> Void) {
        tarnslateMgr = VolcesBusManager(audioType,.zh, [.en], isUseA2dp,{ [weak self] status in
            guard let self = self else { return }
            JLLogManager.logLevel(.COMPLETE, content: "初始化翻译状态:\(status)")
            if status {
                resultBlock(true)
                self.isInitCfg = true
                addObsTargetData()
            } else {
                resultBlock(false)
                self.isInitCfg = false
            }
        })
    }
    
    func sendOpusTest(_ data: Data) {
        if !isInitCfg {
            return
        }
        tarnslateMgr?.startTranslateData(data)
    }

    func startRecord(audioType: JL_SpeakDataType) {
        do {
            try JLAudioRecoder.shared.startRecording { [weak self] data in
                   guard let self = self else { return }
                   if audioType == .OPUS {
                       opusPackager.opusEncode(data)
                   } else if audioType == .JLA_V2 {
                       jlav2Packager.encode(data)
                   }
            }
            JLLogManager.logLevel(.DEBUG, content: "开始录音")
        } catch {
            JLLogManager.logLevel(.DEBUG, content: "开始录音失败:\(error.localizedDescription)")
        }
    }
    
    private func addObsTargetData(){
        tarnslateMgr?.targetData.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            targetData.accept(data)
        }).disposed(by: disposeBag)
    }

}

extension TranslateVM: JLAV2CodecDelegate {
    func encodecData(_ data: Data?, error: (any Error)?) {
        guard let data = data else { return }
        targetData.accept(data)
    }
}

extension TranslateVM: JLOpusEncoderDelegate {
    func opusEncoder(_ encoder: JLOpusEncoder, data: Data?, error: (any Error)?) {
        guard let data = data else { return }
        targetData.accept(data)
    }
}
