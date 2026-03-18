//
//  JLAudioSessionManager.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/7/21.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import AVFoundation

class JLAudioSessionManager {
    static let shared = JLAudioSessionManager()

    private var isActive = false
    private var currentCategory: AVAudioSession.Category = .playAndRecord
    private let session = AVAudioSession.sharedInstance()
    /// 当前是否活跃
    var isSessionActive: Bool {
        return isActive
    }

    /// 当前是否有录音权限
    var hasRecordPermission: Bool {
        return session.recordPermission == .granted
    }

    private init() {}

    /// 配置并激活音频会话
    /// - Parameters:
    ///   - category: 使用的类型（默认 playAndRecord）
    ///   - options: 会话选项
    func activate(category: AVAudioSession.Category = .playAndRecord,
                  options: AVAudioSession.CategoryOptions = [.defaultToSpeaker, .allowBluetoothA2DP]) throws
    {
        // 避免重复设置
        if isActive, session.category == category { return }

        do {
            try session.setCategory(category, mode: .default, options: options)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            currentCategory = category
            isActive = true
        } catch {
            isActive = false
            throw error
        }
    }

    /// 主动停用音频会话（仅在完全不再使用音频时调用）
    func deactivate() {
        guard isActive else { return }
        do {
            try session.setActive(false)
        } catch {
            print("AVAudioSession deactivate failed: \(error)")
        }
        isActive = false
    }

    /// 异步请求录音权限
    func requestPermission(completion: @escaping (Bool) -> Void) {
        session.requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}
