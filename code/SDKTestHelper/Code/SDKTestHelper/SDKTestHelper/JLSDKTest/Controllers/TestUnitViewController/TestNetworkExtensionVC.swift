//
//  TestNetworkExtensionVC.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/7/22.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import Foundation
import NetworkExtension
import CoreLocation
import RxSwift
import RxCocoa
import SnapKit

class TestNetworkExtensionVC: BaseViewController, CLLocationManagerDelegate {
    private let ssidInput = InputView()
    private let passwordInput = InputView()
    private let statusLab = UILabel()
    private let connectBtn = UIButton()
    private let disConnectBtn = UIButton()
    private let locationManager = CLLocationManager()
    private var ssid: String?
    private var password: String?
    
    override func initUI() {
        super.initUI()
        navigationView.title = "NetworkExtension"
        navigationView.rightBtn.isHidden = true
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(statusLab)
        view.addSubview(ssidInput)
        view.addSubview(passwordInput)
        view.addSubview(connectBtn)
        view.addSubview(disConnectBtn)
        ssidInput.configure(title: "SSID", placeholder: "Input SSID", SettingInfo.getSSID() ?? "")
        ssidInput.contextView = self
        passwordInput.configure(title: "Password", placeholder: "Input Password", SettingInfo.getPassword())
        passwordInput.contextView = self
        
        statusLab.font = UIFont.systemFont(ofSize: 16)
        statusLab.textColor = .darkText
        statusLab.numberOfLines = 0
        statusLab.textAlignment = .center
        statusLab.adjustsFontSizeToFitWidth = true
        statusLab.text = "Not Connected"
        
        connectBtn.setTitle("Connect", for: .normal)
        connectBtn.setTitleColor(.white, for: .normal)
        connectBtn.layer.cornerRadius = 10
        connectBtn.layer.masksToBounds = true
        connectBtn.backgroundColor = .random()
        
        disConnectBtn.setTitle("Disconnect", for: .normal)
        disConnectBtn.setTitleColor(.white, for: .normal)
        disConnectBtn.layer.cornerRadius = 10
        disConnectBtn.layer.masksToBounds = true
        disConnectBtn.backgroundColor = .random()
        
        ssidInput.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(40)
        }
        
        passwordInput.snp.makeConstraints { make in
            make.top.equalTo(ssidInput.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(40)
        }
        
        statusLab.snp.makeConstraints { make in
            make.top.equalTo(passwordInput.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(40)
        }
        
        connectBtn.snp.makeConstraints { make in
            make.top.equalTo(statusLab.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(40)
        }
        
        disConnectBtn.snp.makeConstraints { make in
            make.top.equalTo(connectBtn.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(40)
        }
        
    }
    
    override func initData() {
        super.initData()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        connectBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.connect()
        }).disposed(by: disposeBag)
        disConnectBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.disconnect()
        }).disposed(by: disposeBag)
        ssidInput.textField.rx.text.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            self.ssid = text
        }).disposed(by: disposeBag)
        
        passwordInput.textField.rx.text.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            self.password = text
        }).disposed(by: disposeBag)
        
        self.ssid = SettingInfo.getSSID()
        self.password = SettingInfo.getPassword()
        
    }
    
    private func connect() {
        guard let ssid = ssid, let password = password else { return }
        let configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        configuration.joinOnce = true
        NEHotspotConfigurationManager.shared.apply(configuration) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                if (error as NSError).code == NEHotspotConfigurationError.alreadyAssociated.rawValue {
                    JLLogManager.logLevel(.DEBUG, content: "⚠️ 已连接到网络")
                    self.statusLab.text = "Already connected to network"
                } else {
                    JLLogManager.logLevel(.DEBUG, content: "❌ 连接失败: \(error)")
                    self.statusLab.text = error.localizedDescription
                }
            } else {
                JLLogManager.logLevel(.DEBUG, content: "✅ 成功连接到 \(String(describing: self.ssid))")
                self.statusLab.text = "Connected to \(String(describing: self.ssid))"
                SettingInfo.saveSSID(ssid)
                SettingInfo.savePassword(password)
            }
        }
    }
    
    private func disconnect() {
        guard let ssid = ssid else { return }
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
        JLLogManager.logLevel(.DEBUG, content: "🔌 移除配置，断开 \(ssid)")
        statusLab.text = "Disconnected from \(ssid)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            JLLogManager.logLevel(.DEBUG, content: "已授权")
        }else{
            JLLogManager.logLevel(.DEBUG, content: "未授权")
        }
    }
    
}

