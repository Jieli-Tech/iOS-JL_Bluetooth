//
//  StreamModeSelectionViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/5/28.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JLLogHelper

class StreamModeSelectionViewController: BaseViewController {

    private let titleLabel = UILabel()
    private let receiveButton = UIButton(type: .system)
    private let pushButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.title = "流媒体传输"
        navigationView.leftBtn.setTitle("返回", for: .normal)
        setupUI()
    }

    private func setupUI() {
        navigationView.leftBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.spacing = 20
        cardStack.alignment = .fill
        view.addSubview(cardStack)
        cardStack.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(32)
        }

        // Receive mode card
        styleCardButton(receiveButton, emoji: "📥", title: "接收模式", subtitle: "从设备接收音视频流")
        receiveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let vc = StreamTransferViewController()
                vc.canNotPushBack = true
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        cardStack.addArrangedSubview(receiveButton)
        receiveButton.snp.makeConstraints { make in
            make.height.equalTo(100)
        }

        // Push mode card
        styleCardButton(pushButton, emoji: "📤", title: "推送模式", subtitle: "向设备推送视频流")
        pushButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let vc = StreamPushViewController()
                vc.canNotPushBack = true
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        cardStack.addArrangedSubview(pushButton)
        pushButton.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
    }

    private func styleCardButton(_ button: UIButton, emoji: String, title: String, subtitle: String) {
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 6
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)

        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        button.addSubview(emojiLabel)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .black
        button.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .gray
        button.addSubview(subtitleLabel)

        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = UIFont.systemFont(ofSize: 24, weight: .light)
        arrowLabel.textColor = .gray
        button.addSubview(arrowLabel)

        emojiLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(emojiLabel.snp.right).offset(16)
            make.top.equalToSuperview().offset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }

        arrowLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}
