//
//  AlarmDateCollectionCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/23.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class AlarmDateCollectionCell: UICollectionViewCell {
    let titleLab = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.gray
        layer.cornerRadius = 20
        layer.masksToBounds = true
        contentView.addSubview(titleLab)
        titleLab.textColor = .darkText
        titleLab.textAlignment = .center
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        titleLab.adjustsFontSizeToFitWidth = true
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func bind(_ item: AlarmDateSelectModel) {
        titleLab.text = item.dateStr
        if item.isSelected {
            backgroundColor = .blue
            titleLab.textColor = .white
        } else {
            titleLab.textColor = .darkText
            backgroundColor = .gray
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
