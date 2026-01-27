//
//  NormalViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/11/21.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JLLogHelper

/**
 基础发数测试页面。提供日志展示、数据输入与发送功能，并实现键盘避让与便捷收起机制，确保键盘不遮挡发送按钮与输入区域。
 */
class NormalViewController: BaseViewController, JLCustomCmdPtl {
    
    let titleLab = UILabel()
    let logView = LogView()
    let dataInputView: InputView = InputView()
    let dataSendBtn: UIButton = UIButton()
    private var customMgr = BleManager.shared.currentCmdMgr?.mCustomManager
    private var sendBtnBottomConstraint: Constraint?
    
    override func initUI() {
        super.initUI()
        navigationView.title = "基础发数测试"
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        
        titleLab.text = R.localStr.log()
        titleLab.font = .systemFont(ofSize: 16)
        titleLab.textColor = .darkGray
        view.addSubview(titleLab)
        
        logView.layer.cornerRadius = 5
        logView.layer.borderWidth = 1
        logView.layer.borderColor = UIColor.random().cgColor
        logView.layer.masksToBounds = true
        view.addSubview(logView)
        

        dataInputView.configure(title: R.localStr.customerCommand(), placeholder: R.localStr.pleaseInputData())
        dataInputView.textField.keyboardType = .asciiCapable
        dataInputView.textField.returnKeyType = .done
        dataInputView.textField.autocorrectionType = .no
        dataInputView.contextView = self
        
        view.addSubview(dataInputView)
        
        dataSendBtn.setTitle(R.localStr.send(), for: .normal)
        dataSendBtn.setTitleColor(.white, for: .normal)
        dataSendBtn.backgroundColor = .random()
        dataSendBtn.layer.cornerRadius = 5
        dataSendBtn.layer.masksToBounds = true
        view.addSubview(dataSendBtn)
        stepUI()
    }
    
    private func stepUI() {
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        logView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(dataInputView.snp.top).offset(-10)
        }
        
        
        dataInputView.snp.makeConstraints { make in
            make.top.equalTo(logView.snp.bottom).offset(10)
            make.right.left.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }
        
        dataSendBtn.snp.makeConstraints { make in
            make.top.equalTo(dataInputView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(40)
            self.sendBtnBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20).constraint
        }
    
    }
    
    override func initData() {
        super.initData()
        
        customMgr?.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        dataInputView.textField.inputAccessoryView = accessoryToolbar()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        dataSendBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            guard let dataStr = dataInputView.textField.text else { return }
            let data = dataStr.beData
            BleManager.shared.sendData(data)
        }.disposed(by: disposeBag)
    }

    /// 接收到自定义数据
    /// - Parameter data: 自定义数据
    func otaCustomReceive(_ data: JLOtaCustomData) {
        
    }
    
    func customCmdResponse(_ manager: JL_ManagerM, status: UInt8, with data: Data) {
        
    }
    
    func customCmdRequire(_ manager: JL_ManagerM, with data: Data, isNeedResponse: Bool, sn: UInt8) {
        if isNeedResponse {
            self.view.makeToast(R.localStr.receiveDataBytesNeedResponse(String(data.count)))
            //TODO: 自定义应答
            customMgr?.cmdCustomResponse(sn, data: nil)
        } else {
            self.view.makeToast(R.localStr.receiveDataBytes(String(data.count)))
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func handleKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? 7
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        var newOffset: CGFloat = -20
        if let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let endFrame = value.cgRectValue
            let converted = view.convert(endFrame, from: nil)
            let overlap = max(0, view.bounds.height - converted.origin.y)
            let effective = max(0, overlap - view.safeAreaInsets.bottom)
            if notification.name == UIResponder.keyboardWillHideNotification {
                newOffset = -20
            } else {
                newOffset = -(effective + 10)
            }
        }
        sendBtnBottomConstraint?.update(offset: newOffset)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func accessoryToolbar() -> UIToolbar {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: R.localStr.oK(), style: .done, target: self, action: #selector(dismissKeyboard))
        bar.items = [flex, done]
        return bar
    }
}
