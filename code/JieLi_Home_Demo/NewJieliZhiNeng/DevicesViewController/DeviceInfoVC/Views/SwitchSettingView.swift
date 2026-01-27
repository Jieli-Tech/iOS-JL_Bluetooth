//
//  SwitchSettingView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/6/12.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class SwitchSettingView: BasicView {
    private lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.isOn = true
        switchView.onTintColor = .eHex("#7657EC")
        return switchView
    }()
    private lazy var contextLab: UILabel = {
       let lab = UILabel()
        lab.textColor = .eHex("#242424")
        lab.font = R.Font.medium(15)
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()
    private lazy var centerImgv: UIImageView = {
        let imgv = UIImageView()
        return imgv
    }()
    
    var switchBlock: ((Bool) -> Void)?
    
    override func initUI() {
        super.initUI()
        addSubview(switchView)
        addSubview(contextLab)
        addSubview(centerImgv)
        backgroundColor = .white
        
        switchView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        contextLab.snp.makeConstraints { make in
            make.left.equalTo(centerImgv.snp.right).offset(10)
            make.right.equalTo(switchView.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        centerImgv.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
    }
    
    override func initData() {
        super.initData()
        switchView.rx.value.changed.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            
        }).disposed(by: disposeBag)
    }
    
    func config(_ title: String, _ imgv: String, _ switchIsOn: Bool) {
        contextLab.text = title
        centerImgv.image = R.Image.img(imgv)
        switchView.isOn = switchIsOn
    }
    
}
