//
//  BleManager.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/26.
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

    /// 当前正在使用的设备（含广播信息对象）
    private var _currentEntity: JL_EntityM?

    /// 设备管理
    private var mBleMultiple: JL_BLEMultiple = .init()

    /// 自定义蓝牙接入助手
    private let assist: JL_Assist = .init()

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
    
    private var discoverServices: [CBService] = []
    
    private var disConnectBlock: DisconnectBlock?

    /// 蓝牙中心管理
    lazy var centerManager: CBCentralManager = .init(delegate: self, queue: .main)
    
    var discoverAttDevices = BehaviorRelay<[String: CBPeripheral]>(value: [:])

    /// 搜索到的设备
    var blesArray: [JL_EntityM] {
        // 注意这里的 SettingInfo 记录了开发者是否启用自定义蓝牙连接和是否启用了 GATT over EDR 连接 的
        if SettingInfo.getCustomerBleConnect() || SettingInfo.getATTComunication() {
            return devices
        } else {
            return mBleMultiple.blePeripheralArr as! [JL_EntityM]
        }
    }

    let bleStatus = BehaviorRelay<CBManagerState>(value: .poweredOff)

    /// 当前连接的设备
    var currentEntity: JL_EntityM? {
        get {
            // 注意这里的 SettingInfo 记录了开发者是否启用自定义蓝牙连接和是否启用了 GATT over EDR 连接 的
            if SettingInfo.getCustomerBleConnect() || SettingInfo.getATTComunication() {
                assist.mCmdManager.mEntity
            } else {
                _currentEntity
            }
        }
        set {
            _currentEntity = newValue
        }
    }
    
    /// 当前连接的设备
    var currentPeripheral: CBPeripheral? {
        get {
            handleCbp
        }
    }
    /// 当前连接的设备的服务
    var currentServices: [CBService] {
        get {
            discoverServices
        }
    }
    
    /// 更新的特征值
    var didUpdateCharacteristicValue = PublishRelay<(CBCharacteristic, CBPeripheral)>()

    /// 当前连接的命令管理对象
    var currentCmdMgr: JL_ManagerM? {
        if SettingInfo.getCustomerBleConnect() || SettingInfo.getATTComunication() {
            assist.mCmdManager
        } else {
            currentEntity?.mCmdManager
        }
    }
    
    /// 当前连接的设备是否使用了 GATT over EDR
    var isConnectWithAtt = false

    override init() {
        super.init()
        /// 杰理 SDK 的日志
        JLLogManager.clearLog()
        JLLogManager.setLog(true, isMore: false, level: .DEBUG)
        JLLogManager.log(withTimestamp: true)
        JLLogManager.saveLog(asFile: true)

        /// 启用 SDK 蓝牙连接时需要使用
        mBleMultiple.ble_FILTER_ENABLE = true
        mBleMultiple.ble_TIMEOUT = 7
        setPairEnable(true)
    }

    /// 设置是否启用设备认证
    /// 若关闭，需要多方一起关闭包括设备端跟安卓端
    /// - Parameter status: 设备认证开关
    func setPairEnable(_ status: Bool) {
        SettingInfo.savePairEnable(status)
        mBleMultiple.ble_PAIR_ENABLE = status
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
        // 启用自定义蓝牙连接是开发者自行搜索设备
        if SettingInfo.getCustomerBleConnect() {
            devices.removeAll()
            centerManager.scanForPeripherals(withServices: nil, options: [CBConnectPeripheralOptionEnableTransportBridgingKey: true])
            JLLogManager.logLevel(.DEBUG, content: "startSearchBle")
        } else {
            // 启用 SDK 蓝牙连接时，调用库里的方法直接搜索
            mBleMultiple.scanStart()
        }
    }

    /// 停止搜索
    func stopSearchBle() {
        if SettingInfo.getCustomerBleConnect() {
            centerManager.stopScan()
            JLLogManager.logLevel(.DEBUG, content: "stopSearchBle")
        } else {
            mBleMultiple.scanStop()
        }
    }

    /// 根据 cbp 更新当前连接的设备
    /// - Parameter cbp: 当前连接的设备
    func mutilUpdateEntity(_ cbp: CBPeripheral) {
        if let items = mBleMultiple.bleConnectedArr as? [JL_EntityM] {
            if let entity = items.first(where: { $0.mUUID == cbp.identifier.uuidString }) {
                _currentEntity = entity
            }
        }
    }

    /// 连接设备
    /// - Parameter entity: 要连接的设备
    func connectEntity(_ entity: JL_EntityM) {
        if SettingInfo.getATTComunication() {
            centerManager.connect(entity.mPeripheral)
            return
        }

        stopSearchBle()

        if SettingInfo.getCustomerBleConnect() {
            // 这里的连接增加了一个连接参数，用于设备支持 CTKD 协议时的，GATT OVER EDR 连接时可忽略
            // 连接的结果需要看 centerManager 的代理回调
            centerManager.connect(entity.mPeripheral, options: [CBConnectPeripheralOptionEnableTransportBridgingKey: true])
        } else {
            // SDK 蓝牙连接，连接结果会在这里返回
            connectBySDKEntity(entity)
        }
    }

    func connectByUUID(_ uuid: String, _ peripheral: CBPeripheral? = nil, completion: ((Bool) -> Void)? = nil) {
        connectTimeoutID = TimerHelper.createTimer(timeOut: 10, completion: { [weak self] _ in
            completion?(false)
            self?.connectTimeoutBlock = nil
        })
        connectTimeoutBlock = completion
        JLLogManager.logLevel(.DEBUG, content: "reconnect uuid: \(uuid)")
        
        if SettingInfo.getCustomerBleConnect() {
            stopSearchBle()
            if let peripheral = peripheral {
                centerManager.connect(peripheral)
                return
            }
            connectUUID = uuid
            startSearchBle()
        } else {
            guard let entity = mBleMultiple.makeEntity(withUUID: uuid) else {
                JLLogManager.logLevel(.DEBUG, content: "设备不存在")
                completion?(false)
                return
            }
            connectBySDKEntity(entity)
        }
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
        if SettingInfo.getCustomerBleConnect() || SettingInfo.getATTComunication() {
            if let cbp = BleManager.shared.handleCbp {
                centerManager.cancelPeripheralConnection(cbp)
            }
        } else {
            let uuid = BleManager.shared.currentEntity?.mUUID ?? ""
            if let entity = BleManager.shared.currentEntity {
                mBleMultiple.disconnectEntity(entity) { _ in
                    self.disConnectBlock?(uuid)
                }
            }
            currentEntity = nil;
        }
    }
    
    func disconnectCurrentDev(_ block:DisconnectBlock? = nil) {
        disConnectBlock = block
        disconnectEntity()
    }

    /// 根据历史记录连接
    func connectByHistory() {
        if let uuid = SettingInfo.getToHistory() {
            // 当设备支持 ANCS 协议时，可通过这个方法找到已连接的设备
            if let entity = BleManager.shared.mBleMultiple.makeEntity(withUUID: uuid) {
                if SettingInfo.getCustomerBleConnect() {
                    startSearchBle()
                } else {
                    connectEntity(entity)
                }
            }
        }
    }
    
    

    private func connectBySDKEntity(_ entity: JL_EntityM) {
        mBleMultiple.connectEntity(entity) { st in
            switch st {
            case .bleOFF:
                JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
            case .connectFail:
                JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
            case .connecting:
                break
            case .connectRepeat:
                break
            case .connectTimeout:
                JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
            case .connectRefuse:
                JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
            case .pairFail:
                JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
            case .pairTimeout:
                JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
            case .paired:
                BleManager.shared.currentEntity = entity
                BleManager.shared.currentCmdMgr?.cmdTargetFeatureResult({[weak self] _, _, _ in
                    guard let self = self else { return }
                    SettingInfo.setToHistory(entity.mUUID)
                    DevHistory.share.insert(entity.mPeripheral, entity.mAdvData, false)
                    self.connectTimeoutBlock?(true)
                    self.connectTimeoutBlock = nil
                    TimerHelper.stopTimer(timerID: &self.connectTimeoutID)
                })
            case .masterChanging:
                break
            case .disconnectOk:
                break
            case .null:
                break
            @unknown default:
                break
            }
        }
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
            if currentCmdMgr?.getDeviceModel().mBLE_UUID == peripheral.identifier.uuidString {
                disconnectEntity()
            }
            discoverAttDevices.accept(discoverAttDevice)
            
        }
    }

    func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi _: NSNumber) {
        devices.removeAll(where: { $0.mUUID == peripheral.identifier.uuidString })
        let newEntity = JL_EntityM()
        newEntity.mUUID = peripheral.identifier.uuidString
        newEntity.setBlePeripheral(peripheral)
        if peripheral.name != nil {
            if devices.contains(where: { $0.mPeripheral.name == peripheral.name }) {
            } else {
                devices.append(newEntity)
            }
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
        currentEntity = nil
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
        discoverServices = []
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error _: Error?) {
        assist.assistDiscoverCharacteristics(for: service, peripheral: peripheral)
        self.discoverServices.append(service)
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

    func peripheral(_ cbp: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error err: Error?) {
        // 自定义连接是设备更新数据过来时，需要通过此方法传入 SDK 处理
        assist.assistUpdateValue(for: characteristic)
        if err != nil {
            return
        }
        didUpdateCharacteristicValue.accept((characteristic,cbp))
    }
    
    private func initTargetFeature(peripheral: CBPeripheral) {

        currentCmdMgr?.cmdTargetFeatureResult { state,_,_ in
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
            self.isConnectWithAtt = isAtt
            JLLogManager.logLevel(.DEBUG, content: "discoverAttDevice:\(self.discoverAttDevice)")
            DevHistory.share.insert(self.handleCbp!, entity.mAdvData, isAtt)
            
            self.connectTimeoutBlock = nil
            TimerHelper.stopTimer(timerID: &self.connectTimeoutID)
            BleManager.shared.currentCmdMgr?.cmdGetSystemInfo(.COMMON) { _, _, _ in
            }
        }
    }
}
