//
//  StatusInfoView.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/12.
//

import UIKit
import SnapKit

class StatusInfoView: BasicView {
    private let productImgvL = UIImageView()
    private let productImgvR = UIImageView()
    private let stackView = UIStackView()
    private let batteryView = BatteryView()
    override func initUI() {
        super.initUI()
        addSubview(stackView)
        stackView.addArrangedSubview(productImgvL)
        stackView.addArrangedSubview(productImgvR)
        addSubview(batteryView)
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually

        productImgvL.image = RResources.image.function_img_earphone()
        productImgvR.image = RResources.image.function_img_chargingbay()

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
        batteryView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview()
        }
    }
}

class BatteryView: BasicView {
    private var batteryViews: [BatteryViewCell] = []
    private var addViews: [UIView] = []
    private let line1 = UIView()
    private let line2 = UIView()

    override func initUI() {
        backgroundColor = .white
        for _ in 0 ..< 3 {
            let view = UIView()
            addViews.append(view)
            addSubview(view)
        }
        addViews[0].snp.makeConstraints { make in
            make.height.equalTo(72)
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(addViews[1].snp.width)
        }

        addViews[1].snp.makeConstraints { make in
            make.height.equalTo(72)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(addViews[2].snp.width)
            make.left.equalTo(addViews[0].snp.right)
        }

        addViews[2].snp.makeConstraints { make in
            make.height.equalTo(72)
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(addViews[1].snp.right)
            make.width.equalTo(addViews[0].snp.width)
        }

        line1.backgroundColor = .eHex("#000000", alpha: 0.08)
        addSubview(line1)
        line1.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(14)
            make.width.equalTo(1)
            make.left.equalTo(addViews[0].snp.right)
        }

        line2.backgroundColor = .eHex("#000000", alpha: 0.08)
        addSubview(line2)
        line2.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(14)
            make.width.equalTo(1)
            make.left.equalTo(addViews[1].snp.right)
        }
        for index in 0 ..< 3 {
            batteryViews.append(BatteryViewCell())
            addViews[index].addSubview(batteryViews[index])
            batteryViews[index].snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
}

class BatteryViewCell: BasicView {
    private let batteryImageV = UIImageView()
    private let batteryTypeImageV = UIImageView()
    private let batteryLabel = UILabel()
    override func initUI() {
        super.initUI()
        backgroundColor = .white
        addSubview(batteryImageV)
        addSubview(batteryTypeImageV)
        addSubview(batteryLabel)

        batteryImageV.image = RResources.image.cell_charge()
        batteryTypeImageV.image = RResources.image.icon_left()

        batteryLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        batteryLabel.textAlignment = .center
        batteryLabel.adjustsFontSizeToFitWidth = true
        batteryLabel.textColor = .eHex("#000000", alpha: 0.9)
        batteryLabel.text = "100%"

        batteryImageV.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(8)
            make.right.equalTo(batteryTypeImageV.snp.left).offset(-8)
            make.width.height.equalTo(24)
        }

        batteryTypeImageV.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.width.height.equalTo(14)
            make.centerY.equalTo(batteryImageV)
            make.left.equalTo(batteryImageV.snp.right).offset(8)
        }

        batteryLabel.snp.makeConstraints { make in
            make.top.equalTo(batteryImageV.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}
