//
//  FileModelCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/27.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class FileModelCell: UITableViewCell {
    let textLabel1 = UILabel()
    let imgv = UIImageView()
    let centerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(centerView)
        centerView.addSubview(textLabel1)
        centerView.addSubview(imgv)

        centerView.layer.shadowColor = UIColor.black.cgColor
        centerView.layer.shadowRadius = 6
        centerView.layer.shadowOpacity = 0.5
        centerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        centerView.layer.cornerRadius = 10
        centerView.clipsToBounds = true

        imgv.contentMode = .center

        centerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }

        textLabel1.font = UIFont.systemFont(ofSize: 14)
        textLabel1.numberOfLines = 0
        textLabel1.textColor = UIColor.white

        textLabel1.snp.makeConstraints { make in
            make.left.equalTo(imgv.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-4)
        }
        imgv.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(2)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
