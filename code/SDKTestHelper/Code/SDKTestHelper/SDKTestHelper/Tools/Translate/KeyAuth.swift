//
//  KeyAuth.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/8.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import CryptoKit

/// AI 密钥授权工具类：负责 Doubao 等平台的授权信息解析、存取与校验
class KeyAuth {
    /// 抖音系授权AES信息(一般发布时会使用脚本生成另一个）
    static let saveSecretKey = "YT19f-A1lWr5nmE7BYpsFy39VBccawiE"
    /// 抖音系授权信息结构体：包括翻译与 TTS 所需的关键字段，以及有效期与更新时间
    struct ByteDance {
        let accessKeyId: String
        let secretAccessKey: String
        let appid: String
        let accessToken: String
        let secretKey: String
        let updateTime: Int64
        let validity: Int64
        
        init(
            accessKeyId: String,
            secretAccessKey: String,
            appid: String,
            accessToken: String,
            secretKey: String,
            updateTime: Int64 = 0,
            validity: Int64 = 7 * 24 * 3600
        ) {
            self.accessKeyId = accessKeyId
            self.secretAccessKey = secretAccessKey
            self.appid = appid
            self.accessToken = accessToken
            self.secretKey = secretKey
            self.updateTime = updateTime
            self.validity = validity
            if self.isInvalid() {
                save()
            }
        }
        
        func save() {
            let authString = toString()
            let key = KeyAuth.saveSecretKey.data(using: .utf8)!
            let keySec = SymmetricKey(data: key)
            guard let data = authString.data(using: .utf8) else {
                JLLogManager.logLevel(.ERROR, content: "ai_auth_key save -> string to data failed")
                return
            }
            do {
                let encrypted = try AES.GCM.seal(data, using: keySec)
                guard let combined = encrypted.combined else {
                    JLLogManager.logLevel(.ERROR, content: "ai_auth_key save -> combined nil")
                    return
                }
                let path = _R.path.document + "/ai_auth_key"
                try combined.write(to: URL(fileURLWithPath: path))
                JLLogManager.logLevel(.INFO, content: "ai_auth_key save success")
            } catch {
                JLLogManager.logLevel(.ERROR, content: "ai_auth_key save -> seal error: \(error)")
            }
        }
        
        static func getAiAuth() -> ByteDance? {
            let path = _R.path.document + "/ai_auth_key"
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            guard let data else {
                JLLogManager.logLevel(.ERROR, content: "getAiAuth -> not found")
                return nil
            }
            let key = KeyAuth.saveSecretKey.data(using: .utf8)!
            let keySec = SymmetricKey(data: key)
            guard let sealedBox = try? AES.GCM.SealedBox(combined: data) else {
                JLLogManager.logLevel(.ERROR, content: "getAiAuth -> parse error")
                return nil
            }
            guard let decrypted = try? AES.GCM.open(sealedBox, using: keySec) else {
                JLLogManager.logLevel(.ERROR, content: "getAiAuth -> decrypt error")
                return nil
            }
            guard let result = String(data: decrypted, encoding: .utf8) else {
                JLLogManager.logLevel(.ERROR, content: "getAiAuth -> parse error")
                return nil
            }
            JLLogManager.logLevel(.INFO, content: "getAiAuth -> success")
            let auth = ByteDance.parse(from: result)
            return auth
        }
        
        static private func parse(from string: String) -> ByteDance {
            var dict: [String: String] = [:]
            for pair in string.split(separator: "&") {
                let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
                if parts.count == 2 {
                    dict[parts[0]] = parts[1]
                }
            }
            let accessKeyId = dict["accessKeyId"] ?? ""
            let secretAccessKey = dict["secretAccessKey"] ?? ""
            let appid = dict["appid"] ?? ""
            let accessToken = dict["accessToken"] ?? ""
            let secretKey = dict["secretKey"] ?? ""
            let updateTime = Int64(dict["updateTime"] ?? "0") ?? 0
            let validity = Int64(dict["validity"] ?? "0") ?? 7 * 24 * 3600
            return ByteDance(accessKeyId: accessKeyId, secretAccessKey: secretAccessKey, appid: appid, accessToken: accessToken, secretKey: secretKey, updateTime: updateTime, validity: validity)
        }

        func isInvalid() -> Bool {
            let validityTime = updateTime + validity * 1000
            let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
            let result = currentTime <= validityTime
            JLLogManager.logLevel(.INFO, content: "aiAuth isInvalid -> \(result)")
            return result
        }
        
        private func toString() -> String {
            return "accessKeyId=\(accessKeyId)&secretAccessKey=\(secretAccessKey)&appid=\(appid)&accessToken=\(accessToken)&secretKey=\(secretKey)&updateTime=\(updateTime)&validity=\(validity)"
        }
    }
    
    static func makeAuth(_ basic64: String) -> KeyAuth.ByteDance {
        let empty = ByteDance(accessKeyId: "", secretAccessKey: "", appid: "", accessToken: "", secretKey: "")
        guard let decoded = Data(base64Encoded: basic64, options: .ignoreUnknownCharacters),
              let jsonString = String(data: decoded, encoding: .utf8),
              let jsonData = jsonString.data(using: .utf8) else {
            JLLogManager.logLevel(.ERROR, content: "makeAuth -> base64 decode failed")
            return empty
        }
        do {
            let obj = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let dict = obj as? [String: Any] else {
                JLLogManager.logLevel(.ERROR, content: "makeAuth -> top-level JSON not dict")
                return empty
            }
            let translationStr = dict["translation"] as? String ?? ""
            let ttsStr = dict["tts"] as? String ?? ""
            var updateTime: Int64 = 0
            if let ut = dict["updateTime"] as? NSNumber {
                updateTime = ut.int64Value
            } else if let utStr = dict["updateTime"] as? String, let utVal = Int64(utStr) {
                updateTime = utVal
            } else {
                updateTime = Int64(Date().timeIntervalSince1970 * 1000)
            }
            var validity: Int64 = 7 * 24 * 3600
            if let v = dict["validity"] as? NSNumber {
                validity = v.int64Value
            } else if let vStr = dict["validity"] as? String, let vVal = Int64(vStr) {
                validity = vVal
            }
            var accessKeyId = ""
            var secretAccessKey = ""
            var appid = ""
            var accessToken = ""
            var secretKey = ""
            if let tData = translationStr.data(using: .utf8),
               let tObj = try? JSONSerialization.jsonObject(with: tData, options: []),
               let tDict = tObj as? [String: Any] {
                accessKeyId = tDict["accessKey"] as? String ?? ""
                secretAccessKey = tDict["secretKey"] as? String ?? ""
            }
            if let sData = ttsStr.data(using: .utf8),
               let sObj = try? JSONSerialization.jsonObject(with: sData, options: []),
               let sDict = sObj as? [String: Any] {
                appid = sDict["appId"] as? String ?? ""
                accessToken = sDict["accessToken"] as? String ?? ""
                secretKey = sDict["secretKey"] as? String ?? ""
            }
            JLLogManager.logLevel(.INFO, content: "makeAuth -> decode success")
            return ByteDance(accessKeyId: accessKeyId, secretAccessKey: secretAccessKey, appid: appid, accessToken: accessToken, secretKey: secretKey, updateTime: updateTime, validity: validity)
        } catch {
            JLLogManager.logLevel(.ERROR, content: "makeAuth -> parse error: \(error)")
            return empty
        }
    }
}
