//
//  AlertiKnowTips.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/29.
//

import UIKit

class AlertiKnowTips: BasicView {
    private let bgView = UIView()
    private let centerView = UIView()
    private let titleLab = UILabel()
    private let contentLab = UILabel()
    private let confirmBtn = UIButton()
    private let line = UIView()

    override func initUI() {
        super.initUI()
        backgroundColor = UIColor.clear
        addSubview(bgView)
        addSubview(centerView)
        centerView.addSubview(titleLab)
        centerView.addSubview(contentLab)
        centerView.addSubview(confirmBtn)
        centerView.addSubview(line)

        bgView.backgroundColor = UIColor.eHex("#000000", alpha: 0.3)

        centerView.backgroundColor = UIColor.white
        centerView.layer.cornerRadius = 12
        centerView.layer.masksToBounds = true

        titleLab.text = R.localStr.iKnow()
        titleLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLab.textColor = R.color.fontBackText_90()
        titleLab.numberOfLines = 0
        titleLab.textAlignment = .center

        contentLab.text = R.localStr.wrongPassword()
        contentLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        contentLab.textColor = R.color.fontBackText_90()
        contentLab.numberOfLines = 0
        contentLab.textAlignment = .center

        confirmBtn.setTitle(R.localStr.iKnow(), for: .normal)
        confirmBtn.setTitleColor(R.color.btnBlueText(), for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)

        line.backgroundColor = R.color.lineColorF7F7F7()

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }

        titleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview().inset(20)
        }

        contentLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(titleLab.snp.bottom).offset(8)
            make.bottom.equalTo(line.snp.top).offset(-20)
        }

        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(confirmBtn.snp.top)
            make.height.equalTo(1)
        }

        confirmBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
    }

    override func initData() {
        super.initData()
        confirmBtn.rx.tap.subscribe(onNext: { _ in
            AlertManager.hiddenPasswordErrorView()
            AlertManager.hiddenReceiveBroadcastFailed()
        }).disposed(by: disposeBag)
    }

    func configText(_ title: String? = nil, _ text: String) {
        titleLab.text = title
        if title == nil {
            firstLabStyle(contentLab)
            contentLab.text = R.localStr.incorrectPassword(text)
        } else {
            secondLabStyle(contentLab)
            contentLab.text = R.localStr.pleaseMakeSureIsOpenAndWithinCommunicationRange(text)
        }
    }

    private func secondLabStyle(_ label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = R.color.fontBackText_90()
        label.numberOfLines = 0
        label.textAlignment = .center
    }

    private func firstLabStyle(_ label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = R.color.fontBackText_90()
        label.numberOfLines = 0
        label.textAlignment = .center
    }
}
