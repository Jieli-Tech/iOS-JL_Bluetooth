//
//  FPSControlView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/5/28.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class FPSControlView: BaseView {

    private let titleLabel = UILabel()
    private let decreaseButton = UIButton(type: .system)
    private let fpsLabel = UILabel()
    private let increaseButton = UIButton(type: .system)
    private let rangeLabel = UILabel()

    let decreaseTap = PublishRelay<Void>()
    let increaseTap = PublishRelay<Void>()

    override func initUI() {
        super.initUI()
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4

        titleLabel.text = "帧率控制"
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(titleLabel)

        decreaseButton.setTitle("−", for: .normal)
        decreaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        decreaseButton.backgroundColor = UIColor.lightGray
        decreaseButton.layer.cornerRadius = 8
        addSubview(decreaseButton)

        fpsLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        fpsLabel.textAlignment = .center
        fpsLabel.text = "10 FPS"
        addSubview(fpsLabel)

        increaseButton.setTitle("+", for: .normal)
        increaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        increaseButton.backgroundColor = UIColor.lightGray
        increaseButton.layer.cornerRadius = 8
        addSubview(increaseButton)

        rangeLabel.text = "范围: 1 - 60 FPS"
        rangeLabel.font = UIFont.systemFont(ofSize: 11)
        rangeLabel.textColor = .gray
        rangeLabel.textAlignment = .center
        addSubview(rangeLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12)
        }

        decreaseButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(fpsLabel)
            make.width.height.equalTo(44)
        }

        fpsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.width.equalTo(100)
        }

        increaseButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(fpsLabel)
            make.width.height.equalTo(44)
        }

        rangeLabel.snp.makeConstraints { make in
            make.top.equalTo(fpsLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }

        decreaseButton.rx.tap
            .bind(to: decreaseTap)
            .disposed(by: disposeBag)

        increaseButton.rx.tap
            .bind(to: increaseTap)
            .disposed(by: disposeBag)
    }

    func bind(fpsDriver: Driver<Int>) {
        fpsDriver
            .drive(onNext: { [weak self] fps in
                self?.fpsLabel.text = "\(fps) FPS"
            })
            .disposed(by: disposeBag)
    }

    func bind(decreaseEnabled: Driver<Bool>) {
        decreaseEnabled
            .drive(onNext: { [weak self] enabled in
                self?.decreaseButton.isEnabled = enabled
                self?.decreaseButton.alpha = enabled ? 1.0 : 0.4
            })
            .disposed(by: disposeBag)
    }

    func bind(increaseEnabled: Driver<Bool>) {
        increaseEnabled
            .drive(onNext: { [weak self] enabled in
                self?.increaseButton.isEnabled = enabled
                self?.increaseButton.alpha = enabled ? 1.0 : 0.4
            })
            .disposed(by: disposeBag)
    }
}
