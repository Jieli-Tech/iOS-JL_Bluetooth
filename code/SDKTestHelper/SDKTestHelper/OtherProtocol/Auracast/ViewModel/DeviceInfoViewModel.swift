//
//  DeviceInfoViewModel.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/3.
//

import CoreBluetooth
import UIKit
import JLAuracastKit
import RxSwift

enum DevAssistType {
    case receiver
    case transmitter
}

class DeviceInfoViewModel: NSObject {
    // MARK: - Private Properties

    private weak var transmitter: JLAuracastTransmitter?
    private var deviceUUID: String = ""

    let isScaningSubject = PublishSubject<Bool>()
    let broadcastModelList = PublishSubject<[JLBroadcastDataModel]>()
    var currentConnectting: JLBroadcastDataModel?
    var receiveStatusSubject = PublishSubject<JLBroadcastDataModel>()
    private let disposeBag = DisposeBag()

    private var codeName: (String, String)?
    private var scanConnectBlock: ((_ status: Bool) -> Void)?

    // MARK: - Public Properties

    lazy var devInfoMgr: JLBroadcastInfoManager? =
        JLBroadcastInfoManager(transmitter: transmitter!, protocol: self)
    /// 广播数据列表
    public let devBroadcastModelList = BehaviorRelay<[JLBroadcastDataModel]>(value: [])

    var isScaningDev: Bool = false

    var currentUUID: String {
        return deviceUUID
    }

    /// 设备类型
    var devAssistType: DevAssistType {
        if transmitter?.devInfoSystem.infoBasic.productType.type == .adapter {
            return .transmitter
        } else {
            return .receiver
        }
    }

    /// 当前正在使用的 broadcastID
    var currentBroadcastID: Int {
        return devInfoMgr?.currentBroadcastModel?.broadcastID ?? -1
    }

    /// 是否支持音量同步
    var isSupportAudioSync: Bool {
        return transmitter?.devInfoStatus.isSupportVolumeSync ?? false
    }

    // MARK: - Public Methods

    init(_ uuid: String) {
        super.init()
        deviceUUID = uuid
        transmitter = AuracastManager.shared.getTransmitters(uuid)
        guard let transmitter = transmitter else {
            JLLogManager.logLevel(.DEBUG, content: "transmitter is nil")
            return
        }
        JLLogManager.logLevel(.DEBUG, content: "DeviceInfoViewModel init: \(uuid) \(self)")
        // 请求当前正在使用的设备
        devInfoMgr?.controlMgr.onControlGetState(transmitter)
    }

    /// 开始/停止设备端的搜索
    /// - Parameter on: status
    func makeDevScanLancer(_ isOn: Bool) {
        guard let transmitter = transmitter else {
            JLLogManager.logLevel(.DEBUG, content: "transmitter is nil")
            return
        }
        if isOn {
            devInfoMgr?.scanMgr.onSearchStartedTransmitter(transmitter) { [weak self] _, err in
                guard let self = self else { return }
                if let err = err {
                    JLLogManager.logLevel(.DEBUG, content: "JLScanDevManager onSearchStartedTransmitter error: \(err.localizedDescription)")
                    return
                }
                self.isScaningSubject.onNext(true)
                self.isScaningDev = true
            }
        } else {
            devInfoMgr?.scanMgr.onSearchStoppedTransmitter(transmitter) { [weak self] _, err in
                guard let self = self else { return }
                if let err = err {
                    JLLogManager.logLevel(.DEBUG, content: "JLScanDevManager onSearchStoppedTransmitter error: \(err.localizedDescription)")
                }
                self.isScaningSubject.onNext(false)
                self.isScaningDev = false
            }
        }
    }

    /// 添加播放源
    /// - Parameters:
    ///   - model: JLBroadcastDataModel
    ///   - completion: 回调
    func addSource(model: JLBroadcastDataModel, completion: ((Bool) -> Void)?) {
        if currentConnectting != nil {
            JLLogManager.logLevel(.ERROR, content: "JLBASSManager deviceAddSource error: \("已经正在添加播放源，请等上一个完成后再添加下一个")")
            return
        }
        guard let transmitter = transmitter else {
            JLLogManager.logLevel(.DEBUG, content: "transmitter is nil")
            return
        }
        if isScaningDev {
            JLTaskPromise<(Bool, Error?)> { [weak self] fullfill in
                self?.devInfoMgr?.scanMgr.onSearchStoppedTransmitter(transmitter) { status, err in
                    fullfill((status, err))
                }
            }.then { [weak self] result in
                guard let self = self else { return }
                if let err = result.1 {
                    JLLogManager.logLevel(.DEBUG, content: "JLScanDevManager onSearchStoppedTransmitter error: \(err.localizedDescription)")
                    return
                }
                self.isScaningSubject.onNext(false)
                self.isScaningDev = false
                addSource(model: model, completion: completion)
            }
            return
        }
        currentConnectting = model
        devInfoMgr?.controlMgr.onControl(with: transmitter, addSource: model, result: { [weak self] state in
            guard let self = self else { return }
            if state == .success {
                completion?(true)
            } else {
                completion?(false)
            }
            self.currentConnectting = nil
        })
    }

    /// 移除播放源
    func removeSource(_ completion: ((Bool) -> Void)?) {
        guard let transmitter = transmitter else {
            JLLogManager.logLevel(.DEBUG, content: "transmitter is nil")
            return
        }
        if devInfoMgr?.currentBroadcastModel?.syncState.state != .idle {
            devInfoMgr?.controlMgr.onControl(withRemove: transmitter, result: { [weak self] status in
                if status == .success {
                    JLAuracastLog.logLevel(.JLLOG_DEBUG, content: "deviceRemoveSource success")
                    self?.devInfoMgr?.currentBroadcastModel = nil
                    completion?(true)
                } else {
                    JLAuracastLog.logLevel(.JLLOG_DEBUG, content: "deviceRemoveSource error")
                    completion?(false)
                }
            })
        }
    }

    /// 扫描添加播放源
    /// - Parameters:
    ///   - code: broadcastCode
    ///   - name: name
    ///   - completion: 回调
    func scanCodeAddSource(code: String, name: String, _ completion: @escaping (_ status: Bool) -> Void) {
        if codeName != nil {
            JLLogManager.logLevel(.ERROR, content: "JLBASSManager deviceAddSource error: \("已经正在添加播放源，请等上一个完成后再添加下一个")")
            completion(false)
            return
        }
        codeName = (code, name)
        makeDevScanLancer(true)
        scanConnectBlock = completion
    }

    /// 退出广播
    func leaveBroadcast() {
        guard let transmitter = transmitter else {
            JLLogManager.logLevel(.DEBUG, content: "transmitter is nil")
            return
        }
        devInfoMgr?.controlMgr.onControl(withRemove: transmitter, result: { status in
            if status == .success {
                JLAuracastLog.logLevel(.JLLOG_DEBUG, content: "deviceRemoveSource success")
            }
        })
    }

    /// 广播是否在附近
    /// - Parameter model: 广播对象
    /// - Returns: 状态
    func isNear(_ model: JLBroadcastDataModel) -> Bool {
        guard let broadcastInfoMgr = devInfoMgr else {
            return false
        }
        if let modelist = broadcastInfoMgr.broadcastDataModels as? [JLBroadcastDataModel] {
            return modelist.contains(where: { $0.broadcastID == model.broadcastID })
        }
        return false
    }

    func onRelease() {
        devInfoMgr?.onRelease()
        transmitter = nil
        JLLogManager.logLevel(.DEBUG, content: "DeviceInfoViewModel onRelease")
    }

    deinit {
        devInfoMgr?.onRelease()
        transmitter = nil
        JLLogManager.logLevel(.DEBUG, content: "DeviceInfoViewModel deinit")
    }
}

// MARK: - JLBroadcastInfoManagerProtocol

extension DeviceInfoViewModel: JLBroadcastInfoManagerProtocol {
    func jlBroadcastInfoManager(_: JLBroadcastInfoManager,
                                broadcastDataModelList models: [JLBroadcastDataModel]) {
        broadcastModelList.onNext(models)
        devBroadcastModelList.accept(models)
    }

    func jlBroadcastInfoManager(_: JLBroadcastInfoManager, broadcastDataModel _: JLBroadcastDataModel) {}

    func jlBroadcastInfoManager(_: JLBroadcastInfoManager, broadcastState model: JLBroadcastDataModel) {
        receiveStatusSubject.onNext(model)
    }
}
