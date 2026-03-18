//
//  iNrfScanCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/11.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import CoreBluetooth


/// NFR 扫描列表单元格
class iNrfScanCell: UITableViewCell {
    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let companyLabel = UILabel()
    private let subLabel = UILabel()
    private let rssiLabel = UILabel()
    private let connectBtn = UIButton(type: .system)
    private let expandBtn = UIButton(type: .system)
    private let broadcastLabel = UILabel()
    
    var onConnect: (() -> Void)?
    var onHeightChanged: (() -> Void)?
    private var isExpanded = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(iconView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(companyLabel)
        contentView.addSubview(subLabel)
        contentView.addSubview(rssiLabel)
        contentView.addSubview(expandBtn)
        contentView.addSubview(broadcastLabel)
        contentView.addSubview(connectBtn)

        iconView.contentMode = .scaleAspectFit
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = .label
        
        companyLabel.font = .systemFont(ofSize: 12, weight: .bold)
        companyLabel.textColor = .systemOrange
        
        subLabel.font = .systemFont(ofSize: 12)
        subLabel.textColor = .secondaryLabel
        subLabel.numberOfLines = 0
        
        rssiLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        rssiLabel.textColor = .systemBlue
        
        expandBtn.setTitle("Broadcast Data: Show", for: .normal)
        expandBtn.setTitle("Broadcast Data: Hide", for: .selected)
        expandBtn.setTitleColor(.white, for: .normal)
        expandBtn.setTitleColor(.systemBlue, for: .selected)
        expandBtn.backgroundColor = .systemBlue
        expandBtn.layer.cornerRadius = 8
        expandBtn.titleLabel?.font = .systemFont(ofSize: 12)
        expandBtn.contentHorizontalAlignment = .left
        expandBtn.addTarget(self, action: #selector(onExpandTapped), for: .touchUpInside)
        
        broadcastLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        broadcastLabel.textColor = .secondaryLabel
        broadcastLabel.numberOfLines = 0
        broadcastLabel.isHidden = true
        
        
        connectBtn.setTitle("Connect", for: .normal)
        connectBtn.setTitleColor(.white, for: .normal)
        connectBtn.backgroundColor = .systemBlue
        connectBtn.layer.cornerRadius = 8
        connectBtn.layer.masksToBounds = true
        
        connectBtn.addTarget(self, action: #selector(onConnectTapped), for: .touchUpInside)
        
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
        connectBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(10)
            make.width.equalTo(88)
            make.height.equalTo(32)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.equalTo(connectBtn.snp.left).offset(-12)
        }
        companyLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.left.equalTo(nameLabel)
            make.right.equalTo(connectBtn.snp.left).offset(-12)
            make.height.equalTo(0) // Default hidden
        }
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(companyLabel.snp.bottom).offset(2)
            make.left.equalTo(nameLabel)
            make.right.equalTo(connectBtn.snp.left).offset(-12)
        }
        expandBtn.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(4)
            make.left.equalTo(nameLabel)
            make.height.equalTo(20)
        }
        broadcastLabel.snp.makeConstraints { make in
            make.top.equalTo(expandBtn.snp.bottom).offset(4)
            make.left.equalTo(nameLabel)
            make.right.equalToSuperview().inset(16)
        }
        rssiLabel.snp.makeConstraints { make in
            make.top.equalTo(broadcastLabel.snp.bottom).offset(6)
            make.left.equalTo(nameLabel)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    @objc private func onExpandTapped() {
        isExpanded.toggle()
        expandBtn.isSelected = isExpanded
        broadcastLabel.isHidden = !isExpanded
        
        broadcastLabel.snp.updateConstraints { make in
            make.top.equalTo(expandBtn.snp.bottom).offset(isExpanded ? 4 : 0)
        }
        onHeightChanged?()
    }
    
    @objc private func onConnectTapped() {
        onConnect?()
    }
    
    func configure(with device: DiscoveredDevice) {
        nameLabel.text = device.name ?? "N/A"
        subLabel.text = "UUID: \n\(device.identifier.uuidString)"
        if let rssi = device.rssi {
            rssiLabel.text = "\(rssi.intValue) dBm"
        } else {
            rssiLabel.text = "— dBm"
        }
        
        // 厂商图标逻辑 (使用 BluetoothDeviceParse)
        iconView.image = BluetoothDeviceParse.shared.parseIcon(for: device)
        
        // 厂商名称逻辑
        if let company = BluetoothDeviceParse.shared.parseCompanyName(for: device) {
            companyLabel.text = company
            companyLabel.isHidden = false
            companyLabel.snp.updateConstraints { make in
                make.height.equalTo(14)
                make.top.equalTo(nameLabel.snp.bottom).offset(2)
            }
        } else {
            companyLabel.text = nil
            companyLabel.isHidden = true
            companyLabel.snp.updateConstraints { make in
                make.height.equalTo(0)
                make.top.equalTo(nameLabel.snp.bottom).offset(0)
            }
        }
        
        // Broadcast Data Logic
        // 默认收起状态
        isExpanded = false
        expandBtn.isSelected = false
        broadcastLabel.isHidden = true
        
        if let mData = device.manufacturerData, !mData.isEmpty {
            let hexStr = mData.map { String(format: "%02X", $0) }.joined(separator: " ")
            broadcastLabel.text = "Manufacturer Data:\n\(hexStr)"
            expandBtn.isHidden = false
            
            expandBtn.snp.updateConstraints { make in
                make.height.equalTo(20)
                make.top.equalTo(subLabel.snp.bottom).offset(4)
            }
            
            broadcastLabel.snp.updateConstraints { make in
                make.top.equalTo(expandBtn.snp.bottom).offset(0)
            }
        } else {
            broadcastLabel.text = nil
            expandBtn.isHidden = true
            
            expandBtn.snp.updateConstraints { make in
                make.height.equalTo(0)
                make.top.equalTo(subLabel.snp.bottom).offset(0)
            }
            broadcastLabel.snp.updateConstraints { make in
                make.top.equalTo(expandBtn.snp.bottom).offset(4)
            }
        }
        
        switch device.peripheral.state {
        case .connected:
            connectBtn.setTitle("Disconnect", for: .normal)
            connectBtn.backgroundColor = .systemRed
            connectBtn.isEnabled = true
        case .connecting:
            connectBtn.setTitle("Connecting...", for: .normal)
            connectBtn.backgroundColor = .systemGray
            connectBtn.isEnabled = false
        case .disconnected, .disconnecting:
            connectBtn.setTitle("Connect", for: .normal)
            connectBtn.backgroundColor = .systemBlue
            connectBtn.isEnabled = true
        @unknown default:
            connectBtn.setTitle("Connect", for: .normal)
            connectBtn.backgroundColor = .systemBlue
            connectBtn.isEnabled = true
        }
    }
    
}
