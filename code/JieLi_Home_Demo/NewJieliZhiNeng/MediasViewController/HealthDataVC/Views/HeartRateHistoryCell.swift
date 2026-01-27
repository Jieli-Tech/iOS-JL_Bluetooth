//
//  HeartRateHistoryCell.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/15.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SwiftyAttributes

/// 心率历史列表 Cell
/// 展示：左侧心形图标（虚线边框），标题“心率检测”，右上角时间戳，
/// 左下角最大心率数值（大号字体）+ 单位“次/分”，右下角区间“min–max次/分”。
class HeartRateHistoryCell: UITableViewCell {
    // MARK: - UI
    private let containerView = UIView()
    private let heartImageView = UIImageView()
    private let titleLabel = UILabel()
    private let bpmValueLabel = UILabel()
    private let timestampLabel = UILabel()
    private let rangeLabel = UILabel()


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
        bpmValueLabel.text = nil
        timestampLabel.text = nil
        rangeLabel.text = nil
    }

    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)

        heartImageView.contentMode = .scaleAspectFit
        heartImageView.image = UIImage(named: "icon_heart")
        containerView.addSubview(heartImageView)

        titleLabel.textColor = .eHex("#919191")
        titleLabel.font = R.Font.regular(13)
        titleLabel.text = R.Language.lan("Heart rate monitoring") // 多语言占位
        containerView.addSubview(titleLabel)

        bpmValueLabel.textColor = .eHex("#242424")
        bpmValueLabel.font = R.Font.medium(18)
        containerView.addSubview(bpmValueLabel)

        timestampLabel.textColor = .eHex("#919191")
        timestampLabel.font = R.Font.regular(12)
        timestampLabel.textAlignment = .right
        containerView.addSubview(timestampLabel)

        rangeLabel.textColor = .eHex("#919191")
        rangeLabel.font = R.Font.regular(12)
        rangeLabel.textAlignment = .right
        containerView.addSubview(rangeLabel)
    }

    private func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(4)
            make.height.greaterThanOrEqualTo(64)
        }
        
        heartImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(12)
            make.width.height.equalTo(28)
        }

        timestampLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().inset(12)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(heartImageView.snp.right).offset(8)
            make.right.lessThanOrEqualTo(timestampLabel.snp.left).offset(-8)
        }

        bpmValueLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.bottom.lessThanOrEqualToSuperview().inset(10)
        }

        rangeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(10)
        }
    }

    // MARK: - Bind
    func configure(with model: HeartRateEntryData) {
        // 标题固定文案（可根据多语言调整）
        titleLabel.text = R.Language.lan("Heart rate monitoring")

        // 最大心率作为主显示值
        let maxVal = Int(model.maxBpm)
        bpmValueLabel.attributedText = String(maxVal).withFont(R.Font.medium(18)).withTextColor(.eHex("#242424"))
        + " ".withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
        + R.Language.lan("BPM").withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))

        // 时间戳：yyyy/MM/dd HH:mm
        timestampLabel.text = Self.dateFormatter.string(from: model.date)

        // 区间展示：min–max次/分
        let minVal = Int(model.minBpm)
        rangeLabel.text = "\(minVal)–\(maxVal)\(R.Language.lan("BPM"))"
    }

    // MARK: - Helpers
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_Hans_CN")
        df.dateFormat = "yyyy/MM/dd HH:mm"
        return df
    }()
}
