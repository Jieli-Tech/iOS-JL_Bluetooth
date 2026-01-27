//
//  UpdateSrcVM.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/21.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JLDialUnit
import RxSwift

class UpdateSrcVM: NSObject {
    var srcFilePath: String?
    var dialUnitMgr: JLDialUnitMgr?
    var sourceUpdateMgr: JLSourceUpdate?
    var otaManager: JL_OTAManager?
    var progressPresent: PublishSubject<Double> = .init()
    var stateStr: PublishSubject<String> = .init()
    private var didSelectCard: JL_CardType = .FLASH
    private var currentUUID: String?
    private var otaFilePath: String?
    private var onNextUpdateSrcs: [JLSourceInfo] = []

    override init() {
        super.init()
        JLLogManager.logLevel(.DEBUG, content: "UpdateSrcVM init")
        NotificationCenter.default.addObserver(self, selector: #selector(connectStatusChange(_:)), name: NSNotification.Name(kJL_BLE_M_ENTITY_CONNECTED), object: nil)
    }
    /// 初始化
    /// - Parameters:
    ///   - vc: ViewController
    ///   - result: 返回结果
    func srcSystemInit(result: @escaping (Bool) -> Void) {
        
        guard let mgr = BleManager.shared.currentCmdMgr else { return }
        otaManager = mgr.mOTAManager
        
        let chain = JLTaskChain()
        chain.addTask {[weak self] _, completion in
            self?.dialUnitMgr = JLDialUnitMgr(manager: mgr, completion: { err in
                if err == nil {
                    JLLogManager.logLevel(.DEBUG, content: "JLDialUnitMgr init success")
                    completion("create success",nil)
                }else {
                    JLLogManager.logLevel(.DEBUG, content: "JLDialUnitMgr init failed")
                    completion("careate failed",err)
                }
            })
        }
        // select file handle
        chain.addTask { _, completion in
            mgr.cmdGetSystemInfo(.COMMON) { [weak self] _, _, _ in
                let dev = mgr.getDeviceModel()
                let alert = UIAlertController(title: R.localStr.selectFileHandle(),
                                              message: nil,
                                              preferredStyle: .actionSheet)
                for it in dev.cardInfo.cardArray {
                    if let value = it as? Int {
                        let action = UIAlertAction(title: JL_CardType(rawValue: UInt8(value))!.beString(), style: .default) { ac in
                            switch ac.title {
                            case "SD_0":
                                mgr.mFileManager.setCurrentFileHandleType(.SD_0)
                            case "SD_1":
                                mgr.mFileManager.setCurrentFileHandleType(.SD_1)
                            case "USB":
                                mgr.mFileManager.setCurrentFileHandleType(.USB)
                            case "lineIn":
                                mgr.mFileManager.setCurrentFileHandleType(.lineIn)
                            case "FLASH":
                                mgr.mFileManager.setCurrentFileHandleType(.FLASH)
                            case "FLASH2":
                                mgr.mFileManager.setCurrentFileHandleType(.FLASH2)
                            case "FLASH3":
                                mgr.mFileManager.setCurrentFileHandleType(.FLASH3)
                            case "reservedArea":
                                mgr.mFileManager.setCurrentFileHandleType(.reservedArea)
                            default:
                                break
                            }
                            self?.didSelectCard = JL_CardType(rawValue: UInt8(value)) ?? .FLASH
                            completion(nil,nil)
                        }
                        alert.addAction(action)
                    }
                }
                alert.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel, handler: { _ in
                    let err = NSError(domain: "Select file handle failed", code: -1, userInfo: nil)
                    completion(nil, err)
                }))
                AppDelegate.getCurrentWindows()?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
        
        //read file list
        chain.addTask { [weak self] _, completion in
            if let card = self?.didSelectCard {
                self?.dialUnitMgr?.getFileList(card, count: 100, completion: { sourcesList, err in
                    if err == nil {
                        JLLogManager.logLevel(.DEBUG, content: "read file list success")
                        completion(sourcesList, nil)
                    }else {
                        JLLogManager.logLevel(.DEBUG, content: "read file list failed")
                        completion(nil, err)
                    }
                })
            }
        }
        
        //create update manager
        chain.addTask { [weak self] _, completion in
            guard let self = self, let dialUnitMgr = self.dialUnitMgr else {
                let err = NSError(domain: "Create JLSourceUpdate failed", code: -1, userInfo: nil)
                completion(nil,err)
                return
            }
            let handleType = mgr.mFileManager.getCurrentFileHandleType()
            self.sourceUpdateMgr = JLSourceUpdate(manager: mgr, handleType: handleType, dialMgr: dialUnitMgr, delegate: self)
            JLLogManager.logLevel(.DEBUG, content: "create JLSourceUpdate success")
            completion(nil, nil)
        }
        
        chain.run(withInitialInput: nil) { value, err in
            if err != nil {
                JLLogManager.logLevel(.DEBUG, content: "init failed")
                result(false)
            }else {
                JLLogManager.logLevel(.DEBUG, content: "init success")
                result(true)
            }
        }
    }
    

    func startOta() {
       
        guard let dialUnitMgr = dialUnitMgr,
              let filePath = srcFilePath,
              let mgr = BleManager.shared.currentCmdMgr,
              let sourceUpdateMgr = sourceUpdateMgr else { return }
        
        let otaMgr = mgr.mOTAManager
        
        if otaMgr.isSupportReuseSpaceOTA {
            sourceUpdateMgr.updateSourcesV2(filePath, dialUnitMgr: dialUnitMgr)
        } else {
            sourceUpdateMgr.updateSources(filePath, dialUnitMgr: dialUnitMgr)
        }
    }
    
    private func otaUpgradeResult(_ result: JL_OTAResult, progress: Float) {
        progressPresent.onNext(Double(progress))
        switch result {
        case .success:
            stateStr.onNext("update ufw success!")
            AppDelegate.getCurrentWindows()?.makeToast("update ufw success")
        case .fail:
            AppDelegate.getCurrentWindows()?.makeToast("update ufw fail")
        case .dataIsNull:
            stateStr.onNext("data is null")
            AppDelegate.getCurrentWindows()?.makeToast("data is null")
        case .commandFail:
            stateStr.onNext("command fail")
            AppDelegate.getCurrentWindows()?.makeToast("command fail")
        case .seekFail:
            stateStr.onNext("seek fail")
            AppDelegate.getCurrentWindows()?.makeToast("seek fail")
        case .infoFail:
            stateStr.onNext("info fail")
            AppDelegate.getCurrentWindows()?.makeToast("info fail")
        case .lowPower:
            stateStr.onNext("low power")
            AppDelegate.getCurrentWindows()?.makeToast("low power")
        case .enterFail:
            stateStr.onNext("enter fail")
            AppDelegate.getCurrentWindows()?.makeToast("enter fail")
        case .upgrading:
            stateStr.onNext("upgrading")
            progressPresent.onNext(Double(progress))
        case .reconnect:
            AppDelegate.getCurrentWindows()?.makeToast(R.localStr.reconnect(), position: .center)
            // TODO: 开发者需要根据设备 UUID 去回连设备
            reconnectAction()
        case .reboot:
            stateStr.onNext("reboot")
            AppDelegate.getCurrentWindows()?.makeToast("reboot")
            reconnectAction()
        case .preparing:
            stateStr.onNext("preparing")
        case .prepared:
            stateStr.onNext("prepared")
        case .statusIsUpdating:
            stateStr.onNext("status is updating")
        case .failedConnectMore:
            stateStr.onNext("failed connect more")
            JLLogManager.logLevel(.DEBUG, content: "failed connect more")
        case .failSameSN:
            stateStr.onNext("fail same sn")
            JLLogManager.logLevel(.DEBUG, content: "fail same sn")
        case .cancel:
            stateStr.onNext("cancel")
            JLLogManager.logLevel(.DEBUG, content: "cancel")
        case .failVerification:
            stateStr.onNext("fail verification")
            JLLogManager.logLevel(.DEBUG, content: "fail verification")
        case .failCompletely:
            stateStr.onNext("fail completely")
            JLLogManager.logLevel(.DEBUG, content: "fail completely")
        case .failKey:
            stateStr.onNext("fail key")
            JLLogManager.logLevel(.DEBUG, content: "fail key")
        case .failErrorFile:
            stateStr.onNext("fail error file")
            JLLogManager.logLevel(.DEBUG, content: "fail error file")
        case .failUboot:
            stateStr.onNext("fail uboot")
            JLLogManager.logLevel(.DEBUG, content: "fail uboot")
        case .failLenght:
            stateStr.onNext("fail length")
            JLLogManager.logLevel(.DEBUG, content: "fail length")
        case .failFlash:
            stateStr.onNext("fail flash")
            JLLogManager.logLevel(.DEBUG, content: "fail flash")
        case .failCmdTimeout:
            stateStr.onNext("fail cmd timeout")
            JLLogManager.logLevel(.DEBUG, content: "fail cmd timeout")
        case .failSameVersion:
            stateStr.onNext("fail same version")
            JLLogManager.logLevel(.DEBUG, content: "fail same version")
        case .failTWSDisconnect:
            stateStr.onNext("fail tws disconnect")
            JLLogManager.logLevel(.DEBUG, content: "fail tws disconnect")
        case .failNotInBin:
            stateStr.onNext("fail not in bin")
            JLLogManager.logLevel(.DEBUG, content: "fail not in bin")
        case .reconnectWithMacAddr:
            stateStr.onNext("reconnect with mac addr")
            JLLogManager.logLevel(.DEBUG, content: "reconnect with mac addr")
            guard let otaManager = otaManager else { return }
            BleManager.shared.reConnectWithMac(otaManager.bleAddr)
        case .disconnect:
            stateStr.onNext("disconnect")
            JLLogManager.logLevel(.DEBUG, content: "disconnect")
        case .reconnectUpdateSource:
            stateStr.onNext("reconnect update source")
            JLLogManager.logLevel(.DEBUG, content: "reconnect update source")
            reconnectAction()
        case .unknown:
            stateStr.onNext("unknown")
            JLLogManager.logLevel(.DEBUG, content: "unknown")
        @unknown default:
            break
        }
    }
    
    
    @objc private func connectStatusChange(_ notification: Notification) {
        if (BleManager.shared.currentEntity) != nil {
            otaManager = BleManager.shared.currentCmdMgr?.mOTAManager
            let chain = JLTaskChain()
            
            chain.addTask { [weak self] _, completion in
                JLLogManager.logLevel(.DEBUG, content: "did get feature")
                guard let manager = self?.otaManager else {
                    let err = NSError(domain: "error for get manager", code: -1, userInfo: nil)
                    completion(nil, err)
                    return
                }
                if manager.otaStatus == .force, let path = self?.otaFilePath {
                    // 继续完成 OTA 升级
                    guard let dt = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                        let err = NSError(domain: "error for get data", code: -1, userInfo: nil)
                        completion(nil, err)
                        return
                    }
                    manager.cmdOTAData(dt) { [weak self] res, progress in
                        guard let self = self else { return }
                        otaUpgradeResult(res, progress: progress)
                    }
                }
                if manager.otaStatus == .normal,
                   manager.isSupportReuseSpaceOTA,
                   manager.otaSourceMode == .sourcesExtendModeFirmwareOnly,
                   let path = self?.otaFilePath {
                    // 继续完成 OTA 升级
                    guard let dt = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                        let err = NSError(domain: "error for get data", code: -1, userInfo: nil)
                        completion(nil, err)
                        return
                    }
                    manager.cmdOTAData(dt) { [weak self] res, progress in
                        guard let self = self else { return }
                        otaUpgradeResult(res, progress: progress)
                    }
                }
                if manager.otaStatus == .normal,
                   manager.isSupportReuseSpaceOTA,
                   manager.otaSourceMode == .sourcesExtendModeSourceOnly {
                    JLLogManager.logLevel(.DEBUG, content: "start update src.")
                    self?.srcSystemInit(result: { _ in
                        completion(nil, nil)
                        self?.sourceUpdateMgr?.updateAciton(self?.onNextUpdateSrcs ?? [], result: { _, err in
                            
                        })
                    })
                }
            }
            
            chain.run(withInitialInput: "") { output, err in
                if err != nil {
                    JLLogManager.logLevel(.DEBUG, content: "init error")
                } else {
                    JLLogManager.logLevel(.DEBUG, content: "init success")
                }
            }
        }
    }

    // MARK: - 重连
    private func reconnectAction() {
        JLLogManager.logLevel(.DEBUG, content: "断开设备....")
        let chain = JLTaskChain()
        chain.addTask { input, completion in
            BleManager.shared.disconnectCurrentDev { uuid in
                completion(uuid, nil)
            }
        }
        chain.addTask { [weak self] input, completion in
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem(block: {
                JLLogManager.logLevel(.DEBUG, content: "重新连接设备....")
                let reUUID = self?.currentUUID ?? ""
                JLLogManager.logLevel(.DEBUG, content: reUUID)
                BleManager.shared.connectByUUID(reUUID)
                completion(nil, nil)
            }))
        }
        chain.run(withInitialInput: "") { _, _ in
        }
    }

}


extension UpdateSrcVM: JLSourceUpdateDelegate {
    func updateProgress(_ progress: Double, type: JLSourceUpdateType, source: JLSourceInfo?, error: (any Error)?) {
        progressPresent.onNext(progress)
        stateStr.onNext(type.beString)
        
        switch type {
        case .finished:
            JLLogManager.logLevel(.DEBUG, content: "update finished")
            AppDelegate.getCurrentWindows()?.makeToast("update finished")
        case .updateUfw:
            guard let source = source,
                  let data = source.fileData,
                  let mgr = BleManager.shared.currentCmdMgr else { return }
            JLLogManager.logLevel(.DEBUG, content: "should go to update ufw")
            AppDelegate.getCurrentWindows()?.makeToast("update ufw")
            stateStr.onNext("update ufw:\(source.fileName)")
            currentUUID = mgr.mBLE_UUID
            otaFilePath = source.filePath
            otaManager?.cmdOTAData(data) { [weak self] res, progress in
                guard let self = self else { return }
                otaUpgradeResult(res, progress: progress)
            }
        case .newest, .invalid, .empty, .noSpace, .zipError, .compareFail, .updateNotSupport:
            JLLogManager.logLevel(.DEBUG, content: "update failed,:\(String(describing: error))")
            guard let err = error as? NSError else { return }
            AppDelegate.getCurrentWindows()?.makeToast(err.localizedDescription)
            break
        case .srcError:
            JLLogManager.logLevel(.DEBUG, content: "update failed,:\(String(describing: error))")
            guard let err = error as? NSError else { return }
            AppDelegate.getCurrentWindows()?.makeToast(err.localizedDescription)
            break
        case .updateing:
            let currentFile = source?.fileName ?? ""
            stateStr.onNext("updateing:\(currentFile)")
            break
        @unknown default:
            break
        }
    }
    func updateUfwFirst(_ filePath: String, thenUpdateSrc filePaths: [JLSourceInfo]) {
        otaFilePath = filePath
        JLLogManager.logLevel(.DEBUG, content: "should go to update ufw first")
        stateStr.onNext("update ufw first")
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
        onNextUpdateSrcs = filePaths
        currentUUID = BleManager.shared.currentCmdMgr?.mBLE_UUID
        otaManager?.cmdOTAData(data) { [weak self] res, progress in
            guard let self = self else { return }
            otaUpgradeResult(res, progress: progress)
        }
    }
}


fileprivate extension JLSourceUpdateType {
    var beString: String {
        switch self {
        case .finished:
            return "Source update finished"
        case .newest:
            return "Source is newest"
        case .invalid:
            return "Source is invalid"
        case .empty:
            return "Source is empty"
        case .srcError:
            return "Source update error"
        case .updateing:
            return "Source updateing"
        case .noSpace:
            return "No enough space"
        case .zipError:
            return "zip error"
        case .compareFail:
            return "Compare fail"
        case .updateUfw:
            return "Update ufw"
        case .updateNotSupport:
            return "Update not support"
        @unknown default:
            return "unKnow"
        }
    }
}
