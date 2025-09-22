//
//  AuracastViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class AuracastViewController: BaseViewController {
    private let assistementBtn = UIButton()
    private var assistViewModel: DeviceInfoViewModel?
    override func initData() {
        super.initData()
        assistementBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            AuracastManager.shared.createTransmitters {
                guard let cbp = BleManager.shared.currentPeripheral else { return }
                self.assistViewModel = DeviceInfoViewModel(cbp.identifier.uuidString)
                let vc = ReceiverHelperVC()
                vc.vm = self.assistViewModel
                self.navigationController?.pushViewController( vc, animated: true)
            }
        }).disposed(by: disposeBag)
        navigationView.title = R.localStr.auracastProtocol()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
    
    override func initUI() {
        super.initUI()
        view.addSubview(assistementBtn)
        assistementBtn.setTitle(R.localStr.auracastAssistant(), for: .normal)
        assistementBtn.setTitleColor(.white, for: .normal)
        assistementBtn.backgroundColor = UIColor.random()
        assistementBtn.layer.cornerRadius = 10
        assistementBtn.layer.masksToBounds = true
        
        assistementBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
    }
    
}
