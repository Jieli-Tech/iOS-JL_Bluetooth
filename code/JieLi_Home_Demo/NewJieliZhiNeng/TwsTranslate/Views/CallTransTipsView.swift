//
//  CallTransTipsView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

private class CallTipsView: BasicView {
    private let contentView = UIView()
    private let imgv = UIImageView()
    private let tips1Lab = UILabel()
    private let tips2Lab = UILabel()

    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        contentView.backgroundColor = .eHex("#7657EC", alpha: 0.1)
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true

        imgv.image = R.Image.img("translation_icon_assistant")
        imgv.contentMode = .scaleAspectFit

        tips1Lab.text = LanguageCls.localizableTxt("Original voice")
        tips1Lab.textColor = .eHex("#7657EC")
        tips1Lab.font = R.Font.medium(12)

        tips2Lab.text = LanguageCls.localizableTxt("The other party's voice")
        tips2Lab.textColor = .eHex("#000000", alpha: 0.8)
        tips2Lab.font = R.Font.medium(12)
        tips2Lab.textAlignment = .center

        contentView.addSubview(imgv)
        contentView.addSubview(tips1Lab)
        addSubview(contentView)
        addSubview(tips2Lab)

        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
            make.bottom.equalTo(tips2Lab.snp.top).offset(-4)
        }
        imgv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(tips1Lab.snp.left).offset(-4)
            make.height.width.equalTo(16)
        }

        tips1Lab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
        }

        tips2Lab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(4)
        }
    }

    func config(image: UIImage, tips1: String, tips2: String, color: UIColor, alpha: CGFloat) {
        imgv.image = image
        tips1Lab.text = tips1
        tips2Lab.text = tips2
        tips1Lab.textColor = color
        contentView.backgroundColor = color.withAlphaComponent(alpha)
    }
}

class CallTransTipsView: BasicView {
    private let bgView = UIView()
    private let tipsLab = UILabel()
    private let contentLab = UILabel()
    private let imageImgv = UIImageView()
    private let callTipsView1 = CallTipsView()
    private let callTipsView2 = CallTipsView()
    private let confirmBtn = UIButton()
    private let contentView = UIView()

    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        bgView.backgroundColor = .eHex("#000000", alpha: 0.3)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 24
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.masksToBounds = true

        tipsLab.text = LanguageCls.localizableTxt("About call translation")
        tipsLab.textColor = .eHex("#000000", alpha: 0.9)
        tipsLab.font = R.Font.medium(16)
        tipsLab.textAlignment = .center

        contentLab.text = LanguageCls.localizableTxt("During a call, both parties will hear the translated language. The left earphone will play the other party's original voice, and the right earphone will play the translated language as a translation assistant. Please wear both earphones.")
        contentLab.adjustsFontSizeToFitWidth = true
        contentLab.numberOfLines = 0
        contentLab.textColor = .eHex("#000000", alpha: 0.5)
        contentLab.font = R.Font.medium(13)

        imageImgv.image = R.Image.img("img_talking")
        imageImgv.contentMode = .scaleAspectFit

        confirmBtn.setTitle(LanguageCls.localizableTxt("I understand"), for: .normal)
        confirmBtn.setTitleColor(.eHex("#000000", alpha: 0.9), for: .normal)
        confirmBtn.backgroundColor = .eHex("#F6F6F8")
        confirmBtn.layer.cornerRadius = 6
        confirmBtn.titleLabel?.font = R.Font.medium(15)

        callTipsView1.config(image: R.Image.img("translation_icon_assistant"),
                             tips1: LanguageCls.localizableTxt("Translated voice"),
                             tips2: LanguageCls.localizableTxt("Translation assistant"),
                             color: .eHex("#448EFF"), alpha: 0.4)

        callTipsView2.config(image: R.Image.img("translation_icon_voice_16"),
                             tips1: LanguageCls.localizableTxt("Original voice"),
                             tips2: LanguageCls.localizableTxt("The other party's voice"),
                             color: .eHex("#F89514"), alpha: 0.1)

        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(tipsLab)
        contentView.addSubview(contentLab)
        contentView.addSubview(callTipsView1)
        contentView.addSubview(imageImgv)
        contentView.addSubview(callTipsView2)
        contentView.addSubview(confirmBtn)

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        tipsLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(23)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(22)
        }
        contentLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(tipsLab.snp.bottom).offset(12)
        }
        imageImgv.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(contentLab.snp.bottom).offset(16)
            make.height.equalTo(190)
            make.width.equalTo(180)
        }
        callTipsView1.snp.makeConstraints { make in
            make.centerY.equalTo(imageImgv)
            make.centerX.equalTo(imageImgv.snp.left).offset(-20)
        }
        callTipsView2.snp.makeConstraints { make in
            make.centerX.equalTo(imageImgv.snp.right).offset(20)
            make.centerY.equalTo(imageImgv)
        }
        confirmBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
            make.top.equalTo(imageImgv.snp.bottom).offset(34)
            make.bottom.equalToSuperview().inset(30 + self.safeAreaInsets.bottom)
        }
    }

    override func initData() {
        super.initData()
        confirmBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.isHidden = true
        }).disposed(by: disposeBag)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
    }

    @objc private func hide() {
        isHidden = true
    }
}
