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
    init(_ pcmResultBlock: @escaping (Data) -> Void, _ opusResultBlock: @escaping (Data) -> Void, _ pcmLRResultBlock: ((_ left:Data?, _ right:Data?) -> Void)?)
    func pcmToEnCodeData(_ pcmData: Data)
    func decodeDataToPcm(_ decodeData: Data)
    func onDestory()
}

class TranslateOpusHelper: NSObject, TranslateDeEncodePtl {
    private var opusToPcm: JLOpusDecoder?
    private var pcmToOpus: JLOpusEncoder?
    private var pcmResultBlock: ((Data) -> Void)?
    private var opusResultBlock: ((Data) -> Void)?
    private var pcmLRResultBlock: ((_ left:Data?, _ right:Data?) -> Void)?

    required init(_ pcmResultBlock: @escaping (Data) -> Void, _ opusResultBlock: @escaping (Data) -> Void, _ pcmLRResultBlock: ((_ left:Data?, _ right:Data?) -> Void)? = nil) {
        super.init()
        self.pcmResultBlock = pcmResultBlock
        self.opusResultBlock = opusResultBlock
        self.pcmLRResultBlock = pcmLRResultBlock
        let ops = JLOpusFormat.defaultFormats()
        ops.hasDataHeader = false
        opusToPcm = JLOpusDecoder(decoder: ops, delegate: self)
        pcmToOpus = JLOpusEncoder(format: JLOpusEncodeConfig.default(), delegate: self)
        JLLogManager.logLevel(.DEBUG, content: "opus encoder init")
    }
    
    func resetDecoderByFormat(_ format: JLOpusFormat) {
        opusToPcm?.opusOnRelease()
        opusToPcm = JLOpusDecoder(decoder: format, delegate: self)
    }
    
    func resetEncoderByFormat(_ format: JLOpusEncodeConfig) {
        pcmToOpus?.opusOnRelease()
        pcmToOpus = JLOpusEncoder(format: format, delegate: self)
    }

    func pcmToEnCodeData(_ pcmData: Data) {
        JLLogManager.logLevel(.DEBUG, content: "TranslateOpusHelper pcmToEnCodeData: input=\(pcmData.count) bytes, encoder=\(pcmToOpus != nil ? "exist" : "NIL")")
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
    func opusDecoder(_: JLOpusDecoder, data: Data?, error: (any Error)?) {
        if error != nil {
            JLLogManager.logLevel(.ERROR, content: "Translate Log opusDecoder error:\(String(describing: error))")
            return
        }
        guard let data = data else {
            JLLogManager.logLevel(.WARN, content: "Translate Log opusDecoder data 为 nil")
            return
        }
        JLLogManager.logLevel(.DEBUG, content: "Translate Log opusDecoder 单声道回调，数据长度: \(data.count)")
        pcmResultBlock?(data)
    }
    func opusDecoderStereo(_ decoder: JLOpusDecoder, left: Data?, right: Data?, error: (any Error)?) {
        if error != nil {
            JLLogManager.logLevel(.ERROR, content: "Translate Log opusDecoderStereo error:\(String(describing: error))")
            return
        }
        JLLogManager.logLevel(.DEBUG, content: "Translate Log opusDecoderStereo 回调，left: \(left?.count ?? 0), right: \(right?.count ?? 0)")
        pcmLRResultBlock?(left, right)
    }

}

extension TranslateOpusHelper: JLOpusEncoderDelegate {
    func opusEncoder(_: JLOpusEncoder, data: Data?, error: (any Error)?) {
        if error != nil {
            JLLogManager.logLevel(.ERROR, content: "opusEncoder error:\(String(describing: error))")
            return
        }
        guard let data = data else {
            JLLogManager.logLevel(.WARN, content: "opusEncoder callback: data is nil")
            return
        }
        JLLogManager.logLevel(.COMPLETE, content: "opusEncoder callback: output=\(data.count) bytes → opusResultBlock")
        opusResultBlock?(data)
    }
}
