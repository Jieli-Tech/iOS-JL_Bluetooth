//
//  FindDevicesViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/10/17.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import JL_BLEKit
import AudioToolbox

class FindDevicesViewController: BaseViewController {

    // UI
    private let playWaySeg = UISegmentedControl(items: [R.localStr.all(), R.localStr.left(), R.localStr.right(), R.localStr.pauseAll()]) // 0,1,2,3
    private let soundSwitch = UISwitch() // 0x00 关闭；0x01 播放
    private let timeoutField: UITextField = {
        let tf = UITextField()
        tf.placeholder = R.localStr.timeoutSecondsDefault60()
        tf.keyboardType = .numberPad
        tf.borderStyle = .roundedRect
        return tf
    }()
    private let sendBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(R.localStr.mobileFindDevice(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.backgroundColor = .random()
        return btn
    }()

    // Phone ring control
    private var ringTimer: Timer?
    private var ringRemaining: Int = 0

    override func initUI() {
        navigationView.title = R.localStr.findDevice()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        view.backgroundColor = .systemBackground
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill

        let playWayRow = row(title: R.localStr.playMode(), rightView: playWaySeg)
        let soundRow = row(title: R.localStr.whetherToRing(), rightView: soundSwitch)
        let timeoutRow = row(title: R.localStr.timeoutSeconds(), rightView: timeoutField)

        [playWayRow, soundRow, timeoutRow, sendBtn].forEach { stack.addArrangedSubview($0) }
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        // 每行设置固定高度，避免行内容高度不明确导致挤压
        playWayRow.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        soundRow.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        timeoutRow.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        // 为具体控件设置合适高度
        playWaySeg.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        timeoutField.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
        // 在“是否响铃”与“超时(秒)”之间加额外间距
        stack.setCustomSpacing(12, after: soundRow)
        // 调整行间距与按钮高度，避免控件挤在一起
        stack.setCustomSpacing(24, after: timeoutRow)
        sendBtn.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        playWaySeg.selectedSegmentIndex = 0
        soundSwitch.isOn = true
        timeoutField.text = "60"

        sendBtn.addTarget(self, action: #selector(onSendFindDevice), for: .touchUpInside)

        // 监听设备主动推送的“查找手机”通知
        NotificationCenter.default.addObserver(self, selector: #selector(onFindPhoneNotify(_:)), name: NSNotification.Name(rawValue: kJL_MANAGER_FIND_PHONE), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopPhoneRing()
    }

    // MARK: - UI helpers
    private func row(title: String, rightView: UIView) -> UIView {
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 15)
        // 让标题尽量保持完整显示，右侧控件扩展占据剩余空间
        titleLbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        rightView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let hStack = UIStackView(arrangedSubviews: [titleLbl, rightView])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.distribution = .fill
        return hStack
    }

    // MARK: - Actions
    @objc private func onSendFindDevice() {
        guard let mgr = BleManager.shared.currentCmdMgr else {
            toast(R.localStr.currentlyNotConnected())
            return
        }
       let findMgr = mgr.mFindDeviceManager
        let op = JLFindDeviceOperation()
        // 播放方式: 0全部 1左 2右 3暂停
        let playIdx = UInt8(playWaySeg.selectedSegmentIndex)
        op.playWay = playIdx
        // 超时(秒)
        let timeoutVal = UInt16(Int(timeoutField.text ?? "60") ?? 60)
        op.timeout = timeoutVal
        // 铃声操作: 0x00关闭 0x01播放
        op.sound = soundSwitch.isOn ? 0x01 : 0x00

        findMgr.cmdFindDevice(with: op)
        view.makeToast(R.localStr.deviceFindCommandSent(), position: .center)
    }

    // MARK: - 监听设备查找手机
    @objc private func onFindPhoneNotify(_ noti: Notification) {
        // noti.object 是一个包装字典，含 kJL_MANAGER_KEY_OBJECT、kJL_MANAGER_KEY_UUID
        guard let wrapper = noti.object as? [String: Any] else { return }
        let inner = wrapper[kJL_MANAGER_KEY_OBJECT] as? [String: Any] ?? wrapper["object"] as? [String: Any]
        guard let payload = inner ?? (noti.userInfo as? [String: Any]) else { return }
        let op = (payload["op"] as? NSNumber)?.intValue ?? payload["op"] as? Int ?? 1
        let timeout = (payload["timeout"] as? NSNumber)?.intValue ?? payload["timeout"] as? Int ?? 10

        // 弹窗与响铃
        let message = op == 1 ? R.localStr.deviceIsSearchingForPhoneAndIsRingingVibrating() : R.localStr.deviceRequestsToTurnOffRinging()
        let alert = UIAlertController(title: R.localStr.findPhone(), message: message, preferredStyle: .alert)
        if op == 1 {
            alert.addAction(UIAlertAction(title: R.localStr.stopRinging(), style: .destructive, handler: { [weak self] _ in
                self?.stopPhoneRing()
            }))
        }
        alert.addAction(UIAlertAction(title: R.localStr.iGotIt(), style: .cancel, handler: nil))
        present(alert, animated: true)

        if op == 1 {
            startPhoneRing(timeout: timeout)
        } else {
            stopPhoneRing()
        }
    }

    // MARK: - Phone ring logic
    private func startPhoneRing(timeout: Int) {
        stopPhoneRing()
        ringRemaining = max(timeout, 1)
        // 立即播放一次提示音震动
        AudioServicesPlayAlertSound(SystemSoundID(1007)) // 提示音
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        ringTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else { return }
            self.ringRemaining -= 1
            AudioServicesPlayAlertSound(SystemSoundID(1007))
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            if self.ringRemaining <= 0 {
                self.stopPhoneRing()
            }
        }
        RunLoop.main.add(ringTimer!, forMode: .common)
    }

    private func stopPhoneRing() {
        ringTimer?.invalidate()
        ringTimer = nil
    }

    // MARK: - Toast 简易实现
    private func toast(_ text: String) {
        let hud = UILabel()
        hud.text = text
        hud.textColor = .white
        hud.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        hud.textAlignment = .center
        hud.numberOfLines = 0
        hud.font = .systemFont(ofSize: 14)
        hud.layer.cornerRadius = 8
        hud.layer.masksToBounds = true
        view.addSubview(hud)
        hud.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(100)
            make.width.lessThanOrEqualToSuperview().inset(40)
        }
        hud.alpha = 0
        UIView.animate(withDuration: 0.25, animations: { hud.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.25, delay: 1.2, options: [], animations: {
                hud.alpha = 0
            }, completion: { _ in
                hud.removeFromSuperview()
            })
        }
    }
}

