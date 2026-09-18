//
//  PushControlPanelView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/5/28.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PushControlPanelView: BaseView {

    let startButton = UIButton(type: .system)
    let pauseButton = UIButton(type: .system)
    let resumeButton = UIButton(type: .system)
    let stopButton = UIButton(type: .system)
    let resetButton = UIButton(type: .system)
    let closeButton = UIButton(type: .system)
    let retryButton = UIButton(type: .system)

    private let row1Stack = UIStackView()
    private let row2Stack = UIStackView()
    private let row3Stack = UIStackView()

    // MARK: - Button Taps
    let startTap = PublishRelay<Void>()
    let pauseTap = PublishRelay<Void>()
    let resumeTap = PublishRelay<Void>()
    let stopTap = PublishRelay<Void>()
    let resetTap = PublishRelay<Void>()
    let closeTap = PublishRelay<Void>()
    let retryTap = PublishRelay<Void>()

    override func initUI() {
        super.initUI()
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4

        setupButtons()
        setupStacks()
        bindButtonTaps()
    }

    private func setupButtons() {
        styleButton(startButton, title: "开始推送", color: UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0))
        styleButton(pauseButton, title: "暂停推送", color: UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))
        styleButton(resumeButton, title: "继续推送", color: UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0))
        styleButton(stopButton, title: "停止推送", color: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        styleButton(resetButton, title: "重置推流", color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))
        styleButton(closeButton, title: "关闭推流会话", color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))
        styleButton(retryButton, title: "重试", color: UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))
        retryButton.isHidden = true
    }

    private func styleButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }

    private func setupStacks() {
        row1Stack.axis = .horizontal
        row1Stack.spacing = 12
        row1Stack.distribution = .fillEqually
        row1Stack.addArrangedSubview(startButton)
        row1Stack.addArrangedSubview(retryButton)
        addSubview(row1Stack)

        row2Stack.axis = .horizontal
        row2Stack.spacing = 12
        row2Stack.distribution = .fillEqually
        row2Stack.addArrangedSubview(pauseButton)
        row2Stack.addArrangedSubview(resumeButton)
        addSubview(row2Stack)

        row3Stack.axis = .horizontal
        row3Stack.spacing = 12
        row3Stack.distribution = .fillEqually
        row3Stack.addArrangedSubview(stopButton)
        row3Stack.addArrangedSubview(resetButton)
        addSubview(row3Stack)

        closeButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        addSubview(closeButton)

        row1Stack.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12)
        }

        row2Stack.snp.makeConstraints { make in
            make.top.equalTo(row1Stack.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(12)
        }

        row3Stack.snp.makeConstraints { make in
            make.top.equalTo(row2Stack.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(12)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(row3Stack.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    private func bindButtonTaps() {
        startButton.rx.tap.bind(to: startTap).disposed(by: disposeBag)
        pauseButton.rx.tap.bind(to: pauseTap).disposed(by: disposeBag)
        resumeButton.rx.tap.bind(to: resumeTap).disposed(by: disposeBag)
        stopButton.rx.tap.bind(to: stopTap).disposed(by: disposeBag)
        resetButton.rx.tap.bind(to: resetTap).disposed(by: disposeBag)
        closeButton.rx.tap.bind(to: closeTap).disposed(by: disposeBag)
        retryButton.rx.tap.bind(to: retryTap).disposed(by: disposeBag)
    }

    func bindButtonStates(
        startEnabled: Driver<Bool>,
        pauseEnabled: Driver<Bool>,
        resumeEnabled: Driver<Bool>,
        stopEnabled: Driver<Bool>,
        resetEnabled: Driver<Bool>,
        closeEnabled: Driver<Bool>,
        retryVisible: Driver<Bool>
    ) {
        startEnabled.drive(onNext: { [weak self] in self?.setButton(self?.startButton, enabled: $0) }).disposed(by: disposeBag)
        pauseEnabled.drive(onNext: { [weak self] in self?.setButton(self?.pauseButton, enabled: $0) }).disposed(by: disposeBag)
        resumeEnabled.drive(onNext: { [weak self] in self?.setButton(self?.resumeButton, enabled: $0) }).disposed(by: disposeBag)
        stopEnabled.drive(onNext: { [weak self] in self?.setButton(self?.stopButton, enabled: $0) }).disposed(by: disposeBag)
        resetEnabled.drive(onNext: { [weak self] in self?.setButton(self?.resetButton, enabled: $0) }).disposed(by: disposeBag)
        closeEnabled.drive(onNext: { [weak self] in self?.setButton(self?.closeButton, enabled: $0) }).disposed(by: disposeBag)
        retryVisible.drive(onNext: { [weak self] visible in
            self?.retryButton.isHidden = !visible
            self?.startButton.isHidden = visible
        }).disposed(by: disposeBag)
    }

    private func setButton(_ button: UIButton?, enabled: Bool) {
        button?.isEnabled = enabled
        button?.alpha = enabled ? 1.0 : 0.4
    }
}
