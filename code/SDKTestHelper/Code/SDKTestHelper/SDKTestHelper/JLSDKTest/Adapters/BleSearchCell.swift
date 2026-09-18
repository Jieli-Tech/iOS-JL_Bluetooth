//
//  BleSearchCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/7/16.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit

class BleSearchCell: UITableViewCell {

    let nameLab = UILabel()
    let advDataLab = UILabel()
    let rssiLab = UILabel()
    let typeLab = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        nameLab.font = .systemFont(ofSize: 15, weight: .medium)
        nameLab.textColor = .black

        advDataLab.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        advDataLab.textColor = .gray
        advDataLab.numberOfLines = 0
        advDataLab.lineBreakMode = .byWordWrapping

        rssiLab.font = .systemFont(ofSize: 12)
        rssiLab.textColor = UIColor.eHex("#007AFF")

        typeLab.font = .systemFont(ofSize: 12)
        typeLab.textColor = UIColor.eHex("#FF6B35")
        typeLab.textAlignment = .right

        contentView.addSubview(nameLab)
        contentView.addSubview(advDataLab)
        contentView.addSubview(rssiLab)
        contentView.addSubview(typeLab)

        nameLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
            make.right.lessThanOrEqualTo(typeLab.snp.left).offset(-8)
        }

        typeLab.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(nameLab)
        }
        typeLab.setContentHuggingPriority(.required, for: .horizontal)

        advDataLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(nameLab.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
        }

        rssiLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(advDataLab.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    func config(_ item: JL_EntityM) {
        nameLab.text = item.mPeripheral?.name ?? "unKnow"
        typeLab.text = deviceTypeString(item.mType)

        // 广播数据 hex
        let advHex = item.mAdvData.hexStringFormatted()
        advDataLab.text = advHex.count > 0 ? advHex : "ADV: --"

        let rssi = item.mRSSI.intValue
        rssiLab.text = "RSSI: \(rssi) dBm"
    }

    private func deviceTypeString(_ type: JL_DeviceType) -> String {
        switch type.rawValue {
        case 0:  return "AI音箱"
        case 1:  return "充电仓"
        case 2:  return "TWS耳机"
        case 3:  return "耳机"
        case 4:  return "声卡"
        case 5:  return "手表"
        case 6:  return "Dongle"
        default: return "设备"
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Data → hex

extension Data {
    func hexStringFormatted() -> String {
        if count == 0 { return "" }
        let raw = map { String(format: "%02X", $0) }.joined()
        return stride(from: 0, to: raw.count, by: 8)
            .map { String(raw.dropFirst($0).prefix(8)) }
            .joined(separator: " ")
    }
}
