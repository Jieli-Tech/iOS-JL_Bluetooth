//
//  AlertPswModifyTip.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/10/10.
//

import UIKit

class AlertPswModifyTip: BasicView {
    private let centerView = UIView()
    private let statusImgv = UIImageView()
    private let titleLab = UILabel()

    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        addSubview(centerView)
        centerView.addSubview(statusImgv)
        centerView.addSubview(titleLab)

        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 8
        centerView.layer.masksToBounds = true

        titleLab.text = R.localStr.passwordChangedSuccessfully()
        titleLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLab.textColor = R.color.fontBackText_90()
        titleLab.textAlignment = .center
        titleLab.adjustsFontSizeToFitWidth = true
        titleLab.numberOfLines = 0

        statusImgv.image = R.image.icon_sucess()
        statusImgv.contentMode = .scaleAspectFit

        centerView.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.center.equalToSuperview()
        }

        statusImgv.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(30)
            make.width.height.equalTo(44)
        }

        titleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(6)
            make.top.equalTo(statusImgv.snp.bottom).offset(16)
        }
    }
}
