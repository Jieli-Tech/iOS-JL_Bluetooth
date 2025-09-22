//
//  VolcesTranslateMgr.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/2.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import Starscream
import UIKit

enum TranslateLanguage: String {
    case zh
    case en
    case ja
}

class VolcesTranslateMgr: NSObject {
    var sourceType = TranslateLanguage.zh
    var targetType = [TranslateLanguage.en]
    var isConnected = false
    typealias ResultBlock = (SpeechTranslateResponse) -> Void
    private var socket: WebSocket?
    private var resultBlock: ((Bool) -> Void)?
    private var responseBlock: ResultBlock?
    

    func start(_ sourceType: TranslateLanguage, _ targetType: [TranslateLanguage],_ resultBlock: @escaping ResultBlock, result: @escaping (Bool) -> Void) {
        self.sourceType = sourceType
        self.targetType = targetType
        self.resultBlock = result
        do {
            let url = try SpeechSigner.share.generateWebSocketURL()
            var req = URLRequest(url: URL(string: url)!)
            req.timeoutInterval = 10
            socket = WebSocket(request: req)
            socket?.connect()
            socket?.delegate = self
            responseBlock = resultBlock
        } catch {
            JLLogManager.logLevel(.ERROR, content: "生成websocket失败:\(error)")
            result(false)
        }
    }
    
    func changeLanguage(_ sourceType: TranslateLanguage, _ targetType: [TranslateLanguage]) {
        self.sourceType = sourceType
        self.targetType = targetType
        let str = config()
        socket?.write(string: str)
    }
    
    func sendAudioData(_ pcmData: Data) {
        if !isConnected {
            return
        }
        let pcmBase64 = pcmData.base64EncodedString()
        let str = "{\"AudioData\": \"\(pcmBase64)\"}"
        socket?.write(string: str)
    }
    
    func endAudioData() {
        if !isConnected {
            return
        }
        let str = "{\"End\": true}"
        socket?.write(string: str)
    }

    func stop() {
        if !isConnected {
            return
        }
        socket?.disconnect()
    }

    private func config() -> String {
        return "{\"Configuration\": {\"SourceLanguage\": \"\(sourceType.rawValue)\",\"TargetLanguages\": [\(targetType.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]}}"
    }
    
}

extension VolcesTranslateMgr: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client _: any Starscream.WebSocketClient) {
        switch event {
        case let .connected(headers):
            isConnected = true
            JLLogManager.logLevel(.INFO, content: "websocket is connected: \(headers)")
            socket?.write(string: config())
            resultBlock?(isConnected)
        case let .disconnected(reason, code):
            isConnected = false
            JLLogManager.logLevel(.INFO, content: "translate websocket is disconnected: \(reason) with code: \(code)")
        case let .text(string):
            JLLogManager.logLevel(.INFO, content: "Received text: \(string)")
            // 将 JSON 字符串转换为 Data 对象
            if let jsonData = string.data(using: .utf8) {
                do {
                    // 解析 JSON 数据到模型
                    let response = try JSONDecoder().decode(SpeechTranslateResponse.self, from: jsonData)
                    responseBlock?(response)
                } catch {
                    JLLogManager.logLevel(.ERROR, content: "解析 JSON 失败:\(error)")
                }
            }
        case let .binary(data):
            if let response = try? JSONDecoder().decode(SpeechTranslateResponse.self, from: data) {
                responseBlock?(response)
            } else {
                JLLogManager.logLevel(.ERROR, content: "解析 JSON 失败,:\(data.eHex)")
            }
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
            JLLogManager.logLevel(.ERROR, content: "volces Translate error:\(String(describing: error))")
            self.resultBlock?(false)
        case .peerClosed:
            break
        }
    }
}

struct SpeechTranslateResponse: Codable {
    let subtitle: Subtitle
    let responseMetaData: ResponseMetaData

    enum CodingKeys: String, CodingKey {
        case subtitle = "Subtitle"
        case responseMetaData = "ResponseMetaData"
    }
}

struct Subtitle: Codable {
    let text: String
    let beginTime: Int
    let endTime: Int
    let definite: Bool
    let language: String
    let sequence: Int

    enum CodingKeys: String, CodingKey {
        case text = "Text"
        case beginTime = "BeginTime"
        case endTime = "EndTime"
        case definite = "Definite"
        case language = "Language"
        case sequence = "Sequence"
    }
}

struct ResponseMetaData: Codable {
    let requestId: String
    let action: String
    let version: String
    let service: String
    let region: String

    enum CodingKeys: String, CodingKey {
        case requestId = "RequestId"
        case action = "Action"
        case version = "Version"
        case service = "Service"
        case region = "Region"
    }
}
