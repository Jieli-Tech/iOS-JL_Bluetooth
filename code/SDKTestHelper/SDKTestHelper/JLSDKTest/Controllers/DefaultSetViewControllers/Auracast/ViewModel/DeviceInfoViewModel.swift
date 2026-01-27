//
//  DeviceInfoViewModel.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/3.
//

import CoreBluetooth
import UIKit
import RxSwift

enum DevAssistType {
    case receiver
    case lancer
    case none
}

class DeviceInfoViewModel: NSObject {
    // MARK: - Private Properties
    
    /*
     receiver
     */
    let isScaningSubject = PublishSubject<Bool>()
    let deviceStateModel = BehaviorSubject<JLAuracastDevStateModel?>(value: nil)
    let broadcastModelList = BehaviorSubject<[JLBroadcastDataModel]>(value: [])
    var currentSourceModel = BehaviorSubject<JLBroadcastDataModel?>(value: nil)
    /*
     lancer
     */
    let lancerSettingModel = BehaviorSubject<JLAuracastLancerSettingMode?>(value: nil)
    
    var deviceTypeSubject = BehaviorSubject<DevAssistType>(value: .none)
    var isAuracastDeviceSubject = BehaviorSubject<Bool>(value: false)
    
    private let disposeBag = DisposeBag()
    var auracastManager: JLAuracastManager?
    var auracastLancerManager: JLAuracastLancerManager?
    
    
    // MARK: - Public Properties
    override init() {
        super.init()
        guard let manager = BleManager.shared.currentCmdMgr else { return }
        JLDeviceConfig.share().delegate = self
        JLDeviceConfig.share().deviceConfigGet(manager)
    }
    
}

extension DeviceInfoViewModel: JLConfigPtl {
    func deviceTwsConfig(with configModel: JLDeviceConfigTws) {
        isAuracastDeviceSubject.onNext(configModel.isSupportAuracast)
        if configModel.isSupportReceiveAuracast {
            deviceTypeSubject.onNext(.receiver)
            getReceiverInfo()
        }
        if configModel.isSupportLancerAuracast {
            deviceTypeSubject.onNext(.lancer)
            getLancerInfo()
        }
    }
    func deviceAuracastConfig(with configModel: JLDeviceConfigDongle) {
        if configModel.isSupportAuracast {
            deviceTypeSubject.onNext(.lancer)
            getLancerInfo()
        }
        if configModel.isSupportReceiveAuracast {
            deviceTypeSubject.onNext(.receiver)
            getReceiverInfo()
        }
        isAuracastDeviceSubject.onNext(configModel.isSupportAuracast)
    }
    
    func deviceSoundBoxConfig(with configModel: JLDeviceConfigSoundBox) {
        if configModel.isSupportAuracast {
            deviceTypeSubject.onNext(.lancer)
            getLancerInfo()
        }
        if configModel.isSupportReceiveAuracast {
            deviceTypeSubject.onNext(.receiver)
            getReceiverInfo()
        }
        isAuracastDeviceSubject.onNext(configModel.isSupportAuracast)
    }
    
    
    private func getLancerInfo(){
        guard let manager = BleManager.shared.currentCmdMgr else { return }
        auracastLancerManager = JLAuracastLancerManager(manager: manager)
        auracastLancerManager?.delegate = self
        auracastLancerManager?.getBroadcastLancerSetting()
        auracastLancerManager?.auracastGetDevState()
    }
    
    private func getReceiverInfo(){
        guard let manager = BleManager.shared.currentCmdMgr else { return }
        auracastManager = JLAuracastManager(manager: manager)
        auracastManager?.delegate = self
        auracastManager?.auracastGetDevState()
        auracastManager?.getCurrentOperationSource { currentSource in
            self.currentSourceModel.onNext(currentSource)
        }
    }
    
}

extension DeviceInfoViewModel: JLAuracastManagerDelegate {
    func auracastManager(_ mgr: JLAuracastManager, didUpdateSearchState state: Bool) {
        isScaningSubject.onNext(state)
    }
    func auracastManager(_ mgr: JLAuracastManager, didUpdateDeviceState state: JLAuracastDevStateModel) {
        deviceStateModel.onNext(state)
    }
    func auracastManager(_ mgr: JLAuracastManager, didUpdateBroadcastList list: [JLBroadcastDataModel]) {
        broadcastModelList.onNext(list)
    }
    func auracastManager(_ mgr: JLAuracastManager, didUpdateCurrentSource source: JLBroadcastDataModel?) {
        currentSourceModel.onNext(source)
    }
}

extension DeviceInfoViewModel: JLAuracastLancerManagerDelegate {
    func lancerManager(_ mgr: JLAuracastLancerManager, didUpdateSetting mode: JLAuracastLancerSettingMode) {
        lancerSettingModel.onNext(mode)
    }
}

