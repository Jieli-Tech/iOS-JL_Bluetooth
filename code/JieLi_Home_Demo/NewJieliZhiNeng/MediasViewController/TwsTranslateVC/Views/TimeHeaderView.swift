//
//  TimeHeaderView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/26.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class TimeHeaderView: BasicView {
    private let timeLab = UILabel()
    private let originalImgv = UIImageView()
    private let originalLab = UILabel()
    private let switchImgv = UIImageView()
    private let translateImgv = UIImageView()
    private let translateLab = UILabel()

    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        timeLab.text = "00:00:00"
        timeLab.textColor = .eHex("#000000", alpha: 0.9)
        timeLab.font = R.Font.medium(18)
        timeLab.textAlignment = .center

        originalImgv.image = R.Image.img("translation_icon_our")
        originalLab.text = "英语"
        originalLab.textColor = .eHex("#000000", alpha: 0.5)
        originalLab.font = R.Font.regular(12)
        originalLab.adjustsFontSizeToFitWidth = true
        originalLab.textAlignment = .center

        switchImgv.image = R.Image.img("translation_icon_change_16")

        translateImgv.image = R.Image.img("translation_icon_other")
        translateLab.text = "中文"
        translateLab.textColor = .eHex("#000000", alpha: 0.5)
        translateLab.font = R.Font.regular(12)
        translateLab.adjustsFontSizeToFitWidth = true
        translateLab.textAlignment = .center

        addSubview(timeLab)
        addSubview(originalImgv)
        addSubview(originalLab)
        addSubview(switchImgv)
        addSubview(translateImgv)
        addSubview(translateLab)

        timeLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
        }
        originalImgv.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerY.equalTo(originalLab.snp.centerY)
            make.right.equalTo(originalLab.snp.left).offset(-2)
        }
        originalLab.snp.makeConstraints { make in
            make.left.equalTo(originalImgv.snp.right).offset(2)
            make.right.equalTo(switchImgv.snp.left).offset(-2)
            make.centerY.equalTo(switchImgv)
            make.width.equalTo(translateLab.snp.width)
        }

        switchImgv.snp.makeConstraints { make in
            make.top.equalTo(timeLab.snp.bottom).offset(2)
            make.width.height.equalTo(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
        translateLab.snp.makeConstraints { make in
            make.left.equalTo(switchImgv.snp.right).offset(2)
            make.right.equalTo(translateImgv.snp.left).offset(-2)
            make.centerY.equalTo(switchImgv)
            make.width.equalTo(originalLab.snp.width)
        }
        translateImgv.snp.makeConstraints { make in
            make.left.equalTo(translateLab.snp.right).offset(2)
            make.width.height.equalTo(12)
            make.centerY.equalTo(translateLab.snp.centerY)
        }
    }

    func setTime(time: String) {
        timeLab.text = time
    }

    func configText(_ original: String, _ translate: String) {
        originalLab.text = original
        translateLab.text = translate
    }

    func configSwitch(_ swImage: UIImage) {
        switchImgv.image = swImage
    }

    func configImage(_ original: UIImage, _ translate: UIImage) {
        originalImgv.image = original
        translateImgv.image = translate
    }
}
