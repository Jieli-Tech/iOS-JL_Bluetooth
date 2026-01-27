//
//  DHASectionController.swift
//  JLPiHome
//
//  Created by TraeAI on 2025/12/23.
//
//  DHA 功能节控制器：负责创建 DHA 功能视图，处理点击交互并调用配准逻辑，保持视图与业务的模块化。

import UIKit
import SnapKit

class DHASectionController: NSObject, DeviceInfoSectionControlling {
    private weak var owner: UIViewController?
    private weak var manager: JL_ManagerM?
    private var viewRef: DevInfoFunctionView?

    init(manager: JL_ManagerM, owner: UIViewController) {
        self.manager = manager
        self.owner = owner
    }

    func makeView() -> UIView {
        let v = DevInfoFunctionView()
        v.config(title: R.localStr.hearing_aid_fitting(), imgv: "Theme.bundle/icon_earphone_60", detail: "")
        v.tapBlock = { [weak self] in
            guard let self, let owner = self.owner, let mgr = self.manager else { return }
            JLDhaFitting.auxiGetInfo({ info, gains in
                if info.ch_num != 0 {
                    let vc = DhaFittingVC()
                    owner.navigationController?.pushViewController(vc, animated: true)
                } else {
                    owner.view.makeToast(R.localStr.msg_read_file_err_reading(), duration: 2, position: .center)
                }
            }, manager: mgr)
        }
        JLLogManager.logLevel(.DEBUG, content: "设备支持DHA")
        viewRef = v
        return v
    }

    func start() {
        // 当前 DHA 无状态监听，保留接口以便未来扩展
    }

    func stop() {
        viewRef = nil
    }
}
