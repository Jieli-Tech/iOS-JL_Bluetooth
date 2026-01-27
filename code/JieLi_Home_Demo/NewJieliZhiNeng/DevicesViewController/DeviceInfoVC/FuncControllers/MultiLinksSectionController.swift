//
//  MultiLinksSectionController.swift
//  JLPiHome
//
//  Created by TraeAI on 2025/12/23.
//
//  一拖二功能节控制器：负责视图创建、状态展示与拖更多能力的KVO监听，并处理点击跳转。

import UIKit
import SnapKit

class MultiLinksSectionController: NSObject, DeviceInfoSectionControlling {
    private weak var owner: UIViewController?
    private weak var manager: JL_TwsManager?
    private var viewRef: DevInfoFunctionView?
    private var hasSetupObserver = false

    init(manager: JL_TwsManager, owner: UIViewController) {
        self.manager = manager
        self.owner = owner
    }

    func makeView() -> UIView {
        let status = (manager?.dragWithMore ?? false) ? R.localStr.on() : R.localStr.off()
        let v = DevInfoFunctionView()
        v.config(title: R.localStr.dual_device_connection(), imgv: "function_icon_connection", detail: status)
        v.tapBlock = { [weak self] in
            guard let self, let owner = self.owner else { return }
            let vc = MultiLinksViewController()
            owner.navigationController?.pushViewController(vc, animated: true)
        }
        viewRef = v
        JLLogManager.logLevel(.DEBUG, content: "设备支持一拖二")
        return v
    }

    func start() {
        guard !hasSetupObserver, let mgr = manager else { return }
        mgr.addObserver(self, forKeyPath: "dragWithMore", options: [.initial, .new], context: nil)
        hasSetupObserver = true
    }

    func stop() {
        if let mgr = manager {
            mgr.removeObserver(self, forKeyPath: "dragWithMore")
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "dragWithMore" {
            let on = (change?[.newKey] as? NSNumber)?.boolValue ?? false
            viewRef?.config(title: R.localStr.dual_device_connection(), imgv: "function_icon_connection", detail: on ? R.localStr.on() : R.localStr.off())
            JLLogManager.logLevel(.INFO, content: "MultiLinks -> dragWithMore:\(on)")
        }
    }
}
