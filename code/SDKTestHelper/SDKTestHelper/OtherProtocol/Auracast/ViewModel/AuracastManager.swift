//
//  AuracastManager.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/5.
//

import UIKit
import JLAuracastKit
import RxSwift
import RxCocoa

class AuracastManager: NSObject {
    static let serviceUUID = "AE00"
    static let characteristicWriteUUID = "AE03"
    static let characteristicNotifyUUID = "AE04"

    static let serviceUUIDBASS = "BF00"
    static let characteristicWriteUUIDBASS = "BF01"
    static let characteristicNotifyUUIDBASS = "BF02"

    static let shared = AuracastManager()

    private var devTransmitters: [JLAuracastTransmitter] = []
    private var devTransmittersList = BehaviorSubject<[JLAuracastTransmitter]>(value: [])
    private var characteristicWrite: CBCharacteristic?
    private var characteristicNotify: CBCharacteristic?
    private var disBag: Disposable?
    private let disposeBag = DisposeBag()

    override init() {
        super.init()
        JL_Tools.add(kJL_BLE_M_ENTITY_DISCONNECTED, action: #selector(disconnectAction(note:)), own: self)
        
    }
    
    
    
    
    private func writeData(_ data: Data, respType: CBCharacteristicWriteType = .withoutResponse) {
        if let cbp = BleManager.shared.currentPeripheral, let characteristicWrite = characteristicWrite {
            let mtu = Int(cbp.maximumWriteValueLength(for: respType))
            var offset = 0
            while offset < data.count {
                let length = min(mtu, data.count - offset)
                cbp.writeValue(data.subdata(in: offset ..< offset + length), for: characteristicWrite, type: respType)
                offset += length
            }
        }
    }
    
    private func initCharacteristic () {
        for service in BleManager.shared.currentServices {
            if service.uuid.uuidString == AuracastManager.serviceUUID {
                for item in service.characteristics ?? [] {
                    if item.uuid.uuidString == AuracastManager.characteristicWriteUUID {
                        characteristicWrite = item
                    } else if item.uuid.uuidString == AuracastManager.characteristicNotifyUUID {
                        characteristicNotify = item
                    }
                }
            }
        }
    }
    
    @objc private func disconnectAction(note : Notification) {
        JLLogManager.logLevel(.DEBUG, content: "disconnectAction,\(note)")
        let status = JLDevBleConnectStatus(cbPeripheral: BleManager.shared.currentPeripheral, connectStatus: .disconnected)
        updateTransmitters(status)
        disBag?.dispose()
        
        disBag =  BleManager.shared.didUpdateCharacteristicValue.subscribe(onNext: { [weak self] updateInfo in
            guard let self = self else { return }
            
            let characteristic = updateInfo.0
            let cbp = updateInfo.1
            if characteristic.uuid.uuidString != AuracastManager.characteristicNotifyUUID {
                return
            }
            let serviceUUID = characteristic.service?.uuid.uuidString ?? ""
            let characteristicUUID = characteristic.uuid.uuidString
            let model = JLGattModel.`init`(cbp.identifier.uuidString,
                                           name: cbp.name ?? "",
                                           serviceUUID: serviceUUID,
                                           characteristicUUID: characteristicUUID)
            if let assist = getTransmitters(cbp.identifier.uuidString) {
                assist.handler.onDataReceive(model, data: characteristic.value ?? Data())
            }
        })
        
    }

    // MAKR: - Subject
//    var transmitterList: Observable<[JLAuracastTransmitter]> {
//        return devTransmittersList
//    }

    // MARK: - Public

    func createTransmitters(_ callBack: @escaping (() -> Void)) {
        let status = JLDevBleConnectStatus(cbPeripheral: BleManager.shared.currentPeripheral, connectStatus: .connected)
        initCharacteristic()
        updateTransmitters(status, callBack)
    }
    /// 更新/初始化
    /// - Parameter status: 蓝牙设备连接状态
    func updateTransmitters(_ status: JLDevBleConnectStatus, _ callback: (() -> Void)? = nil) {
        if status.connectStatus == .connected, let dev = status.cbPeripheral {
            let gattHandler = JLGattProxyHandler(uuid: dev.identifier.uuidString, delegate: self)

            let transmitter = JLAuracastTransmitter(gattProxyHandler: gattHandler) { [weak self] state, err in
                guard let self = self else { return }
                if state {
                    JLLogManager.logLevel(.DEBUG, content: "JLAuracastTransmitter init: \(state),\(err?.localizedDescription ?? "no error")")
                    devTransmittersList.onNext(devTransmitters)
                    callback?()
                }
            }
            if !devTransmitters.contains(where: { $0.handler.uuid == transmitter.handler.uuid }) {
                devTransmitters.append(transmitter)
            }
        }
        if status.connectStatus == .disconnected {
            devTransmitters.removeAll { item in
                if item.handler.uuid == status.cbPeripheral?.identifier.uuidString {
                    item.onRelease()
                    return true
                }
                return false
            }
            devTransmittersList.onNext(devTransmitters)
            callback?()
        }
    }

    /// 获取指定设备
    /// - Parameter uuid: 设备 UUID
    /// - Returns: 设备上下文句柄
    func getTransmitters(_ uuid: String) -> JLAuracastTransmitter? {
        return devTransmitters.first(where: { $0.handler.uuid == uuid })
    }
    
    
}

extension AuracastManager: JLGattProxyProtocol {
    func jlBleDataRTXHandlerSend(_ data: Data, gattModel model: JLGattModel) {
        writeData(data, respType: .withoutResponse)
    }
}
