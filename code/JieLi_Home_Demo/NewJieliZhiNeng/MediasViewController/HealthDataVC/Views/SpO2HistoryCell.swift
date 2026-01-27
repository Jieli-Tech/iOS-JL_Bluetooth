//
//  SpO2HistoryCell.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/16.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyAttributes

/// SpO2 历史列表 Cell：仅显示测量时间戳，保持与心率页面相似的 UI 风格
class SpO2HistoryCell: UITableViewCell {
    // MARK: - UI
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let timestampLabel = UILabel()

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        setupViews()
        setupLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        timestampLabel.text = nil
        valueLabel.text = nil
    }

    // MARK: - Setup
    private func setupViews() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "icon_spo")
        containerView.addSubview(iconImageView)

        titleLabel.textColor = .eHex("#919191")
        titleLabel.font = R.Font.regular(13)
        titleLabel.text = R.Language.lan("Blood oxygen monitoring")
        containerView.addSubview(titleLabel)

        timestampLabel.textColor = .eHex("#919191")
        timestampLabel.font = R.Font.regular(12)
        timestampLabel.textAlignment = .right
        containerView.addSubview(timestampLabel)
        
        valueLabel.textColor = .eHex("#242424")
        valueLabel.font = R.Font.medium(18)
        containerView.addSubview(valueLabel)
    }

    private func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(4)
            make.height.greaterThanOrEqualTo(64)
        }

        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(12)
            make.size.equalTo(28)
        }

        timestampLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.right.lessThanOrEqualTo(timestampLabel.snp.left).offset(-8)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.bottom.lessThanOrEqualToSuperview().inset(10)
        }
    }

    // MARK: - Bind
    func configure(with model: Spo2EntryData) {
        titleLabel.text = R.Language.lan("Blood oxygen monitoring")
        timestampLabel.text = Self.dateFormatter.string(from: model.date)
        let avg:Int = Int((model.maxPercent + model.minPercent) / 2)
        valueLabel.attributedText = String(avg).withFont(R.Font.medium(18)).withTextColor(.eHex("#242424"))
        + " %".withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
    }

    // MARK: - Helpers
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_Hans_CN")
        df.dateFormat = "yyyy/MM/dd HH:mm"
        return df
    }()
}
