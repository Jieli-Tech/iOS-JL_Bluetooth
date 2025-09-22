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
    

}
