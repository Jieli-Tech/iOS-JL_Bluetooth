//
//  TraRecordOnlyView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/9.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class TraRecordOnlyView: BaseView {

    private let labSwitch = EcLabSwitch()
    private let spectrogramView = SpectrogramView()
    
    override func initUI() {
        super.initUI()
        addSubview(labSwitch)
        addSubview(spectrogramView)
        labSwitch.configSwitch(title: R.localStr.savePCMData(), isOn: false)
        
        labSwitch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(40)
        }
        
        spectrogramView.snp.makeConstraints { make in
            make.top.equalTo(labSwitch.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    override func initData() {
        super.initData()
        labSwitch.swBtn.rx.value.subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                TranslateVM.shared.saveFilePath = _R.path.pcmPath + "/" + Date().getDateStr + ".pcm"
            } else {
                TranslateVM.shared.saveFilePath = nil
            }
        }).disposed(by: disposeBag)
    }

}
