//
//  TranslateSetViewModel.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/5.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import RxSwift
import UIKit

/// 授权展示信息（不含 @available 限制，供 View 层使用）
struct AuthDisplayInfo {
    let accessKeyId: String
    let appid: String
    let isValid: Bool
}

/// 授权状态枚举
enum AuthStatus {
    case checking
    case valid
    case expired
    case notFound
}

/// 翻译设置页 ViewModel：负责授权检查、扫码结果解析与保存
class TranslateSetViewModel {

    // MARK: - Outputs

    /// 当前授权状态
    let authStatusSubject = BehaviorSubject<AuthStatus>(value: .checking)
    /// 当前授权信息（用于 UI 展示）
    let currentAuthSubject = BehaviorSubject<AuthDisplayInfo?>(value: nil)
    /// 结果提示消息
    let toastMessageSubject = PublishSubject<String>()

    // MARK: - Public Methods

    /// 检查本地授权状态，更新 authStatusSubject 和 currentAuthSubject
    func checkAuthStatus() {
        if #available(iOS 13.0, *) {
            guard let auth = KeyAuth.ByteDance.getAiAuth() else {
                authStatusSubject.onNext(.notFound)
                currentAuthSubject.onNext(nil)
                JLLogManager.logLevel(.INFO, content: "TranslateSetVM: auth not found")
                return
            }
            let isValid = auth.isInvalid()
            currentAuthSubject.onNext(AuthDisplayInfo(
                accessKeyId: auth.accessKeyId,
                appid: auth.appid,
                isValid: isValid
            ))
            if isValid {
                authStatusSubject.onNext(.valid)
                JLLogManager.logLevel(.INFO, content: "TranslateSetVM: auth valid")
            } else {
                authStatusSubject.onNext(.expired)
                JLLogManager.logLevel(.INFO, content: "TranslateSetVM: auth expired")
            }
        } else {
            authStatusSubject.onNext(.notFound)
            currentAuthSubject.onNext(nil)
        }
    }

    /// 处理扫码结果：解析 Base64 → 保存 → 返回是否成功
    @discardableResult
    func processScanResult(_ base64String: String) -> Bool {
        if #available(iOS 13.0, *) {
            let auth = KeyAuth.makeAuth(base64String)
            guard !auth.accessKeyId.isEmpty || !auth.appid.isEmpty else {
                JLLogManager.logLevel(.ERROR, content: "TranslateSetVM: scan parse failed - empty fields")
                toastMessageSubject.onNext("Authorization parse failed")
                return false
            }
            let isValid = auth.isInvalid()
            currentAuthSubject.onNext(AuthDisplayInfo(
                accessKeyId: auth.accessKeyId,
                appid: auth.appid,
                isValid: isValid
            ))
            if isValid {
                JLLogManager.logLevel(.INFO, content: "TranslateSetVM: auth saved and valid")
                authStatusSubject.onNext(.valid)
                toastMessageSubject.onNext("Authorization added successfully")
                return true
            } else {
                JLLogManager.logLevel(.WARN, content: "TranslateSetVM: auth saved but expired")
                authStatusSubject.onNext(.expired)
                toastMessageSubject.onNext("Authorization expired")
                return false
            }
        } else {
            toastMessageSubject.onNext("Unsupported system version")
            return false
        }
    }

    /// 判断当前是否有有效授权
    func hasValidAuth() -> Bool {
        if #available(iOS 13.0, *) {
            guard let auth = KeyAuth.ByteDance.getAiAuth() else { return false }
            return auth.isInvalid()
        }
        return false
    }
}
