//
//  OtaCustomViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/17.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JLUsefulTools

class OtaCustomViewController: BaseViewController, JLOtaCustomDelegate {

    
    let titleLab = UILabel()
    let logView = LogView()
    let switchLabel: UILabel = UILabel()
    let isNeedSwitch = UISwitch()
    let dataInputView: InputView = InputView()
    let dataSendBtn: UIButton = UIButton()
    private var customMgr: JLOtaCustom?
    
  
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.otaCustomCommand()
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
        
        switchLabel.text = R.localStr.needResponseSwitch()
        switchLabel.font = .systemFont(ofSize: 16)
        switchLabel.textColor = .darkGray
        view.addSubview(switchLabel)
        
        isNeedSwitch.isOn = false
        view.addSubview(isNeedSwitch)
        

        dataInputView.configure(title: R.localStr.data(), placeholder: R.localStr.pleaseInputData())
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
            make.bottom.equalTo(switchLabel.snp.top).offset(-10)
        }
        
        switchLabel.snp.makeConstraints { make in
            make.top.equalTo(logView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(30)
        }
        isNeedSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(switchLabel.snp.centerY)
            make.left.equalTo(switchLabel.snp.right).offset(10)
        }
        
        dataInputView.snp.makeConstraints { make in
            make.top.equalTo(switchLabel.snp.bottom).offset(10)
            make.right.left.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }
        
        dataSendBtn.snp.makeConstraints { make in
            make.top.equalTo(dataInputView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(40)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
    
    }
    
    override func initData() {
        super.initData()
        guard let manager = BleManager.shared.currentCmdMgr else { return }
        customMgr = JLOtaCustom(delegate: self, otaManager: manager.mOTAManager)
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        dataSendBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            guard let dataStr = dataInputView.textField.text else { return }
            let data = dataStr.beData
            customMgr?.cmdSendCommand(data, needResponse: isNeedSwitch.isOn, result: { responseData, err in
                if let err = err {
                    self.view.makeToast("\(err)")
                }
                if responseData != nil {
                    self.view.makeToast(R.localStr.respondeDataBytes(String(dataStr.count)))
                }
            })
        }.disposed(by: disposeBag)
    }
    
    
    
    /// 接收到自定义数据
    /// - Parameter data: 自定义数据
    func otaCustomReceive(_ data: JLOtaCustomData) {
        if data.needResponse {
            self.view.makeToast(R.localStr.receiveDataBytesNeedResponse(String(data.data.count)))
        } else {
            self.view.makeToast(R.localStr.receiveDataBytes(String(data.data.count)))
        }
    }
    

}


