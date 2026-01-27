//
//  LancerAudioFormatCell.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/10/10.
//

import UIKit

class LancerAudioFormatCell: UITableViewCell {
    private let mainLab = UILabel()
    private let subLab = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.addSubview(mainLab)
        contentView.addSubview(subLab)
        mainLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        mainLab.textColor = R.color.fontBackText242424()

        subLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subLab.textColor = R.color.fontBackText_50()
        subLab.textAlignment = .right

        mainLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        subLab.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configCell(_ model: (String, String)) {
        mainLab.text = model.0
        subLab.text = model.1
    }
}
