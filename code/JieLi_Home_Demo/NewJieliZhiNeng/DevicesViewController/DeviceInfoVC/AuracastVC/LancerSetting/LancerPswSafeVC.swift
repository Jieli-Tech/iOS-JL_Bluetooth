//
//  LancerPswSafeVC.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/10/10.
//

import UIKit

class LancerPswSafeVC: BaseViewController, UITextFieldDelegate {
    var deviceVM: DeviceInfoViewModel?
    private let inputTF = SafePasswordTF()
    private let commitBtn = UIButton()

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.password()
        view.addSubview(inputTF)
        view.addSubview(commitBtn)

        inputTF.placeholder = R.localStr.enterPassword()
        inputTF.delegate = self

        commitBtn.setTitle(R.localStr.modify(), for: .normal)
        commitBtn.setTitleColor(.white, for: .normal)
        commitBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        commitBtn.backgroundColor = R.color.btnBlue()
        commitBtn.layer.cornerRadius = 8
        commitBtn.layer.masksToBounds = true

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        inputTF.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(8)
            make.height.equalTo(56)
        }

        commitBtn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaInsets.bottom).inset(34)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
    }

    override func initData() {
        super.initData()
        inputTF.becomeFirstResponder()
        inputTF.text = deviceVM?.currentLoginPassword
        commitBtn.rx.tap.subscribe { _ in
            self.updatePassword()
        }.disposed(by: disposeBag)
        navigationView.leftBtn.rx.tap.subscribe { _ in
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        inputTF.resignFirstResponder()
        return true
    }

    @objc func hideKeyboard() {
        inputTF.resignFirstResponder()
    }

    private func updatePassword() {
        guard let psw = inputTF.text else {
            return
        }
        if psw.count < 6 {
            view.makeToast(R.localStr.pleaseEnterAPasswordOfAtLeast6Characters())
            return
        }
        if psw.count > 16 {
            view.makeToast(R.localStr.pleaseEnterA16BytePassword())
            return
        }
        guard let oldPwd = deviceVM?.currentLoginPassword else { return }
        deviceVM?.auracastLancerManager?.changePassword(oldPwd, newPassword: psw) { [weak self] result in
            guard let self = self else {
                return
            }
            if result == .success {
                AlertManager.showPswModifyTip()
            }
        }
    }
}

private class SafePasswordTF: UITextField {
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        font = UIFont.systemFont(ofSize: 15, weight: .medium)
        textColor = R.color.fontBackText_90()
        keyboardType = .default
        isSecureTextEntry = true
        borderStyle = .none
        layer.cornerRadius = 4
        backgroundColor = .white

        rightBtn.setImage(R.image.icon_close_nol(), for: .normal)
        rightView = rightBtn
        rightViewMode = .always
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
