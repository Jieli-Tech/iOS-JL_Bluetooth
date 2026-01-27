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

@objcMembers class DeviceInfoViewModel: NSObject {
    
    struct BroadcastIDPassword {
        var id: Data
        var password: Data
    }
    
    static let shared = DeviceInfoViewModel()
    /*
     receiver
     */
    let isScaningSubject = PublishSubject<Bool>()
    let deviceStateModel = BehaviorRelay<JLAuracastDevStateModel?>(value: nil)
    let broadcastModelList = BehaviorRelay<[JLBroadcastDataModel]>(value: [])
    let broadcastModelShowList = BehaviorRelay<[JLBroadcastDataModel]>(value: [])
    private let broadcastModelShowSubject = PublishSubject<[JLBroadcastDataModel]>()
    var currentSourceModel = BehaviorRelay<JLBroadcastDataModel?>(value: nil)
    /*
     lancer
     */
    let lancerSettingModel = BehaviorRelay<JLAuracastLancerSettingMode?>(value: nil)
    let deviceInfoList = BehaviorRelay<[[LancerDeviceSetModel]]>(value: [])

    var deviceTypeSubject = BehaviorRelay<DevAssistType>(value: .none)
    var isAuracastDeviceSubject = BehaviorRelay<Bool>(value: false)
    
    var auracastManager: JLAuracastManager?
    var auracastLancerManager: JLAuracastLancerManager?
    lazy var broadcastDbVm: BroadcastInfoDbVM = {
        .init(deviceUUID)
    }()
    var deviceUUID: String = ""
    var currentLoginPassword: String = ""
    var keyPassword : BroadcastIDPassword?
    
    private let alertScanConnectView = AlertScanConnect()
    private var refreshTimer: Timer?
    private let disposeBag = DisposeBag()
    private var codeName: (String, String)?
    private var scanConnectBlock: ((_ status: Bool) -> Void)?

    
    // MARK: - Public Properties
    override init() {
        super.init()
        broadcastModelShowSubject
            .throttle(.milliseconds(2000), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] list in
                self?.broadcastModelShowList.accept(list)
            })
            .disposed(by: disposeBag)
        onStart()
    }
    @discardableResult class func shareInstance() -> DeviceInfoViewModel {
        return shared
    }
    func onStart() {
        guard let manager = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else { return }
        deviceUUID = manager.getDeviceModel().mBLE_UUID
        JLDeviceConfig.share().delegate = self
        JLDeviceConfig.share().deviceConfigGet(manager)
    }
    
    func onScan() {
        auracastManager?.auracastScanBroadcast(.start)
    }
    
    func onStopScan() {
        auracastManager?.auracastScanBroadcast(.stop)
    }
    
    func onGetScanState() {
        auracastManager?.auracastScanBroadcast(.query)
    }
    
    func onDestory() {
        auracastManager?.onDestory()
        auracastLancerManager?.onDestory()
        auracastManager = nil
        auracastLancerManager = nil
        deviceUUID = ""
        JLDeviceConfig.share().delegate = nil
    }
    
    /// 广播是否在附近
    /// - Parameter model: 广播对象
    /// - Returns: 状态
    func isNear(_ model: JLBroadcastDataModel) -> Bool {
        let modelist = broadcastModelList.value
        if currentSourceModel.value?.broadcastID == model.broadcastID {
            if currentSourceModel.value?.syncState != .idle {
                return false
            }
        }
        return modelist.contains(where: { $0.broadcastID == model.broadcastID })
    }
    
    /// 扫描添加播放源
    /// - Parameters:
    ///   - code: broadcastCode
    ///   - name: name
    ///   - completion: 回调
    func scanCodeAddSource(code: String, name: String, _ completion: @escaping (_ status: Bool) -> Void) {
        if codeName != nil {
            JLLogManager.logLevel(.DEBUG, content: "JLBASSManager deviceAddSource error: \("已经正在添加播放源，请等上一个完成后再添加下一个")")
            completion(false)
            return
        }
        codeName = (code, name)
        auracastManager?.auracastScanBroadcast(.start)
        alertScanConnectView.show(R.localStr.connectingToDevicePleaseWait(), name, 30)
        scanConnectBlock = completion
    }
    

}

extension DeviceInfoViewModel: JLConfigPtl {
    func deviceTwsConfig(with configModel: JLDeviceConfigTws) {
        isAuracastDeviceSubject.accept(configModel.isSupportAuracast)
        if configModel.isSupportReceiveAuracast {
            deviceTypeSubject.accept(.receiver)
            getReceiverInfo()
        }
        if configModel.isSupportLancerAuracast {
            deviceTypeSubject.accept(.lancer)
            getLancerInfo()
        }
    }
    func deviceAuracastConfig(with configModel: JLDeviceConfigDongle) {
        if configModel.isSupportLancerAuracast {
            deviceTypeSubject.accept(.lancer)
            getLancerInfo()
        }
        if configModel.isSupportReceiveAuracast {
            deviceTypeSubject.accept(.receiver)
            getReceiverInfo()
        }
        isAuracastDeviceSubject.accept(configModel.isSupportAuracast)
    }
    
    func deviceSoundBoxConfig(with configModel: JLDeviceConfigSoundBox) {
        if configModel.isSupportLancerAuracast {
            deviceTypeSubject.accept(.lancer)
            getLancerInfo()
        }
        if configModel.isSupportReceiveAuracast {
            deviceTypeSubject.accept(.receiver)
            getReceiverInfo()
        }
        isAuracastDeviceSubject.accept(configModel.isSupportAuracast)
    }
    
    func remvoveBroadcast(model: BroadcastDBInfo) {
        broadcastDbVm.removeModelFromHistory(model.model)
        updateShowList()
    }
    
    func addBroadcast(model: JLBroadcastDataModel, result: JLAuracastManagerResultBlock? = nil) {
        if auracastManager?.isScanning == true {
            auracastManager?.auracastScanBroadcast(.stop)
        }
        auracastManager?.addSource(toDev: model, result: result)
    }
    
    private func updateShowList() {
        let list = broadcastModelList.value
        let history = broadcastDbVm.historyDevices
        let current = currentSourceModel.value
        
        var newValue = list
        
        if current?.syncState == .success {
            newValue.removeAll(where: { $0.broadcastID == current?.broadcastID })
        }
        
        newValue.removeAll { md in
            history.contains(where: { $0.model.broadcastID == md.broadcastID })
        }
        
        if history.count > 0, list.count > 0, newValue.count == 0 {
            self.broadcastDbVm.refreshData()
        }
        
        self.broadcastModelShowSubject.onNext(newValue)
    }
        
    private func getLancerInfo(){
        guard let manager = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else { return }
        auracastLancerManager = JLAuracastLancerManager(manager: manager)
        auracastLancerManager?.delegate = self
        auracastLancerManager?.getBroadcastLancerSetting()
    }
    
    private func getReceiverInfo(){
        guard let manager = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else { return }
        auracastManager = JLAuracastManager(manager: manager)
        auracastManager?.delegate = self
        auracastManager?.getCurrentOperationSource { model in
            JLLogManager.logLevel(.DEBUG, content: "getCurrentOperationSource:\n")
            model.logProperties()
            self.onGetScanState()
        }
    }
    
}

extension DeviceInfoViewModel: JLAuracastManagerDelegate {
    func auracastManager(_ mgr: JLAuracastManager, didUpdateDeviceState state: JLAuracastDevStateModel) {
        DispatchQueue.main.async {
            self.deviceStateModel.accept(state)
        }
    }
    func auracastManager(_ mgr: JLAuracastManager, didUpdateSearchState state: Bool, error: (any Error)?) {
        DispatchQueue.main.async {
            self.isScaningSubject.onNext(state)
            if error != nil {
                AlertManager.toast(R.localStr.broadcastSearchFailed() + error!.localizedDescription)
            }
        }
    }
    func auracastManager(_ mgr: JLAuracastManager, didUpdateBroadcastList list: [JLBroadcastDataModel]) {
        DispatchQueue.main.async {
            self.broadcastModelList.accept(list)
        }
        DispatchQueue.main.async {
            self.updateShowList()
        }
        if let (code, name) = codeName, let _ = scanConnectBlock {
            for model in list {
                if model.broadcastID.map({ String(format: "%02x", $0) }).joined() == code,
                   model.broadcastName == name {
                    codeName = nil
                    auracastManager?.auracastScanBroadcast(.stop)
                    auracastManager?.addSource(toDev: model)
                    break
                }
            }
        }
    }
    func auracastManager(_ mgr: JLAuracastManager, didUpdateCurrentSource source: JLBroadcastDataModel?) {
        currentSourceModel.accept(source)
        guard let source = source else { return }
        // 添加播放源
        if source.syncState == .success {
            if source.encrypted {
                guard let kv = keyPassword, kv.id == source.broadcastID else { return }
                source.broadcastKey = kv.password
                broadcastDbVm.addModelToHistory(source)
                keyPassword = nil
            }else{
                broadcastDbVm.addModelToHistory(source)
            }
            updateShowList()
        }
        if source.syncState == .idle , source.errorCode != .none {
            AlertManager.showReceiveBroadcastFailed(source.broadcastName)
            updateShowList()
        }
    }
}

extension DeviceInfoViewModel: JLAuracastLancerManagerDelegate {
    func lancerManager(_ mgr: JLAuracastLancerManager, didUpdateSetting mode: JLAuracastLancerSettingMode) {
        DispatchQueue.main.async {
            self.lancerSettingModel.accept(mode)
        }
        updateData(model: mode)
    }
    
    func lancerManager(_ mgr: JLAuracastLancerManager, didUpdateDeviceState state: JLAuracastDevStateModel) {
        DispatchQueue.main.async {
            self.deviceStateModel.accept(state)
        }
    }
    
    private func updateData(model: JLAuracastLancerSettingMode){
        var deviceSetList: [LancerDeviceSetModel] = []
        // name
        let devName = LancerDeviceSetModel(
            name: R.localStr.name2(),
            detailContext: model.broadcastName,
            showRightArrow: true
        )
        deviceSetList.append(devName)
        
        // 音量
        let deviceModel = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.getDeviceModel()
        let currentVolume = deviceModel?.currentVol ?? 0
        let devVolume = LancerDeviceSetModel(name: R.localStr.volume(),
                                             showSlider: true,
                                             sliderValue: Float(currentVolume))
        devVolume.maxValue = 10
        devVolume.volumeStep = 1
        deviceSetList.append(devVolume)
        // 发射功率
        let currentPower = lancerSettingModel.value?.powerLevel ?? 0
        let devPower = LancerDeviceSetModel(name: R.localStr.transmitPower(),
                                            showSlider: true,
                                            sliderValue: Float(currentPower))
        devPower.maxValue = 10
        devPower.minValue = 1
        deviceSetList.append(devPower)

        /** 基础配置 **/
        var deviceBaseSetList: [LancerDeviceSetModel] = []
        // 广播配置
        let devBroadcast = LancerDeviceSetModel(name: R.localStr.broadcastConfiguration(), showRightArrow: true)
        deviceBaseSetList.append(devBroadcast)
        // 加密
        let devEncrypt = LancerDeviceSetModel(name: R.localStr.encryptionSettings(),
                                              showRightArrow: false,
                                              isShowSelect: true)
        devEncrypt.selectSwitchStatus = lancerSettingModel.value?.encryptEnabled ?? false
        deviceBaseSetList.append(devEncrypt)

        // 密钥配置
        let devKeyConfig = LancerDeviceSetModel(name: R.localStr.broadcastCode(),
                                                showRightArrow: true)
        devKeyConfig.isEnable = lancerSettingModel.value?.encryptEnabled ?? false
        deviceBaseSetList.append(devKeyConfig)

        // 音频格式
        let audioInfo = JLAudioFormatModel(audioFormat: lancerSettingModel.value?.audioFormatIndex ?? .format16_1_1)
        let devAudioFormat = LancerDeviceSetModel(name: R.localStr.audioFormat(),
                                                  detailContext: audioInfo.name,
                                                  showRightArrow: true)
        deviceBaseSetList.append(devAudioFormat)
        // 更多设置
        let devMoreSet = LancerDeviceSetModel(name: R.localStr.moreSettings(), showRightArrow: true)
        deviceBaseSetList.append(devMoreSet)

        /** 安全设置 **/
        var deviceSafeSetList: [LancerDeviceSetModel] = []
        // 密码
        let devPassword = LancerDeviceSetModel(name: R.localStr.password(), showRightArrow: true)
        deviceSafeSetList.append(devPassword)
        
        DispatchQueue.main.async {
            self.deviceInfoList.accept([deviceSetList, deviceBaseSetList, deviceSafeSetList])
        }
        
    }
}

extension JLBroadcastErrorCode {
    var message: String {
        switch self {
        case .none:
            return ""
        case .name:
            return "broadcastName error"
        case .address:
            return "broadcastAddress error"
        case .ID:
            return "broadcast ID error"
        case .key:
            return "broadcastKey error"
        case .syncFailed:
            return "syncFail error"
        case .syncTimeout:
            return "syncTimeout error"
        case .syncLost:
            return "syncLost error"
        @unknown default:
            return "unKnow error"
        }
    }
}

