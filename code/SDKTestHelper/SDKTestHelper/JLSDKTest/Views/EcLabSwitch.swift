//
//  EcLabSwitch.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/26.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class EcLabSwitch: BaseView {

    private let titleLab = UILabel()
    let swBtn = UISwitch()
    
    override func initUI() {
        super.initUI()
        titleLab.text = "EcLab"
        titleLab.font = .systemFont(ofSize: 15)
        titleLab.textColor = .black
        titleLab.textAlignment = .center
        titleLab.numberOfLines = 0
        titleLab.adjustsFontSizeToFitWidth = true
        addSubview(titleLab)
        addSubview(swBtn)
        titleLab.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(swBtn.snp.left).offset(-10)
        }
        swBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalTo(titleLab)
            make.left.equalTo(titleLab.snp.right).offset(10)
            make.width.equalTo(50)
        }
    }
    
    
    func configSwitch(title: String, isOn: Bool = false) {
        swBtn.isOn = isOn
        swBtn.sendActions(for: .valueChanged)
        titleLab.text = title
    }
    

}
