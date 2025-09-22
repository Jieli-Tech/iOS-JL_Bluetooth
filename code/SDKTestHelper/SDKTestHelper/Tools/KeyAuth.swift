//
//  KeyAuth.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/8.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class KeyAuth {
    struct ByteDance {
        /// 火山大模型机器翻译Key
        static let accessKeyId = SettingInfo.getByteDanceAccessKey()
        /// 火山大模型机器翻译密钥
        static let secretAccessKey = SettingInfo.getByteDanceSecretKey()
        /// 火山大模型 tts AppId
        static let appid = SettingInfo.getByteDanceAppId()
        /// 火山大模型 tts Token
        static let accessToken = SettingInfo.getByteDanceAccessToken()
        /// 火山大模型 tts Secret
        static let secretKey = SettingInfo.getByteDanceSecret()
    }
}
