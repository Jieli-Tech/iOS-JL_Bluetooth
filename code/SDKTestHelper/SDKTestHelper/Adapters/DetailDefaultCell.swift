//
//  DetailDefaultCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/6.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class DetailDefaultCell: UITableViewCell {

    private let mainLab = UILabel()
    private let detailLab = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    func setData(title: String, detail: String) {
        mainLab.text = title
        detailLab.text = detail
    }
    
    private func setupUI() {
        mainLab.textColor = .darkText
        mainLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        mainLab.adjustsFontSizeToFitWidth = true
        mainLab.textAlignment = .left
        
        detailLab.textColor = .gray
        detailLab.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        detailLab.adjustsFontSizeToFitWidth = true
        detailLab.textAlignment = .left
        
        contentView.addSubview(mainLab)
        contentView.addSubview(detailLab)
        
        mainLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.height.equalTo(20)
            make.left.right.equalToSuperview().inset(8)
        }
        
        detailLab.snp.makeConstraints { make in
            make.top.equalTo(mainLab.snp.bottom)
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
