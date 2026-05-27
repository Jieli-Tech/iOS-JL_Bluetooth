//
//  DeviceInfoViewController.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/12/22.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

/// 设备信息页功能节控制器协议：统一视图创建与生命周期，便于扩展与维护
protocol DeviceInfoSectionControlling {
    func makeView() -> UIView
    func start()
    func stop()
}

/// 设备信息页：展示设备能力，并根据网络状态动态显示无网络提示
class DeviceInfoViewController: BaseViewController {
    private let scrollerView = UIScrollView()
    private let disConnectBtn = UIButton()
    private let screenWidth = UIScreen.main.bounds.size.width - 24
    private var ancSection: ANCSectionController?
    private var dhaSection: DHASectionController?
    private var netBanner: NetworkBannerController?
    private var multiLinksSection: MultiLinksSectionController?
    private var headSetView: HeadSetControlView?
    private lazy var deviceModel: JLModel_Device? = {
        JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.getDeviceModel()
    }()
    
    var headsetDict: [String: Any]?
    
    
    override func initUI() {
        super.initUI()
        guard let entity = JL_RunSDK.sharedMe().mBleEntityM else { return }
        let banner = NetworkBannerController()
        banner.attach(on: view, below: navigationView)
        banner.start()
        netBanner = banner
        
        navigationView.title = entity.mItem
        view.addSubview(scrollerView)
        view.addSubview(disConnectBtn)
        disConnectBtn.setTitle(R.localStr.disconnect_device(), for: .normal)
        disConnectBtn.setTitleColor(.eHex("#E15858"), for: .normal)
        disConnectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        disConnectBtn.backgroundColor = .white
        disConnectBtn.layer.cornerRadius = 8
        disConnectBtn.layer.masksToBounds = true
        disConnectBtn.layer.borderColor = UIColor.eHex("#E15858").cgColor
        scrollerView.backgroundColor = .clear
        layoutUI()
    }
    private func layoutUI() {
        disConnectBtn.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(scrollerView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        scrollerView.snp.makeConstraints { make in
            let anchorView = netBanner?.view ?? navigationView
            make.top.equalTo(anchorView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(disConnectBtn.snp.top).offset(-10)
        }
        supportANC()
        supportDHA()
        supportMultiLinks()
        supportAuracast()
        supportCharger()
        supportWeather()
        supportKeySetting()
    }
    
    //MARK: - SUPPORT ANC
    private func supportANC() {
        guard let isSupportAutoANC = deviceModel?.isSupportAutoANC, isSupportAutoANC else {
            return
        }
        let section = ANCSectionController(owner: self)
        let v = section.makeView()
        let lestView = scrollerView.subviews.last
        scrollerView.addSubview(v)
        v.snp.makeConstraints { make in
            if let ref = lestView {
                make.top.equalTo(ref.snp.bottom).offset(10)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(140)
            make.width.equalTo(screenWidth)
        }
        section.start()
        ancSection = section
    }
    //MARK: - DHA 辅听
    private func supportDHA() {
        guard let isSupportDHA = deviceModel?.isSupportDhaFitting, isSupportDHA else {
            return
        }
        guard let manager = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else { return }
        let section = DHASectionController(manager: manager, owner: self)
        let v = section.makeView()
        let lastView = scrollerView.subviews.last
        scrollerView.addSubview(v)
        v.snp.makeConstraints { make in
            if let ref = lastView {
                make.top.equalTo(ref.snp.bottom).offset(10)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(60)
            make.width.equalTo(screenWidth)
        }
        section.start()
        dhaSection = section
    }
    
    //MARK: - MULTI LINKS 一拖二双连接
    private func supportMultiLinks() {
        guard let mTwsManager = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mTwsManager, mTwsManager.supports.isSupportDragWithMore else {
            return
        }
        let section = MultiLinksSectionController(manager: mTwsManager, owner: self)
        let v = section.makeView()
        let lastView = scrollerView.subviews.last
        scrollerView.addSubview(v)
        v.snp.makeConstraints { make in
            if let ref = lastView {
                make.top.equalTo(ref.snp.bottom).offset(10)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(60)
            make.width.equalTo(screenWidth)
        }
        section.start()
        multiLinksSection = section
    }
    
    //MARK: - Auracast
    private func supportAuracast() {
        if !AppStatusManager.shareInstance().isSupportAuracast {
            return
        }
        DeviceInfoViewModel.shared.onStart()
        if AppStatusManager.shareInstance().isAuracastReceiver {
            let receiver = DevInfoFunctionView()
            receiver.config(title: R.localStr.listenAuracastBroadcast(), imgv: "function_icon_auracast", detail: "")
            receiver.tapBlock = { [weak self] in
                let receiverVC = AuracastViewController()
                self?.navigationController?.pushViewController(receiverVC, animated: true)
            }
            let lastView = scrollerView.subviews.last
            scrollerView.addSubview(receiver)
            receiver.snp.makeConstraints { make in
                if let ref = lastView {
                    make.top.equalTo(ref.snp.bottom).offset(10)
                } else {
                    make.top.equalToSuperview()
                }
                make.left.right.equalToSuperview().inset(12)
                make.height.equalTo(60)
                make.width.equalTo(screenWidth)
            }
        }
        if AppStatusManager.shareInstance().isAuracastLancer {
            let lancer = DevInfoFunctionView()
            lancer.config(title: R.localStr.configureAuracastBroadcast(), imgv: "function_icon_auracast_settle", detail: "")
            lancer.tapBlock = { [weak self] in
                let lancerVC = AuracastViewController()
                self?.navigationController?.pushViewController(lancerVC, animated: true)
            }
            let lastView = scrollerView.subviews.last
            scrollerView.addSubview(lancer)
            lancer.snp.makeConstraints { make in
                if let ref = lastView {
                    make.top.equalTo(ref.snp.bottom).offset(10)
                } else {
                    make.top.equalToSuperview()
                }
                make.left.right.equalToSuperview().inset(12)
                make.height.equalTo(60)
                make.width.equalTo(screenWidth)
            }
        }
    }
    
    //MARK: - 充电仓
    private func supportCharger() {
        if deviceModel?.sdkType != .typeChargingCase {
            PublicSettingViewModel.shared.isColorScreenBox = false
            return
        }
        
        // 当识别到是彩屏舱时，立即初始化并加载资源
        PublicSettingViewModel.shared.isColorScreenBox = true
        PublicSettingViewModel.shared.setup()
        
        let charger = DevInfoFunctionView()
        charger.config(title: R.localStr.chargingCaseSetting(), imgv: "function_icon_charger", detail: "")
        charger.tapBlock = { [weak self] in
            guard let self = self else { return }
            let chargerVC = ColorScreenSetVC()
            
            let needLoading = !PublicSettingViewModel.shared.isReady
            if needLoading {
                DFUITools.showHUD(withLabel: "", on: self.view)
            }
            
            chargerVC.initDataAction { status in
                if needLoading {
                    DFUITools.removeHUD()
                }
                if status {
                    self.navigationController?.pushViewController(chargerVC, animated: true)
                } else {
                    let text = R.Language.lan("Load Failed")
                    DFUITools.showText(text, on: self.view, delay: 1.5)
                }
            }
        }
        let lastView = scrollerView.subviews.last
        scrollerView.addSubview(charger)
        charger.snp.makeConstraints { make in
            if let ref = lastView {
                make.top.equalTo(ref.snp.bottom).offset(10)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(60)
            make.width.equalTo(screenWidth)
        }
    }
    
    //MARK: - 天气推送
    private func supportWeather() {
        if deviceModel?.sdkType != .typeChargingCase {
            return
        }
        let weather = DevInfoFunctionView()
        weather.config(title: R.localStr.weatherPush(), imgv: "function_icon_bay", detail: "", hasSwitch: true, switchIsOn: SettingDefault.getWeatherPush())
        weather.switchBlock = { sw in
            SettingDefault.setWeatherPush(sw)
        }
        let lastView = scrollerView.subviews.last
        scrollerView.addSubview(weather)
        weather.snp.makeConstraints { make in
            if let ref = lastView {
                make.top.equalTo(ref.snp.bottom).offset(10)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(60)
            make.width.equalTo(screenWidth)
        }
    }
    
    //MARK: - 按键功能设置
    private func supportKeySetting() {
        //  headsetDict 参考内容
        // "EDR_NAME" = "Oxygen-2";
        // "ISCHARGING_C" = 0;
        // "ISCHARGING_L" = 0;
        // "ISCHARGING_R" = 0;
        // "KEY_SETTING" =     (
        //             {
        //         "KEY_ACTION" = 1;
        //         "KEY_FUNCTION" = 5;
        //         "KEY_LR" = 1;
        //     },
        //             {
        //         "KEY_ACTION" = 1;
        //         "KEY_FUNCTION" = 5;
        //         "KEY_LR" = 2;
        //     },
        //             {
        //         "KEY_ACTION" = 2;
        //         "KEY_FUNCTION" = 6;
        //         "KEY_LR" = 1;
        //     },
        //             {
        //         "KEY_ACTION" = 2;
        //         "KEY_FUNCTION" = 6;
        //         "KEY_LR" = 2;
        //     }
        // );
        // "MIC_MODE" = 2;
        // "POWER_C" = 0;
        // "POWER_L" = 100;
        // "POWER_R" = 0;
        // "WORK_MODE" = 1;
        guard let keySetting = headsetDict?["KEY_SETTING"] as? [[String: Any]] else {
            return
        }
        let bleType = JL_RunSDK.sharedMe().mBleEntityM?.mType ?? .soundBox
        let sdkType = deviceModel?.sdkType ?? .type696xSB
        if bleType == .TWS ||
            (bleType == .chargingBin && sdkType == .typeChargingCase) {
            var doubleTouchArray = [DeviceInfoUsage]()
            var sortTouchArray = [DeviceInfoUsage]()
            for item in keySetting {
                let keyAction = item["KEY_ACTION"] as? Int ?? 0
                let keyFunc = item["KEY_FUNCTION"] as? Int ?? 0
                let keyLR = item["KEY_LR"] as? Int ?? 0
                if keyAction == 1 {
                    if keyLR == 1 {
                        let usage = DeviceInfoUsage()
                        usage.type = DeviceInfoTools.oneClickEarkeyFunc(Int32(keyFunc))
                        usage.title = R.localStr.left()
                        usage.value = Int32(keyFunc)
                        usage.funcType = 0
                        usage.directionType = 0
                        sortTouchArray.append(usage)
                    } else if keyLR == 2 {
                        let usage = DeviceInfoUsage()
                        usage.type = DeviceInfoTools.oneClickEarkeyFunc(Int32(keyFunc))
                        usage.title = R.localStr.right()
                        usage.value = Int32(keyFunc)
                        usage.funcType = 0
                        usage.directionType = 1
                        sortTouchArray.append(usage)
                    }
                } else if keyAction == 2 {
                    if keyLR == 1 {
                        let usage = DeviceInfoUsage()
                        usage.type = DeviceInfoTools.oneClickEarkeyFunc(Int32(keyFunc))
                        usage.title = R.localStr.left()
                        usage.value = Int32(keyFunc)
                        usage.funcType = 1
                        usage.directionType = 0
                        doubleTouchArray.append(usage)
                    } else if keyLR == 2 {
                        let usage = DeviceInfoUsage()
                        usage.type = DeviceInfoTools.oneClickEarkeyFunc(Int32(keyFunc))
                        usage.title = R.localStr.right()
                        usage.value = Int32(keyFunc)
                        usage.funcType = 1
                        usage.directionType = 1
                        doubleTouchArray.append(usage)
                    }
                }
            }
            let protrocolVersion = JL_RunSDK.sharedMe().mBleEntityM?.mProtocolType ?? 0
            var eHeight = 0
            let rowHight = 60
            let specialVersion = 3 // 3是特殊版本,挂脖耳机
            if (protrocolVersion == specialVersion) {
                eHeight = 45 + rowHight*sortTouchArray.count;
            }else{
                eHeight = 45*2 + rowHight*sortTouchArray.count + rowHight*doubleTouchArray.count;
            }
            if (protrocolVersion == specialVersion) {
                headSetView = HeadSetControlView2()
            }else{
                headSetView = HeadSetControlView()
            }
            headSetView?.frame = CGRect(x: 0, y: 0, width: Int(screenWidth), height: eHeight)
            headSetView?.delegate = self;
            JLUI_Effect.addShadow(on: headSetView!)
            headSetView?.layer.masksToBounds = true
            headSetView?.initWithData(withSort: sortTouchArray, withDouble: doubleTouchArray)
            let lastView = scrollerView.subviews.last
            scrollerView.addSubview(headSetView!)
            headSetView?.snp.makeConstraints { make in
                if let ref = lastView {
                    make.top.equalTo(ref.snp.bottom).offset(10)
                } else {
                    make.top.equalToSuperview()
                }
                make.left.right.equalToSuperview().inset(12)
                make.height.equalTo(eHeight)
                make.width.equalTo(screenWidth)
            }
        }
        localDeviceJson()
    }
    private func localDeviceJson() {
        let bleSDKType = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.getDeviceModel().sdkType ?? .typeST
        let currentUUID = JL_RunSDK.sharedMe().mBleEntityM?.mUUID ?? ""
        var path:URL?
        switch bleSDKType {
        case .typeAI:
            normalDeviceJson()
            return
        case .typeST:
            normalDeviceJson()
            return
        case .type693xTWS:
            let specialVersion = 3
            let proto = JL_RunSDK.sharedMe().mBleEntityM?.mProtocolType ?? 0
            if proto == specialVersion {
                path = RResources.file.ac693x_headset_neck_jsonTxt.url()
            }else{
                path = RResources.file.ac693x_headset_jsonTxt.url()
            }
            
        case .type695xSDK:
            path = RResources.file.ac695x_soundbox_jsonTxt.url()
        case .type697xTWS:
            path = RResources.file.ac697x_headset_jsonTxt.url()
        case .type696xSB:
            path = RResources.file.ac696x_soundbox_jsonTxt.url()
        case .type696xTWS:
            path = RResources.file.ac696x_soundbox_tws_jsonTxt.url()
        case .type695xSC:
            path = RResources.file.ac695x_soundbox_jsonTxt.url()
        case .type695xWATCH:
            normalDeviceJson()
            return
        case .type701xWATCH:
            normalDeviceJson()
            return
        case .typeManifestEarphone:
            path = RResources.file.manifest_headset_jsonTxt.url()
        case .typeManifestSoundbox:
            path = RResources.file.manifest_soundbox_jsonTxt.url()
        case .typeChargingCase:
            path = RResources.file.ac697x_headset_jsonTxt.url()
        case .type707nWATCH:
            path = RResources.file.ac696x_soundbox_tws_jsonTxt.url()
        case .typeDongle:
            normalDeviceJson()
            return
        case .typeCommon:
            normalDeviceJson()
            return
        case .typeUnknown:
            normalDeviceJson()
            return
        @unknown default:
            normalDeviceJson()
            return
        }
        guard let path else { return }
        guard let localData = try? Data(contentsOf: path), localData.count > 0 else {
            JLLogManager.logLevel(.DEBUG, content: "加载本地json描述失败，请查看是否存在对应json！！！！")
            return
        }
        let totalDict_1 = try? JSONSerialization.jsonObject(with: localData, options: []) as? [String: Any]
        let deviceDic = totalDict_1?["device"] as? [String: Any] ?? [:]
        JLCacheBox.cacheUuid(currentUUID).ledDic = deviceDic as NSDictionary
        setTitleArray(deviceDic)
    }
    private func normalDeviceJson(){
        let bleType = JL_RunSDK.sharedMe().mBleEntityM?.mType ?? .soundBox
        let currentUUID = JL_RunSDK.sharedMe().mBleEntityM?.mUUID ?? ""
        var path:URL?
        if bleType == .soundBox {
            path = RResources.file.ac696x_soundbox_jsonTxt.url()
        }
        if bleType == .TWS {
            path = RResources.file.ac693x_headset_jsonTxt.url()
        }
        if bleType == .soundCard {
            path = RResources.file.ac695x_soundbox_jsonTxt.url()
        }
        guard let path, let localData = try? Data(contentsOf: path) else { return }
        let totalDict_1 = try? JSONSerialization.jsonObject(with: localData, options: []) as? [String: Any]
        let deviceDic = totalDict_1?["device"] as? [String: Any] ?? [:]
        JLCacheBox.cacheUuid(currentUUID).ledDic = deviceDic as NSDictionary
        setTitleArray(deviceDic)
    }
    
    private func setTitleArray(_ dict: [String: Any]) {
        if(dict["key_settings"] == nil){
            return
        }
        headSetView?.funcDict = dict
    }

    
    deinit {
        netBanner?.stop()
        multiLinksSection?.stop()
    }
    
}

extension DeviceInfoViewController: HeadSetControlDelegate {
    func headSetControlDidTouch(_ usage: DeviceInfoUsage) {
        
    }
}

extension DeviceInfoViewController: HeadsetDenoisePtl {
    func headSetDenoiseMore(_ deviceModelAnc: JLModel_ANC?) {
        if deviceModelAnc?.mAncMode == .normal {
            view.makeToast(R.localStr.normal_model_cannot_entry(), duration: 2, position: .center)
            return
        }
        guard let deviceModelAnc else { return }
        JLLogManager.logLevel(.INFO, content: "DenoiseVC:left:\(deviceModelAnc.mAncCurrent_L),right:\(deviceModelAnc.mAncCurrent_R)")
        let vc = DenoiseVC()
        vc.model_ANC = deviceModelAnc
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
}

// MARK: - Helpers
