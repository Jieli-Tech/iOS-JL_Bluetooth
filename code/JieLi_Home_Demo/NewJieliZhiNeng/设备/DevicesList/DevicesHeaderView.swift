//
//  DevicesHeaderView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class DevicesHeaderView: BasicView {
    let bgImgv = UIImageView()
    let addDeviceBtn = UIButton()
    let settingBtn = UIButton()
    override func initUI() {
        super.initUI()
        bgImgv.image = R.Image.img("Theme.bundle/product_bg_img")
        addSubview(bgImgv)
        bgImgv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addDeviceBtn.setImage(R.Image.img("Theme.bundle/product_icon_add"), for: .normal)
        addDeviceBtn.semanticContentAttribute = .forceLeftToRight
        addDeviceBtn.titleLabel?.font = R.Font.medium(16)
        addDeviceBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        addDeviceBtn.setTitleColor(UIColor.eHex("#FFFFFF"), for: .normal)
        addDeviceBtn.setTitle(LanguageCls.localizableTxt("add_device"), for: .normal)
        addSubview(addDeviceBtn)
        addDeviceBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(11)
            make.width.equalTo(86)
        }
        
        settingBtn.setImage(R.Image.img("Theme.bundle/mul_icon_settle_nor"), for: .normal)
        settingBtn.semanticContentAttribute = .forceLeftToRight
        settingBtn.titleLabel?.font = R.Font.medium(12)
        settingBtn.setTitleColor(UIColor.eHex("#FFFFFF"), for: .normal)
        addSubview(settingBtn)
        settingBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalTo(addDeviceBtn)
            make.height.width.equalTo(40)
        }
    }
    
}

