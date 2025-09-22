//
//  SyncTraBottomView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/27.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class SyncTraBottomView: BasicView {
    let languageBtn = UIButton()
    private let lineView = UIView()
    private let controlBtn = UIButton()
    private let stopBtn = UIButton()

    override func initUI() {
        super.initUI()
        backgroundColor = .white
        lineView.backgroundColor = .eHex("#EBEBEB")

        languageBtn.setImage(R.Image.img("icon_language"), for: .normal)
        languageBtn.setTitle(LanguageCls.localizableTxt("Language"), for: .normal)
        languageBtn.setTitleColor(.eHex("#000000", alpha: 0.8), for: .normal)
        languageBtn.titleLabel?.font = R.Font.medium(13)
        languageBtn.layoutButtonImageTopTitleBottom()

        controlBtn.setImage(R.Image.img("icon_pause"), for: .normal)
        stopBtn.setImage(R.Image.img("icon_end_sync"), for: .normal)

        addSubview(lineView)
        addSubview(languageBtn)
        addSubview(controlBtn)
        addSubview(stopBtn)

        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalToSuperview()
        }
        controlBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(4)
            make.width.height.equalTo(52)
        }
        languageBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalTo(controlBtn)
        }
        stopBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.centerY.equalTo(controlBtn)
        }
    }

    override func initData() {
        super.initData()
        controlBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            JLLogManager.logLevel(.DEBUG, content: "control:\(self)")
        }).disposed(by: disposeBag)

        stopBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
        }).disposed(by: disposeBag)

        languageBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            JLLogManager.logLevel(.DEBUG, content: "language:\(self)")
        }).disposed(by: disposeBag)
    }
}
