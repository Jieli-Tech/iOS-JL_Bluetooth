//
//  LancerEncryptSetVC.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/10/11.
//

import UIKit

class LancerEncryptSetVC: BaseViewController, UITextFieldDelegate {
    private let encryptTF = EncryptTF()
    private let commitBtn = UIButton()
    private let subMaskView = UIView()
    weak var deviceVM: DeviceInfoViewModel?

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.broadcastCode()
        view.addSubview(encryptTF)
        view.addSubview(commitBtn)
        view.addSubview(subMaskView)

        encryptTF.placeholder = R.localStr.pleaseSetBroadcastCode()
        encryptTF.delegate = self

        commitBtn.setTitle(R.localStr.oK(), for: .normal)
        commitBtn.setTitleColor(.white, for: .normal)
        commitBtn.backgroundColor = R.color.btnBlue()
        commitBtn.layer.cornerRadius = 8
        commitBtn.layer.masksToBounds = true

        subMaskView.backgroundColor = .eHex("#ffffff", alpha: 0.35)
        subMaskView.layer.cornerRadius = 8
        subMaskView.layer.masksToBounds = true

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        encryptTF.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(8)
            make.height.equalTo(56)
        }

        commitBtn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaInsets.bottom).inset(44)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        subMaskView.snp.makeConstraints { make in
            make.edges.equalTo(commitBtn)
        }
    }

    override func initData() {
        super.initData()
        commitBtn.rx.tap.subscribe { [self] _ in
            updateEncrypt()
        }.disposed(by: disposeBag)

        navigationView.leftBtn.rx.tap.subscribe { _ in
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        guard let broadcastCode = deviceVM?.auracastLancerManager?.settingMode?.broadcastCode else {
            return
        }
        encryptTF.text = String(data: broadcastCode, encoding: .utf8)
    }

    @objc private func hideKeyboard() {
        encryptTF.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_: UITextField,
                   shouldChangeCharactersIn _: NSRange,
                   replacementString _: String) -> Bool {
        let data = (encryptTF.text ?? "").data(using: .utf8) ?? Data()
        if data.count > 6 && data.count <= 16 {
            subMaskView.isHidden = true
        } else {
            subMaskView.isHidden = false
        }
        return true
    }

    private func updateEncrypt() {
        guard let psw = encryptTF.text else {
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
        guard let status = deviceVM?.auracastLancerManager?.settingMode?.encryptEnabled else { return }
        deviceVM?.auracastLancerManager?.setEncryptEnabled( status, code: psw.data(using: .utf8) ?? Data())
        self.view.makeToast(R.localStr.setBroadcastCodeSuccessfully(), duration: 2, position: .center)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}

private class EncryptTF: UITextField {
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
