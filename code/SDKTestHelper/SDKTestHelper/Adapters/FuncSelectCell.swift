//
//  FuncSelectCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/18.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class FuncSelectCell: UITableViewCell {
    let titleLab = UILabel()
    let centerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLab.textColor = .white
        titleLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLab.adjustsFontSizeToFitWidth = true
        titleLab.textAlignment = .center

        backgroundColor = UIColor.clear
        centerView.backgroundColor = .random()
        centerView.layer.cornerRadius = 10
        centerView.layer.masksToBounds = true
        centerView.layer.shadowColor = UIColor.black.cgColor
        centerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        centerView.layer.shadowOpacity = 0.5
        centerView.layer.shadowRadius = 2

        contentView.addSubview(centerView)
        centerView.addSubview(titleLab)

        centerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
