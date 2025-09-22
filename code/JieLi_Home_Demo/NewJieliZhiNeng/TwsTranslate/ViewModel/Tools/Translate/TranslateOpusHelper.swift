//
//  TranslateOpusHelper.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/7.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JLAudioUnitKit
import UIKit

protocol TranslateDeEncodePtl {
    init(_ pcmResultBlock: @escaping (Data) -> Void, _ opusResultBlock: @escaping (Data) -> Void)
    func pcmToEnCodeData(_ pcmData: Data)
    func decodeDataToPcm(_ decodeData: Data)
    func onDestory()
}

class TranslateOpusHelper: NSObject,TranslateDeEncodePtl {
    private var opusToPcm: JLOpusDecoder?
    private var pcmToOpus: JLOpusEncoder?
    private var pcmResultBlock: ((Data) -> Void)?
    private var opusResultBlock: ((Data) -> Void)?
    
    required init(_ pcmResultBlock: @escaping (Data) -> Void, _ opusResultBlock: @escaping (Data) -> Void) {
        super.init()
        self.pcmResultBlock = pcmResultBlock
        self.opusResultBlock = opusResultBlock
        let ops = JLOpusFormat.defaultFormats()
        ops.hasDataHeader = false
        opusToPcm = JLOpusDecoder(decoder: ops, delegate: self)
        pcmToOpus = JLOpusEncoder(format: ops, delegate: self)
    }
    
    func pcmToEnCodeData(_ pcmData: Data) {
        pcmToOpus?.opusEncode(pcmData)
    }
    
    func decodeDataToPcm(_ opusData: Data) {
        opusToPcm?.opusDecoderInputData(opusData)
    }
    
    func onDestory() {
        opusToPcm?.opusOnRelease()
        pcmToOpus?.opusOnRelease()
        opusToPcm = nil
        pcmToOpus = nil
    }
}

extension TranslateOpusHelper: JLOpusDecoderDelegate {
    func opusDecoder(_ decoder: JLOpusDecoder, data: Data?, error: (any Error)?) {
        if error != nil {
            JLLogManager.logLevel(.ERROR, content: "opusDecoder error:\(String(describing: error))")
            return
        }
        guard let data = data else { return }
        pcmResultBlock?(data)
//        JLLogManager.logLevel(.INFO, content: "opusDecoder data:\(data.count)")
    }
}

extension TranslateOpusHelper: JLOpusEncoderDelegate {
    func opusEncoder(_ encoder: JLOpusEncoder, data: Data?, error: (any Error)?) {
        if error != nil {
            JLLogManager.logLevel(.ERROR, content: "opusEncoder error:\(String(describing: error))")
            return
        }
        guard let data = data else { return }
        opusResultBlock?(data)
//        JLLogManager.logLevel(.INFO, content: "opusEncoder data:\(data.count)")
    }
}
