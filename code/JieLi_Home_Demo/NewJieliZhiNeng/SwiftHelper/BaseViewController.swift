//
//  BaseViewController.swift
//  IPCLink
//
//  Created by EzioChan on 2023/4/10.
//  Copyright © 2023 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

import RxSwift
import UIKit
import CoreBluetooth

class BaseViewController: UIViewController {
    open var navigationView = NaviView()
    open var disposeBag = DisposeBag()
    open var canNotPushBack: Bool = false
    open var bgColor = UIColor.eHex("#F8FAFE")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navigationView)
        view.backgroundColor = bgColor
        let window = UIApplication.shared.windows.first
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.top).inset(0)
            make.height.equalTo(44 + (window?.safeAreaInsets.top ?? 20))
            make.left.right.equalTo(view).inset(0)
        }

        initUI()
        initData()
        prepareData()
        JL_Tools.add(kJL_BLE_M_ENTITY_DISCONNECTED, action: #selector(disconnectStatusChange), own: self)
    }
    
    func removeObserver() {
        JL_Tools.remove(kJL_BLE_M_ENTITY_DISCONNECTED, own: self)
    }

    override func viewWillAppear(_: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground(_:)),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification, object: nil)
        if canNotPushBack {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if canNotPushBack {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }

    @objc func disconnectStatusChange(_ note: Notification) {
        navigationController?.popToRootViewController(animated: true)
    }

    func initUI() {}

    func initData() {}

    func prepareData() {}

    @objc func didBecomeActive(_: Notification) {}

    @objc func willEnterForeground(_: Notification) {}
}

final class DeviceOrientation {
    static let shared: DeviceOrientation = .init()

    // MARK: - Private methods

    @available(iOS 13.0, *)
    private var windowScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes.first as? UIWindowScene
    }

    // MARK: - Public methods

    func set(orientation: UIInterfaceOrientationMask) {
        if #available(iOS 16.0, *) {
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
        } else {
            UIDevice.current.setValue(orientation.toUIInterfaceOrientation.rawValue, forKey: "orientation")
        }
    }

    var isLandscape: Bool {
        if #available(iOS 16.0, *) {
            return windowScene?.interfaceOrientation.isLandscape ?? false
        }
        return UIDevice.current.orientation.isLandscape
    }

    var isPortrait: Bool {
        if #available(iOS 16.0, *) {
            return windowScene?.interfaceOrientation.isPortrait ?? false
        }
        return UIDevice.current.orientation.isPortrait
    }

    var isFlat: Bool {
        if #available(iOS 16.0, *) {
            return false
        }
        return UIDevice.current.orientation.isFlat
    }
}

extension UIInterfaceOrientationMask {
    var toUIInterfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .portrait:
            return UIInterfaceOrientation.portrait
        case .portraitUpsideDown:
            return UIInterfaceOrientation.portraitUpsideDown
        case .landscapeRight:
            return UIInterfaceOrientation.landscapeRight
        case .landscapeLeft:
            return UIInterfaceOrientation.landscapeLeft
        default:
            return UIInterfaceOrientation.unknown
        }
    }
}
