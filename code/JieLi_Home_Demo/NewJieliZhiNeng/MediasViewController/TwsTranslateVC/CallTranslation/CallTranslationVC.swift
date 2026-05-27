//
//  CallTranslationVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/8.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class CallTranslationVC: BasicViewController {
    let bottomSpeakView = CallTraBottomView()
    let speakView = CallTraTypeKeyBorad()
    var tapgesture = UITapGestureRecognizer()
    private let headerView = TimeHeaderView()
    private let callTipsView = CallTransTipsView()
    private let chatView = ChatDialogView()
    private let lanSelectView = LanguageSelect()
    private let disposeBag = DisposeBag()
    private let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 20
    private var callVM: CallTranslateVM?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TranslateVM.shared.exitMode()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func initUI() {
        naviView.isHidden = true
        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(chatView)
        view.addSubview(bottomSpeakView)
        view.addSubview(speakView)
        view.addSubview(lanSelectView)
        view.addSubview(callTipsView)

        bottomSpeakView.contextView = self
        speakView.contextView = self
        speakView.isHidden = true

        headerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        chatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.bottom.equalTo(bottomSpeakView.snp.top)
        }

        bottomSpeakView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(58 + bottomInset)
            make.bottom.equalToSuperview()
        }

        speakView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(58 + bottomInset)
            make.bottom.equalToSuperview()
        }
        lanSelectView.snp.remakeConstraints { make in
            make.top.equalTo(self.view.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview()
        }
        callTipsView.isHidden = true
        callTipsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        let languages = TranslateTools.getLanguages(.call)
        headerView.configText(languages.0.title(), languages.1.title())
        lanSelectView.languangeSelectView.configLanguage(mySide: languages.0, otherSide: languages.1)
        bottomSpeakView.languageBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.lanSelectView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })

        }).disposed(by: disposeBag)
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
                callVM?.resetLanguage(languages: languages) { [weak self] languages, err in
                    guard let self = self else { return }
                    if err != nil {
                        JLLogManager.logLevel(.ERROR, content: "reset error:\(String(describing: err))")
                        return
                    }
                    self.headerView.configText(languages.1.title(), languages.0.title())
                }
            }).disposed(by: disposeBag)

        bottomSpeakView.controlBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            guard let navigationController = self.navigationController else { return }
            let viewControllers = navigationController.viewControllers
            var count = 3
            if CallTranslationTipsVC.shouldShowTips() { count += 1 }
            if viewControllers.count >= count {
                let targetViewController = viewControllers[viewControllers.count - count]
                navigationController.popToViewController(targetViewController, animated: true)
            }
            callVM?.dispose()
        }).disposed(by: disposeBag)

        callVM = CallTranslateVM(self)
        callVM?.currentCountTime.subscribe(onNext: { [weak self] time in
            guard let self = self else { return }
            self.headerView.setTime(time: time)
        }).disposed(by: disposeBag)

        callVM?.syncSpeakArray.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            chatView.messages.accept(data)
        }).disposed(by: disposeBag)

        speakView.sendBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            callVM?.sendText(text: speakView.inputTxfd.text ?? "")
            speakView.speakBtn.sendActions(for: .touchUpInside)
            speakView.inputTxfd.text = ""
        }).disposed(by: disposeBag)
        
        // 监听设备进入空闲状态，自动退出页面
        TranslateVM.shared.deviceDidEnterIdle
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                guard let navigationController = self.navigationController else { return }
                let viewControllers = navigationController.viewControllers
                var count = 3
                if CallTranslationTipsVC.shouldShowTips() { count += 1 }
                if viewControllers.count >= count {
                    let targetViewController = viewControllers[viewControllers.count - count]
                    navigationController.popToViewController(targetViewController, animated: true)
                }
                self.callVM?.dispose()
            }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        callVM?.startHeartBeat()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        callVM?.stopHeartBeat()
    }

    func addTapGesture() {
        tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapgesture)
    }

    @objc private func tapAction() {
        view.removeGestureRecognizer(tapgesture)
        speakView.speakBtn.sendActions(for: .touchUpInside)
    }
}
