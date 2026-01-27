//
//  VolcesTranslateMgr.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/2.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JL_BLEKit
import JLLogHelper
import Starscream
import UIKit

enum TranslateLanguage: String {
    case zh
    case en
    case ja

    static func allLanguages() -> [TranslateLanguage] {
        return [.zh, .en, .ja]
    }

    static func commonLanguages() -> [TranslateLanguage] {
        return [.zh, .en]
    }
    
    func localizable() -> String {
        switch self {
        case .zh:
            return "zh"
        case .en:
            return "en"
        case .ja:
            return "ja"
        }
    }
}

class VolcesTranslateMgr: NSObject {
    var sourceType = TranslateLanguage.zh
    var targetType = [TranslateLanguage.en]
    var isConnected = false
    typealias ResultBlock = (SpeechTranslateResponse) -> Void
    private var socket: Starscream.WebSocket?
    private var resultBlock: ((Bool) -> Void)?
    private var responseBlock: ResultBlock?

    func start(_ sourceType: TranslateLanguage, _ targetType: [TranslateLanguage], _ resultBlock: @escaping ResultBlock, result: @escaping (Bool) -> Void) {
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
            JLLogManager.logLevel(.DEBUG, content: "translate websocket is not connected")
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
        isConnected = false
        socket?.disconnect()
    }

    private func config() -> String {
        return "{\"Configuration\": {\"SourceLanguage\": \"\(sourceType.rawValue)\",\"TargetLanguages\": [\(targetType.map { "\"\($0.rawValue)\"" }.joined(separator: ","))]}}"
    }
}

extension VolcesTranslateMgr: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case let .connected(headers):
            isConnected = true
            JLLogManager.logLevel(.WARN, content: "translate websocket is connected: \(headers)")
            socket?.write(string: config())
            resultBlock?(isConnected)
        case let .disconnected(reason, code):
            if code != 1000 {
                JLLogManager.logLevel(.WARN, content: "reconnect translate websocket is disconnected: \(reason) with code: \(code)")
                start(self.sourceType, self.targetType, self.responseBlock!){ st in
                    JLLogManager.logLevel(.DEBUG, content: "translate websocket is reconnected: \(st)")
                }
            }
            if code == 1000 {
                JLLogManager.logLevel(.WARN, content: "translate websocket is disconnected: \(reason) with code: \(code)")
            }
        case let .text(string):
            JLLogManager.logLevel(.WARN, content: "Received text: \(string)")
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
//            JLLogManager.logLevel(.ERROR, content: "Received binary data: \(data.map { String(format: "%02x", $0) }.joined())")
            if let response = try? JSONDecoder().decode(SpeechTranslateResponse.self, from: data) {
                responseBlock?(response)
            } else {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    if errorResponse.responseMetaData.error.code == kErrorCodeInternalError {
                        JLLogManager.logLevel(.ERROR, content: "volces Translate error: \(errorResponse.responseMetaData.error.message)")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kNotificationVolcesTranslateError"), object: nil)
                        }
                    }
                } catch {
                    JLLogManager.logLevel(.ERROR, content: "解析 JSON 失败,:\(data)")
                }
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
            JLLogManager.logLevel(.WARN, content: "translate websocket is cancelled")
        case let .error(error):
            isConnected = false
            JLLogManager.logLevel(.ERROR, content: "volces Translate error:\(String(describing: error))")
            resultBlock?(false)
        case .peerClosed:
            isConnected = false
        }
    }
}

// MARK: - 模型

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

//错误模型
// 错误响应模型

// 错误常量 -500
let kErrorCodeInternalError = "-500" //网络不稳定

struct ErrorResponse: Codable {
    let subtitle: String?
    let responseMetaData: ErrorResponseMetaData

    enum CodingKeys: String, CodingKey {
        case subtitle = "Subtitle"
        case responseMetaData = "ResponseMetaData"
    }
}

struct ErrorResponseMetaData: Codable {
    let requestId: String
    let action: String
    let version: String
    let service: String
    let region: String
    let error: ErrorDetail

    enum CodingKeys: String, CodingKey {
        case requestId = "RequestId"
        case action = "Action"
        case version = "Version"
        case service = "Service"
        case region = "Region"
        case error = "Error"
    }
}

struct ErrorDetail: Codable {
    let code: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case message = "Message"
    }
}
