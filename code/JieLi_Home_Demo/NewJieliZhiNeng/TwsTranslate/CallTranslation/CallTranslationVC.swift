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
    private let headerView = TimeHeaderView()
    private let callTipsView = CallTransTipsView()
    private let chatView = ChatDialogView()
    private let lanSelectView = LanguageSelect()
    private let disposeBag = DisposeBag()
    private let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0

    override func initUI() {
        naviView.isHidden = true
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
            make.centerY.equalTo(naviView.snp.bottom)
        }

        chatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.bottom.equalTo(bottomSpeakView.snp.top)
        }

        bottomSpeakView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50 + bottomInset)
            make.bottom.equalToSuperview()
        }

        speakView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50 + bottomInset)
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
        chatView.messages.accept(ChatDialogView.sampleMessages())
        bottomSpeakView.languageBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.lanSelectView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }).disposed(by: disposeBag)

        lanSelectView.confirmBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.lanSelectView.snp.remakeConstraints { make in
                make.top.equalTo(self.view.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalToSuperview()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }).disposed(by: disposeBag)
    }
}
