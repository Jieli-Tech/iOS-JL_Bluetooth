//
//  FaceToFaceTranslateVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/27.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class FaceToFaceTranslateVC: BasicViewController {
    var dataVM: FaceToFaceTranslateVM?
    let lanSelectView = LanguageSelect()
    let bottomView = FaceToFaceTraBottomView()
    private let headerView = TimeHeaderView()
    private let tipsView = FaceToFaceStartTipsView()
    private let chatView = ChatDialogView()
    private let disposeBag = DisposeBag()
    private let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0

    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(tipsView)
        view.addSubview(chatView)
        view.addSubview(bottomView)
        view.addSubview(lanSelectView)

        headerView.configImage(R.Image.img("translation_icon_our"), R.Image.img("translation_icon_phone"))
        headerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(naviView.snp.centerY).offset(10)
        }

        tipsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(headerView.snp.bottom).offset(5)
        }

        chatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }

        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        lanSelectView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        lanSelectView.confirmBtn.rx.tap.subscribe(
            onNext: { [weak self] _ in
                guard let self = self else { return }
                self.lanSelectView.snp.remakeConstraints { make in
                    make.top.equalTo(self.view.snp.bottom)
                    make.left.right.equalToSuperview()
                    make.height.equalToSuperview()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
                let languages = (
                    lanSelectView.languangeSelectView.currentMySideLanguage,
                    lanSelectView.languangeSelectView.currentOtherSideLanguage
                )
                dataVM?.dicChangeLanguage(languages: languages)
            }).disposed(by: disposeBag)
        
        dataVM = FaceToFaceTranslateVM(viewController: self)
        dataVM?.syncSpeakArray.subscribe(onNext: { [weak self] array in
            guard let self = self else { return }
            chatView.messages.accept(array)
        }).disposed(by: disposeBag)

        chatView.messages.subscribe(onNext: { [weak self] array in
            guard let self = self else { return }
            self.tipsView.isHidden = array.count > 0 ? true : false
        }).disposed(by: disposeBag)

        dataVM?.countTimerStr.subscribe(onNext: { [weak self] str in
            guard let self = self else { return }
            self.headerView.setTime(time: str)
        }).disposed(by: disposeBag)

        bottomView.contextView = self
    }

    override func backBtnAction() {
        let alert = UIAlertController(title: R.Language.lan("Are you sure you want to exit face-to-face translation?"), message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: R.Language.lan("confirm"), style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.dataVM?.cancelSend()
            self.dataVM?.exitTimer()
                TranslateVM.shared.exitMode { _, _ in
                    guard let viewControllers = self.navigationController?.viewControllers else { return }
                    if viewControllers.count >= 3 {
                        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                        self.dataVM = nil
                    }
                }
           
        }
        let cancelAction = UIAlertAction(title: R.Language.lan("Cancel"), style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let languages = TranslateTools.getLanguages(.face)
        headerView.configText(languages.0.title(), languages.1.title())
        lanSelectView.languangeSelectView.configLanguageTitle(
            mySide: LanguageCls.localizableTxt("Wearing headphones"),
            otherSide: LanguageCls.localizableTxt("Holding mobile phone")
        )
        lanSelectView.languangeSelectView.configLanguage(mySide: languages.0, otherSide: languages.1)
        tipsView.configTitleLanguage(original: languages.0, translate: languages.1)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    func showLanguageView() {
        lanSelectView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
