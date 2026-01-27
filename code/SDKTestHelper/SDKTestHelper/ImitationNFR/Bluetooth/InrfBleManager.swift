//
//  InrfBleManager.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/11.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreBluetooth
import JLLogHelper

/// NFR 蓝牙中心管理器
/// 负责：设备扫描/过滤、连接/断开与超时、服务与特征发现、RSSI 监听，以及通过 RxSwift 向上层回调
class InrfBleManager: NSObject {
    static let shared = InrfBleManager()
    private override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: centralQueue)
    }

    // MARK: - CoreBluetooth
    private let centralQueue = DispatchQueue(label: "inrf.central.queue")
    private var central: CBCentralManager!
    private var currentPeripheral: CBPeripheral?

    // MARK: - Discover & Filter
    private var devicesDict: [UUID: DiscoveredDevice] = [:]
    private var filterNameContains: String?
    private var filterIdentifierContains: String?
    private var isScanning = false
    private var discoverEmitTimer: DispatchSourceTimer?
    private let discoverEmitInterval: TimeInterval = 0.5 // ≤500ms/次
    private var knownServiceUUIDs: [CBUUID]? = nil
    private var scanStopTimer: DispatchSourceTimer?

    // MARK: - Connection Timeout & RSSI
    private var connectTimeoutTimer: DispatchSourceTimer?
    private var connectTimeout: TimeInterval = 10
    private var rssiTimer: DispatchSourceTimer?
    private let rssiInterval: TimeInterval = 1.0

    // MARK: - Rx Subjects
    private let devicesSubject = BehaviorSubject<[DiscoveredDevice]>(value: [])
    private let rssiSubject = PublishSubject<(CBPeripheral, NSNumber)>()
    private let errorSubject = PublishSubject<InrfBleError>()
    private let scanTimeoutSubject = PublishSubject<Void>()

    // MARK: - Exposed Observables
    var devicesObservable: RxSwift.Observable<[DiscoveredDevice]> { devicesSubject.asObservable() }
    var servicesObservable: BehaviorRelay<(CBPeripheral?, [CBService]?)> = BehaviorRelay(value: (nil, nil))
    var characteristicsObservable: BehaviorRelay<(CBPeripheral?, CBService?, [CBCharacteristic]?)> = BehaviorRelay(value: (nil, nil, nil))
    var rssiObservable: RxSwift.Observable<(CBPeripheral, NSNumber)> { rssiSubject.asObservable() }
    var errorObservable: RxSwift.Observable<InrfBleError> { errorSubject.asObservable() }
    var scanTimeoutObservable: RxSwift.Observable<Void> { scanTimeoutSubject.asObservable() }
    var notifyValueObservable: BehaviorRelay<(CBPeripheral?, CBCharacteristic?, Data?)> = BehaviorRelay(value: (nil, nil, nil))
    var writeResultObservable: BehaviorRelay<(CBPeripheral?, CBCharacteristic?, Bool?, Error?)> = BehaviorRelay(value: (nil, nil, nil, nil))
    var notifyStateObservable: BehaviorRelay<(CBPeripheral?, CBCharacteristic?, Bool?, Error?)> = BehaviorRelay(value: (nil, nil, nil, nil))

    // MARK: - Public APIs
    func startScan(nameContains: String? = nil, identifierContains: String? = nil) {
        centralQueue.async { [weak self] in
            guard let self = self else { return }
            guard self.central.state == .poweredOn else {
                self.errorSubject.onNext(.stateUnavailable)
                return
            }
            self.filterNameContains = nameContains?.lowercased()
            self.filterIdentifierContains = identifierContains?.lowercased()
            self.devicesDict.removeAll()
            self.isScanning = true
            self.central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            self.startDiscoverEmitTimer()
            self.startScanStopTimer(after: 4.0)
            self.mergeSystemConnectedPeripherals()
        }
    }

    func stopScan() {
        centralQueue.async { [weak self] in
            guard let self = self else { return }
            self.isScanning = false
            self.central.stopScan()
            self.stopDiscoverEmitTimer()
            self.stopScanStopTimer()
        }
    }

    func connect(to peripheral: CBPeripheral, timeout: TimeInterval = 10) {
        centralQueue.async { [weak self] in
            guard let self = self else { return }
            guard self.central.state == .poweredOn else {
                self.errorSubject.onNext(.stateUnavailable)
                return
            }
            // Disconnect current if exists and different? 
            // For now, allow multiple, but update current.
            self.currentPeripheral = peripheral
            self.connectTimeout = timeout
            self.central.connect(peripheral, options: nil)
            self.startConnectTimeoutTimer()
            self.emitDevices()
        }
    }

    func disconnect(_ peripheral: CBPeripheral) {
        centralQueue.async { [weak self] in
            guard let self = self else { return }
            self.central.cancelPeripheralConnection(peripheral)
            if self.currentPeripheral?.identifier == peripheral.identifier {
                self.clearConnectTimers()
                self.currentPeripheral = nil
            }
            self.emitDevices()
        }
    }
    
    func disconnect() {
        if let p = currentPeripheral {
            disconnect(p)
        }
    }

    func setKnownServiceUUIDs(_ uuids: [CBUUID]) {
        centralQueue.async { [weak self] in
            self?.knownServiceUUIDs = uuids
        }
    }

    /// 主动发起服务与特征发现（在已连接前提下）
    func discoverAll(for peripheral: CBPeripheral) {
        centralQueue.async { [weak self] in
            guard let self = self else { return }
            JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Discovering all for \(peripheral.name ?? "Unknown")")
            peripheral.delegate = self
            
            // 1. 触发系统发现流程（获取最新数据）
            peripheral.discoverServices(nil)
            
            // 2. 利用缓存数据兜底（解决已发现服务时不重复回调导致无数据的问题）
            if let services = peripheral.services, !services.isEmpty {
                JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Using cached services: \(services.count) services")
                self.servicesObservable.accept((peripheral, services))
                for service in services {
                    // 对已有服务也触发特征发现，防止出现 Unknown（有服务无特征）
                    JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Discovering cached characteristics for service: \(service.uuid)")
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }

    /// 读取特征值
    func readValue(for characteristic: CBCharacteristic) {
        centralQueue.async { [weak self] in
            guard let self = self, let p = self.currentPeripheral else { return }
            JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Read value for \(characteristic.uuid)")
            p.readValue(for: characteristic)
        }
    }

    /// 写入数据到特征
    func write(_ data: Data, to characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        centralQueue.async { [weak self] in
            guard let self = self, let p = self.currentPeripheral else { return }
            JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Writing \(data.count) bytes to \(characteristic.uuid) (type: \(type.rawValue))")
            p.writeValue(data, for: characteristic, type: type)
            // withResponse 的成功与失败由 didWriteValueFor 回调；withoutResponse 直接回报成功（无法得知失败）
            if type == .withoutResponse {
                JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Write without response emitted success")
                self.writeResultObservable.accept((p, characteristic, true, nil))
            }
        }
    }

    /// 订阅/取消订阅通知
    func setNotify(_ enabled: Bool, for characteristic: CBCharacteristic) {
        centralQueue.async { [weak self] in
            guard let self = self, let p = self.currentPeripheral else { return }
            JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Set notify \(enabled) for \(characteristic.uuid)")
            p.setNotifyValue(enabled, for: characteristic)
        }
    }

    // MARK: - Helpers
    private func emitDevices() {
        let list = Array(devicesDict.values).sorted { ($0.rssi?.intValue ?? -127) > ($1.rssi?.intValue ?? -127)}
        devicesSubject.onNext(list)
    }

    private func startDiscoverEmitTimer() {
        stopDiscoverEmitTimer()
        let t = DispatchSource.makeTimerSource(queue: centralQueue)
        t.schedule(deadline: .now() + discoverEmitInterval, repeating: discoverEmitInterval)
        t.setEventHandler { [weak self] in
            self?.emitDevices()
        }
        discoverEmitTimer = t
        t.resume()
    }

    private func stopDiscoverEmitTimer() {
        discoverEmitTimer?.cancel()
        discoverEmitTimer = nil
    }

    private func startConnectTimeoutTimer() {
        clearConnectTimers()
        let t = DispatchSource.makeTimerSource(queue: centralQueue)
        t.schedule(deadline: .now() + connectTimeout)
        t.setEventHandler { [weak self] in
            guard let self = self, let p = self.currentPeripheral else { return }
            self.central.cancelPeripheralConnection(p)
            self.errorSubject.onNext(.connectTimeout)
            self.currentPeripheral = nil
            self.clearConnectTimers()
        }
        connectTimeoutTimer = t
        t.resume()
    }

    private func clearConnectTimers() {
        connectTimeoutTimer?.cancel()
        connectTimeoutTimer = nil
        rssiTimer?.cancel()
        rssiTimer = nil
    }

    private func startRSSITimer() {
        rssiTimer?.cancel()
        let t = DispatchSource.makeTimerSource(queue: centralQueue)
        t.schedule(deadline: .now() + rssiInterval, repeating: rssiInterval)
        t.setEventHandler { [weak self] in
            guard let self = self, let p = self.currentPeripheral else { return }
            p.readRSSI()
        }
        rssiTimer = t
        t.resume()
    }

    private func startScanStopTimer(after seconds: TimeInterval) {
        stopScanStopTimer()
        let t = DispatchSource.makeTimerSource(queue: centralQueue)
        t.schedule(deadline: .now() + seconds)
        t.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.isScanning = false
            self.central.stopScan()
            self.stopDiscoverEmitTimer()
            self.scanTimeoutSubject.onNext(())
            self.stopScanStopTimer()
        }
        scanStopTimer = t
        t.resume()
    }

    private func stopScanStopTimer() {
        scanStopTimer?.cancel()
        scanStopTimer = nil
    }

    // MARK: - Helpers
    private func mergeSystemConnectedPeripherals() {
        guard let uuids = knownServiceUUIDs, !uuids.isEmpty else { return }
        let connected = central.retrieveConnectedPeripherals(withServices: uuids)
        for p in connected {
            let dev = DiscoveredDevice(peripheral: p, name: p.name, identifier: p.identifier, rssi: nil, manufacturerData: nil)
            devicesDict[p.identifier] = dev
        }
    }

    private func matchesFilter(name: String?, identifier: UUID) -> Bool {
        let nameOk: Bool = {
            guard let f = filterNameContains, !f.isEmpty else { return true }
            guard let n = name?.lowercased() else { return false }
            return n.contains(f)
        }()
        let idOk: Bool = {
            guard let f = filterIdentifierContains, !f.isEmpty else { return true }
            return identifier.uuidString.lowercased().contains(f)
        }()
        return nameOk && idOk
    }
}

// MARK: - Models & Errors
struct DiscoveredDevice {
    let peripheral: CBPeripheral
    let name: String?
    let identifier: UUID
    let rssi: NSNumber?
    let manufacturerData: Data?
}

enum InrfBleError: Error {
    case stateUnavailable
    case scanFailed
    case connectFailed
    case connectTimeout
    case servicesDiscoverFailed
    case characteristicsDiscoverFailed
}

// MARK: - CBCentralManagerDelegate & CBPeripheralDelegate
extension InrfBleManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 状态变化由调用方自行决定是否重新发起扫描
        if central.state != .poweredOn {
            errorSubject.onNext(.stateUnavailable)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard isScanning else { return }
        if matchesFilter(name: peripheral.name, identifier: peripheral.identifier) {
            let oldDev = devicesDict[peripheral.identifier]
            let mData = (advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data) ?? oldDev?.manufacturerData
            let dev = DiscoveredDevice(peripheral: peripheral, name: peripheral.name, identifier: peripheral.identifier, rssi: RSSI, manufacturerData: mData)
            devicesDict[peripheral.identifier] = dev
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Connected to \(peripheral.name ?? "Unknown")")
        clearConnectTimers()
        currentPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        startRSSITimer()
        emitDevices()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        JLLogManager.logLevel(.ERROR, content: "[InrfBle] Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        clearConnectTimers()
        currentPeripheral = nil
        errorSubject.onNext(.connectFailed)
        emitDevices()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        JLLogManager.logLevel(.INFO, content: "[InrfBle] Disconnected: \(error?.localizedDescription ?? "Normal")")
        clearConnectTimers()
        if currentPeripheral?.identifier == peripheral.identifier { currentPeripheral = nil }
        emitDevices()
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            JLLogManager.logLevel(.ERROR, content: "[InrfBle] Discover services failed: \(error)")
            errorSubject.onNext(.servicesDiscoverFailed)
            return
        }
        let services = peripheral.services ?? []
        JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Discovered \(services.count) services")
        servicesObservable.accept((peripheral, services))
        for s in services { peripheral.discoverCharacteristics(nil, for: s) }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            JLLogManager.logLevel(.ERROR, content: "[InrfBle] Discover characteristics failed for \(service.uuid): \(error)")
            errorSubject.onNext(.characteristicsDiscoverFailed)
            return
        }
        let chs = service.characteristics ?? []
        JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Discovered \(chs.count) characteristics for service \(service.uuid)")
        characteristicsObservable.accept((peripheral, service, chs))
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value, error == nil {
            JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Did update value for \(characteristic.uuid): \(data.count) bytes")
            notifyValueObservable.accept((peripheral, characteristic, data))
        } else if let error = error {
            JLLogManager.logLevel(.ERROR, content: "[InrfBle] Update value error: \(error)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let ok = (error == nil)
        JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Did write value for \(characteristic.uuid): ok=\(ok)")
        writeResultObservable.accept((peripheral, characteristic, ok, error))
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let notifying = characteristic.isNotifying
        JLLogManager.logLevel(.DEBUG, content: "[InrfBle] Did update notification state for \(characteristic.uuid): isNotifying=\(notifying), error=\(String(describing: error))")
        notifyStateObservable.accept((peripheral, characteristic, notifying, error))
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if error == nil {
            rssiSubject.onNext((peripheral, RSSI))
            if let old = devicesDict[peripheral.identifier] {
                let newDev = DiscoveredDevice(peripheral: peripheral, name: old.name, identifier: old.identifier, rssi: RSSI, manufacturerData: old.manufacturerData)
                devicesDict[peripheral.identifier] = newDev
                emitDevices()
            }
        }
    }
}
