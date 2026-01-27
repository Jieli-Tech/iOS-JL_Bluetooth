//
//  LanguageSelectVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class LanguageSelectVC: BasicViewController {
    private let languangeSelectView = SelectTraLanguageView()
    private let commonLanView = CommonLanguageView()
    private let confirmBtn = UIButton()
    private let disposeBag = DisposeBag()
    var type: TranslateLanType = .call

    override func initUI() {
        super.initUI()
        
        TranslateVM.shared.twsConfigModel = JL_RunSDK.sharedMe().twsConfigMode

        if type == .call {
            naviView.titleLab.text = LanguageCls.localizableTxt("Call translation")
        }
        if type == .sync {
            naviView.titleLab.text = LanguageCls.localizableTxt("Simultaneous interpretation")
            languangeSelectView.configLanguageTitle(mySide: LanguageCls.localizableTxt("Play"), otherSide: LanguageCls.localizableTxt("Receive"))
            languangeSelectView.configLanguageImage(R.Image.img("translation_icon_our"), R.Image.img("translation_icon_phone"))
        }
        if type == .face {
            naviView.titleLab.text = LanguageCls.localizableTxt("Face-to-face translation")
            languangeSelectView.configLanguageTitle(mySide: LanguageCls.localizableTxt("Wearing headphones"), otherSide: LanguageCls.localizableTxt("Holding mobile phone"))
            languangeSelectView.configLanguageImage(R.Image.img("translation_icon_our"), R.Image.img("translation_icon_phone"))
        }

        let languages = TranslateTools.getLanguages(type)
        languangeSelectView.configLanguage(mySide: languages.0, otherSide: languages.1)
        commonLanView.currentLanguage.accept(languages.0)

        view.addSubview(languangeSelectView)
        view.addSubview(commonLanView)
        view.addSubview(confirmBtn)

        confirmBtn.backgroundColor = .eHex("#7657EC")
        confirmBtn.layer.cornerRadius = 8
        confirmBtn.setTitle(LanguageCls.localizableTxt("confirm"), for: .normal)
        confirmBtn.titleLabel?.font = R.Font.medium(15)
        confirmBtn.setTitleColor(.white, for: .normal)

        languangeSelectView.snp.makeConstraints { make in
            make.top.equalTo(naviView.snp.bottom).offset(6)
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
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
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
        confirmBtn.rx.tap.subscribe(
            onNext: { [weak self] _ in
                guard let self = self else { return }
                TranslateTools.saveLanguages(
                    (
                        self.languangeSelectView.currentMySideLanguage,
                        self.languangeSelectView.currentOtherSideLanguage
                    ),
                    type: type
                )
                if type == .call {
                    TranslateVM.shared.translateLanguage = (
                        self.languangeSelectView.currentMySideLanguage,
                        [self.languangeSelectView.currentOtherSideLanguage]
                    )
                    TranslateVM.shared.translateCallLanguage = (
                        self.languangeSelectView.currentOtherSideLanguage,
                        [self.languangeSelectView.currentMySideLanguage]
                    )
                    if CallTranslationTipsVC.shouldShowTips() {
                        let vc = CallTranslationTipsVC()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        TranslateVM.shared.setMode(type: .call) { _, err in
                            if err != nil {
                                self.view.makeToast(err?.localizedDescription ?? "")
                                return
                            }
                            let vc = CallTranslationVC()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                if type == .sync {
                    TranslateVM.shared.translateLanguage = (self.languangeSelectView.currentOtherSideLanguage,
                                                            [self.languangeSelectView.currentMySideLanguage])
                    TranslateVM.shared.setMode(type: .sync) { _, err in
                        if err != nil {
                            self.view.makeToast(err?.localizedDescription ?? "")
                            return
                        }
                        let vc = SyncTranslationVC()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                if type == .face {
                    TranslateVM.shared.translateLanguage = (self.languangeSelectView.currentOtherSideLanguage,
                                                            [self.languangeSelectView.currentMySideLanguage])
                    TranslateVM.shared.setMode(type: .face) { _, err in
                        if err != nil {
                            self.view.makeToast(err?.localizedDescription ?? "")
                            return
                        }
                        let vc = FaceToFaceTranslateVC()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let languages = TranslateTools.getLanguages(type)
        languangeSelectView.configLanguage(mySide: languages.0, otherSide: languages.1)
        commonLanView.currentLanguage.accept(languages.0)
        TranslateVM.shared.exitMode()
    }
}
