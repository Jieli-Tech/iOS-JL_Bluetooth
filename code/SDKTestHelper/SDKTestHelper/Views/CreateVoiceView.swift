//
//  CreateVoiceView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/19.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class CreateVoiceView: BaseView {
    let bgView = UIView()
    let centerView = UIView()
    let tipsLab = UILabel()

    override func initUI() {
        super.initUI()
        addSubview(bgView)
        addSubview(centerView)
        centerView.addSubview(tipsLab)
        backgroundColor = UIColor.clear
        bgView.backgroundColor = .black
        bgView.alpha = 0.4

        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 10
        centerView.layer.masksToBounds = true

        tipsLab.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        tipsLab.textColor = .black
        tipsLab.text = R.localStr.creating()
        tipsLab.textAlignment = .center

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(100)
        }

        tipsLab.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
