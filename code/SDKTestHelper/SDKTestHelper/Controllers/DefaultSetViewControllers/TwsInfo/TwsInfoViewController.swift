//
//  TwsInfoViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/2/27.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JL_BLEKit
import UIKit

class TwsInfoViewController: BaseViewController {
    let gotoColorScreenBox = UIButton()
    let tableView = UITableView()
    let itemsArray = BehaviorRelay(value: [FuncCodeMode]())
    private var isOpenNotify = false
    private var isNotifyAncChange = false
    private var ancObc: NSKeyValueObservation?

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.headphoneTWSInformation()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        tableView.backgroundColor = .clear
        tableView.register(FuncCodeShowCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        itemsArray.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: FuncCodeShowCell.self)) { _, element, cell in
            cell.bind(model: element)
        }.disposed(by: disposeBag)
        view.addSubview(tableView)
        
        let sdkInfo = BleManager.shared.currentCmdMgr?.getDeviceModel()
        if sdkInfo?.sdkType == .typeChargingCase {
            gotoColorScreenBox.setTitle(R.localStr.colorScreenCabin(), for: .normal)
            gotoColorScreenBox.setTitleColor(.white, for: .normal)
            gotoColorScreenBox.backgroundColor = UIColor.random()
            gotoColorScreenBox.layer.cornerRadius = 10
            gotoColorScreenBox.layer.masksToBounds = true
            gotoColorScreenBox.titleLabel?.adjustsFontSizeToFitWidth = true
            view.addSubview(gotoColorScreenBox)
            gotoColorScreenBox.snp.makeConstraints { make in
                make.top.equalTo(navigationView.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(40)
            }
            tableView.snp.makeConstraints { make in
                make.top.equalTo(gotoColorScreenBox.snp.bottom).offset(8)
                make.left.right.bottom.equalToSuperview().inset(16)
            }
        } else {
            tableView.snp.makeConstraints { make in
                make.top.equalTo(navigationView.snp.bottom).offset(8)
                make.left.right.bottom.equalToSuperview().inset(16)
            }
        }
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        gotoColorScreenBox.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.pushViewController(ColorScreenViewController(), animated: true)
        }.disposed(by: disposeBag)

        tableView.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            self.tableView.deselectRow(at: index, animated: true)
            handleAction(index.row)
        }).disposed(by: disposeBag)

        let getTwsInfo = FuncCodeMode()
        getTwsInfo.title = R.localStr.getHeadphoneInformation()
        getTwsInfo.code = R.codeDict["Get Tws Info"] ?? ""

        let anc = FuncCodeMode()
        anc.title = R.localStr.ancSettings()
        anc.code = R.codeDict["ANC Set"] ?? ""

        let gameMode = FuncCodeMode()
        gameMode.title = R.localStr.gameModeSettings()
        gameMode.code = R.codeDict["Game Mode Set"] ?? ""

        let openCloseNotify = FuncCodeMode()
        openCloseNotify.title = R.localStr.turnOnOffStatusNotifications()
        openCloseNotify.code = R.codeDict["Open/Close Notify"] ?? ""

        let notifyAncChange = FuncCodeMode()
        notifyAncChange.title = R.localStr.notifyTurnOffANCChangeMonitoring()
        notifyAncChange.code = R.codeDict["Notify/Close ANC Change"] ?? ""
        
        let rename = FuncCodeMode()
        rename.title = R.localStr.rename()
        rename.code = R.codeDict["tws Rename"] ?? ""
        
        let twsKeyFunction = FuncCodeMode()
        twsKeyFunction.title = R.localStr.headphoneButtonFunctions()
        

        itemsArray.accept([getTwsInfo, anc, gameMode, openCloseNotify, notifyAncChange, rename, twsKeyFunction])
    }

    func handleAction(_ index: Int) {
        switch index {
        case 0:
            getTwsCurrentInfo()
        case 1:
            ancSet()
        case 2:
            gameModeSet()
        case 3:
            openCloseNotify()
        case 4:
            notifyAncChange()
        case 5:
            renameAction()
        case 6:
            twsKeyFunction()
        default:
            break
        }
    }

    private func getTwsCurrentInfo() {
        guard let mManager: JL_ManagerM = BleManager.shared.currentCmdMgr else { return }
        // can use .edrName to get name
        mManager.mTwsManager.cmdHeadsetGetAdvFlag(.all) { result in
            JLLogManager.logLevel(.DEBUG, content: "\(String(describing: result))")
            //
            JLLogManager.logLevel(.DEBUG, content: "edrName\(mManager.mTwsManager.edrName)")
        }
        
    }

    private func ancSet() {
        guard let mManager: JL_ManagerM = BleManager.shared.currentCmdMgr else { return }
        // 从设备端读取到当前的 ANC 模式
        let modeInfo = mManager.getDeviceModel()
        let currentAncMode = modeInfo.mAncModeCurrent
        // 读取 tws 对象
        let twsMgr = mManager.mTwsManager
        if !twsMgr.supports.isSupportAnc {
            view.makeToast("设备不支持 ANC 模式")
            return
        }
        // 切换 ANC 模式
        if currentAncMode.mAncMode == .noiseReduction {
            currentAncMode.mAncMode = .transparent
        } else if currentAncMode.mAncMode == .transparent {
            currentAncMode.mAncMode = .normal
        } else {
            currentAncMode.mAncMode = .noiseReduction
        }
        twsMgr.cmdSetANC(currentAncMode)
    }

    private func gameModeSet() {
        guard let mManager: JL_ManagerM = BleManager.shared.currentCmdMgr else { return }
        let twsMgr = mManager.mTwsManager
        let gameMode = twsMgr.workMode
        if gameMode == 0 { // 不支持设置
            view.makeToast("不支持设置")
            return
        }
        var mode = 0
        if gameMode == 1 { // 普通模式
            mode = 2
        } else if gameMode == 2 { // 游戏模式
            mode = 1
        }
        twsMgr.cmdHeadsetWorkSettingMode(UInt8(mode))
        
    }

    private func openCloseNotify() {
        guard let mManager: JL_ManagerM = BleManager.shared.currentCmdMgr else { return }
        isOpenNotify.toggle()
        mManager.mTwsManager.cmdHeadsetAdvEnable(isOpenNotify)
        if isOpenNotify {
            NotificationCenter.default.addObserver(self, selector: #selector(handleAdvNote(_:)), name: Notification.Name(rawValue: kJL_MANAGER_HEADSET_ADV), object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: kJL_MANAGER_HEADSET_ADV), object: nil)
        }
    }
    
    private func renameAction() {
        guard let mManager: JL_ManagerM = BleManager.shared.currentCmdMgr else { return }
        let name = "test" + UUID().uuidString
        let nameDt = Data(name.utf8)
        // nameDt 最大长度不能超过 20 Byte
        // nameDt max length is 20
        mManager.mTwsManager.cmdHeadsetEdrName(nameDt)
    }
    
    private func twsKeyFunction() {
        self.navigationController?.pushViewController(TwsKeyViewController(), animated: true)
    }

    @objc private func handleAdvNote(_ note: Notification) {
        guard let advInfo = note.object as? [String: Any] else { return }
        JLLogManager.logLevel(.DEBUG, content: "advInfo: \(advInfo)")
    }

    private func notifyAncChange() {
        isNotifyAncChange.toggle()
        guard let mManager: JL_ManagerM = BleManager.shared.currentCmdMgr else { return }
        let deviceModel = mManager.getDeviceModel()
        if isNotifyAncChange {
            ancObc = deviceModel.observe(\.mAncModeCurrent) { deviceModel, change in
                JLLogManager.logLevel(.DEBUG, content: "mAncModeCurrent: \(deviceModel.mAncModeCurrent.logProperties())")
            }
        } else {
            ancObc?.invalidate()
        }
    }

}
