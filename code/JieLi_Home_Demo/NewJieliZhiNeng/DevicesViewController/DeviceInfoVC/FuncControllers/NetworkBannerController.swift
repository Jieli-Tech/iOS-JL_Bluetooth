//
//  NetworkBannerController.swift
//  JLPiHome
//
//  Created by TraeAI on 2025/12/23.
//
//  负责管理设备信息页顶部的网络提示视图：包含视图创建、布局高度动态更新以及网络状态的KVO监听。

import UIKit
import SnapKit

class NetworkBannerController: NSObject {
    private let bannerView = NoNetView(byFrame: CGRectMake(0, 0, UIScreen.main.bounds.size.width, 40))
    private var heightConstraint: Constraint?
    private var hasSetupObserver = false

    func attach(on rootView: UIView, below topView: UIView) {
        rootView.addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.equalToSuperview()
            heightConstraint = make.height.equalTo(0).constraint
        }
    }

    func start() {
        guard !hasSetupObserver else { return }
        hasSetupObserver = true
        let mgr = AFNetworkReachabilityManager.shared()
        mgr.startMonitoring()
        mgr.addObserver(self, forKeyPath: "networkReachabilityStatus", options: [.initial, .new], context: nil)
    }

    func stop() {
        AFNetworkReachabilityManager.shared().removeObserver(self, forKeyPath: "networkReachabilityStatus")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "networkReachabilityStatus" {
            let newVal = (change?[.newKey] as? NSNumber)?.intValue ?? AFNetworkReachabilityStatus.unknown.rawValue
            let isNoNet = (newVal == AFNetworkReachabilityStatus.notReachable.rawValue) || (newVal == AFNetworkReachabilityStatus.unknown.rawValue)
            update(show: isNoNet)
        }
    }

    private func update(show: Bool) {
        guard let heightConstraint else { return }
        heightConstraint.update(offset: show ? 40 : 0)
        bannerView.isHidden = !show
        UIView.animate(withDuration: 0.2) {
            self.bannerView.superview?.layoutIfNeeded()
        }
        JLLogManager.logLevel(.INFO, content: "NetReachability -> show:\(show)")
    }

    var view: UIView { bannerView }
}

