//
//  PublicSettingViewModel.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/1/10.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import JL_BLEKit
import UIKit
import JLDialUnit
import JLBmpConvertKit

enum ColorScreenChipType {
    case AC701N
    case AC707N
}

@objcMembers class ScreenSaverModel: NSObject {
    var fileName = ""
    var cluster: UInt32 = 0
    var crc: UInt16 = 0
}

@objcMembers class PublicSettingViewModel: NSObject {
    /// 背景纸
    static let backgroundPaper: UInt8 = 0x03
    /// 屏保
    static let screenSaver: UInt8 = 0x01

    let currentLight: BehaviorRelay<UInt8> = BehaviorRelay(value: 0)
    let currentScreenSaver: BehaviorRelay<ScreenSaverModel?> = BehaviorRelay(value: nil)
    let currentWallpaper: BehaviorRelay<JLPublicSourceInfoModel?> = BehaviorRelay(value: nil)
    let fileModelList: BehaviorRelay<[JLDialSourceModel]> = BehaviorRelay(value: [])
    private let disposeBag = DisposeBag()
    private var publicSetting: JLPublicSetting?
    private var devFileManager: JL_FileManager?
    private var dialInfo: JLDialInfoExtentedModel? = JL_RunSDK.sharedMe().dialInfoExtentedModel
    private var dialUnitMgr:JLDialUnitMgr? = JL_RunSDK.sharedMe().dialUnitMgr
    private var currentFileModel: JLDialSourceModel = .init()
    private var observerCurrentBg: NSKeyValueObservation?
    private var fileCount: UInt8 = 20
    private var manager: JL_ManagerM? {
        JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager
    }

    public var sdkInfo: JLPublicSDKInfoModel? = JL_RunSDK.sharedMe().publicSDKInfoModel
    public var isFinish: ((_ isFinish: Bool) -> Void)?
    public var chipType: ColorScreenChipType {
        // 当前只有 0x01 类型，仅支持：充电仓项目、彩屏舱
        guard let info = sdkInfo,
              info.projectId == 0x01,
              info.productId == 0x01
        else {
            return .AC701N
        }

        switch info.chipId {
        case 0x01: // AC701N
            return .AC701N
        default:
            return .AC707N
        }
    }
    public var wallPaperMode: JLPublicSourceInfoModel? {
        get {
            currentWallpaper.value
        }
    }
    public var screenSaverMode: ScreenSaverModel? {
        get {
            currentScreenSaver.value
        }
    }

    override init() {
        super.init()
        if let _ = manager {
            publicSetting = JLPublicSetting()
            publicSetting?.delegate = self
            let chain = JLTaskChain()
            prepareLight(chain)
            prepareBroser()
            parepareScreenSaver(chain)
            chain.run(withInitialInput: nil) { [weak self] _, err in
                guard let `self` = self else { return }
                if let err = err {
                    JLLogManager.logLevel(.ERROR, content: err.localizedDescription)
                }
                self.isFinish?(true)
                self.isFinish = nil
            }
        } else {
            isFinish?(false)
            isFinish = nil
            JLLogManager.logLevel(.ERROR, content: "PublicSettingViewModel manager is nil")
        }
    }

    /// 更新屏幕亮度
    /// - Parameter value: 亮度值
    public func updateLightValue(_ value: UInt8) {
        guard let mgr = manager else { return }
        var sendValue = value
        if sendValue > 80 && sendValue <= 100 {
            sendValue = 100
        }else if sendValue > 60 && sendValue <= 80 {
            sendValue = 80
        }else if sendValue > 40 && sendValue <= 60 {
            sendValue = 60
        }else if sendValue > 20 && sendValue <= 40 {
            sendValue = 40
        }else if sendValue >= 0 && sendValue <= 20 {
            sendValue = 20
        }
        currentLight.accept(sendValue)
        publicSetting?.cmdScreenLightSet(mgr, value: sendValue, result: { _ , _ in
        })
    }
    
    public func getScreenLight() {
        guard let mgr = manager else { return }
        publicSetting?.cmdScreenLightGet(mgr, result: { [weak self] status, light in
            guard let `self` = self else { return }
            if status == .success {
                self.currentLight.accept(light)
            }
        })
    }

    /// 设置壁纸
    /// - Parameter model: 壁纸
    public func setWallPaper(_ model: PtColModel) {
        guard let mgr = manager, let fileModel = findByModel(model) else { return }
        let info = JLPublicSourceInfoModel()
        info.type = PublicSettingViewModel.backgroundPaper
        info.cluster = fileModel.fileClus
        info.fileHandle = JL_Tools.hex(toData: fileModel.fileHandle) as Data
        info.filePath = String(data: fileModel.pathData ?? Data(), encoding: .utf8) ?? ""
        publicSetting?.cmdDeviceFuncUseSourceSet(mgr, info: info, result: { [weak self] _, _ in
            guard let `self` = self else { return }
            let devHandle = manager?.outputDeviceModel().cardInfo.flashHandle ?? Data()
            currentFileModel.cardType = .FLASH
            currentFileModel.folderName = "Flash"
            currentFileModel.fileName = "Flash"
            currentFileModel.fileClus = 0
            currentFileModel.fileType = .folder
            currentFileModel.fileHandle = devHandle.map { String(format: "%02X", $0) }.joined()
            devFileManager?.cmdSetDeviceStorage(devHandle, result: { _, _, _ in
                self.checkUpdateFileList()
            })
        })
    }
    
    //预设浏览设备端信息的内容
    private func prepareBroser() {
        guard let dialUnitMgr = dialUnitMgr else { return }
        fileModelList.accept(dialUnitMgr.fileArray as? [JLDialSourceModel] ?? [])
    }

    private func prepareLight(_ chain: JLTaskChain) {
        guard let mgr = manager else { return }
        chain.addTask { _, completion in
            self.publicSetting?.cmdScreenLightGet(mgr, result: { [weak self] status, light in
                guard let `self` = self else { return }
                if status == .success {
                    self.currentLight.accept(light)
                }
                completion(nil, nil)
            })
        }
    }

    private func parepareScreenSaver(_ chain: JLTaskChain) {
        guard let mgr = manager else { return }
        chain.addTask {  _, completion in
            if self.chipType == .AC701N {
                self.publicSetting?.cmdDeviceFuncUsedSourceGet(mgr, type: PublicSettingViewModel.screenSaver, result: { [weak self] status, model in
                    guard let self = self else { return }
                    if status == .success, let model = model {
                        if model.type == PublicSettingViewModel.screenSaver {
                            let screenSaverModel = ScreenSaverModel()
                            screenSaverModel.crc = model.crc
                            let url = URL(fileURLWithPath: model.filePath)
                            screenSaverModel.fileName = url.lastPathComponent
                            screenSaverModel.cluster = model.cluster
                            self.currentScreenSaver.accept(screenSaverModel)
                        }
                    }
                    completion(nil, nil)
                })
            } else {
                self.observerCurrentBg = self.dialUnitMgr?.observe(\.currentBackground, options: .new, changeHandler: { _, value in
                    guard let mode = value.newValue, let mode = mode else { return }
                    let screenSaverModel = ScreenSaverModel()
                    screenSaverModel.crc = mode.crc
                    screenSaverModel.cluster = mode.fileClus
                    screenSaverModel.fileName = mode.fileName
                    self.currentScreenSaver.accept(screenSaverModel)
                })
                self.dialUnitMgr?.dialGetCurrentBackground({ currentScreenSaverMode, err in
                    if let mode = currentScreenSaverMode {
                        let screenSaverModel = ScreenSaverModel()
                        screenSaverModel.crc = mode.crc
                        screenSaverModel.cluster = mode.fileClus
                        screenSaverModel.fileName = mode.fileName
                        self.currentScreenSaver.accept(screenSaverModel)
                    }
                    self.publicSetting?.cmdDeviceFuncUsedSourceGet(mgr, type: PublicSettingViewModel.backgroundPaper, result: { [weak self] status, model in
                        guard let self = self else { return }
                        if status == .success, let model = model {
                            if model.type == PublicSettingViewModel.backgroundPaper {
                                self.currentWallpaper.accept(model)
                            }
                        }
                        completion(nil, nil)
                    })
                })
            }
        }
    }

    public func checkUpdateFileList() {
        dialUnitMgr?.getFileList(.FLASH, count: Int(fileCount), completion: { [weak self] list, err in
            guard let `self` = self else { return }
            if let list = list {
                self.fileModelList.accept(list)
            }
        })
    }
    
    public func makeGIFBin(_ data: Data, _ binData: @escaping (Data?) -> Void) {
        var type = JLGIFBinChipType.JL_701N
        if chipType == .AC707N {
            type = .JL_707N
        }
        JLGifBin.makeData(toBin: data, level: 1, chipType: type, packageType: .JLVGL) { code, data in
            if code == 0, let data = data {
                binData(data)
            } else {
                binData(nil)
            }
        }
    }
    
    public func makeConvert(_ data: UIImage)->Data? {
        guard let model = dialInfo else {return nil}
        let imgData = JLBmpConvert.resize(data, andResizeTo: model.size)
        var type = JLBmpConvertType.type701N_RBG
        if chipType == .AC707N {
            type = .type707N_RBG
        }
        let option = JLBmpConvertOption()
        option.convertType = type
        return JLBmpConvert.convert(option, imageData: imgData).outFileData
    }
    
    public func transportToDev(data:Data, name: String, _ completion: @escaping (Int, Double, Error?) -> Void) {
        dialUnitMgr?.updateFile(toDevice: .FLASH, data: data, filePath: "/" + name.uppercased(), completion: { status, progress, err in
            completion(Int(status), progress, err)
        })
    }
    
    public func activeVIE(name: String, vieImage: UIImage) {
        if chipType != .AC707N { return }
        let model = JLDialSourceModel()
        model.fileName = name
        let chain = JLTaskChain()
        //先设表盘
        chain.addTask { [weak self] _, completion in
            self?.dialUnitMgr?.dialActiveCustomBackground(model, completion: {  _, _ in
                completion(nil, nil)
            })
        }
        //再读设备列表
        chain.addTask { [weak self] _, completion in
            self?.dialUnitMgr?.getFileList(.FLASH, count: 100, completion: { list, _ in
                if let list = list {
                    self?.fileModelList.accept(list)
                }
                completion(nil, nil)
            })
        }
        //再读表盘背景（当前的屏保）
        chain.addTask { [weak self] _, completion in
            self?.dialUnitMgr?.dialGetCurrentBackground({ currentScreenSaverMode, err in
                if let mode = currentScreenSaverMode {
                    let screenSaverModel = ScreenSaverModel()
                    screenSaverModel.crc = mode.crc
                    screenSaverModel.cluster = mode.fileClus
                    screenSaverModel.fileName = mode.fileName
                    self?.currentScreenSaver.accept(screenSaverModel)
                    if name == "VIE_CST" {
                        let newName = name + String(format: "-%.0f-%04X", Date().timeIntervalSince1970, mode.crc)
                        SwiftHelper.saveProtectCustomToCache(
                            vieImage,
                            newName
                        )
                    }
                }
                completion(nil, nil)
            })
        }
        //执行
        chain.run(withInitialInput: nil) { [weak self] _, _ in
            guard let self = self else { return }
            let value = self.fileModelList.value
            self.fileModelList.accept(value)
        }
    }
    
    public func deleteScreenSavers(_ items: [JLDialSourceModel]) {
        if chipType == .AC701N { return }
        let chain = JLTaskChain()
        for item in items {
            if currentScreenSaver.value?.fileName == item.fileName {
                chain.addTask { [weak self] _, completion in
                    self?.dialUnitMgr?.dialResetCustomBackground({ _, _ in
                        self?.currentScreenSaver.accept(nil)
                        completion(nil,nil)
                    })
                }
            }
        }
        var paths:[String] = []
        for item in items {
            paths.append("/" + item.fileName)
        }
        chain.addTask { [weak self] _, completion in
            self?.dialUnitMgr?.deleteFiles(paths, completion: { status, err in
                completion(nil, nil)
            })
        }
        chain.run(withInitialInput: nil) { [weak self] _ , _ in
            guard let self = self else { return }
            self.fileModelList.accept(dialUnitMgr?.fileArray as? [JLDialSourceModel] ?? [])
        }
    }
    
    

    private func findByModel(_ model: PtColModel) -> JLModel_File? {
        for item in dialUnitMgr?.fileArray as? [JLDialSourceModel] ?? [] {
            let name = model.imgPath?.lastPathComponent.replacingOccurrences(of: ".png", with: "")
            if item.fileName.uppercased() == name?.uppercased() {
                return item
            }
        }
        return nil
    }
    deinit {
        print("PublicSettingViewModel deinit")
        observerCurrentBg?.invalidate()
    }
    
}

extension PublicSettingViewModel: JLPublicSettingProtocol {
    func publicSettingScreenLight(_: JL_ManagerM, value light: UInt8) {
        currentLight.accept(light)
    }

    func publicSettingFuncSource(_: JL_ManagerM, model: JLPublicSourceInfoModel) {
        if model.type == PublicSettingViewModel.backgroundPaper {
            currentWallpaper.accept(model)
        } else if model.type == PublicSettingViewModel.screenSaver {
            let screenSaverModel = ScreenSaverModel()
            screenSaverModel.crc = model.crc
            let url = URL(fileURLWithPath: model.filePath)
            screenSaverModel.fileName = url.lastPathComponent
            screenSaverModel.cluster = model.cluster
            currentScreenSaver.accept(screenSaverModel)
        }
    }
}
