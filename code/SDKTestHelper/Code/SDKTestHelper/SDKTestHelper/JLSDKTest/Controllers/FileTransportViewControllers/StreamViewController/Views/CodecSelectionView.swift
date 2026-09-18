//
//  CodecSelectionView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/8.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CodecSelectionView: BaseView {

    private let titleLabel = UILabel()
    private let jpegButton = UIButton(type: .system)
    private let h264Button = UIButton(type: .system)
    private let infoLabel = UILabel()

    let jpegTap = PublishRelay<Void>()
    let h264Tap = PublishRelay<Void>()

    override func initUI() {
        super.initUI()
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4

        titleLabel.text = "编码格式"
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(titleLabel)

        setupCodecButton(jpegButton, title: "JPEG", subtitle: "兼容性好")
        setupCodecButton(h264Button, title: "H264", subtitle: "压缩率高")

        addSubview(jpegButton)
        addSubview(h264Button)

        infoLabel.font = UIFont.systemFont(ofSize: 11)
        infoLabel.textColor = .gray
        infoLabel.text = "根据设备能力自动选择最优编码"
        infoLabel.textAlignment = .center
        addSubview(infoLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12)
            make.height.equalTo(30)
        }

        jpegButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(44)
        }

        h264Button.snp.makeConstraints { make in
            make.top.equalTo(jpegButton)
            make.left.equalTo(jpegButton.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(jpegButton)
            make.height.equalTo(44)
        }

        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(jpegButton.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }

        jpegButton.rx.tap.bind(to: jpegTap).disposed(by: disposeBag)
        h264Button.rx.tap.bind(to: h264Tap).disposed(by: disposeBag)
    }

    private func setupCodecButton(_ button: UIButton, title: String, subtitle: String) {
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .black
        button.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 11)
        subtitleLabel.textColor = .gray
        button.addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(6)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
    }

    func bind(selectedCodec: Driver<StreamCodecType>) {
        selectedCodec
            .drive(onNext: { [weak self] codec in
                self?.updateSelection(codec: codec)
            })
            .disposed(by: disposeBag)
    }

    func bind(isSelectable: Driver<Bool>) {
        isSelectable
            .drive(onNext: { [weak self] selectable in
                self?.jpegButton.isEnabled = selectable
                self?.h264Button.isEnabled = selectable
                self?.alpha = selectable ? 1.0 : 0.6
            })
            .disposed(by: disposeBag)
    }

    private func updateSelection(codec: StreamCodecType) {
        let selectedColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
        let normalColor = UIColor.lightGray.withAlphaComponent(0.2)

        switch codec {
        case .jpeg:
            jpegButton.backgroundColor = selectedColor.withAlphaComponent(0.15)
            jpegButton.layer.borderColor = selectedColor.cgColor
            h264Button.backgroundColor = normalColor
            h264Button.layer.borderColor = UIColor.clear.cgColor
        case .h264:
            h264Button.backgroundColor = selectedColor.withAlphaComponent(0.15)
            h264Button.layer.borderColor = selectedColor.cgColor
            jpegButton.backgroundColor = normalColor
            jpegButton.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
