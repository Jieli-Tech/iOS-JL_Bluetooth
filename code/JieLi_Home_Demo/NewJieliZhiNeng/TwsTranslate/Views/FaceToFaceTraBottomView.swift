//
//  FaceToFaceTraBottomView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/27.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import RxCocoa
import UIKit

class FaceToFaceTraBottomView: BasicView {
    let languageBtn = UIButton()
    let headPhonesCtrlBtn = UIButton()
    let spectogramView = SpectrogramView()
    private let bgView = UIView()
    private let lineView = UIView()
    private let controlBtn = UIButton()
    private let tipsLab = PaddingLabel()

    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        lineView.backgroundColor = .eHex("#EBEBEB")

        languageBtn.setImage(R.Image.img("icon_language"), for: .normal)
        languageBtn.setTitle(LanguageCls.localizableTxt("Language"), for: .normal)
        languageBtn.setTitleColor(.eHex("#000000", alpha: 0.8), for: .normal)
        languageBtn.titleLabel?.font = R.Font.medium(13)
        languageBtn.layoutButtonImageTopTitleBottom()

        controlBtn.setTitle(LanguageCls.localizableTxt("Press and hold to speak"), for: .normal)
        controlBtn.backgroundColor = .eHex("#7657EC", alpha: 0.08)
        controlBtn.setTitleColor(.eHex("#7657EC"), for: .normal)
        controlBtn.titleLabel?.font = R.Font.medium(13)
        controlBtn.layer.cornerRadius = 8
        controlBtn.layer.masksToBounds = true

        headPhonesCtrlBtn.setImage(R.Image.img("icon_voice_stop"), for: .normal)
        headPhonesCtrlBtn.setTitle(LanguageCls.localizableTxt("Stop recording"), for: .normal)
        headPhonesCtrlBtn.setTitleColor(.eHex("#000000", alpha: 0.8), for: .normal)
        headPhonesCtrlBtn.titleLabel?.font = R.Font.medium(13)
        headPhonesCtrlBtn.layoutButtonImageTopTitleBottom()

        tipsLab.topInset = 4
        tipsLab.bottomInset = 4
        tipsLab.leftInset = 8
        tipsLab.rightInset = 8
        tipsLab.text = R.Language.lan("Release to send/swipe up to cancel")
        tipsLab.font = R.Font.medium(10)
        tipsLab.textColor = .eHex("#FFFFFF")
        tipsLab.backgroundColor = .eHex("#7E7D85")
        tipsLab.layer.cornerRadius = 4
        tipsLab.layer.masksToBounds = true
        tipsLab.isHidden = true

        spectogramView.currentBgColor = .clear
        spectogramView.barColor = .white
        spectogramView.maxVisibleSamples = 50

        bgView.backgroundColor = .white

        addSubview(bgView)
        addSubview(lineView)
        addSubview(languageBtn)
        addSubview(controlBtn)
        addSubview(headPhonesCtrlBtn)
        addSubview(tipsLab)
        controlBtn.addSubview(spectogramView)
        spectogramView.isHidden = true

        bgView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom)
        }

        tipsLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(lineView)
        }

        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalToSuperview().inset(12)
        }
        controlBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-bottomInset / 3)
            make.left.equalTo(languageBtn.snp.right).offset(6)
            make.right.equalTo(headPhonesCtrlBtn.snp.left).offset(-6)
            make.height.equalTo(38)
        }

        languageBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalTo(controlBtn)
            make.right.equalTo(controlBtn.snp.left).offset(-6)
        }
        headPhonesCtrlBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(6)
            make.centerY.equalTo(controlBtn)
        }

        spectogramView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
        }
    }

    override func initData() {
        super.initData()
        // 按下事件
        controlBtn.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                languageBtn.isHidden = true
                headPhonesCtrlBtn.isHidden = true
                controlBtn.setTitle("", for: .normal)
                spectogramView.isHidden = false
                tipsLab.isHidden = false
                controlBtn.backgroundColor = .eHex("#7657EC")
                controlBtn.snp.remakeConstraints { make in
                    make.left.equalToSuperview().inset(16)
                    make.right.equalToSuperview().inset(16)
                    make.centerY.equalToSuperview().offset(-self.bottomInset / 3)
                    make.height.equalTo(38)
                }
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)

        // 在按钮内部松开
        controlBtn.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                resetControlBtn()
            })
            .disposed(by: disposeBag)

        // 在按钮外部松开
        controlBtn.rx.controlEvent(.touchUpOutside)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                resetControlBtn()
            })
            .disposed(by: disposeBag)

        // 手指滑出按钮外部
        controlBtn.rx.controlEvent(.touchDragOutside)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                controlBtn.setTitle(R.Language.lan("Release to cancel"), for: .normal)
                controlBtn.backgroundColor = .eHex("#F07373")
                controlBtn.setTitleColor(.white, for: .normal)
                spectogramView.isHidden = true
                tipsLab.isHidden = true

            })
            .disposed(by: disposeBag)
        // 在按钮内部拖动
        controlBtn.rx.controlEvent(.touchDragInside)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                controlBtn.setTitle("", for: .normal)
                spectogramView.isHidden = false
                controlBtn.backgroundColor = .eHex("#7657EC")
                tipsLab.isHidden = false
            })
            .disposed(by: disposeBag)
        controlBtn.rx.controlEvent(.touchDragExit)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                controlBtn.setTitle(R.Language.lan("Release to cancel"), for: .normal)
                controlBtn.backgroundColor = .eHex("#F07373")
                controlBtn.setTitleColor(.white, for: .normal)
                spectogramView.isHidden = true
                tipsLab.isHidden = true
            })
            .disposed(by: disposeBag)

        controlBtn.rx.controlEvent(.touchDragEnter)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                controlBtn.setTitle("", for: .normal)
                spectogramView.isHidden = false
                controlBtn.backgroundColor = .eHex("#7657EC")
                tipsLab.isHidden = false
            })
            .disposed(by: disposeBag)

        headPhonesCtrlBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
        }).disposed(by: disposeBag)

        languageBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            JLLogManager.logLevel(.DEBUG, content: "language:\(self)")
        }).disposed(by: disposeBag)
    }

    private func resetControlBtn() {
        languageBtn.isHidden = false
        headPhonesCtrlBtn.isHidden = false
        controlBtn.setTitle(R.Language.lan("Press and hold to speak"), for: .normal)
        spectogramView.isHidden = true
        tipsLab.isHidden = true
        controlBtn.backgroundColor = .eHex("#7657EC", alpha: 0.08)
        controlBtn.setTitleColor(.eHex("#7657EC"), for: .normal)
        controlBtn.snp.remakeConstraints { make in
            make.centerY.equalToSuperview().offset(-bottomInset / 3)
            make.left.equalTo(languageBtn.snp.right).offset(6)
            make.right.equalTo(headPhonesCtrlBtn.snp.left).offset(-6)
            make.height.equalTo(38)
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}

class PaddingLabel: UILabel {
    var topInset: CGFloat = 0.0
    var bottomInset: CGFloat = 0.0
    var leftInset: CGFloat = 0.0
    var rightInset: CGFloat = 0.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // 确保内容在 bounds 改变时正确重绘
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}

class FaceToFaceStartTipsView: BasicView {
    private let mainView = UIView()
    private let originalLab = UILabel()
    private let translateLab = UILabel()
    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        mainView.backgroundColor = .eHex("#F3F4F6")
        mainView.layer.cornerRadius = 8
        mainView.layer.masksToBounds = true

        originalLab.textColor = .eHex("#000000", alpha: 0.9)
        originalLab.text = R.Language.lan("Please put on your headphones and click the button below to start the translation.", .en)
        originalLab.numberOfLines = 0
        originalLab.font = R.Font.medium(14)

        translateLab.textColor = .eHex("#000000", alpha: 0.5)
        translateLab.numberOfLines = 0
        translateLab.text = R.Language.lan("Please put on your headphones and click the button below to start the translation.", .zh)
        translateLab.font = R.Font.medium(14)

        addSubview(mainView)
        mainView.addSubview(originalLab)
        mainView.addSubview(translateLab)

        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        originalLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(12)
        }

        translateLab.snp.makeConstraints { make in
            make.top.equalTo(originalLab.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    func configContent(original: String, translate: String, translateColor: UIColor) {
        originalLab.text = original
        translateLab.text = translate
        translateLab.textColor = translateColor
    }
}
