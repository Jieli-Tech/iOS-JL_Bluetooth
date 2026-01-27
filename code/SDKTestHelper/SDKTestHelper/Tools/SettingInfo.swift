//
//  SettingInfo.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/3/1.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class SettingInfo {
    
    class func saveSSID(_ ssid: String) {
        UserDefaults.standard.set(ssid, forKey: "ssid")
        UserDefaults.standard.synchronize()
    }
    class func getSSID() -> String? {
        return UserDefaults.standard.string(forKey: "ssid")
    }
    
    class func savePassword(_ password: String) {
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.synchronize()
    }
    class func getPassword() -> String? {
        return UserDefaults.standard.string(forKey: "password")
    }
        
    class func saveCustomerBleConnect(_ status: Bool) {
        UserDefaults.standard.set(status, forKey: "customerBleConnect")
        UserDefaults.standard.synchronize()
    }

    class func getCustomerBleConnect() -> Bool {
        return UserDefaults.standard.bool(forKey: "customerBleConnect")
    }
    class func saveAuthEnable(_ status: Bool) {
        UserDefaults.standard.set(status, forKey: "pairEnable")
        UserDefaults.standard.synchronize()
        JLLogManager.logLevel(.INFO, content: "saveAuthEnable:\(status)")
    }

    class func getAuthEnable() -> Bool {
        let state = UserDefaults.standard.bool(forKey: "pairEnable")
        return state
    }

    class func setToHistory(_ uuid: String) {
        UserDefaults.standard.set(uuid, forKey: "toHistory")
        UserDefaults.standard.synchronize()
    }

    class func getToHistory() -> String? {
        return UserDefaults.standard.string(forKey: "toHistory")
    }

    class func getCustomTransportSupport() -> Bool {
        let status = UserDefaults.standard.bool(forKey: "customTransportSupport")
        JLLogManager.logLevel(.INFO, content: "getCustomTransportSupport:\(status)")
        return status
    }

    class func saveCustomTransportSupport(_ status: Bool) {
        UserDefaults.standard.set(status, forKey: "customTransportSupport")
        JLLogManager.logLevel(.INFO, content: "saveCustomTransportSupport:\(status)")
        UserDefaults.standard.synchronize()
    }

    class func getATTComunication() -> Bool {
        return UserDefaults.standard.bool(forKey: "ATTCommunication")
    }

    class func saveATTComunication(_ status: Bool) {
        UserDefaults.standard.set(status, forKey: "ATTCommunication")
        UserDefaults.standard.synchronize()
    }

    class func getAttDevUUID() -> String? {
        return UserDefaults.standard.string(forKey: "attDevUUID")
    }

    class func saveAttDevUUID(_ uuid: String) {
        UserDefaults.standard.set(uuid, forKey: "attDevUUID")
        UserDefaults.standard.synchronize()
    }
    
    class func saveByteDanceAccessKey(_ accessKeyId: String) {
        UserDefaults.standard.set(accessKeyId, forKey: "accessKeyId")
        UserDefaults.standard.synchronize()
    }
    
    class func getByteDanceAccessKey() ->  String {
        let accessKeyId = UserDefaults.standard.string(forKey: "accessKeyId") ?? ""
        return accessKeyId
    }
    
    class func saveByteDanceSecretKey(_ secretAccessKey: String) {
        UserDefaults.standard.set(secretAccessKey, forKey: "secretAccessKey")
        UserDefaults.standard.synchronize()
    }
    
    class func getByteDanceSecretKey() ->  String {
        let secretAccessKey = UserDefaults.standard.string(forKey: "secretAccessKey") ?? ""
        return secretAccessKey
    }
    
    class func saveByteDanceAppId(_ appid: String) {
        UserDefaults.standard.set(appid, forKey: "appid")
        UserDefaults.standard.synchronize()
    }
    
    class func getByteDanceAppId() ->  String {
        let appid = UserDefaults.standard.string(forKey: "appid") ?? ""
        return appid
    }
    
    class func saveByteDanceAccessToken(_ accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        UserDefaults.standard.synchronize()
    }
    
    class func getByteDanceAccessToken() ->  String {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        return accessToken
    }
    
    class func saveByteDanceSecret(_ secretKey: String) {
        UserDefaults.standard.set(secretKey, forKey: "secretKey")
        UserDefaults.standard.synchronize()
    }
    
    class func getByteDanceSecret() ->  String {
        let secretKey = UserDefaults.standard.string(forKey: "secretKey") ?? ""
        return secretKey
    }
    
    class func saveKeyConfig(_ keyConfig: String) {
        UserDefaults.standard.set(keyConfig, forKey: "keyConfig")
        UserDefaults.standard.synchronize()
    }
    
    class func getKeyConfig() ->  String {
        let keyConfig = UserDefaults.standard.string(forKey: "keyConfig") ?? ""
        return keyConfig
    }
    
}
