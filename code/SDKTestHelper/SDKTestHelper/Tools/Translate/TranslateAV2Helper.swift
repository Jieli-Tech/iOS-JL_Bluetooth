//
//  TranslateAV2Helper.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/14.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit


class TranslateAV2Helper: NSObject , TranslateDeEncodePtl {
   
    private var codecManager: JLAV2Codec?
    private var pcmResultBlock: ((Data) -> Void)?
    private var av2ResultBlock: ((Data) -> Void)?
    
    required init(_ pcmResultBlock: @escaping (Data) -> Void, _ opusResultBlock: @escaping (Data) -> Void) {
        super.init()
        self.pcmResultBlock = pcmResultBlock
        self.av2ResultBlock = opusResultBlock
        codecManager = JLAV2Codec(delegate: self)
        let info = JLAV2CodeInfo.default()
        codecManager?.createDecode(info)
        codecManager?.createEncode(info)
    }
    
    
    func pcmToEnCodeData(_ pcmData: Data) {
        codecManager?.encode(pcmData)
    }
    
    func decodeDataToPcm(_ decodeData: Data) {
        codecManager?.decode(decodeData)
    }
    
    func onDestory() {
        codecManager?.destoryDecode()
        codecManager?.destoryEncode()
    }
    

}

extension TranslateAV2Helper: JLAV2CodecDelegate {
    
    func decodecData(_ data: Data?, error: (any Error)?) {
        if error != nil {
            //JLLogManager.logLevel(.ERROR, content: "opusDecoder error:\(String(describing: error))")
            return
        }
        guard let data = data else { return }
        pcmResultBlock?(data)
    }
    func encodecData(_ data: Data?, error: (any Error)?) {
        if error != nil {
            JLLogManager.logLevel(.ERROR, content: "opusDecoder error:\(String(describing: error))")
            return
        }
        guard let data = data else { return }
        av2ResultBlock?(data)
    }
    
}
