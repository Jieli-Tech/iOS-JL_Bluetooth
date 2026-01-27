//
//  AssistBleManager.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/19.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JL_AdvParse
import JL_BLEKit
import JL_HashPair
import JL_OTALib
import UIKit
import CoreBluetooth

typealias DisconnectBlock = (String) -> Void

class BleManager: NSObject {
    /// 单例
    static let shared = BleManager()

    // 自定义蓝牙接入助手
    let assist: JL_Assist = {
        let assist = JL_Assist()
        // 设备蓝牙服务
        assist.mService = "AE00"
        // 设备蓝牙特征写入
        assist.mRcsp_W = "AE01"
        // 设备蓝牙特征读取（通知）
        assist.mRcsp_R = "AE02"
        // 是否启用设备认证，默认是开启的，如果需要关闭，需要设备端以及其他端一同修改
        assist.mNeedPaired = true
        return assist
    }()

    /// 搜索到的设备
    private var devices: [JL_EntityM] = []

    /// 当前连接的设备
    private var handleCbp: CBPeripheral?

    /// 设备的 mac 地址
    private var pMac: String?

    /// 用于连接的 UUID
    private var connectUUID: String?

    private var connectTimeoutBlock: ((Bool) -> Void)?

    private var connectTimeoutID: String = ""

    private var discoverAttDevice: [String: CBPeripheral] = [:]
    
    private var disConnectBlock: DisconnectBlock?

    /// 蓝牙中心管理
    lazy var centerManager: CBCentralManager = .init(delegate: self, queue: .main)
    
    var discoverAttDevices = BehaviorRelay<[String: CBPeripheral]>(value: [:])

    /// 搜索到的设备
    var blesArray: [JL_EntityM] {
         return devices
    }

    let bleStatus = BehaviorRelay<CBManagerState>(value: .poweredOff)

    /// 当前连接的设备
    var currentEntity: JL_EntityM? {
       assist.mCmdManager.mEntity
    }

    /// 当前连接的命令管理对象
    var currentCmdMgr: JL_ManagerM? {
        assist.mCmdManager
    }

    override init() {
        super.init()
        /// 杰理 SDK 的日志
        JLLogManager.clearLog()
        JLLogManager.setLog(true, isMore: false, level: .DEBUG)
        JLLogManager.log(withTimestamp: true)
        JLLogManager.saveLog(asFile: true)
        setPairEnable(true)
    }

    /// 设置是否启用设备认证
    /// 若关闭，需要多方一起关闭包括设备端跟安卓端
    /// - Parameter status: 设备认证开关
    func setPairEnable(_ status: Bool) {
        SettingInfo.savePairEnable(status)
        assist.mNeedPaired = status
    }

    /// 开始搜索
    func startSearchBle() {
        // 启用 GATT over EDR 时需要先连接上设备的 EDR 否则会搜索不到
        if SettingInfo.getATTComunication() {
            devices.removeAll()
            let uuid = SettingInfo.getAttDevUUID() ?? "AE00"
            let cbuuid = CBUUID(string: uuid)
            let machingUUIDs = [CBConnectionEventMatchingOption.serviceUUIDs:
                [cbuuid]]
            centerManager.registerForConnectionEvents(options: machingUUIDs)
            centerManager.scanForPeripherals(withServices: nil, options: [CBConnectPeripheralOptionEnableTransportBridgingKey: true])
            return
        }
        devices.removeAll()
        centerManager.scanForPeripherals(withServices: nil, options: [CBConnectPeripheralOptionEnableTransportBridgingKey: true])
        JLLogManager.logLevel(.DEBUG, content: "startSearchBle")
    }

    /// 停止搜索
    func stopSearchBle() {
        centerManager.stopScan()
        JLLogManager.logLevel(.DEBUG, content: "stopSearchBle")
    }

    /// 连接设备
    /// - Parameter entity: 要连接的设备
    func connectEntity(_ entity: JL_EntityM) {
        if SettingInfo.getATTComunication() {
            centerManager.connect(entity.mPeripheral)
            return
        }
        stopSearchBle()
        centerManager.connect(entity.mPeripheral, options: [CBConnectPeripheralOptionEnableTransportBridgingKey: true])
    }

    func connectByUUID(_ uuid: String, _ peripheral: CBPeripheral? = nil, completion: ((Bool) -> Void)? = nil) {
        connectTimeoutID = TimerHelper.createTimer(timeOut: 10, completion: { [weak self] _ in
            completion?(false)
            self?.connectTimeoutBlock = nil
        })
        connectTimeoutBlock = completion
        JLLogManager.logLevel(.DEBUG, content: "reconnect uuid: \(uuid)")
        stopSearchBle()
        if let peripheral = peripheral {
            centerManager.connect(peripheral)
            return
        }
        connectUUID = uuid
        startSearchBle()
    }

    /// 重新连接
    /// 一般用于 OTA 的但备份升级回连
    /// - Parameter mac: 设备的 mac 地址
    func reConnectWithMac(_ mac: String) {
        pMac = mac
        startSearchBle()
    }

    /// 断开连接
    func disconnectEntity() {
       centerManager.cancelPeripheralConnection(BleManager.shared.handleCbp!)
    }
    
    func disconnectCurrentDev(_ block:DisconnectBlock? = nil) {
        disConnectBlock = block
        disconnectEntity()
    }

}

/** CBCentralManagerDelegate
 在自定义蓝牙连接时需要处理以下的内容
 - centralManagerDidUpdateState: 蓝牙状态更新
 - centralManager(_: connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral): 连接事件
 - centralManager(_: didFailToConnect peripheral: CBPeripheral, error: Error?): 连接失败
 - centralManager(_: didDisconnectPeripheral peripheral: CBPeripheral, error: Error?): 连接断开
 - centralManager(_: didConnect peripheral: CBPeripheral): 连接成功
 */
extension BleManager: CBCentralManagerDelegate {
    /// 蓝牙状态更新
    /// - Parameter central: CBCentralManager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startSearchBle()
        }
        assist.assistUpdate(central.state)
        bleStatus.accept(central.state)
    }

    /// 连接事件
    /// 此代理方法是针对 GATT over EDR 的，当支持 ATT 连接的设备都 EDR 连上或者断开时都会触发此方法
    /// - Parameters:
    ///   - _: 蓝牙中心
    ///   - event: 连接事件
    ///   - peripheral: 连接的设备
    func centralManager(_: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        if event == .peerConnected {
            let newEntity = JL_EntityM()
            newEntity.mUUID = peripheral.identifier.uuidString
            newEntity.setBlePeripheral(peripheral)
            if peripheral.name != nil {
                if devices.contains(where: { $0.mPeripheral.name == peripheral.name }) {
                } else {
                    devices.append(newEntity)
                }
            }
            JLLogManager.logLevel(.DEBUG, content: "设备 EDR 已连接！")

            discoverAttDevice.updateValue(peripheral, forKey: peripheral.identifier.uuidString)
            
            discoverAttDevices.accept(discoverAttDevice)

            if connectUUID == peripheral.identifier.uuidString {
                connectEntity(newEntity)
                connectUUID = nil
            }
        }
        if event == .peerDisconnected {
            discoverAttDevice.removeValue(forKey: peripheral.identifier.uuidString)
            JLLogManager.logLevel(.DEBUG, content: "设备断开连接,EDR 已断开！")
            discoverAttDevices.accept(discoverAttDevice)
        }
    }

    func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        devices.removeAll(where: { $0.mUUID == peripheral.identifier.uuidString })
        let newEntity = JL_EntityM()
        newEntity.mUUID = peripheral.identifier.uuidString
        newEntity.setBlePeripheral(peripheral)
        newEntity.mAdvData = advertisementData["kCBAdvDataManufacturerData"] as? Data ?? Data()
        let dict = JLAdvParse.bluetoothAdvData(advertisementData, rssi: rssi)
        newEntity.updateEntity(dict)
        
        if peripheral.name != nil {
            devices.removeAll(where: { $0.mPeripheral.identifier.uuidString == peripheral.identifier.uuidString })
            devices.append(newEntity)
        }

        if let connectUUID = connectUUID, connectUUID == peripheral.identifier.uuidString {
            connectEntity(newEntity)
            self.connectUUID = nil
            stopSearchBle()
            return
        }
        if pMac != nil {
            if let blead = advertisementData["kCBAdvDataManufacturerData"] as? Data {
                if JL_BLEAction.otaBleMacAddress(pMac!, isEqualToCBAdvDataManufacturerData: blead) {
                    stopSearchBle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem(block: {
                        self.centerManager.connect(peripheral, options: [CBConnectPeripheralOptionEnableTransportBridgingKey: true])
                        self.pMac = nil
                    }))
                }
            }
        }
        JL_Tools.post(kJL_BLE_M_FOUND, object: blesArray)
    }

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?) {
        if peripheral.identifier.uuidString == currentEntity?.mUUID {
            disConnectBlock?(peripheral.identifier.uuidString)
            disConnectBlock = nil
        }
        assist.assistDisconnectPeripheral(peripheral)
        assist.mCmdManager.mEntity = nil
        handleCbp = nil
        JL_Tools.post(kJL_BLE_M_ENTITY_DISCONNECTED, object: peripheral)
    }

    func centralManager(_: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error _: Error?) {
        JL_Tools.post(kJL_CONNECT_FAILED, object: peripheral)
    }
}

/**
 CBPeripheralDelegate
 在自定义蓝牙连接时，需要处理以下内容
 - peripheral(_: didDiscoverServices error: Error?): 发现服务
 - peripheral(_: didDiscoverCharacteristicsFor service: CBService, error: Error?): 发现特征
 - peripheral(_: didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?): 更新通知
 */
extension BleManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error _: Error?) {
        assist.assistDiscoverCharacteristics(for: service, peripheral: peripheral)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error _: Error?) {
        if SettingInfo.getPairEnable() {
            // 自定义蓝牙连接时，连上设备后需要进行设备认证
            assist.assistUpdate(characteristic, peripheral: peripheral) { isPaired in
                if isPaired {
                    self.handleCbp = peripheral
                    self.initTargetFeature(peripheral: peripheral)
                } else {
                    self.centerManager.cancelPeripheralConnection(peripheral)
                    self.connectTimeoutBlock?(false)
                }
              
            }
        } else {
            // 不需要认证时，直接回调成功
            handleCbp = peripheral
            initTargetFeature(peripheral: peripheral)
        }
    }

    func peripheral(_: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error _: Error?) {
        // 自定义连接是设备更新数据过来时，需要通过此方法传入 SDK 处理
        assist.assistUpdateValue(for: characteristic)
    }
    
    private func initTargetFeature(peripheral: CBPeripheral) {

        
        assist.mCmdManager.cmdTargetFeatureResult { state,_,_ in
            if state != .success {
                self.connectTimeoutBlock?(false)
                return
            }
            let entity = self.devices.first(where: { $0.mUUID == peripheral.identifier.uuidString }) ?? JL_EntityM()
            entity.setBlePeripheral(peripheral)
            self.assist.mCmdManager.mEntity = entity
            
            SettingInfo.setToHistory(peripheral.identifier.uuidString)
            JL_Tools.post(kJL_BLE_M_ENTITY_CONNECTED, object: self.handleCbp)
            self.connectTimeoutBlock?(true)
            // 保存历史
            let isAtt = self.discoverAttDevice[self.handleCbp!.identifier.uuidString] == nil ? false : true
            JLLogManager.logLevel(.DEBUG, content: "discoverAttDevice:\(self.discoverAttDevice)")
            DevHistory.share.insert(self.handleCbp!, entity.mAdvData, isAtt)
            
            self.connectTimeoutBlock = nil
            TimerHelper.stopTimer(timerID: &self.connectTimeoutID)
        }
    }
}

