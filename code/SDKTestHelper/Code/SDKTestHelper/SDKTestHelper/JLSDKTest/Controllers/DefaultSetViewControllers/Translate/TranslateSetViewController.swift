//
//  TranslateSetViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/17.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class TranslateSetViewController: BaseViewController, UITextFieldDelegate {

    let titleLab = UILabel()
    let accessKeyInput = InputView()
    let secretKeyInput = InputView()
    let appidInput = InputView()
    let accessTokenInput = InputView()
    let secretKeyInput2 = InputView()
    let configBtn = UIButton()
    let scanBtn = UIButton()
    
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Translate Set"
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(titleLab)
        view.addSubview(accessKeyInput)
        view.addSubview(secretKeyInput)
        view.addSubview(appidInput)
        view.addSubview(accessTokenInput)
        view.addSubview(secretKeyInput2)
        view.addSubview(scanBtn)
        view.addSubview(configBtn)
        
        accessKeyInput.textField.delegate = self
        accessKeyInput.textField.isSecureTextEntry = true
        secretKeyInput.textField.delegate = self
        secretKeyInput.textField.isSecureTextEntry = true
        appidInput.textField.delegate = self
        appidInput.textField.isSecureTextEntry = true
        accessTokenInput.textField.delegate = self
        accessTokenInput.textField.isSecureTextEntry = true
        secretKeyInput2.textField.delegate = self
        secretKeyInput2.textField.isSecureTextEntry = true

        accessKeyInput.textField.tag = 0
        secretKeyInput.textField.tag = 1
        appidInput.textField.tag = 2
        accessTokenInput.textField.tag = 3
        secretKeyInput2.textField.tag = 4
        
        accessKeyInput.configure(title: "Access Key Id", placeholder: "input Access Key Id")
        secretKeyInput.configure(title: "Secret Access Key", placeholder: "input Secret Access Key")
        appidInput.configure(title: "TTS App Id", placeholder: "input App Id")
        accessTokenInput.configure(title: "TTS Access Token", placeholder: "input tts Access Token")
        secretKeyInput2.configure(title: "TTS Secret Key", placeholder: "input tts Secret Key")
        
        accessKeyInput.contextView = self
        secretKeyInput.contextView = self
        appidInput.contextView = self
        accessTokenInput.contextView = self
        secretKeyInput2.contextView = self
        
        accessKeyInput.textField.autocorrectionType = .no
        secretKeyInput.textField.autocorrectionType = .no
        appidInput.textField.autocorrectionType = .no
        accessTokenInput.textField.autocorrectionType = .no
        secretKeyInput2.textField.autocorrectionType = .no
        
        accessKeyInput.textField.keyboardType = .asciiCapable
        secretKeyInput.textField.keyboardType = .asciiCapable
        appidInput.textField.keyboardType = .asciiCapable
        accessTokenInput.textField.keyboardType = .asciiCapable
        secretKeyInput2.textField.keyboardType = .asciiCapable
        
        accessKeyInput.textField.returnKeyType = .next
        secretKeyInput.textField.returnKeyType = .next
        appidInput.textField.returnKeyType = .next
        accessTokenInput.textField.returnKeyType = .next
        secretKeyInput2.textField.returnKeyType = .done
        
        accessKeyInput.textField.text = KeyAuth.ByteDance.getAiAuth()?.accessKeyId
        secretKeyInput.textField.text = KeyAuth.ByteDance.getAiAuth()?.secretAccessKey
        appidInput.textField.text = KeyAuth.ByteDance.getAiAuth()?.appid
        accessTokenInput.textField.text = KeyAuth.ByteDance.getAiAuth()?.accessToken
        secretKeyInput2.textField.text = KeyAuth.ByteDance.getAiAuth()?.secretKey
        
        scanBtn.setTitle("Scan", for: .normal)
        scanBtn.setTitleColor(.white, for: .normal)
        scanBtn.backgroundColor = .random()
        scanBtn.layer.cornerRadius = 10
        scanBtn.layer.masksToBounds = true
        
        configBtn.setTitle("Config", for: .normal)
        configBtn.setTitleColor(.white, for: .normal)
        configBtn.backgroundColor = .random()
        configBtn.layer.cornerRadius = 10
        configBtn.layer.masksToBounds = true
        
        accessKeyInput.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        secretKeyInput.snp.makeConstraints { make in
            make.top.equalTo(accessKeyInput.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        appidInput.snp.makeConstraints { make in
            make.top.equalTo(secretKeyInput.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        accessTokenInput.snp.makeConstraints { make in
            make.top.equalTo(appidInput.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        secretKeyInput2.snp.makeConstraints { make in
            make.top.equalTo(accessTokenInput.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        scanBtn.snp.makeConstraints { make in
            make.top.equalTo(secretKeyInput2.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        configBtn.snp.makeConstraints { make in
            make.top.equalTo(scanBtn.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            secretKeyInput.textField.becomeFirstResponder()
        } else if textField.tag == 1 {
            appidInput.textField.becomeFirstResponder()
        } else if textField.tag == 2 {
            accessTokenInput.textField.becomeFirstResponder()
        } else if textField.tag == 3 {
            secretKeyInput2.textField.becomeFirstResponder()
        } else if textField.tag == 4 {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func initData() {
        super.initData()
        configBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            guard let accessKey = self.accessKeyInput.textField.text,
                  let secretKey = self.secretKeyInput.textField.text,
                  let appid = self.appidInput.textField.text,
                  let accessToken = self.accessTokenInput.textField.text,
                  let secret = self.secretKeyInput2.textField.text
            else {
                return
            }
            let _ = KeyAuth.ByteDance.init(accessKeyId: accessKey, secretAccessKey: secretKey, appid: appid, accessToken: accessToken, secretKey: secret, updateTime: Int64(Date().timeIntervalSince1970))
            view.makeToast("Save Success !!", position: .center)
        }.disposed(by: disposeBag)
        scanBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            let vc = QRScanerViewController()
            vc.handleScanResult = { [weak self] result in
                guard let `self` = self else {
                    return
                }
                let auth = KeyAuth.makeAuth(result)
                self.accessKeyInput.textField.text = auth.accessKeyId
                self.secretKeyInput.textField.text = auth.secretAccessKey
                self.appidInput.textField.text = auth.appid
                self.accessTokenInput.textField.text = auth.accessToken
                self.secretKeyInput2.textField.text = auth.secretKey
                self.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }

}
