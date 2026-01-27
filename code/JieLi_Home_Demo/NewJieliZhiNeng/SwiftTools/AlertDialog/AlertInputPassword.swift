//
//  AlertInputPassword.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/29.
//

import UIKit

/// 密码输入弹窗视图：负责展示密码输入、键盘适配与交互
class AlertInputPassword: BasicView, UITextFieldDelegate {
    private let bgView = UIView()
    private let centerView = UIView()
    private let titleLab = UILabel()
    private let inputTF = InputPasswordTF(frame: .zero)
    private let cancelBtn = UIButton()
    private let confirmBtn = UIButton()
    private let scanBtn = UIButton()
    private let line = UIView()
    private let line1 = UIView()
    var callback: ((_ inputText: String) -> Void)?
    private var centerYConstraint: Constraint?
    private var bottomConstraint: Constraint?

    override func initUI() {
        super.initUI()
        backgroundColor = UIColor.clear
        bgView.backgroundColor = UIColor.eHex("#000000", alpha: 0.3)

        addSubview(bgView)
        bgView.addSubview(centerView)
        centerView.addSubview(titleLab)
        centerView.addSubview(inputTF)
        centerView.addSubview(cancelBtn)
        centerView.addSubview(confirmBtn)
        centerView.addSubview(scanBtn)
        centerView.addSubview(line)
        centerView.addSubview(line1)

        centerView.backgroundColor = UIColor.white
        centerView.layer.cornerRadius = 16
        centerView.layer.masksToBounds = true

        titleLab.text = R.Language.lan("Enter Password")//R.localStr.enterPassword()
        titleLab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLab.textColor = RResources.color.fontBackText242424()
        titleLab.textAlignment = .center

        line.backgroundColor = RResources.color.lineColorF7F7F7()
        line1.backgroundColor = RResources.color.lineColorF7F7F7()

        inputTF.placeholder = R.localStr.enterPassword()
        inputTF.delegate = self

        cancelBtn.setTitle(R.localStr.cancel(), for: .normal)
        cancelBtn.setTitleColor(R.color.fontBackText_40(), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)

        confirmBtn.setTitle(R.localStr.oK(), for: .normal)
        confirmBtn.setTitleColor(R.color.btnBlueText(), for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)

        scanBtn.setTitle(R.localStr.scanQRCodeToLogIn(), for: .normal)
        scanBtn.setTitleColor(R.color.fontBackText_90(), for: .normal)
        scanBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(220)
            make.centerX.equalToSuperview()
            centerYConstraint = make.centerY.equalToSuperview().constraint
            bottomConstraint = make.bottom.equalToSuperview().inset(0).constraint
        }
        bottomConstraint?.deactivate()

        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(25)
        }

        inputTF.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        scanBtn.snp.makeConstraints { make in
            make.top.equalTo(inputTF.snp.bottom).offset(8)
            make.right.equalToSuperview().inset(32)
            make.height.equalTo(20)
        }

        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(cancelBtn.snp.top)
            make.height.equalTo(1)
        }

        line1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(1)
            make.bottom.equalToSuperview()
        }

        cancelBtn.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(50)
            make.right.equalTo(confirmBtn.snp.left)
            make.width.equalTo(confirmBtn.snp.width)
        }

        confirmBtn.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(cancelBtn.snp.width)
        }
        // 注册键盘通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(beHidden)))
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                JLLogManager.logLevel(.DEBUG, content: "AlertInputPassword didMoveToWindow → becomeFirstResponder")
                self.inputTF.becomeFirstResponder()
            }
        }
    }
    
    @objc private func beHidden() {
        AlertManager.hiddenInputPasswordView()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = frame.height
        JLLogManager.logLevel(.DEBUG, content: "keyboardWillShow height: \(keyboardHeight)")
        bottomConstraint?.activate()
        centerYConstraint?.deactivate()
        bottomConstraint?.update(inset: keyboardHeight + 16)
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(_: Notification) {
        JLLogManager.logLevel(.DEBUG, content: "keyboardWillHide")
        bottomConstraint?.deactivate()
        centerYConstraint?.activate()
        let duration = 0.25
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }

    override func initData() {
        super.initData()
        cancelBtn.rx.tap.subscribe { _ in
            AlertManager.hiddenInputPasswordView()
        }.disposed(by: disposeBag)

        confirmBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.callback?(self.inputTF.text ?? "")
        }.disposed(by: disposeBag)

        scanBtn.rx.tap.subscribe { _ in
            AlertManager.hiddenInputPasswordView()
            let qrVc = QRScanerViewController()
            qrVc.handleScanResult = { result in
                let tempDt = result.data(using: .utf8)
                if let json = try? JSONSerialization.jsonObject(with: tempDt!,
                                                                options: .mutableContainers) as? [String: String] {
                    self.inputTF.text = json["code"]
                    qrVc.navigationController?.popViewController(animated: true)
                }
            }
            self.contextView?.navigationController?.pushViewController(qrVc, animated: true)
        }.disposed(by: disposeBag)
    }

    func resetInput() {
        inputTF.reset()
    }

    func focusInput() {
        JLLogManager.logLevel(.DEBUG, content: "AlertInputPassword focusInput → becomeFirstResponder")
        inputTF.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        callback?(textField.text ?? "")
        return true
    }
}

/// 密码输入框：包含显示/隐藏密码、内边距与清空逻辑
class InputPasswordTF: UITextField {
    private let padding: CGFloat = 20
    private let rightBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    private let disposeBag = DisposeBag()

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return CGRect(x: rect.minX + padding, y: rect.minY, width: rect.width - padding * 2, height: rect.height)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return CGRect(x: rect.minX + padding, y: rect.minY, width: rect.width - padding * 2, height: rect.height)
    }

    override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.rightViewRect(forBounds: bounds)
        return CGRect(x: rect.maxX - padding, y: rect.minY, width: rect.width - padding * 2, height: rect.height)
    }

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.clearButtonRect(forBounds: bounds)
        return CGRect(x: rect.maxX - padding, y: rect.minY, width: rect.width, height: rect.height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textColor = R.color.fontBackText242424()
        keyboardType = .default
        isSecureTextEntry = true
        borderStyle = .none
        layer.cornerRadius = 4
        backgroundColor = R.color.fontGrayTextF0F0F0()
        clearButtonMode = .always

        rightBtn.setImage(R.image.icon_close_nol(), for: .normal)
        rightView = rightBtn
        rightViewMode = .unlessEditing
        rightBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.isSecureTextEntry = !self.isSecureTextEntry
            if self.isSecureTextEntry {
                self.rightBtn.setImage(R.image.icon_close_nol(), for: .normal)
            } else {
                self.rightBtn.setImage(R.image.icon_open_nol(), for: .normal)
            }
        }).disposed(by: disposeBag)
        returnKeyType = .done
    }

    func reset() {
        isSecureTextEntry = true
        rightBtn.setImage(R.image.icon_close_nol(), for: .normal)
        text = ""
    }
}
