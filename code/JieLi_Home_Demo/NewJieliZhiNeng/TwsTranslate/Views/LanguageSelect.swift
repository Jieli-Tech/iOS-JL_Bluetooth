//
//  LanguageSelect.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/27.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class LanguageSelect: BasicView {
    private let bgView = UIView()
    private let centerView = UIView()
    private let languangeSelectView = SelectTraLanguageView()
    private let commonLanView = CommonLanguageView()
    let confirmBtn = UIButton()

    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        bgView.backgroundColor = .eHex("#000000", alpha: 0.3)
        addSubview(bgView)
        centerView.backgroundColor = .eHex("#F8FAFC")
        centerView.layer.cornerRadius = 24
        centerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        addSubview(centerView)
        centerView.addSubview(languangeSelectView)
        centerView.addSubview(commonLanView)
        centerView.addSubview(confirmBtn)

        confirmBtn.backgroundColor = .eHex("#7657EC")
        confirmBtn.layer.cornerRadius = 8
        confirmBtn.setTitle(LanguageCls.localizableTxt("confirm"), for: .normal)
        confirmBtn.titleLabel?.font = R.Font.medium(15)
        confirmBtn.setTitleColor(.white, for: .normal)

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        centerView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.85)
        }

        languangeSelectView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.right.equalToSuperview()
            make.height.equalTo(76)
        }

        commonLanView.snp.makeConstraints { make in
            make.top.equalTo(languangeSelectView.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
            make.height.equalTo(136)
        }

        confirmBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(16 + bottomInset)
        }
    }

    override func initData() {
        super.initData()
        commonLanView.currentLanguage.subscribe(onNext: { [weak self] type in
            guard let self = self else { return }
            languangeSelectView.configLanguage(typeMode: type)
        }).disposed(by: disposeBag)
        languangeSelectView.currentLanguageType.subscribe(onNext: { [weak self] type in
            guard let self = self else { return }
            commonLanView.currentLanguage.accept(type)
        }).disposed(by: disposeBag)
        bgView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(disAction)))
    }

    @objc private func disAction() {
        confirmBtn.sendActions(for: .valueChanged)
    }
}
