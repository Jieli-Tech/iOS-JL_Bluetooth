//
//  AlertRenameView.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/10/9.
//

import UIKit

class AlertRenameView: BasicView, UITextFieldDelegate {
    private let bgView = UIView()
    private let centerView = UIView()
    private let titleLab = UILabel()
    private let inputTF = RenameTF()
    private let commitBtn = UIButton()
    private let cancelBtn = UIButton()
    private let line = UIView()
    private let line2 = UIView()

    var callback: ((_ inputText: String) -> Void)?

    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        bgView.backgroundColor = UIColor.eHex("#000000", alpha: 0.3)

        addSubview(bgView)
        bgView.addSubview(centerView)
        centerView.addSubview(titleLab)
        centerView.addSubview(inputTF)
        centerView.addSubview(commitBtn)
        centerView.addSubview(cancelBtn)
        centerView.addSubview(line)
        centerView.addSubview(line2)

        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 16
        centerView.layer.masksToBounds = true

        titleLab.text = R.localStr.name()
        titleLab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLab.textColor = R.color.fontBackText242424()
        titleLab.textAlignment = .center

        inputTF.placeholder = R.localStr.pleaseEnterANameOf432Characters()
        inputTF.delegate = self

        commitBtn.setTitle(R.localStr.oK(), for: .normal)
        commitBtn.setTitleColor(R.color.btnBlueText(), for: .normal)
        commitBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)

        cancelBtn.setTitle(R.localStr.cancel(), for: .normal)
        cancelBtn.setTitleColor(R.color.fontBackText_40(), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)

        line.backgroundColor = R.color.lineColorF7F7F7()
        line2.backgroundColor = R.color.lineColorF7F7F7()

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(212)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

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

        commitBtn.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.width.equalTo(cancelBtn.snp.width)
            make.left.equalTo(cancelBtn.snp.right)
            make.height.equalTo(48)
        }

        cancelBtn.snp.makeConstraints { make in
            make.bottom.left.equalToSuperview()
            make.width.equalTo(commitBtn.snp.width)
            make.right.equalTo(commitBtn.snp.left)
            make.height.equalTo(48)
        }

        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(cancelBtn.snp.top)
            make.height.equalTo(1)
        }

        line2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(48)
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
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {
            let keyboardHeight = keyboardSize.height
            var offset: CGFloat = 0
            let yOffset = (UIScreen.main.bounds.size.height / 2 - 110) - keyboardHeight
            if yOffset > 0 {
                offset = yOffset - 60
            }
            // 调整容器视图的位置
            centerView.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(offset)
            }
        }
    }

    @objc func keyboardWillHide(_: Notification) {
        // 调整容器视图的位置
        centerView.snp.updateConstraints { make in
            make.centerY.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        cancelBtn.rx.tap.subscribe { _ in
            self.isHidden = true
            self.removeFromSuperview()
        }.disposed(by: disposeBag)

        commitBtn.rx.tap.subscribe { _ in
            self.inputCallBack()
        }.disposed(by: disposeBag)
    }

    func setName(_ name: String) {
        inputTF.text = name
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        inputCallBack()
        return true
    }

    private func inputCallBack() {
        if !validateInput(inputTF.text ?? "") {
            makeToast(R.localStr.pleaseEnterANameOf432Characters(), position: .center)
            return
        }
        callback?(inputTF.text ?? "")
        isHidden = true
        removeFromSuperview()
    }

    private func isValidLength(_ input: String, minLength: Int, maxLength: Int) -> Bool {
        let byteCount = input.utf8.count
        return byteCount >= minLength && byteCount <= maxLength
    }

    private func validateInput(_ input: String) -> Bool {
        let minLength = 4
        let maxLength = 32
        return isValidLength(input, minLength: minLength, maxLength: maxLength)
    }
}

private class RenameTF: UITextField {
    private let padding: CGFloat = 20

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return CGRect(x: rect.minX + padding, y: rect.minY, width: rect.width - padding * 2, height: rect.height)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return CGRect(x: rect.minX + padding, y: rect.minY, width: rect.width - padding * 2, height: rect.height)
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
        borderStyle = .none
        layer.cornerRadius = 4
        backgroundColor = R.color.fontGrayTextF0F0F0()
        clearButtonMode = .whileEditing
        returnKeyType = .done
    }
}
