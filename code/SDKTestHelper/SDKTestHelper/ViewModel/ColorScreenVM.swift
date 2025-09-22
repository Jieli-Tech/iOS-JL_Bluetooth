//
//  ColorScreenVM.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/1.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JL_BLEKit
import JLDialUnit
import JLBmpConvertKit

class ColorScreenVM: NSObject {
    
    /// SDK类型
    var sdkType: JL_SDKType = .typeST
    /// 屏幕亮度
    var screenBrightness: BehaviorRelay<UInt8> = .init(value: 0)
    /// 手电筒
    var flashlightStatus: BehaviorRelay<Bool> = .init(value: false)
    
    /// 绑定状态
    /// - Parameter value: 
    var bindStatus: BehaviorRelay<JLPublicBindDeviceModel> = .init(value: JLPublicBindDeviceModel())
    
    /// 墙纸
    var currentWallPaperModel: BehaviorRelay<JLPublicSourceInfoModel> = .init(value: JLPublicSourceInfoModel())
    /// 屏保
    var currentScreensaverModel: BehaviorRelay<JLPublicSourceInfoModel> = .init(value: JLPublicSourceInfoModel())
    /// 启动动画
    var currentBootAnimation: BehaviorRelay<JLPublicSourceInfoModel> = .init(value: JLPublicSourceInfoModel())
    
    /// SDK信息
    var sdkInfo: BehaviorRelay<JLPublicSDKInfoModel> = .init(value: JLPublicSDKInfoModel())
    
    /// 屏幕尺寸信息
    var dialInfo: BehaviorRelay<JLDialInfoExtentedModel> = .init(value: JLDialInfoExtentedModel())
    
    /// 设备端已有屏保列表(仅707N 支持）
    var screenSaverList: BehaviorRelay<[JLDialSourceModel]> = .init(value: [])
    
    /// 设备端已有墙纸列表(仅707N 支持)
    var wallPaperList: BehaviorRelay<[JLDialSourceModel]> = .init(value: [])
    
    var dialMgr:JLDialUnitMgr?
    
    /// 彩屏信息管理工具
    private var screenMgr = JLPublicSetting()
    
    override init() {
        super.init()
        guard let currentMgr = BleManager.shared.currentCmdMgr else { return }
        let model = currentMgr.getDeviceModel()
        sdkType = model.sdkType
        
        screenMgr = JLPublicSetting()
        screenMgr.delegate = self
        
        let chain = JLTaskChain()
        // 获取屏幕亮度
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            screenMgr.cmdScreenLightGet(currentMgr) { _, _ in
            }
            completion(nil, nil)
        }
        // 获取手电筒
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            screenMgr.cmdFlashLightGet(currentMgr) { _, _ in
            }
            completion(nil, nil)
        }
        // 获取SDK的信息
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            screenMgr.cmdDeviceGetDeviceSDKInfo(currentMgr) { _, _ in
                completion(nil, nil)
            }
        }
        
        // 获取屏幕尺寸的信息
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            JLDeviceConfig.share().deviceGet(currentMgr) { st, _, devModel in
                guard let devModel = devModel else { return }
                if devModel.exportFunc.spDialInfoExtend {
                    JLDialInfoExtentManager.share().getDialInfoExtented(currentMgr) { _, model in
                        if let model = model {
                            self.dialInfo.accept(model)
                        }
                        completion(nil, nil)
                    }
                }
            }
        }
        
        // 获取壁纸
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            screenMgr.cmdDeviceFuncUsedSourceGet(currentMgr, type: 1) { [weak self] _, sourceModel in
                guard let self = self else { return }
                if let sourceModel = sourceModel {
                    self.currentScreensaverModel.accept(sourceModel)
                }
                completion(nil, nil)
            }
        }
        // 获取开机动画
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            screenMgr.cmdDeviceFuncUsedSourceGet(currentMgr, type: 2) { [weak self] _, sourceModel in
                guard let self = self else { return }
                if let sourceModel = sourceModel {
                    self.currentBootAnimation.accept(sourceModel)
                }
            }
            completion(nil, nil)
        }
        // 获取墙纸
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            screenMgr.cmdDeviceFuncUsedSourceGet(currentMgr, type: 3) { [weak self] _, sourceModel in
                guard let self = self else { return }
                if let sourceModel = sourceModel {
                    self.currentWallPaperModel.accept(sourceModel)
                }
                completion(nil, nil)
            }
        }
        
        chain.run(withInitialInput: nil) { _,_ in
            JLLogManager.logLevel(.DEBUG, content: "init success")
        }

    }
    
    
    func getScreenSaverListAndWallPaper() {
        guard let currentMgr = BleManager.shared.currentCmdMgr else { return }
        //只有 707N 才有列表，701N 只有单个屏保
        if !isScreenBox707() {
            return
        }
        let chain = JLTaskChain()
        
        chain.addTask { [weak self] _, completion in
            guard let self = self else { return }
            dialMgr = JLDialUnitMgr(manager: currentMgr, completion: { _ in
                completion(nil,nil)
            })
        }
        chain.addTask { _, completion in
            currentMgr.cmdGetSystemInfo(.COMMON) { _, _, _ in
                currentMgr.mFileManager.setCurrentFileHandleType(.FLASH)
                completion(nil, nil)
            }
        }
        
        chain.addTask { [weak self] _, completion in
            guard let self = self,
                  let dialMgr = self.dialMgr else { return }
            dialMgr.getFileList(.FLASH, count: 100) { list, err in
                if err == nil, let list = list {
                    completion(nil, nil)
                    var tmpScreenSaverList: [JLDialSourceModel] = []
                    var tmpWallPaperList: [JLDialSourceModel] = []
                    for item in list {
                        if item.fileName.hasPrefix("CSBG") {
                            tmpWallPaperList.append(item)
                        }
                        if item.fileName.hasPrefix("VIE") {
                            tmpScreenSaverList.append(item)
                        }
                    }
                    self.wallPaperList.accept(tmpWallPaperList)
                    self.screenSaverList.accept(tmpScreenSaverList)
                } else {
                    completion(nil, err)
                }
            }
        }
        
        chain.run(withInitialInput: nil) { _, err in
            if err != nil {
                JLLogManager.logLevel(.DEBUG, content: "getScreenSaverList failed")
            } else {
                JLLogManager.logLevel(.DEBUG, content: "getScreenSaverList success")
            }
        }
    }
    
    func setScreenSaver(_ model: JLDialSourceModel) {
        guard let dialMgr = dialMgr else { return }
        dialMgr.dialSetCurrent(model) { state, err in
            if err == nil {
                JLLogManager.logLevel(.DEBUG, content: "setScreenSaver success")
            }
        }
    }
    
    

    func setWallPaper(_ model: JLDialSourceModel) {
        guard let mgr = BleManager.shared.currentCmdMgr else { return }
        let info = JLPublicSourceInfoModel()
        info.type = 0x03
        info.fileHandle = model.fileHandle.beData
        info.filePath = "/" + model.fileName.uppercased()
        screenMgr.cmdDeviceFuncUseSourceSet(mgr, info: info) { [weak self] status, srcModel in
            guard let self = self else { return }
            if status != .success {
                JLLogManager.logLevel(.ERROR, content: "setWallPaper failed")
            }
            JLLogManager.logLevel(.DEBUG, content: "setWallPaper success:\(srcModel?.logProperties() ?? "")")
        }
    }

    
    func deleteScreenSaverOrWallPaper(_ model:JLDialSourceModel) {
        guard let dialMgr = dialMgr else { return }
        let filePath = "/\(model.fileName.uppercased())"
        dialMgr.deleteFile(filePath) { [weak self] state, err in
            if state {
                self?.getScreenSaverListAndWallPaper()
            }
        }
    }
    
    
    func addScreenSaver(_ data: Data, _ resultBlock: @escaping (Bool,Double,Error?) -> Void) {
        guard let dialMgr = dialMgr else { return }
        var name = "VIE"
        if isScreenBox707() {
            let list = self.screenSaverList.value
            name = generateNextFilename(from: list)
        }
        let chain = JLTaskChain()
        
        chain.addTask { _, completion in
            dialMgr.updateFile(toDevice: .FLASH, data: data, filePath: name) { state, progress, err  in
                if err != nil {
                    resultBlock(false, 0.0, err)
                    completion(nil, err)
                }
                if state == 0 {
                    resultBlock(true, 1.0, nil)
                    JLLogManager.logLevel(.DEBUG, content: "addScreenSaver success")
                    completion(nil, nil)
                }
                if state == 1 {
                    resultBlock(false, progress, nil)
                }
            }
        }
        
        chain.addTask { [weak self] _, completion in
            guard let self = self,
                  let mgr = BleManager.shared.currentCmdMgr else { return }
            if isScreenBox707() {
                let dialModel = JLDialSourceModel()
                dialModel.fileName = name
                dialMgr.dialSetCurrent(dialModel) { state, err in
                    if state {
                        JLLogManager.logLevel(.DEBUG, content: "set success")
                    }
                    completion(nil, nil)
                }
            } else {
                let info = JLPublicSourceInfoModel()
                info.type = 0x01
                info.fileHandle = mgr.getDeviceModel().cardInfo.flashHandle
                info.filePath = "/" + name
                screenMgr.cmdDeviceFuncUseSourceSet(mgr, info: info) { state, _ in
                    if state == .success {
                        JLLogManager.logLevel(.DEBUG, content: "set success")
                    }
                    completion(nil, nil)
                }
            }
            completion(nil, nil)
        }
        
        chain.run(withInitialInput: nil) { [weak self] _, err in
            if err != nil {
                JLLogManager.logLevel(.DEBUG, content: "addScreenSaver failed")
                return
            }
            self?.getScreenSaverListAndWallPaper()
        }
    }
    
    func addWallPaper(_ data: Data, _ resultBlock: @escaping (Bool,Double,Error?) -> Void) {
        guard let dialMgr = dialMgr else { return }
        let name = generateCsbgNextFilename(from: self.wallPaperList.value)
        let chain = JLTaskChain()
        chain.addTask { _, completion in
            dialMgr.updateFile(toDevice: .FLASH, data: data, filePath: "/" + name) { state, progress, err in
                if err != nil {
                    resultBlock(false, 0.0, err)
                    completion(nil, err)
                }
                if state == 0 {
                    resultBlock(true, 1.0, nil)
                    JLLogManager.logLevel(.DEBUG, content: "addWallPaper success")
                    self.reloadSourceCache()
                    completion(nil, nil)
                }
                if state == 1 {
                    resultBlock(false, progress, nil)
                }
            }
        }
        
        chain.addTask {[weak self] _, completion in
            guard let self = self,
                  let mgr = BleManager.shared.currentCmdMgr else { return }
            let info = JLPublicSourceInfoModel()
            info.type = 0x03
            info.fileHandle = mgr.getDeviceModel().cardInfo.flashHandle
            info.filePath = "/" + name
            screenMgr.cmdDeviceFuncUseSourceSet(mgr, info: info) { state, _ in
                if state == .success {
                    JLLogManager.logLevel(.DEBUG, content: "setWallPaper success")
                }
                completion(nil, nil)
            }
        }
        
        chain.run(withInitialInput: nil) { [weak self] _, err in
            if err != nil {
                JLLogManager.logLevel(.DEBUG, content: "addWallPaper failed")
                return
            }
            self?.getScreenSaverListAndWallPaper()
        }
    }
    
    
    func imageToData(_ image: UIImage, _ resultBlock: @escaping (Data?) -> Void) {
        var type = JLBmpConvertType.type701N_ARBG
        if isScreenBox707() {
            type = JLBmpConvertType.type707N_ARGB
        }
        let option = JLBmpConvertOption()
        option.convertType = type
        let targetData = JLBmpConvert.convert(option, image: image)
        resultBlock(targetData.outFileData)
    }
    
    func gifToData(_ data: Data, _ resultBlock: @escaping (Data?) -> Void) {
        JLGifBin.makeData(toBin: data, level: 1) { _, data in
            resultBlock(data)
        }
    }
    
    private func reloadSourceCache() {
        guard let list = dialMgr?.fileArray as? [JLDialSourceModel] else { return }
        var tmpScreenSaverList: [JLDialSourceModel] = []
        var tmpWallPaperList: [JLDialSourceModel] = []
        for item in list {
            if item.fileName.hasPrefix("CSBG") {
                tmpWallPaperList.append(item)
            }
            if item.fileName.hasPrefix("VIE") {
                tmpScreenSaverList.append(item)
            }
        }
        self.wallPaperList.accept(tmpWallPaperList)
        self.screenSaverList.accept(tmpScreenSaverList)
    }
    
    // 找到最大的 VIE_xxx，并生成新的 filename
    private func generateNextFilename(from objects: [JLDialSourceModel]) -> String {
        // 提取所有符合条件的编号
        let validNumbers = objects.compactMap { object -> Int? in
            // 跳过特殊命名 VIE_CST
            guard !object.fileName.uppercased().hasPrefix("VIE_CST") else { return nil }
            
            // 提取编号部分
            let prefix = "VIE_"
            guard object.fileName.uppercased().hasPrefix(prefix) else { return nil }
            let numberString = String(object.fileName.uppercased().dropFirst(prefix.count))
            // 转换为整数
            return Int(numberString)
        }
        
        // 找到最大值
        let maxNumber = validNumbers.max() ?? 0
        // 计算下一个编号
        let nextNumber: Int
        if maxNumber == 999 {
            nextNumber = 0
        } else {
            nextNumber = maxNumber + 1
        }
        let nextFilename = String(format: "VIE_%03d", nextNumber)
        return nextFilename
    }
    
    // 找到最大的 csbg_xxx，并生成新的 filename
    private func generateCsbgNextFilename(from objects: [JLDialSourceModel]) -> String {
        // 提取所有符合条件的编号
        let validNumbers = objects.compactMap { object -> Int? in
            // 跳过特殊命名 csbg_x
            guard !object.fileName.uppercased().hasPrefix("CSBG_X") else { return nil }
            
            // 提取编号部分
            let prefix = "CSBG_"
            guard object.fileName.uppercased().hasPrefix(prefix) else { return nil }
            let numberString = String(object.fileName.uppercased().dropFirst(prefix.count))
            // 转换为整数
            return Int(numberString)
        }
        
        // 找到最大值
        let maxNumber = validNumbers.max() ?? 0
        // 计算下一个编号
        let nextNumber: Int
        if maxNumber == 999 {
            nextNumber = 0
        } else {
            nextNumber = maxNumber + 1
        }
        let nextFilename = String(format: "CSBG_%03d", nextNumber)
        return nextFilename
    }
    
    private func isScreenBox707() ->Bool {
        if sdkInfo.value.chipId == 0x0002 &&
            sdkInfo.value.productId == 0x01 &&
            sdkInfo.value.projectId == 0x01 {
            return true
        }
        return false
    }

}




extension ColorScreenVM : JLPublicSettingProtocol {
    func publicSettingScreenLight(_ manager: JL_ManagerM, value light: UInt8) {
        screenBrightness.accept(light)
    }
    func publicSettingFlashLight(_ manager: JL_ManagerM, value isOn: Bool) {
        flashlightStatus.accept(isOn)
    }
    
    func publicSettingFuncSource(_ manager: JL_ManagerM, model: JLPublicSourceInfoModel) {
        if model.type == 1 {
            currentScreensaverModel.accept(model)
        } else if model.type == 2 {
            currentBootAnimation.accept(model)
        } else if model.type == 3 {
            currentWallPaperModel.accept(model)
        }
    }
    
    func publicSettingBindStatus(_ manager: JL_ManagerM, model: JLPublicBindDeviceModel) {
        bindStatus.accept(model)
    }
    
    func publicSettingDeviceSDKMessage(_ manager: JL_ManagerM, mode: JLPublicSDKInfoModel?) {
        if let model = mode {
            sdkInfo.accept(model)
        }
    }
    
    
    

}
