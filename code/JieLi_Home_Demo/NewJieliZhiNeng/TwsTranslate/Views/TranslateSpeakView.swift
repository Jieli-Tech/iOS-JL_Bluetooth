//
//  TranslateSpeakView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/20.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import SwiftyAttributes
import UIKit

class TranslateSpeakView: UITableViewCell {
    private let titleLab = UILabel()
    private let pointImgv = UIImageView()
    private let mainView = UIView()
    private let originalLab = UILabel()
    private let translateLab = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initUI() {
        backgroundColor = .clear
        mainView.backgroundColor = .eHex("#F3F4F6")
        mainView.layer.cornerRadius = 8
        mainView.layer.masksToBounds = true

        pointImgv.layer.cornerRadius = 3
        pointImgv.layer.masksToBounds = true

        titleLab.textColor = .eHex("#000000", alpha: 0.9)
        titleLab.font = R.Font.medium(13)

        originalLab.textColor = .eHex("#000000", alpha: 0.9)
        originalLab.numberOfLines = 0
        originalLab.font = R.Font.medium(14)

        translateLab.textColor = .eHex("#000000", alpha: 0.5)
        translateLab.numberOfLines = 0
        translateLab.font = R.Font.medium(14)

        contentView.addSubview(pointImgv)
        contentView.addSubview(titleLab)
        contentView.addSubview(mainView)
        mainView.addSubview(originalLab)
        mainView.addSubview(translateLab)

        pointImgv.snp.makeConstraints { make in
            make.centerY.equalTo(titleLab)
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(6)
        }

        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().inset(16)
            make.left.equalTo(pointImgv.snp.right).offset(6)
            make.height.equalTo(20)
        }

        mainView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(16)
            make.top.equalTo(titleLab.snp.bottom).offset(4)
        }

        originalLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(translateLab.snp.top).offset(-8)
        }

        translateLab.snp.makeConstraints { make in
            make.top.equalTo(originalLab.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    func configTitle(title: String, color: UIColor) {
        let att = title.withFont(R.Font.medium(13)).withTextColor(.eHex("#000000", alpha: 0.9))
        titleLab.attributedText = att
        pointImgv.backgroundColor = color
    }

    func configContent(original: String, translate: String, translateColor: UIColor) {
        originalLab.text = original
        translateLab.text = translate
        translateLab.textColor = translateColor
    }
}

class TranslateSyncSpeakCell: UITableViewCell {
    private let mainView = UIView()
    private let originalLab = UILabel()
    private let translateLab = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initUI() {
        backgroundColor = .clear
        mainView.backgroundColor = .eHex("#F3F4F6")
        mainView.layer.cornerRadius = 8
        mainView.layer.masksToBounds = true

        originalLab.textColor = .eHex("#000000", alpha: 0.9)
        originalLab.numberOfLines = 0
        originalLab.font = R.Font.medium(14)

        translateLab.textColor = .eHex("#000000", alpha: 0.5)
        translateLab.numberOfLines = 0
        translateLab.font = R.Font.medium(14)

        contentView.addSubview(mainView)
        mainView.addSubview(originalLab)
        mainView.addSubview(translateLab)

        mainView.snp.makeConstraints { make in
            make.left.right.bottom.top.equalToSuperview().inset(16)
        }

        originalLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(translateLab.snp.top).offset(-8)
        }

        translateLab.snp.makeConstraints { make in
            make.top.equalTo(originalLab.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    func configContent(original: String, translate: String, translateColor: UIColor = .eHex("#000000", alpha: 0.5)) {
        originalLab.text = original
        translateLab.text = translate
        translateLab.textColor = translateColor
    }
}
