//
//  NrfWriteInputViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import CoreBluetooth

/// 特征写入自定义弹窗
/// 替代系统 UIAlertController，提供更丰富的输入选项和更好的布局适配
class NrfWriteInputViewController: UIViewController {
    
    /// 特征属性，用于控制写入类型选项
    var properties: CBCharacteristicProperties = []
    
    /// 确认回调
    var onConfirm: ((NrfDetailsViewModel.WriteInput) -> Void)?
    
    private let container = UIView()
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let typeLabel = UILabel()
    private let typeSegment = UISegmentedControl(items: ["Hex Array", "UInt", "Bool", "UTF8"])
    private let writeTypeLabel = UILabel()
    private let writeTypeSegment = UISegmentedControl(items: ["Request (Rsp)", "Command (NoRsp)"])
    private let cancelBtn = UIButton(type: .system)
    private let confirmBtn = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupUI()
        setupActions()
        updateWriteTypeSegment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    private func setupUI() {
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        view.addSubview(container)
        
        container.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(32)
            make.width.lessThanOrEqualTo(400)
        }
        
        titleLabel.text = "Write Characteristic"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        textField.placeholder = "Please input data to write"
        textField.borderStyle = .roundedRect
        textField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        // 自动弹出键盘
        textField.becomeFirstResponder()
        container.addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        
        typeLabel.text = "Data Type"
        typeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        typeLabel.textColor = .secondaryLabel
        container.addSubview(typeLabel)
        
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(16)
            make.left.equalTo(textField)
        }
        
        typeSegment.selectedSegmentIndex = 0
        container.addSubview(typeSegment)
        
        typeSegment.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(8)
            make.left.right.equalTo(textField)
        }
        
        writeTypeLabel.text = "Write Type"
        writeTypeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        writeTypeLabel.textColor = .secondaryLabel
        container.addSubview(writeTypeLabel)
        
        writeTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(typeSegment.snp.bottom).offset(16)
            make.left.equalTo(textField)
        }
        
        writeTypeSegment.selectedSegmentIndex = 0
        container.addSubview(writeTypeSegment)
        
        writeTypeSegment.snp.makeConstraints { make in
            make.top.equalTo(writeTypeLabel.snp.bottom).offset(8)
            make.left.right.equalTo(textField)
        }
        
        let hStack = UIStackView(arrangedSubviews: [cancelBtn, confirmBtn])
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 16
        container.addSubview(hStack)
        
        hStack.snp.makeConstraints { make in
            make.top.equalTo(writeTypeSegment.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.backgroundColor = .systemGray5
        cancelBtn.layer.cornerRadius = 8
        cancelBtn.setTitleColor(.label, for: .normal)
        
        confirmBtn.setTitle("Write", for: .normal)
        confirmBtn.backgroundColor = .systemBlue
        confirmBtn.layer.cornerRadius = 8
        confirmBtn.setTitleColor(.white, for: .normal)
    }
    
    private func setupActions() {
        cancelBtn.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(onOK), for: .touchUpInside)
        
        // 点击背景关闭
        let tap = UITapGestureRecognizer(target: self, action: #selector(onCancel))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    private func updateWriteTypeSegment() {
        let hasWrite = properties.contains(.write)
        let hasNoRsp = properties.contains(.writeWithoutResponse)
        
        writeTypeSegment.setEnabled(hasWrite, forSegmentAt: 0)
        writeTypeSegment.setEnabled(hasNoRsp, forSegmentAt: 1)
        
        if hasWrite {
            writeTypeSegment.selectedSegmentIndex = 0
        } else if hasNoRsp {
            writeTypeSegment.selectedSegmentIndex = 1
        }
    }
    
    @objc private func onCancel() {
        dismiss(animated: true)
    }
    
    @objc private func onOK() {
        guard let text = textField.text else { return }
        let typeIndex = typeSegment.selectedSegmentIndex
        let inputType: NrfDetailsViewModel.WriteInputType = [.byteArray, .unsignedInt, .bool, .utf8][typeIndex]
        let withRsp = (writeTypeSegment.selectedSegmentIndex == 0)
        let input = NrfDetailsViewModel.WriteInput(type: inputType, payload: text, withResponse: withRsp)
        
        onConfirm?(input)
        dismiss(animated: true)
    }
    
    // MARK: - Keyboard Handling
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        // 简单策略：上移键盘高度的一半，确保弹窗不被遮挡
        let offset = -keyboardHeight / 2
        
        UIView.animate(withDuration: duration) {
            self.container.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(offset)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(withDuration: duration) {
            self.container.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(0)
            }
            self.view.layoutIfNeeded()
        }
    }
}

extension NrfWriteInputViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 点击 container 内部不关闭
        if touch.view?.isDescendant(of: container) == true {
            return false
        }
        return true
    }
}
