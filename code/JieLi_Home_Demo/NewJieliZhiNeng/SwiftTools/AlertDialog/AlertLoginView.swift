//
//  AlertLoginView.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/10/8.
//

import UIKit

class AlertLoginView: BasicView, UITextFieldDelegate {
    private let bgView = UIView()
    private let centerView = UIView()
    private let titleLab = UILabel()
    private let inputTF = InputPasswordTF(frame: .zero)
    private let btnMaskView = UIView()
    private let scanBtn = UIButton()
    private let loginBtn = UIButton()
    private weak var lancerVM: DeviceInfoViewModel?

    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        addSubview(bgView)
        addSubview(centerView)
        centerView.addSubview(titleLab)
        centerView.addSubview(inputTF)
        centerView.addSubview(scanBtn)
        centerView.addSubview(loginBtn)
        centerView.addSubview(btnMaskView)

        bgView.backgroundColor = UIColor.eHex("#000000", alpha: 0.3)
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBgView)))

        centerView.backgroundColor = UIColor.white
        centerView.layer.cornerRadius = 16
        centerView.layer.masksToBounds = true

        titleLab.text = R.localStr.login()
        titleLab.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLab.textColor = R.color.fontBackText_90()
        titleLab.textAlignment = .center

        inputTF.placeholder = R.localStr.enterPassword()
        inputTF.delegate = self

        scanBtn.setTitle(R.localStr.scanQRCodeToLogIn(), for: .normal)
        scanBtn.setTitleColor(R.color.fontBackText_90(), for: .normal)
        scanBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        loginBtn.setTitle(R.localStr.login(), for: .normal)
        loginBtn.setTitleColor(.white, for: .normal)
        loginBtn.backgroundColor = R.color.switchColor()
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        loginBtn.layer.cornerRadius = 24
        loginBtn.layer.masksToBounds = true

        btnMaskView.backgroundColor = .eHex("#000000", alpha: 0.2)
        btnMaskView.layer.cornerRadius = 24
        btnMaskView.layer.masksToBounds = true

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(278)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        titleLab.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(25)
            make.height.equalTo(24)
        }

        inputTF.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }

        scanBtn.snp.makeConstraints { make in
            make.top.equalTo(inputTF.snp.bottom).offset(12)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(38)
        }

        loginBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(40)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        btnMaskView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(40)
            make.left.right.equalToSuperview().inset(24)
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

    @objc func tapBgView() {
        inputTF.resignFirstResponder()
        AlertManager.hiddenLoginView()
        reset()
    }

    private func reset() {
        btnMaskView.isHidden = false
        inputTF.reset()
    }

    override func initData() {
        super.initData()

        loginBtn.rx.tap.subscribe { _ in
            let password = self.inputTF.text ?? ""
            self.lancerVM?.auracastLancerManager?.loginVerify(password) { status in
                if status != .lancerLoginVerifyTypeSuccess {
                    self.makeToast(R.localStr.loginFailed(), position: .center)
                }else{
                    self.reset()
                }
            }
        }.disposed(by: disposeBag)

        scanBtn.rx.tap.subscribe { _ in
            AlertManager.hiddenLoginView()
            let qrVc = QRScanerViewController()
            qrVc.handleScanResult = { result in
                let tempDt = result.data(using: .utf8)
                if let json = try? JSONSerialization.jsonObject(with: tempDt!,
                                                                options: .mutableContainers) as? [String: String] {
                    self.inputTF.text = json["loginPassword"]
                    self.btnMaskView.isHidden = true
                    qrVc.navigationController?.popViewController(animated: true)
                    AlertManager.showLoginView(lancerVm: self.lancerVM!, contextView: self.contextView)
                }
            }
            self.contextView?.navigationController?.pushViewController(qrVc, animated: true)
        }.disposed(by: disposeBag)
    }

    func textField(_: UITextField,
                   shouldChangeCharactersIn _: NSRange,
                   replacementString _: String) -> Bool {
        if (inputTF.text?.count ?? 0) > 6 {
            btnMaskView.isHidden = false
        } else {
            btnMaskView.isHidden = true
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.count ?? 0 < 6 {
            makeToast(R.localStr.pleaseEnterAPasswordOfAtLeast6Characters(), position: .center)
            return false
        }
        let password = inputTF.text ?? ""
        lancerVM?.auracastLancerManager?.loginVerify(password) { status in
            if status != .lancerLoginVerifyTypeSuccess {
                self.makeToast(R.localStr.loginFailed(), position: .center)
            }else{
                self.reset()
            }
        }
        return true
    }
}
