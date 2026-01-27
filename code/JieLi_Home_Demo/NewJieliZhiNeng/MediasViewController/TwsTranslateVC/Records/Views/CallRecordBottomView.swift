//
//  CallRecordBottomView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/8/26.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation

class CallRecordBottomView: BasicView {
    let playOriginBtn = UIButton()
    let playTranslateBtn = UIButton()
    private let lineView = UIView()
    override func initUI() {
        super.initUI()
        setupUI()
        setupLayout()
    }

    private func setupUI() {
        lineView.backgroundColor = .eHex("#000000", alpha: 0.08)

        playOriginBtn.setImage(R.Image.img("icon_voice_initial"), for: .normal)
        playOriginBtn.backgroundColor = .eHex("#FFAE44", alpha: 0.1)
        playOriginBtn.titleLabel?.font = R.Font.medium(16)
        playOriginBtn.setTitleColor(.eHex("#F89514"), for: .normal)
        playOriginBtn.layer.cornerRadius = 12
        playOriginBtn.layer.masksToBounds = true
        playOriginBtn.setTitle(R.Language.lan("Play original"), for: .normal)
        playOriginBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        playOriginBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        playOriginBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        playOriginBtn.semanticContentAttribute = .forceLeftToRight
        playOriginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        playTranslateBtn.setImage(R.Image.img("icon_voice_tanslation"), for: .normal)
        playTranslateBtn.setTitle(R.Language.lan("Play translated"), for: .normal)
        playTranslateBtn.backgroundColor = .eHex("#448EFF", alpha: 0.1)
        playTranslateBtn.titleLabel?.font = R.Font.medium(16)
        playTranslateBtn.setTitleColor(.eHex("#448EFF"), for: .normal)
        playTranslateBtn.layer.cornerRadius = 12
        playTranslateBtn.layer.masksToBounds = true
        playTranslateBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        playTranslateBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        playTranslateBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        playTranslateBtn.semanticContentAttribute = .forceLeftToRight
        playTranslateBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }

    private func setupLayout() {
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        addSubview(playOriginBtn)
        addSubview(playTranslateBtn)

        playOriginBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(playTranslateBtn.snp.left).offset(-20)
            make.width.equalTo(playTranslateBtn)
            make.top.equalTo(lineView.snp.bottom).offset(14)
            make.height.equalTo(46)
        }
        playTranslateBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.left.equalTo(playOriginBtn.snp.right).offset(20)
            make.width.equalTo(playOriginBtn)
            make.top.equalTo(lineView.snp.bottom).offset(14)
            make.height.equalTo(46)
        }
    }

    override func initData() {
        super.initData()
    }
}
