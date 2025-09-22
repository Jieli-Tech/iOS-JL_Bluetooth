//
//  DevBleInfo.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/2.
//

import CoreBluetooth
import UIKit

/// 设备蓝牙信息
class DevBleInfo: NSObject {
    /// 设备蓝牙信息
    var cbPeripheral: CBPeripheral
    /// 设备信号
    var devRssi: NSNumber
    /// 设备广播数据
    var devAdvData: [String: Any]
    /// 广播的信息
    var broadcastModel: DevBroadcastModel?
    /// 设备图标
    var image: UIImage? {
        if let mode = broadcastModel {
            if mode.type.type == .adapter {
                return R.image.mul_icon_dongle_black()
            } else if mode.type.type == .earphone {
                return R.image.mul_icon_earphone_black()
            } else if mode.type.type == .speaker {
                return R.image.mul_icon_soundbox_black()
            }
        }
        return R.image.mul_icon_earphone_black()
    }

    init(cbPeripheral: CBPeripheral, devRssi: NSNumber, devAdvData: [String: Any]) {
        self.cbPeripheral = cbPeripheral
        self.devRssi = devRssi
        self.devAdvData = devAdvData
        if let data = devAdvData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
            for item in data where item.key.uuidString == AuracastManager.serviceUUID {
                let model = DevBroadcastModel(data: item.value)
                self.broadcastModel = model
            }
        }
    }
}

/// 设备蓝牙连接状态
class JLDevBleConnectStatus {
    /// 蓝牙设备
    var cbPeripheral: CBPeripheral?
    /// 连接状态
    var connectStatus: CBPeripheralState = .disconnected

    init(cbPeripheral: CBPeripheral? = nil, connectStatus: CBPeripheralState) {
        self.connectStatus = connectStatus
        self.cbPeripheral = cbPeripheral
    }
}
