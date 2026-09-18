//
//  PushStatusView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/5/28.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PushStatusView: BaseView {

    private let statusDot = UIView()
    private let statusLabel = UILabel()
    private let progressLabel = UILabel()

    override func initUI() {
        super.initUI()
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4

        statusDot.layer.cornerRadius = 5
        addSubview(statusDot)

        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(statusLabel)

        progressLabel.font = UIFont.systemFont(ofSize: 12)
        progressLabel.textColor = .gray
        addSubview(progressLabel)

        statusDot.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(10)
        }

        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(statusDot.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        progressLabel.snp.makeConstraints { make in
            make.left.equalTo(statusLabel.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-12)
        }
    }

    func bind(statusDriver: Driver<PushStatus>) {
        statusDriver
            .drive(onNext: { [weak self] status in
                self?.updateDisplay(status: status)
            })
            .disposed(by: disposeBag)
    }

    private func updateDisplay(status: PushStatus) {
        switch status {
        case .idle:
            statusDot.backgroundColor = .gray
            statusLabel.text = "未开始"
            statusLabel.textColor = .gray
            progressLabel.text = nil
        case .preparing:
            statusDot.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
            statusLabel.text = "准备中..."
            statusLabel.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
            progressLabel.text = nil
        case .pushing(let frameIndex, let totalFrames):
            statusDot.backgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
            statusLabel.text = "推送中"
            statusLabel.textColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
            progressLabel.text = "帧 \(frameIndex + 1)/\(totalFrames)"
        case .paused(let frameIndex):
            statusDot.backgroundColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
            statusLabel.text = "已暂停"
            statusLabel.textColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
            progressLabel.text = "帧 \(frameIndex)"
        case .completed:
            statusDot.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
            statusLabel.text = "已完成"
            statusLabel.textColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
            progressLabel.text = nil
        case .error(let reason, _):
            statusDot.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            statusLabel.text = "错误: \(reason)"
            statusLabel.textColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            progressLabel.text = nil
        }
    }
}
