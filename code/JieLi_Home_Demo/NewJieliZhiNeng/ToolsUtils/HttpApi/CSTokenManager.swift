//
//  CSTokenManager.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2026-03-25.
//  Copyright © 2026 杰理科技. All rights reserved.
//

import Foundation
import JLLogHelper

/// 彩屏舱 Token 管理机制，负责 Token 的获取、缓存与过期刷新
class CSTokenManager {
    static let shared = CSTokenManager()
    
    // UserDefaults Keys
    private let tokenKey = "cs_access_token_key"
    private let expireKey = "cs_access_token_expire_key"
    private let vidKey = "cs_access_token_vid_key"
    private let pidKey = "cs_access_token_pid_key"
    
    // 防重复刷新相关
    private var isRefreshing = false
    private var refreshCompletionHandlers: [(String?) -> Void] = []
    private let queue = DispatchQueue(label: "com.jieli.cstokenmanager.queue")
    
    private init() {}
    
    /// 获取有效的 Token
    /// - Parameters:
    ///   - vid: 当前设备的 vid
    ///   - pid: 当前设备的 pid
    ///   - completion: 成功返回 token，失败返回 nil
    func getValidToken(vid: Int, pid: Int, completion: @escaping (String?) -> Void) {
        queue.async {
            // 检查是否更换了设备
            let cachedVid = UserDefaults.standard.integer(forKey: self.vidKey)
            let cachedPid = UserDefaults.standard.integer(forKey: self.pidKey)
            
            // 如果 UserDefaults 中不存在对应 key，integer(forKey:) 会返回 0。
            // 为了准确判断，我们假设如果 token 不为空，说明曾存过。
            let deviceChanged = (cachedVid != vid || cachedPid != pid)
            
            if !deviceChanged {
                if let token = UserDefaults.standard.string(forKey: self.tokenKey),
                   let expireDate = UserDefaults.standard.object(forKey: self.expireKey) as? Date,
                   expireDate > Date() {
                    // Token 存在且未过期
                    DispatchQueue.main.async {
                        completion(token)
                    }
                    return
                }
            }
            
            // 需要重新获取 Token
            self.refreshCompletionHandlers.append(completion)
            
            if !self.isRefreshing {
                self.isRefreshing = true
                self.requestToken(vid: vid, pid: pid)
            }
        }
    }
    
    /// 强制清除本地 Token 缓存
    func clearToken() {
        queue.async {
            UserDefaults.standard.removeObject(forKey: self.tokenKey)
            UserDefaults.standard.removeObject(forKey: self.expireKey)
            UserDefaults.standard.removeObject(forKey: self.vidKey)
            UserDefaults.standard.removeObject(forKey: self.pidKey)
            JLLogManager.logLevel(.DEBUG, content: "CSTokenManager: Local token cleared.")
        }
    }
    
    // MARK: - Private Methods
    
    private func requestToken(vid: Int, pid: Int) {
        JLLogManager.logLevel(.DEBUG, content:"CSTokenManager: Requesting new token for vid: \(vid), pid: \(pid)")
        let path = CSApiConst.Paths.authToken + "?pid=\(pid)&vid=\(vid)"
        CSNetworkManager.shared.request(path: path, method: "POST") { [weak self] (result: Result<CSAuthTokenModel, CSNetworkError>) in
            guard let self = self else { return }
            
            self.queue.async {
                self.isRefreshing = false
                let handlers = self.refreshCompletionHandlers
                self.refreshCompletionHandlers.removeAll()
                
                switch result {
                case .success(let model):
                    if let token = model.accessToken, let expiresIn = model.expiresIn {
                        // 保存 token
                        UserDefaults.standard.set(token, forKey: self.tokenKey)
                        
                        // 预留 60 秒提前过期，防止临界点失效
                        let expireDate = Date().addingTimeInterval(TimeInterval(max(expiresIn - 60, 0)))
                        UserDefaults.standard.set(expireDate, forKey: self.expireKey)
                        
                        UserDefaults.standard.set(vid, forKey: self.vidKey)
                        UserDefaults.standard.set(pid, forKey: self.pidKey)
                        
                        JLLogManager.logLevel(.DEBUG, content:"CSTokenManager: Token obtained and cached successfully.")
                        
                        DispatchQueue.main.async {
                            handlers.forEach { $0(token) }
                        }
                    } else {
                        JLLogManager.logLevel(.ERROR, content:"CSTokenManager: Missing accessToken or expiresIn in response.")
                        DispatchQueue.main.async {
                            handlers.forEach { $0(nil) }
                        }
                    }
                case .failure(let error):
                    JLLogManager.logLevel(.ERROR, content:"CSTokenManager: Request failed with error - \(error)")
                    DispatchQueue.main.async {
                        handlers.forEach { $0(nil) }
                    }
                }
            }
        }
    }
    
}
