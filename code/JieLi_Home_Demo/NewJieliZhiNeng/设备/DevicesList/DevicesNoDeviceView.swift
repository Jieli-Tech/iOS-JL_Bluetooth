//
//  DevicesNoDeviceView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class DevicesNoDeviceView: BasicView {
    let noneImgv = UIImageView()
    let noneLab = UILabel()
    override func initUI() {
        super.initUI()
        noneImgv.image = R.Image.img("Theme.bundle/product_img_empty2")
        noneLab.textColor = .eHex("#000000", alpha: 0.65)
        noneLab.font = R.Font.medium(14)
        noneLab.adjustsFontSizeToFitWidth = true
        noneLab.textAlignment = .center
        noneLab.text = LanguageCls.localizableTxt("unconnected_device_tips")
        addSubview(noneImgv)
        addSubview(noneLab)
        noneImgv.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        noneLab.snp.makeConstraints { make in
            make.top.equalTo(noneImgv.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }

}
