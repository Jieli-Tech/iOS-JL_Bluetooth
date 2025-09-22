//
//  DevBroadcastModel.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/2.
//

import UIKit
import JLAuracastKit

/// 预设设备连接方式
enum DevConnectWay: UInt8 {
    /// BLE
    case ble = 0x00
    /// ATT（GATT Over ATT）
    case att = 0x01
}

/// 设备广播
class DevBroadcastModel: NSObject {
    /// 广播数据
    var version: Int = 0

    /// 设备类型
    var type: JLAuraDeviceType = .init()

    /// APP会根据这个字段显示的地址进行回连。
    /// 有经典蓝牙/Unicast 同时存在的产品，这个字段存放经典蓝牙的地址。
    /// 其他产品这个字段存放BLE地址。
    var mac: String = ""

    /// 经典蓝牙连接状态
    var edrConnected: Bool = false

    /// LeAudio连接状态
    var leAudioConnected: Bool = false

    /// 连接方式
    var connectWay: DevConnectWay = .ble

    init(data: Data) {
        super.init()
        if data.count == 11 {
            let version = data[0]
            self.version = Int(version)
            type = JLAuraDeviceType.beModel(data.subdata(in: 1 ..< 3))
            mac = data.subdata(in: 3 ..< data.count - 2).map { String(format: "%02X", $0) }.joined()
            let status = data[data.count - 2]
            edrConnected = status & 0x01 == 0x01
            leAudioConnected = status & 0x02 == 0x02
            let connectWay = data[data.count - 1]
            self.connectWay = DevConnectWay(rawValue: connectWay) ?? .ble
            JLLogManager.logLevel(.DEBUG, content: data.map { String(format: "%02X", $0) }.joined())
        }
    }
}
