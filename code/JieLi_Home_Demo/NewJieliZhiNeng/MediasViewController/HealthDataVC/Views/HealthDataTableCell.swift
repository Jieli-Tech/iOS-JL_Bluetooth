//
//  HealthDataTableCell.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/14.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit
import SwiftyAttributes

enum HealthDataType: Int {
    case step = 0
    case heart = 1
    case blood = 2
}

struct HealthDataCellMode {
    let icon: UIImage
    let type: HealthDataType
    let value: String
}

class HealthDataTableCell: UITableViewCell {
    
    static let identifier = "HealthDataTableCell"
    
    private let centerView = UIView()
    private let iconImgv = UIImageView()
    private let typeLab = UILabel()
    private let valueLab = UILabel()
    private let nextIconImgv = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    func setCell(_ mode: HealthDataCellMode) {
        iconImgv.image = mode.icon
        switch mode.type {
        case .step:
            typeLab.text = R.Language.lan("Steps")
            valueLab.attributedText = mode.value.withFont(Font.systemFont(ofSize: 24, weight: .medium)).withTextColor(.eHex("#242424"))
            + " ".withFont(Font.systemFont(ofSize: 24, weight: .regular))
            + R.Language.lan("Step").withFont(Font.systemFont(ofSize: 12, weight: .regular)).withTextColor(.eHex("#989898"))
        case .heart:
            typeLab.text = R.Language.lan("Heart Rate")
            valueLab.attributedText = mode.value.withFont(Font.systemFont(ofSize: 24, weight: .medium)).withTextColor(.eHex("#242424"))
            + " ".withFont(Font.systemFont(ofSize: 24, weight: .regular))
            + R.Language.lan("BPM").withFont(Font.systemFont(ofSize: 12, weight: .regular)).withTextColor(.eHex("#989898"))
        case .blood:
            typeLab.text = R.Language.lan("SpO2")
            valueLab.attributedText = mode.value.withFont(Font.systemFont(ofSize: 24, weight: .medium)).withTextColor(.eHex("#242424"))
            + R.Language.lan("%").withFont(Font.systemFont(ofSize: 24, weight: .medium)).withTextColor(.eHex("#242424"))
        }
        
    }
    
    private func initUI() {
        backgroundColor = .clear
        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 8
        centerView.layer.masksToBounds = true
        contentView.addSubview(centerView)
        iconImgv.contentMode = .scaleAspectFit
        
        nextIconImgv.image = UIImage(named: "icon_next")
        
        typeLab.font = R.Font.regular(14)
        typeLab.textColor = .eHex("#242424")
        
        valueLab.font = R.Font.medium(24)
        valueLab.textColor = .eHex("#242424")
        
        centerView.addSubview(iconImgv)
        centerView.addSubview(typeLab)
        centerView.addSubview(valueLab)
        centerView.addSubview(nextIconImgv)
        
        centerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        iconImgv.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(12)
            make.size.equalTo(28)
        }
        typeLab.snp.makeConstraints { make in
            make.left.equalTo(iconImgv.snp.right).offset(4)
            make.centerY.equalTo(iconImgv.snp.centerY)
        }
        nextIconImgv.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.size.equalTo(16)
            make.centerY.equalTo(iconImgv.snp.centerY)
        }
        valueLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(42)
            make.top.equalTo(iconImgv.snp.bottom).offset(12)
            make.bottom.equalToSuperview().inset(12)
        }
        
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
