//
//  ANCSectionController.swift
//  JLPiHome
//
//  Created by TraeAI on 2025/12/23.
//
//  ANC 功能节控制器：负责创建 ANC 视图并将交互委托给页面控制器，实现视图的顺序编排与职责解耦。

import UIKit
import SnapKit

class ANCSectionController: NSObject, DeviceInfoSectionControlling {
    private weak var owner: UIViewController?
    private var ancView: HeadSetANC?

    init(owner: UIViewController) {
        self.owner = owner
    }

    func makeView() -> UIView {
        let v = HeadSetANC()
        if let delegate = owner as? HeadsetDenoisePtl {
            v.delegate = delegate
        }
        JLLogManager.logLevel(.DEBUG, content: "设备支持ANC")
        ancView = v
        return v
    }

    func start() {
        // 当前 ANC 无状态监听，保留接口以便未来扩展
    }

    func stop() {
        // 清理资源占位
        ancView = nil
    }
}
