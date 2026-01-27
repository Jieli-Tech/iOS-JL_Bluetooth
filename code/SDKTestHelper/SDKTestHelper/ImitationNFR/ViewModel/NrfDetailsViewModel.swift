import Foundation
import RxSwift
import RxCocoa
import CoreBluetooth

/// 外设详情页 ViewModel
/// 负责：触发服务/特征发现、驱动页面分组数据、处理写入与订阅、格式化特征值
class NrfDetailsViewModel {
    struct Section {
        let service: CBService
        let characteristics: [CBCharacteristic]
    }

    enum WriteInputType { case byteArray, unsignedInt, bool, utf8 }
    struct WriteInput {
        let type: WriteInputType
        let payload: String
        let withResponse: Bool
    }

    private let bag = DisposeBag()
    private let manager = InrfBleManager.shared
    private(set) var peripheral: CBPeripheral?

    // 输出
    private let sectionsRelay = BehaviorRelay<[Section]>(value: [])
    private let notifyValueRelay = PublishRelay<(CBUUID, String)>()
    private let writeResultRelay = PublishRelay<(CBUUID, Bool, String?)>()
    private let notifyStateRelay = PublishRelay<(CBUUID, Bool, String?)>()
    private let errorRelay = PublishRelay<String>()

    private var characteristicValues: [CBUUID: String] = [:]

    var sectionsDriver: Driver<[Section]> { sectionsRelay.asDriver() }
    var notifyValueDriver: Driver<(CBUUID, String)> { notifyValueRelay.asDriver(onErrorDriveWith: .empty()) }
    var writeResultDriver: Driver<(CBUUID, Bool, String?)> { writeResultRelay.asDriver(onErrorDriveWith: .empty()) }
    var notifyStateDriver: Driver<(CBUUID, Bool, String?)> { notifyStateRelay.asDriver(onErrorDriveWith: .empty()) }
    var errorDriver: Driver<String> { errorRelay.asDriver(onErrorDriveWith: .empty()) }

    func bind(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        // 重新发起服务发现，确保数据完整性（避免缓存数据导致 Unknown 问题）
        manager.discoverAll(for: peripheral)

        // 监听服务发现事件
        manager.servicesObservable
            .compactMap { (p, services) -> [Section]? in
                guard let p = p, p.identifier == peripheral.identifier, let services = services else { return nil }
                return services.map { Section(service: $0, characteristics: $0.characteristics ?? []) }
            }
            .observe(on: MainScheduler.instance)
            .bind(to: sectionsRelay)
            .disposed(by: bag)

        manager.characteristicsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (p, service, chs) in
                guard let self = self, let p = p, p.identifier == peripheral.identifier, let service = service, let chs = chs else { return }
                var secs = self.sectionsRelay.value
                if let idx = secs.firstIndex(where: { $0.service.uuid == service.uuid }) {
                    secs[idx] = Section(service: service, characteristics: chs)
                    self.sectionsRelay.accept(secs)
                } else {
                    secs.append(Section(service: service, characteristics: chs))
                    self.sectionsRelay.accept(secs)
                }
            })
            .disposed(by: bag)
        
        // 监听错误
        manager.errorObservable
            .observe(on: MainScheduler.instance)
            .map { err -> String in
                switch err {
                case .servicesDiscoverFailed: return "服务发现失败"
                case .characteristicsDiscoverFailed: return "特征发现失败"
                case .stateUnavailable: return "蓝牙不可用"
                default: return err.localizedDescription
                }
            }
            .bind(to: errorRelay)
            .disposed(by: bag)

        manager.notifyValueObservable
            .compactMap { (p, ch, data) -> (CBUUID, String)? in
                guard let p = p, p.identifier == peripheral.identifier, let ch = ch, let data = data else { return nil }
                return (ch.uuid, self.formatData(data))
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] uuid, val in
                self?.characteristicValues[uuid] = val
            })
            .bind(to: notifyValueRelay)
            .disposed(by: bag)

        manager.writeResultObservable
            .compactMap { (p, ch, ok, err) -> (CBUUID, Bool, String?)? in
                guard let p = p, p.identifier == peripheral.identifier, let ch = ch, let ok = ok else { return nil }
                return (ch.uuid, ok, err?.localizedDescription)
            }
            .observe(on: MainScheduler.instance)
            .bind(to: writeResultRelay)
            .disposed(by: bag)

        manager.notifyStateObservable
            .compactMap { (p, ch, state, err) -> (CBUUID, Bool, String?)? in
                guard let p = p, p.identifier == peripheral.identifier, let ch = ch, let state = state else { return nil }
                return (ch.uuid, state, err?.localizedDescription)
            }
            .observe(on: MainScheduler.instance)
            .bind(to: notifyStateRelay)
            .disposed(by: bag)
    }

    func writeValue(input: WriteInput, characteristic: CBCharacteristic) {
        guard let _ = peripheral else { return }
        let type: CBCharacteristicWriteType = input.withResponse ? .withResponse : .withoutResponse
        if let data = buildData(from: input) {
            manager.write(data, to: characteristic, type: type)
        } else {
            writeResultRelay.accept((characteristic.uuid, false, "输入解析失败"))
        }
    }

    func readValue(for characteristic: CBCharacteristic) {
        manager.readValue(for: characteristic)
    }

    func toggleNotify(for characteristic: CBCharacteristic) {
        manager.setNotify(!characteristic.isNotifying, for: characteristic)
    }

    func getValue(for uuid: CBUUID) -> String? {
        return characteristicValues[uuid]
    }

    // MARK: - Helpers
    private func buildData(from input: WriteInput) -> Data? {
        switch input.type {
        case .byteArray:
            return input.payload.hexToData()
        case .unsignedInt:
            guard let v = UInt32(input.payload) else { return nil }
            // 默认小端，长度自适应（<=255:1字节，<=65535:2字节，否则4字节）
            if v <= 0xFF { return Data([UInt8(truncatingIfNeeded: v)]) }
            if v <= 0xFFFF {
                let lo = UInt8(v & 0xFF)
                let hi = UInt8((v >> 8) & 0xFF)
                return Data([lo, hi])
            }
            let b0 = UInt8(v & 0xFF)
            let b1 = UInt8((v >> 8) & 0xFF)
            let b2 = UInt8((v >> 16) & 0xFF)
            let b3 = UInt8((v >> 24) & 0xFF)
            return Data([b0, b1, b2, b3])
        case .bool:
            let lower = input.payload.lowercased()
            if lower == "true" || lower == "1" { return Data([0x01]) }
            if lower == "false" || lower == "0" { return Data([0x00]) }
            return nil
        case .utf8:
            return input.payload.data(using: .utf8)
        }
    }

    private func formatData(_ data: Data) -> String {
        let hex = data.map { String(format: "%02X", $0) }.joined(separator: " ")
        let ascii = String(data.map { c -> Character in
            (c >= 32 && c <= 126) ? Character(UnicodeScalar(c)) : "."
        })
        return hex + " | " + ascii
    }
}

fileprivate extension String {
    func hexToData() -> Data? {
        let hexString = self.removingPrefix("0x").replacingOccurrences(of: " ", with: "")
        guard hexString.count % 2 == 0 else { return nil }
        
        var data = Data(capacity: hexString.count / 2)
        
        // Process string by pairs of characters
        for i in stride(from: 0, to: hexString.count, by: 2) {
            let start = hexString.index(hexString.startIndex, offsetBy: i)
            let end = hexString.index(start, offsetBy: 2)
            let byteString = String(hexString[start..<end])
            
            guard let byte = UInt8(byteString, radix: 16) else {
                return nil
            }
            data.append(byte)
        }
        
        return data
    }
    
    private func removingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
