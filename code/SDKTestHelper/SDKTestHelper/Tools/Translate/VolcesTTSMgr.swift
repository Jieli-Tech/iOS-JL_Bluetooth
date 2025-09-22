//
//  VolcesTTSMgr.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/3.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import Starscream
import UIKit

enum explicitLanguage: String {
    /// 自动,默认中英
    case auto
    /// 启用多语种前端（包含zh/en/ja/es-ms/id/pt-br）
    case cross = "crosslingual"
    /// 中文
    case zh
    /// 英文
    case en
    /// 日文
    case ja
    /// 墨西哥
    case esMx = "es-mx"
    /// 印尼
    case id
    /// 巴西 葡萄牙
    case ptBr = "pt-br"
}

class VolcesTTSMgr: NSObject {
    var isConnected = false
    private let appid = KeyAuth.ByteDance.appid
    private let accessToken = KeyAuth.ByteDance.accessToken
    private let secretKey = KeyAuth.ByteDance.secretKey
    private let wssUrl = "wss://openspeech.bytedance.com/api/v1/tts/ws_binary"
    private var socket: WebSocket?
    private var resultBlock: ((Bool) -> Void)?
    typealias ResultBlock = (Data, Bool) -> Void
    private var responseBlock: ResultBlock?
    

    func start(_ completion: @escaping (Bool) -> Void, _ responseBlock: @escaping ResultBlock) {
        if isConnected {
            completion(isConnected)
            return
        }
        resultBlock = completion
        var request = URLRequest(url: URL(string: wssUrl)!)
        request.timeoutInterval = 10
        request.setValue("Bearer;\(accessToken)", forHTTPHeaderField: "Authorization")
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
        self.responseBlock = responseBlock
    }

    func stop() {
        if !isConnected {
            return
        }
        socket?.disconnect()
    }
    
    func sendText(_ text: String) {
        if !isConnected {
            return
        }
        let data = msgFormat(text)
        JLLogManager.logLevel(.DEBUG, content: "发送语音:\(text),data:\(data.eHex)")
        socket?.write(data: data)
    }

    private func msgFormat(_ text: String) -> Data {
        var targetDict = [String: Any]()
        let appDict = ["appid": appid, "token": secretKey, "cluster": "volcano_tts"]
        targetDict.updateValue(appDict, forKey: "app")
        let user = ["uid": "Jieli_iOS_req"]
        targetDict.updateValue(user, forKey: "user")
        let audioDict: [String: Any] = ["voice_type": "zh_male_beijingxiaoye_emo_v2_mars_bigtts", "rate": 16000, "BitRate": 16, "encoding": "pcm"]
        targetDict.updateValue(audioDict, forKey: "audio")
        let requestDict = ["reqid": NSUUID().uuidString, "text": text, "operation": "submit"]
        targetDict.updateValue(requestDict, forKey: "request")
        let targetData = try! JSONSerialization.data(withJSONObject: targetDict, options: .withoutEscapingSlashes)
        let jsonStr = String(data: targetData, encoding: .utf8)!
        let data = TTsDataSource().jsonToData(json: jsonStr)
        return data
    }
}

extension VolcesTTSMgr: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client _: any Starscream.WebSocketClient) {
        switch event {
        case let .connected(headers):
            isConnected = true
            JLLogManager.logLevel(.INFO, content: "websocket is connected: \(headers)")
            resultBlock?(isConnected)
        case let .disconnected(reason, code):
            isConnected = false
            JLLogManager.logLevel(.INFO, content: "tts websocket is disconnected: \(reason) with code: \(code)")
        case let .text(string):
            JLLogManager.logLevel(.INFO, content: "Received text: \(string)")
        case let .binary(data):
            guard let resp = TTsDataSource.initData(data) else { return }
            responseBlock?(resp.payload, resp.sequenceNumber < 0)
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            isConnected = false
        case let .error(error):
            isConnected = false
            JLLogManager.logLevel(.ERROR, content: "error:\(String(describing: error))")
        case .peerClosed:
            break
        }
    }
}


class TTsDataSource: NSObject {
    // ptl version 0x01
    var ptlVersion: UInt8 = 0x01
    // header size
    // header 实际大小是 header size value x 4 bytes.
    // 这里有个特殊值 0b1111 表示 header 大小大于或等于 60(15 x 4 bytes)，也就是会存在 header extension 字段。
    var headerSize: UInt8 = 0x01
    // msg type 消息类型
    // 0b0001 - full client request.
    var msgType: UInt8 = 0x01
    // msg type specific flag 含义取决于消息类型。
    var msgTypeSpecificFlag: UInt8 = 0x00
    // msg serialization method
    // 0b0001 -- JSON
    var msgSerializationMethod: UInt8 = 0x01
    // msg compress method 定义 payload 的压缩方法。
    // 0b0000 - 无压缩
    var msgCompressMethod: UInt8 = 0x00
    var reserved: UInt8 = 0
    
    var sequenceNumber: Int32 = 0
    var payload: Data = Data()
    var errorCode: Int32 = 0
    var errorMessage: String = ""
    
    var json: String = ""
    
    var data: Data {
        let byte0 = ptlVersion << 4 | headerSize
        let byte1 = msgType << 4 | msgTypeSpecificFlag
        let byte2 = msgSerializationMethod << 4 | msgCompressMethod
        let data = Data([byte0, byte1, byte2, reserved])
        return data
    }
    
    func jsonToData(json: String) -> Data {
        let jsonData = json.data(using: .utf8)!
        let length:UInt32 = UInt32(jsonData.count)
        return data + length.byteSwapped.data + jsonData
    }
    
    // 新增解析需要的属性
    
    
    static func initData(_ data: Data) -> TTsDataSource? {
        let instance = TTsDataSource()
        
        // 确保至少有 4 字节的 header
        guard data.count >= 4 else {
            JLLogManager.logLevel(.INFO, content: "数据长度不足，无法解析 header")
            return nil
        }
        
        // 解析前 4 字节的 header
        let byte0 = data[0]
        instance.ptlVersion = (byte0 & 0xF0) >> 4 // 高4位
        instance.headerSize = byte0 & 0x0F        // 低4位
        
        let byte1 = data[1]
        instance.msgType = (byte1 & 0xF0) >> 4    // 高4位
        instance.msgTypeSpecificFlag = byte1 & 0x0F // 低4位
        
        let byte2 = data[2]
        instance.msgSerializationMethod = (byte2 & 0xF0) >> 4
        instance.msgCompressMethod = byte2 & 0x0F
        
        instance.reserved = data[3]
        
        // 计算 payload 起始位置（headerSize * 4）
        let headerLength = Int(instance.headerSize) * 4
        guard data.count >= headerLength else {
            JLLogManager.logLevel(.INFO, content: "数据长度不足，无法解析 payload")
            return nil
        }
        
        var offset = 4 // 前4字节已解析
        
        // 处理不同类型消息
        switch instance.msgType {
        case 11: // 音频响应
            if instance.msgTypeSpecificFlag != 0 {
                // 读取 sequenceNumber (4 bytes)
                guard offset + 4 <= data.count else { return nil }
                instance.sequenceNumber = data.subdata(in: offset..<offset+4).withUnsafeBytes { $0.load(as: Int32.self).bigEndian }
                offset += 4
                
                // 读取 payloadSize (4 bytes)
                guard offset + 4 <= data.count else { return nil }
                let payloadSize = data.subdata(in: offset..<offset+4).withUnsafeBytes { $0.load(as: Int32.self).bigEndian }
                offset += 4
                
                // 读取 payload
                guard offset + Int(payloadSize) <= data.count else { return nil }
                instance.payload = data.subdata(in: offset..<offset+Int(payloadSize))
                offset += Int(payloadSize)
                
                if instance.sequenceNumber < 0 {
                    JLLogManager.logLevel(.INFO, content: "收到最后一个音频分段")
                }
            }
            
        case 15: // 错误消息
            // 读取错误码 (4 bytes)
            guard offset + 4 <= data.count else { return nil }
            instance.errorCode = data.subdata(in: offset..<offset+4).withUnsafeBytes { $0.load(as: Int32.self).bigEndian }
            offset += 4
            
            // 读取错误消息长度 (4 bytes)
            guard offset + 4 <= data.count else { return nil }
            let messageLength = data.subdata(in: offset..<offset+4).withUnsafeBytes { $0.load(as: Int32.self).bigEndian }
            offset += 4
            
            // 读取错误消息内容
            guard offset + Int(messageLength) <= data.count else { return nil }
            if let message = String(data: data.subdata(in: offset..<offset+Int(messageLength)), encoding: .utf8) {
                instance.errorMessage = message
            }
            offset += Int(messageLength)
            
        default:
            JLLogManager.logLevel(.INFO, content: "未知消息类型: \(instance.msgType)")
            return nil
        }
        
        return instance
    }

}
