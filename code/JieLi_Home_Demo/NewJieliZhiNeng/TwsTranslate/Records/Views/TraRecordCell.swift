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
    private let cardView = MessageCardView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func configure(icon: UIImage?, date: String, time: String, title: String, subtitle: String) {
        cardView.configure(icon: icon, date: date, time: time, title: title, subtitle: subtitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct MessageModel {
    let icon: UIImage?
    let date: String
    let time: String
    let title: String
    let subtitle: String
}


extension TraRecordCell {
    static func testData() ->[MessageModel] {
        let testMessages: [MessageModel] = [
            MessageModel(
                icon: R.Image.img("record_icon_facetoface"),
                date: "2025/03/25",
                time: "10:49",
                title: "How was the business meeting today? Did …",
                subtitle: "今天的商务会谈怎么样？谈妥了吗？什么价格？"
            ),
            MessageModel(
                icon: R.Image.img("record_icon_translation"),
                date: "2025/03/25",
                time: "06:23",
                title: "How was the business meeting today? Did…",
                subtitle: "你好，我的口语不好，会由翻译代我与你沟通，请见谅。"
            ),
            MessageModel(
                icon: R.Image.img("record_icon_chuanyi"),
                date: "2025/03/25",
                time: "06:23",
                title: "我有一个梦想，有一天这个国家会站立起来…",
                subtitle: "I have a dream that one day this nation will rise…"
            )
        ]
        return testMessages
    }
}
