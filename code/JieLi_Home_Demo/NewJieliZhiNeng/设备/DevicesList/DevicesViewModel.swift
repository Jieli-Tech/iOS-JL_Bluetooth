//
//  DevicesViewModel.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit


class DevicesInfoModel: NSObject {
    var dev: DeviceObjc
    var status: CellItemStatus
    var power: TwsElectricity
    init(dev: DeviceObjc, status: CellItemStatus, power: TwsElectricity) {
        self.dev = dev
        self.status = status
        self.power = power
    }
}

struct CellItemSubMode {
    var productImg: UIImage
    var name: String
    var showTypeImg: Bool
    var typeImg: UIImage
    var power: Int
    var status: CellItemStatus
    var isCharge: Bool
}

class DevicesViewModel: NSObject {
    static let share = DevicesViewModel()
    static let noodleDevVersion = 3
    let subArray = BehaviorRelay<[DevicesInfoModel]>(value: [])
    let bleDeviceDict = BehaviorRelay<[AnyHashable : Any]>(value: [:])
    
    private var maxReconnected = 3
    private var currentConnectIndex = 0
    private var isConnecting = false
    private var powerDict = NSMutableDictionary()
    private var dataArray = [String]()
    
    
    override init() {
        super.init()
        addNotes()
        updateList()
    }
    
    func connectDevice(_ dev: DevicesInfoModel, viewController: UIViewController) {
        let uuidType = JL_RunSDK.getStatusUUID(dev.dev.uuid)
        if uuidType == .disconnected {
            AlertManager.showWaitting()
            JL_RunSDK.sharedMe().mBleMultiple.getEntityWithSearchUUID(dev.dev.uuid, searchStatus: true) { [weak self] entity in
                guard let self = self else { return }
                guard let entity = entity else {
                    AlertManager.hideWaitting()
                    AlertManager.windows()?.makeToast(LanguageCls.localizableTxt("bt_connect_failed"), position: .center)
                    return
                }
                guard JL_RunSDK.isConnectedEdr(entity) else {
                    AlertManager.hideWaitting()
                    AlertManager.windows()?.makeToast(LanguageCls.localizableTxt("user_connect_edr"), position: .center)
                    return
                }
                self.connectEntity(entity)
            }
        }
        if uuidType == .connected {
            JL_RunSDK.setActiveUUID(dev.dev.uuid)
        }
        if uuidType == .inUse {
            guard let mgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else { return }
            let devModel = mgr.getDeviceModel()
            if devModel.sdkType == .type693xTWS ||
                devModel.sdkType == .type696xTWS ||
                devModel.sdkType == .type697xTWS ||
                devModel.sdkType == .type695xSDK ||
                devModel.sdkType == .type696xSB ||
                devModel.sdkType == .typeAI ||
                devModel.sdkType == .typeManifestEarphone ||
                devModel.sdkType == .typeManifestSoundbox {
                mgr.mTwsManager.cmdHeadsetGetAdvFlag(.all) { dict in
                    guard let dict = dict else {
                        return
                    }
                    let devInfoVc = DeviceInfoVC()
                    devInfoVc.headsetDict = dict
                    viewController.navigationController?.pushViewController(devInfoVc, animated: true)
                }
            }else{
                let devInfoVc = DeviceInfoVC()
                viewController.navigationController?.pushViewController(devInfoVc, animated: true)
            }
        }
        
        if uuidType == .needOTA {
            let updateVC = UpgradeVC()
            updateVC.otaEntity = JL_RunSDK.getEntity(dev.dev.uuid)
            updateVC.rootNumber = 1
            updateVC.modalPresentationStyle = .fullScreen
            viewController.present(updateVC, animated: true)
        }
        
    }
    
    private func connectEntity(_ entity: JL_EntityM) {
        if isConnecting { return }
        currentConnectIndex += 1
        isConnecting = true
        JL_RunSDK.sharedMe().connectEntity(entity) { [weak self] status in
            guard let self = self else { return }
            self.isConnecting = false
            if status == .paired {
                AlertManager.hideWaitting()
                currentConnectIndex = 0
            }else{
                if currentConnectIndex >= self.maxReconnected {
                    AlertManager.hideWaitting()
                    currentConnectIndex = 0
                    let text = JL_RunSDK.textEntityStatus(status)
                    AlertManager
                        .windows()?
                        .makeToast(
                            LanguageCls.localizableTxt("bt_connect_failed") + "\n" + text ,
                            position: .center
                        )
                } else {
                    self.connectEntity(entity)
                }
            }
        }
    }
    
    //MARK: - 产品图片
    func createCellInfo(_ mode: DevicesInfoModel, _ viewController: UIViewController) ->[CellItemSubMode] {
        if mode.status == .offline {
            return cellInfoOffline(mode)
        }
        let list = JL_RunSDK.sharedMe().mBleMultiple.bleConnectedArr
        let entity = list.first { element in
            guard let entity = element as? JL_EntityM else { return false }
            if entity.mUUID == mode.dev.uuid {
                return true
            }
            return false
        }
        guard let deviceMode = (entity as? JL_EntityM)?.mCmdManager.getDeviceModel() else {
            JLLogManager.logLevel(.DEBUG, content: "设备不存在==>无法获取电量信息以及其他信息")
            return cellInfoOffline(mode)
        }
        switch deviceMode.sdkType {
        case .typeAI, .typeST, .type696xSB, .type695xSDK, .typeManifestSoundbox, .typeUnknown:
            return cellInfoDefault(mode, Int(deviceMode.battery))
        case .type693xTWS, .type697xTWS, .type696xTWS, .typeManifestEarphone, .typeChargingCase:
            return cellInfoTws(mode)
        case .type695xWATCH,.type707nWATCH, .type701xWATCH:
            return cellInfoDefault(mode, Int(deviceMode.battery))
        case .type695xSC:
            return cellInfoDefault(mode, Int(deviceMode.battery))
        @unknown default:
            break
        }
        return []
    }
    private func cellInfoOffline(_ mode: DevicesInfoModel)->[CellItemSubMode] {
        let model = CellItemSubMode(
            productImg: DevicesViewModel.share.productImage(mode.dev),
            name: mode.dev.name,
            showTypeImg: false,
            typeImg: UIImage(),
            power: 0,
            status: .offline,
            isCharge: false
        )
        return [model]
    }
    private func cellInfoDefault(_ mode: DevicesInfoModel, _ battery: Int)->[CellItemSubMode] {
        let leftMode = CellItemSubMode(
            productImg: productImage(mode.dev),
            name: mode.dev.name,
            showTypeImg: false,
            typeImg: UIImage(),
            power: battery,
            status: mode.status,
            isCharge: false
        )
        return [leftMode]
    }
    private func cellInfoTws(_ mode: DevicesInfoModel)->[CellItemSubMode] {
        var modeList = [CellItemSubMode]()
        if mode.power.powerLeft > 0 {
            let leftMode = CellItemSubMode(
                productImg: DevicesViewModel.share.productImageLeft(mode.dev),
                name: mode.dev.name + LanguageCls.localizableTxt("left"),
                showTypeImg: true,
                typeImg: R.Image.img("Theme.bundle/product_icon_left"),
                power: Int(mode.power.powerLeft),
                status: mode.status,
                isCharge: mode.power.isChargingLeft
            )
            modeList.append(leftMode)
        }
        if mode.power.powerRight > 0 {
            let rightMode = CellItemSubMode(
                productImg: DevicesViewModel.share.productImageRight(mode.dev),
                name: mode.dev.name + LanguageCls.localizableTxt("right"),
                showTypeImg: true,
                typeImg: R.Image.img("Theme.bundle/product_icon_right"),
                power: Int(mode.power.powerRight),
                status: mode.status,
                isCharge: mode.power.isChargingRight
            )
            modeList.append(rightMode)
        }
        if mode.power.powerCenter > 0 {
            let centerMode = CellItemSubMode(
                productImg: DevicesViewModel.share.productImageChargingBin(mode.dev),
                name: mode.dev.name + LanguageCls.localizableTxt("charging_txt"),
                showTypeImg: false,
                typeImg: UIImage(),
                power: Int(mode.power.powerCenter),
                status: mode.status,
                isCharge: mode.power.isChargingCenter
            )
            modeList.append(centerMode)
        }
        //挂脖耳机特殊处理
        if mode.dev.mProtocolType == DevicesViewModel.noodleDevVersion {
            modeList.removeAll()
            let leftMode = CellItemSubMode(
                productImg: DevicesViewModel.share.productImage(mode.dev),
                name: mode.dev.name,
                showTypeImg: false,
                typeImg: UIImage(),
                power: Int(mode.power.powerLeft),
                status: mode.status,
                isCharge: mode.power.isChargingLeft
            )
            modeList.append(leftMode)
        }
        return modeList
    }
    
    
    func powerImageInfo(_ power: Int, _ isCharge: Bool)->(image: UIImage, power: String) {
        var image = UIImage()
        if power > 0 && power <= 20 {
            image = R.Image.img("Theme.bundle/product_icon_cell_0")
        }
        if power > 20 && power <= 35 {
            image = R.Image.img("Theme.bundle/product_icon_cell_1")
        }
        if power > 35 && power <= 50 {
            image = R.Image.img("Theme.bundle/product_icon_cell_2")
        }
        if power > 50 && power <= 75 {
            image = R.Image.img("Theme.bundle/product_icon_cell_3")
        }
        if power > 75 && power <= 100 {
            image = R.Image.img("Theme.bundle/product_icon_cell_4")
        }
        if isCharge {
            image = R.Image.img("Theme.bundle/product_icon_cell_5")
        }
        return (image, String(format: "%d%%", power))

    }
    
    private func productImage(_ dev: DeviceObjc) -> UIImage {
        let type = JL_DeviceType(rawValue: Int(dev.type)) ?? .soundBox
        // tws 耳机或者 充电仓
        if type == .TWS || type == .chargingBin {
            if dev.mProtocolType == DevicesViewModel.noodleDevVersion {
                return ImageCacheUtil.getEarphoneImageUUID(
                    dev.uuid,
                    name: ImageCacheUtil.imgProductLogo(),
                    default: ImageCacheUtil.imgEarphoneNoodles()
                )
            } else {
                let def = ImageCacheUtil.getProductImageChargingBin(type)
                return ImageCacheUtil.getEarphoneImageUUID(
                    dev.uuid,
                    name: ImageCacheUtil.imgChargingBinIdle(),
                    default: def
                )
            }
            // 声卡（麦克风）
        } else if type == .soundCard {
            return ImageCacheUtil.getEarphoneImageUUID(
                dev.uuid,
                name: ImageCacheUtil.imgProductLogo(),
                default: ImageCacheUtil.imgMic()
            )
            // 音箱
        } else {
            return ImageCacheUtil.getEarphoneImageUUID(
                dev.uuid,
                name: ImageCacheUtil.imgProductLogo(),
                default: ImageCacheUtil.imgSpeaker()
            )
        }
    }
    
    /// 左耳图标
    /// - Parameter dev: DeviceObjc
    /// - Returns: UIImage
    private func productImageLeft(_ dev: DeviceObjc) -> UIImage {
        let type = JL_DeviceType(rawValue: Int(dev.type)) ?? .TWS
        return ImageCacheUtil.getEarphoneImageUUID(
            dev.uuid,
            name: ImageCacheUtil.imgLeftEarphone(),
            default: ImageCacheUtil.getProductImageEarphoneLeft(type)
        )
    }
    
    /// 右耳图标
    /// - Parameter dev: DeviceObjc
    /// - Returns: UIImage
    private func productImageRight(_ dev: DeviceObjc) -> UIImage {
        let type = JL_DeviceType(rawValue: Int(dev.type)) ?? .TWS
        return ImageCacheUtil.getEarphoneImageUUID(
            dev.uuid,
            name: ImageCacheUtil.imgRightEarphone(),
            default: ImageCacheUtil.getProductImageEarphoneRight(type)
        )
    }
    
    /// 充电仓图标
    /// - Parameter dev: DeviceObjc
    /// - Returns: UIImage
    private func productImageChargingBin(_ dev: DeviceObjc) -> UIImage {
        let type = JL_DeviceType(rawValue: Int(dev.type)) ?? .soundBox
        return ImageCacheUtil.getEarphoneImageUUID(
            dev.uuid,
            name: ImageCacheUtil.imgChargingBinIdle(),
            default: ImageCacheUtil.getProductImageChargingBin(type)
        )
    }
    
    //MARK: - 更新列表状态
    
    func deleteDevice(dev: DevicesInfoModel) {
        SqliteManager.sharedInstance().deleteItem(byIdInt: dev.dev.idInt)
        updateList()
    }
    
    private func updateList() {
        let list = SqliteManager.sharedInstance().checkOutAll()
        var listArray = [DevicesInfoModel]()
        for item in list {
            let type = JL_RunSDK.getStatusUUID(item.uuid)
            let entity = JL_RunSDK.sharedMe().mBleMultiple.bleConnectedArr.first { element in
                guard let entity = element as? JL_EntityM else { return false }
                if entity.mUUID == item.uuid {
                    return true
                }
                return false
            }
            let power = (entity as? JL_EntityM)?.mCmdManager.mTwsManager.electricity ?? TwsElectricity()
            var status: CellItemStatus = .offline
            if type == .connected {
                status = .connected
                let itemEntity = entity as! JL_EntityM
                makeDefaultPowers(itemEntity, power)
            }
            if type == .inUse { status = .using }
            if type == .preparing {
                status = .configing
                let itemEntity = entity as! JL_EntityM
                makeDefaultPowers(itemEntity, power)
            }
            if type == .needOTA { status = .upgrade }
            if type == .disconnected { status = .offline }
            if power.powerLeft == 0 &&
                power.powerRight == 0 &&
                power.powerCenter == 0 && type != .disconnected {
                let model = (entity as? JL_EntityM)?.mCmdManager.getDeviceModel()
                if model?.sdkType == .type693xTWS ||
                    model?.sdkType == .type697xTWS ||
                    model?.sdkType == .type696xTWS {
                    power.powerLeft = Int32(model?.battery ?? 100)
                } else {
                    power.powerCenter = Int32(model?.battery ?? 100)
                }
            }
            let mode = DevicesInfoModel(dev: item, status: status, power: power)
            listArray.append(mode)
        }
        listArray.sort { $0.status.weight < $1.status.weight }
        subArray.accept(listArray)
    }
    private func makeDefaultPowers(_ item: JL_EntityM,_ power: TwsElectricity) {
        power.powerLeft = Int32(item.mPower_L)
        power.powerRight = Int32(item.mPower_R)
        power.powerCenter = Int32(item.mPower_C)
        power.isChargingLeft = item.isCharging_L
        power.isChargingRight = item.isCharging_R
        power.isChargingCenter = item.isCharging_C
    }

    //MARK: - 通知订阅
    private func addNotes() {
        JL_Tools.add(kUI_JL_DEVICE_CHANGE, action: #selector(noteDeviceChange), own: self)
        JL_Tools.add(kUI_JL_DEVICE_PREPARING, action: #selector(noteDeviePreparing), own: self)
        JL_Tools.add(kJL_MANAGER_HEADSET_ADV, action: #selector(noteHeadsetInfo), own: self)
        JL_Tools.add(kJL_BLE_M_ENTITY_DISCONNECTED, action: #selector(noteDeviceDisconnect), own: self)
    }
    

    @objc private func noteDeviceChange(_ note: Notification) {
        let objc = note.object as? UInt8 ?? 0
        let type = JLDeviceChangeType(rawValue: objc)
        if type == .inUseOffline {
            //判断是否为主从回连或者手动切开回连
            guard let uuid = JLUI_Cache.sharedInstance().renameUUID,
                  JL_RunSDK.sharedMe().mBleUUID != uuid else { return }
            JLLogManager.logLevel(.DEBUG, content: "修改名字，回连设备")
            AlertManager.showWaitting()
            guard let entity = JL_RunSDK.sharedMe().mBleMultiple.makeEntity(withUUID: uuid) else { return }
            JL_RunSDK.sharedMe().connectEntity(entity) { status in
                AlertManager.hideWaitting()
                JLLogManager.logLevel(.DEBUG, content: "回连设备结果:\(JL_RunSDK.textEntityStatus(status))")
                if status == .paired {
                    JLUI_Cache.sharedInstance().renameUUID = nil
                }
                JLUI_Cache.sharedInstance().renameUUID = nil
                JL_Tools.post(kUI_JL_BLE_SCAN_OPEN, object: nil)
            }
        }
        if type == .somethingConnected {
            JLLogManager.logLevel(.DEBUG, content: "重新获取一下设备信息")
            guard let tws = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mTwsManager else {return}
            tws.cmdHeadsetGetAdvFlag(.all) { [weak self] dict in
                guard let self = self, let dict = dict else { return }
                self.bleDeviceDict.accept(dict)
            }
        }
        updateList()
    }
    
    
    
    @objc private func noteDeviePreparing(_ note: Notification) {
        updateList()
    }
    
    @objc private func noteHeadsetInfo(_ note: Notification) {
        updateList()
    }
    
    @objc private func noteDeviceDisconnect(_ note: Notification) {
        updateList()
    }
    
    
    deinit {
        JL_Tools.remove(kUI_JL_DEVICE_CHANGE, own: self)
        JL_Tools.remove(kUI_JL_DEVICE_PREPARING, own: self)
        JL_Tools.remove(kJL_MANAGER_HEADSET_ADV, own: self)
        JL_Tools.remove(kJL_BLE_M_ENTITY_DISCONNECTED, own: self)
    }
    
    

}
