//
//  NRFViewModel.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/11.
//

import Foundation
import RxSwift
import RxCocoa
import CoreBluetooth

/// NFR 扫描页面 ViewModel
class NRFViewModel {
    enum SortOption { case rssiDesc, nameAsc }
    
    let filterNameRelay = BehaviorRelay<String?>(value: nil)
    let sortRelay = BehaviorRelay<SortOption>(value: .rssiDesc)
    let scanningRelay = BehaviorRelay<Bool>(value: false)
    
    private let bag = DisposeBag()
    
    // 输出
    lazy var devicesDriver: Driver<[DiscoveredDevice]> = {
        Observable.combineLatest(
            InrfBleManager.shared.devicesObservable,
            filterNameRelay.asObservable(),
            sortRelay.asObservable()
        )
        .map { list, keyword, sort -> [DiscoveredDevice] in
            let kw = keyword?.lowercased()
            let filtered = list.filter { d in
                guard let k = kw, !k.isEmpty else { return true }
                return (d.name ?? "").lowercased().contains(k)
            }
            switch sort {
            case .rssiDesc:
                return filtered.sorted { ($0.rssi?.intValue ?? -127) > ($1.rssi?.intValue ?? -127) }
            case .nameAsc:
                return filtered.sorted { ($0.name ?? "") < ($1.name ?? "") }
            }
        }
        .observe(on: MainScheduler.instance)
        .asDriver(onErrorJustReturn: [])
    }()
    lazy var scanTimeoutDriver: Driver<Void> = {
        InrfBleManager.shared.scanTimeoutObservable
            .do(onNext: { [weak self] in self?.scanningRelay.accept(false) })
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
    }()
    
    init(manager: InrfBleManager = .shared) {
        // 使用 lazy 驱动避免在初始化阶段捕获 self
    }
    
    func startScan() {
        scanningRelay.accept(true)
        InrfBleManager.shared.startScan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.stopScan()
        }
    }
    
    func stopScan() {
        scanningRelay.accept(false)
        InrfBleManager.shared.stopScan()
    }
    
    func connect(_ device: DiscoveredDevice) {
        switch device.peripheral.state {
        case .connected, .connecting:
            InrfBleManager.shared.disconnect(device.peripheral)
        case .disconnected, .disconnecting:
            InrfBleManager.shared.connect(to: device.peripheral, timeout: 10)
        @unknown default:
            break
        }
    }
}
