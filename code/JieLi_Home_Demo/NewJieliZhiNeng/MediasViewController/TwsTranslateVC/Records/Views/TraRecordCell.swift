//
//  TraRecordCell.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/28.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class MessageCardView: BasicView {
    let containerView = UIView()
    let iconImageView = UIImageView()
    let dateLabel = UILabel()
    let timeLabel = UILabel()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    override func initUI() {
        super.initUI()
        setupUI()
        setupLayout()
    }

    private func setupUI() {
        backgroundColor = .clear

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true

        iconImageView.contentMode = .scaleAspectFit

        dateLabel.font = R.Font.medium(11)
        dateLabel.textColor = .eHex("#000000", alpha: 0.5)
        dateLabel.adjustsFontSizeToFitWidth = true

        timeLabel.font = R.Font.medium(11)
        timeLabel.textColor = .eHex("#000000", alpha: 0.5)
        timeLabel.textAlignment = .right
        timeLabel.adjustsFontSizeToFitWidth = true

        titleLabel.font = R.Font.medium(14)
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .eHex("#000000", alpha: 0.9)

        subtitleLabel.font = R.Font.medium(12)
        subtitleLabel.textColor = .eHex("#000000", alpha: 0.5)
        subtitleLabel.numberOfLines = 1

        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
    }

    private func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(5)
            make.width.height.equalTo(26)
        }

        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(6)
        }

        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.right.equalToSuperview().inset(12)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(10)
        }
    }

    func configure(icon: UIImage?, date: String, time: String, title: String, subtitle: String) {
        iconImageView.image = icon
        dateLabel.text = date
        timeLabel.text = time
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

class TraRecordCell: UITableViewCell {
    private let selectIcon = UIImageView()
    private let cardView = MessageCardView()
    private let disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    private func setup() {
        contentView.addSubview(selectIcon)
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }
        selectIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
            make.right.equalTo(contentView.snp.left).offset(-24)
        }
        selectionStyle = .none
        backgroundColor = .clear
    }

    func configure(mode: MessageModel, isSelecting: Bool = false) {
        cardView.configure(icon: mode.icon, date: mode.date.beYyyyMMdd, time: mode.date.beHHmm, title: mode.title, subtitle: mode.subtitle)
        selectIcon.isHidden = !isSelecting
        let image = mode.isSelect ? R.Image
            .img("Theme.bundle/edit_icon_choose_sel") : R.Image
            .img("icon_trans_choose_nor")
        selectIcon.image = image
        if isSelecting {
            selectIcon.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.height.equalTo(24)
                make.left.equalToSuperview().offset(8)
            }
            cardView.snp.remakeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 24 + 16, bottom: 6, right: -24))
            }
        } else {
            selectIcon.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.height.equalTo(24)
                make.right.equalTo(contentView.snp.left).offset(-24)
            }
            cardView.snp.remakeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MessageModel {
    let type: TranslateDBType
    let icon: UIImage?
    let date: Date
    let title: String
    let subtitle: String
    var isSelect: Bool

    init(type: TranslateDBType, icon: UIImage?, date: Date, title: String, subtitle: String) {
        self.type = type
        self.icon = icon
        self.date = date
        self.title = title
        self.subtitle = subtitle
        isSelect = false
    }
}
