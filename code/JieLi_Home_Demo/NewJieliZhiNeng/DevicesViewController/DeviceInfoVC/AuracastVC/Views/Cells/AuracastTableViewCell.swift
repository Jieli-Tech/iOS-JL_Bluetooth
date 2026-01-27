//
//  AuracastTableViewCell.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/12.
//

import UIKit

class AuracastTableViewCell: UITableViewCell {
    private let imgv = UIImageView()
    private let nameLab = UILabel()
    private let lockImgv = UIImageView()
    private let centerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(centerView)
        centerView.addSubview(imgv)
        centerView.addSubview(nameLab)
        centerView.addSubview(lockImgv)
        backgroundColor = .clear

        centerView.backgroundColor = UIColor.white
        centerView.layer.cornerRadius = 8
        centerView.layer.masksToBounds = true

        imgv.image = RResources.image.icon_broadcast()
        lockImgv.image = RResources.image.icon_lock()

        nameLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nameLab.adjustsFontSizeToFitWidth = true
        nameLab.textColor = RResources.color.fontBackText242424()

        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview().inset(4)
        }

        imgv.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        nameLab.snp.makeConstraints { make in
            make.left.equalTo(imgv.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        lockImgv.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }

    func configCell(_ model: JLBroadcastDataModel) {
        nameLab.text = model.broadcastName
        if model.encrypted {
            lockImgv.isHidden = false
        } else {
            lockImgv.isHidden = true
        }
    }

    func configCellTest() {
        nameLab.text = "test_12345"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
