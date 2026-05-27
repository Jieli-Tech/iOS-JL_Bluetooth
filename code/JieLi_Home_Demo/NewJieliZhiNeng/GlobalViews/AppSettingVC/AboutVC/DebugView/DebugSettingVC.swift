//
//  DebugSettingVC.swift
//  JLPiHome
//
//  Created by EzioChan on 2026/3/27.
//  Copyright © 2026 杰理科技. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

@objcMembers
class DebugSettingVC: BaseViewController {
    private let devAuthEmbleLab = UILabel()
    private let devAuthSwitch = UISwitch()
    private let devLocalOTALab = UILabel()
    private let devLocalOTASwitch = UISwitch()
    private let toNextdebugCmdViewBtn = UIButton()
    
    @objc static func isOTALocalTest()-> Bool {
        return UserDefaults.standard.bool(forKey: "Debug_DevLocalOTAEnable")
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = "调试设置"
        navigationView.rightBtn.setTitle("保存", for: .normal)
        navigationView.rightBtn.setTitleColor(.black, for: .normal)
        navigationView.rightBtn.isHidden = false
        
        view.backgroundColor = .white
        
        devAuthEmbleLab.text = "设备认证使能"
        devAuthEmbleLab.font = UIFont.systemFont(ofSize: 16)
        devAuthEmbleLab.textColor = .black
        view.addSubview(devAuthEmbleLab)
        
        view.addSubview(devAuthSwitch)
        
        devLocalOTALab.text = "本地OTA测试"
        devLocalOTALab.font = UIFont.systemFont(ofSize: 16)
        devLocalOTALab.textColor = .black
        view.addSubview(devLocalOTALab)
        
        view.addSubview(devLocalOTASwitch)
        
        toNextdebugCmdViewBtn.setTitle("进入调试指令界面", for: .normal)
        toNextdebugCmdViewBtn.setTitleColor(.white, for: .normal)
        toNextdebugCmdViewBtn.backgroundColor = .systemBlue
        toNextdebugCmdViewBtn.layer.cornerRadius = 8
        view.addSubview(toNextdebugCmdViewBtn)
        
        devAuthEmbleLab.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(24)
        }
        
        devAuthSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(devAuthEmbleLab)
            make.right.equalToSuperview().offset(-24)
        }
        
        devLocalOTALab.snp.makeConstraints { make in
            make.top.equalTo(devAuthEmbleLab.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(24)
        }
        
        devLocalOTASwitch.snp.makeConstraints { make in
            make.centerY.equalTo(devLocalOTALab)
            make.right.equalToSuperview().offset(-24)
        }
        
        toNextdebugCmdViewBtn.snp.makeConstraints { make in
            make.top.equalTo(devLocalOTALab.snp.bottom).offset(60)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(50)
        }
        
        // 初始化读取持久化配置，若 Debug_DevAuthEnable 未设置过（为空），则默认值为 true
        devAuthSwitch.isOn = UserDefaults.standard.value(forKey: "Debug_DevAuthEnable") as? Bool ?? true
        devLocalOTASwitch.isOn = UserDefaults.standard.bool(forKey: "Debug_DevLocalOTAEnable")
    }
    
    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        navigationView.rightBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            // 保存配置到持久化
            UserDefaults.standard.set(self.devAuthSwitch.isOn, forKey: "Debug_DevAuthEnable")
            UserDefaults.standard.set(self.devLocalOTASwitch.isOn, forKey: "Debug_DevLocalOTAEnable")
            UserDefaults.standard.synchronize()
            
            // 提示保存成功
            self.view.makeToast("保存成功", position: .center)
        }.disposed(by: disposeBag)
        
        toNextdebugCmdViewBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            let nextVC = DebugFuncsViewController()
            self.navigationController?.pushViewController(nextVC, animated: true)
        }.disposed(by: disposeBag)
    }
}
