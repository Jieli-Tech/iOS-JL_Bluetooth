//
//  AlertManager.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/10.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class AlertManager: NSObject {
    private static let share = AlertManager()
    private let showWaittingView = AlertWaitting()
    private let inputPasswordView = AlertInputPassword()
    private let iKnowTips = AlertiKnowTips()
    private let loginView = AlertLoginView()
    private let pswModifyTip = AlertPswModifyTip()
    override init() {
        super.init()
    }
    
    static func windows() -> UIWindow? {
        if let window = UIApplication.shared.windows.first {
            return window
        }
        return nil
    }
    
    static func showWaitting() {
        let currentThread = Thread.current
        if currentThread.isMainThread {
            guard let window = AlertManager.windows() else { return }
            share.showWaittingView.show(title: LanguageCls.localizableTxt("bt_connecting"))
            window.addSubview(share.showWaittingView)
            share.showWaittingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            DispatchQueue.main.async {
                guard let window = AlertManager.windows() else { return }
                share.showWaittingView.show(title: LanguageCls.localizableTxt("bt_connecting"))
                window.addSubview(share.showWaittingView)
                share.showWaittingView.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
    
    static func hideWaitting() {
        let currentThread = Thread.current
        if currentThread.isMainThread {
            share.showWaittingView.hide()
        }else{
            DispatchQueue.main.async {
                share.showWaittingView.hide()
            }
        }
    }
    
    // MARK: - PasswordError

    static func showPasswordErrorView(_ text: String) {
        guard let window = AlertManager.windows() else { return }
        share.iKnowTips.configText(nil, text)
        window.addSubview(share.iKnowTips)
        share.iKnowTips.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        share.iKnowTips.isHidden = false
    }

    static func hiddenPasswordErrorView() {
        share.iKnowTips.removeFromSuperview()
        share.iKnowTips.isHidden = true
    }
    
    // MARK: - InputPassword

    static func showInputPasswordView(contextView: UIViewController? = nil, _ callBack: @escaping ((String) -> Void)) {
        guard let window = AlertManager.windows() else { return }
        let currentThread = Thread.current
        if currentThread.isMainThread {
            share.inputPasswordView.contextView = contextView
            window.addSubview(share.inputPasswordView)
            share.inputPasswordView.resetInput()
            share.inputPasswordView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            share.inputPasswordView.callback = callBack
            share.inputPasswordView.isHidden = false
            share.inputPasswordView.focusInput()
        }else{
            DispatchQueue.main.async {
                share.inputPasswordView.contextView = contextView
                window.addSubview(share.inputPasswordView)
                share.inputPasswordView.resetInput()
                share.inputPasswordView.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
                share.inputPasswordView.callback = callBack
                share.inputPasswordView.isHidden = false
                share.inputPasswordView.focusInput()
            }
        }
    }

    static func hiddenInputPasswordView() {
        let currentThread = Thread.current
        if currentThread.isMainThread {
            share.inputPasswordView.removeFromSuperview()
            share.inputPasswordView.isHidden = true
        }else{
            DispatchQueue.main.async {
                share.inputPasswordView.removeFromSuperview()
                share.inputPasswordView.isHidden = true
            }
        }
    }
    
    // MARK: - can not entry broadcast listen

    static func hiddenReceiveBroadcastFailed() {
        let currentThread = Thread.current
        if currentThread.isMainThread {
            share.iKnowTips.removeFromSuperview()
            share.iKnowTips.isHidden = true
        }else{
            DispatchQueue.main.async {
                share.iKnowTips.removeFromSuperview()
                share.iKnowTips.isHidden = true
            }
        }
    }
    static func showReceiveBroadcastFailed(_ text: String) {
        guard let window = AlertManager.windows() else { return }
        let currentThread = Thread.current
        if currentThread.isMainThread {
            window.addSubview(share.iKnowTips)
            share.iKnowTips.configText(R.localStr.failedToReceiveBroadcast(), text)
            share.iKnowTips.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            share.iKnowTips.isHidden = false
        }else{
            DispatchQueue.main.async {
                window.addSubview(share.iKnowTips)
                share.iKnowTips.configText(R.localStr.failedToReceiveBroadcast(), text)
                share.iKnowTips.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
                share.iKnowTips.isHidden = false
            }
        }
    }
    // MARK: - PswModifyTip

    static func showPswModifyTip() {
        guard let window = AlertManager.windows() else { return }
        let currentThread = Thread.current
        if currentThread.isMainThread {
            window.addSubview(share.pswModifyTip)
            share.pswModifyTip.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            share.pswModifyTip.isHidden = false
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2, execute: DispatchWorkItem(block: {
                AlertManager.hiddenPswModifyTip()
            }))
        }else{
            DispatchQueue.main.async {
                window.addSubview(share.pswModifyTip)
                share.pswModifyTip.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
                share.pswModifyTip.isHidden = false
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2, execute: DispatchWorkItem(block: {
                    AlertManager.hiddenPswModifyTip()
                }))
            }
        }
        share.pswModifyTip.isHidden = false
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2, execute: DispatchWorkItem(block: {
            AlertManager.hiddenPswModifyTip()
        }))
    }

    static func hiddenPswModifyTip() {
        let currentThread = Thread.current
        if currentThread.isMainThread {
            share.pswModifyTip.removeFromSuperview()
            share.pswModifyTip.isHidden = true
        }else{
            DispatchQueue.main.async {
                share.pswModifyTip.removeFromSuperview()
                share.pswModifyTip.isHidden = true
            }
        }
    }

    // MARK: - Login input password view

    static func showLoginView(lancerVm _: DeviceInfoViewModel, contextView: UIViewController? = nil) {
        guard let window = AlertManager.windows() else { return }
        let currentThread = Thread.current
        if currentThread.isMainThread {
            share.loginView.contextView = contextView
            window.addSubview(share.loginView)
            share.loginView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            share.loginView.isHidden = false
        }else{
            DispatchQueue.main.async {
                share.loginView.contextView = contextView
                window.addSubview(share.loginView)
                share.loginView.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
                share.loginView.isHidden = false
            }
        }
    }

    static func hiddenLoginView() {
        let currentThread = Thread.current
        if currentThread.isMainThread {
            share.loginView.removeFromSuperview()
            share.loginView.isHidden = true
        }else{
            DispatchQueue.main.async {
                share.loginView.removeFromSuperview()
                share.loginView.isHidden = true
            }
        }
    }
    
    static func toast(_ text: String) {
        guard let window = AlertManager.windows() else { return }
        let currentThread = Thread.current
        if currentThread.isMainThread {
            window.rootViewController?.view.makeToast(text, duration: 2, position: .bottom)
        }else{
            DispatchQueue.main.async {
                window.rootViewController?.view.makeToast(text, duration: 2, position: .bottom)
            }
        }
    }
    

}
